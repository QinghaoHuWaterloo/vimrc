-- Define the Run function
local function is_c_family()
    return vim.bo.filetype == 'c' or vim.bo.filetype == 'cpp' or vim.bo.filetype == 'cc'
end

local function is_racket()
    return vim.bo.filetype == 'racket'
end

local function racket_command(command)
    local directory = vim.fn.shellescape(vim.fn.expand('%:p:h'))
    local filename = vim.fn.shellescape(vim.fn.expand('%:t'))
    return string.format('cd %s && %s %s', directory, command, filename)
end

local function compile_cmd()
    if vim.bo.filetype == 'c' then
        return 'term time gcc % -o %< -std=c17 -Wall -Wextra -Wshadow -Wformat=2 -Wconversion -pedantic'
    elseif is_c_family() then
        return 'term time g++ -O2 -std=c++2b -Wall -Wextra -Wfatal-errors -Wshadow -Wformat=2 -Wfloat-equal -DLOCAL -Wconversion -Winvalid-pch % -o %<'
    end
    return nil
end

function R()
    vim.cmd('w')
    vim.cmd('sp')
    vim.cmd('resize 30')
    local cmd = compile_cmd()
    if cmd then
        vim.cmd(cmd)
        vim.cmd('200')
    elseif is_racket() then
        vim.cmd('term ' .. racket_command('raco test'))
    elseif vim.bo.filetype == 'java' then
        vim.cmd('term javac %')
    elseif vim.bo.filetype == 'python' then
        vim.cmd('term python3 %')
    else
        vim.cmd('terminal')
    end
end

-- Define the Mode function
local fterm = require("FTerm")

function M()
    vim.cmd('w')
    if is_c_family() then
        vim.cmd('cd %:p:h')  -- Change to the file's directory
        fterm.scratch({
            cmd = "time ./" .. vim.fn.expand('%:t:r')
        })
    elseif is_racket() then
        fterm.scratch({
            cmd = racket_command('racket')
        })
    elseif vim.bo.filetype == 'java' then
        vim.cmd('cd %:p:h')  -- Change to the file's directory
        fterm.scratch({
            cmd = "java " .. vim.fn.expand('%:t:r')
        })
    end
end

-- Modd: run compiled binary without 'time' prefix (no-frills run)
function Modd()
    vim.cmd('w')
    if is_c_family() then
        vim.cmd('cd %:p:h')  -- Change to the file's directory
        fterm.scratch({
            cmd = "./" .. vim.fn.expand('%:t:r')  -- fixed: removed stray space before filename
        })
    elseif is_racket() then
        fterm.scratch({
            cmd = racket_command('racket')
        })
    elseif vim.bo.filetype == 'java' then
        vim.cmd('cd %:p:h')  -- Change to the file's directory
        fterm.scratch({
            cmd = "java " .. vim.fn.expand('%:t:r')
        })
    end
end

function Mode()
  vim.cmd('w')  -- Save the file

  local file_dir = vim.fn.expand('%:p:h')
  local file_name_wo_ext = vim.fn.expand('%:t:r')
  local filetype = vim.bo.filetype

  local wait_key = "read -n 1 -s -r -p 'Press any key to exit...'"
  local cmd = ""

  if filetype == 'c' or filetype == 'cpp' or filetype == 'cc' then
    cmd = string.format(
      "foot -e bash -c 'cd \"%s\" && time ./\"%s\"; %s'",
      file_dir, file_name_wo_ext, wait_key
    )
  elseif filetype == 'racket' then
    cmd = string.format(
      "foot -e bash -c 'cd \"%s\" && racket \"%s.rkt\"; %s'",
      file_dir, file_name_wo_ext, wait_key
    )
  elseif filetype == 'java' then
    cmd = string.format(
      "foot -e bash -c 'cd \"%s\" && java \"%s\"; %s'",
      file_dir, file_name_wo_ext, wait_key
    )
  else
    vim.notify("Unsupported filetype: " .. filetype, vim.log.levels.WARN)
    return
  end

  vim.fn.jobstart(cmd, { detach = true })
end

function Check()
    vim.cmd('w')  -- Save the current file
    vim.cmd('cd %:p:h')  -- Change to the file's directory
    if is_racket() then
        fterm.scratch({
            cmd = 'raco test ' .. vim.fn.shellescape(vim.fn.expand('%:t'))
        })
    else
        fterm.scratch({
            cmd = "judge ./" .. vim.fn.expand('%:t:r')
        })
    end
end

--nvimtree
vim.api.nvim_set_keymap('n', 'L', ':bn<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', 'H', ':bp<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<F6>', ':set hlsearch<CR>:/', {noremap = true})
vim.api.nvim_set_keymap('n', '<F7>', ':e ~/cslearning/cptemplate/', {noremap = true})
vim.api.nvim_set_keymap('n', 'x', ':bd<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', 'U', ':u<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<F9>', ':lua R()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F11>', ':lua M()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F3>', ':Trouble diagnostics toggle<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-a>', 'ggVG', { noremap = true })
vim.api.nvim_set_keymap('n', '<F10>', ':cd %:p:h<CR>:FTermToggle<CR>', { noremap = true })
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<backspace>', ':noh<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<f2>', ':NvimTreeToggle<CR>', {noremap = true})
-- vim.api.nvim_set_keymap('n', '<C-s>', ':lua f', {noremap = true})  -- incomplete, was a no-op

vim.keymap.set("n", "D", '"_D')
vim.keymap.set("n", "dd", '"_dd')
vim.keymap.set("n", "dw", '"_dw')

local function insert_template()
  local template_path = vim.fn.input("Template Path: ", "~/cslearning/cptemplate/templates/competitive Programming Templates/", "file")
  template_path = vim.fn.expand(template_path)
  if vim.fn.filereadable(template_path) == 0 then
    vim.api.nvim_err_writeln("Error: Cannot open file " .. template_path)
    return
  end
  local content = vim.fn.readfile(template_path)
  vim.api.nvim_put(content, "b", true, true)
  vim.cmd("1")
end

-- Make the function globally accessible
_G.insert_template = insert_template

vim.api.nvim_set_keymap('n', '<F8>', ':lua insert_template()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F12>', ':lua Check()<CR>', {noremap = true})


-- Define two color schemes and their background preferences
local colorschemes = {
  { name = "kanagawa-wave", background = "dark" },
  { name = "kanagawa-dragon", background = "dark" },
  { name = "onedark", background = "light" },
  { name = "solarized8_flat", background = "light" }
}

local current_index = 1

-- Function to toggle color scheme and background
local function toggle_colorscheme()
  current_index = current_index % #colorschemes + 1
  local cs = colorschemes[current_index]

  -- Set background before setting the colorscheme
  vim.o.background = cs.background

  local ok, err = pcall(vim.cmd.colorscheme, cs.name)
  if not ok then
    vim.notify("Colorscheme '" .. cs.name .. "' not found!", vim.log.levels.ERROR)
  else
    vim.notify("Switched to: " .. cs.name .. " (" .. cs.background .. ")", vim.log.levels.INFO)
  end
end

-- Map the toggle function to <leader>cs
vim.keymap.set("n", "<f5>", toggle_colorscheme, { desc = "Toggle Colorscheme + Background" })


-- vim.keymap.set('n', '<F10>', function()
--   local filepath = vim.fn.expand('%:p:h')
--   vim.fn.jobstart({ 'foot', '-e', 'sh', '-c', 'cd ' .. filepath .. ' && exec $SHELL' }, {
--     detach = true
--   })
-- end, { desc = 'Open foot terminal at current file location' })

