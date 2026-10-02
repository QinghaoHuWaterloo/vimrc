"""Drive an actual insert-mode completion popup over Neovim's built-in RPC client."""
from pathlib import Path
import subprocess
import time


def verify_popup(root, env):
    socket = str(root / 'completion.sock')
    with (root / 'popup.log').open('w+') as log:
        editor = subprocess.Popen([
            'nvim', '--headless', '-i', 'NONE', '--listen', socket,
            '--cmd', f"lua dofile('{root}/tests/prelude.lua')",
            '-c', 'lua for _, name in ipairs({"clangd","jdtls","texlab","marksman","lua_ls","vimls","racket_langserver"}) do vim.lsp.enable(name, false) end',
            '-c', "lua vim.cmd.edit(vim.env.NVIM_TEST_ROOT .. '/popup.tex')",
            '-c', 'lua vim.g.tex_popup_ready = true',
        ], cwd=root, env=env, stdout=log, stderr=log)

        def lua(code):
            expression = "luaeval('" + code.replace("'", "''") + "')"
            result = subprocess.run(['nvim', '--server', socket, '--remote-expr', expression],
                                    env=env, capture_output=True, text=True, timeout=5)
            if result.returncode:
                raise AssertionError(result.stderr)
            return result.stdout.strip()

        def wait(code):
            deadline = time.monotonic() + 5
            while time.monotonic() < deadline:
                if editor.poll() is not None:
                    log.seek(0)
                    raise AssertionError(log.read())
                if Path(socket).exists() and lua(code) == 'true':
                    return
                time.sleep(0.02)
            log.seek(0)
            raise AssertionError(f'Timeout: {code}\n{log.read()}\n' + lua('vim.inspect({line=vim.api.nvim_get_current_line(),mode=vim.fn.mode(),sources=(function() local r={} for _,s in pairs(require("cmp").core.sources) do r[#r+1]={name=s.name,status=s.status,entries=#s.entries,available=s:is_available(),offset=s.offset} end return r end)()})'))

        try:
            wait('vim.g.tex_popup_ready == true')
            lua('vim.api.nvim_input("i")')
            wait('vim.fn.mode() == "i"')
            time.sleep(0.05)
            started = time.monotonic()
            lua(r'vim.api.nvim_input("\\sec")')
            wait('require("cmp").visible()')
            elapsed_ms = (time.monotonic() - started) * 1000
            assert lua('require("cmp").get_entries()[1]:get_completion_item().label') == r'\section{}'
            lua(r'vim.api.nvim_input("<CR>")')
            wait(r'vim.api.nvim_get_current_line() == "\\section{}"')
            wait('vim.api.nvim_win_get_cursor(0)[2] == 9')
            assert lua('require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()].pos') == '1'
            lua(r'vim.api.nvim_input("Title<Tab><Esc>")')
            wait(r'vim.api.nvim_get_current_line() == "\\section{Title}"')
            print(f'PASS: actual automatic popup, Enter confirms section braces/cursor, Tab exits ({elapsed_ms:.0f} ms including RPC polling)')
        finally:
            editor.terminate()
            try:
                editor.wait(timeout=5)
            except subprocess.TimeoutExpired:
                editor.kill()
                editor.wait()
