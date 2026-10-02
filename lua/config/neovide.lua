-- Runtime settings supported by the installed Neovide 0.14.1.
-- Terminal Neovim and VSCode Neovim do not load GUI settings or mappings.
if not vim.g.neovide then return end

local g = vim.g
-- Match Foot: font=DejaVu Sans Mono for Powerline:size=9.
vim.o.guifont = "DejaVu Sans Mono for Powerline,Noto Sans Mono CJK SC:h9"
g.neovide_refresh_rate = 60 -- config.toml disables vsync so this cap applies.
g.neovide_refresh_rate_idle = 5 -- Unfocused limit; Wayland may ignore this.
g.neovide_no_idle = false
g.neovide_transparency = 1.0
g.neovide_normal_opacity = 1.0
g.neovide_window_blurred = false
g.neovide_floating_blur_amount_x = 0.0
g.neovide_floating_blur_amount_y = 0.0
g.neovide_floating_shadow = false
g.neovide_position_animation_length = 0.0
g.neovide_scroll_animation_length = 0.10
g.neovide_scroll_animation_far_lines = 0
g.neovide_cursor_animation_length = 0.04
g.neovide_cursor_trail_size = 0.0
g.neovide_cursor_animate_in_insert_mode = false
g.neovide_cursor_animate_command_line = false
g.neovide_cursor_smooth_blink = false
g.neovide_cursor_vfx_mode = ""
g.neovide_hide_mouse_when_typing = true
g.neovide_padding_top = 4
g.neovide_padding_bottom = 4
g.neovide_padding_left = 4
g.neovide_padding_right = 4
g.neovide_remember_window_size = true
g.neovide_scale_factor = 1.0
vim.opt.linespace = 0 -- Keep terminal box-drawing characters joined.
vim.opt.guicursor:append("a:blinkon0") -- Static cursor avoids periodic redraws.

local map = vim.keymap.set
map("v", "<C-S-c>", '"+y', { desc = "Copy selection to system clipboard" })
map({ "n", "i", "v", "s", "t" }, "<C-S-v>", function()
  vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
end, { desc = "Paste system clipboard" })
map("c", "<C-S-v>", "<C-r>+", { desc = "Paste system clipboard" })
map({ "n", "i" }, "<C-s>", function() vim.cmd.update() end,
  { desc = "Save file" })

local modes = { "n", "i", "v", "t", "c" }
local function zoom(delta)
  g.neovide_scale_factor = math.min(2.0, math.max(0.6, g.neovide_scale_factor + delta))
end
map(modes, "<C-=>", function() zoom(0.1) end, { desc = "Zoom in" })
map(modes, "<C-+>", function() zoom(0.1) end, { desc = "Zoom in" })
map(modes, "<C-->", function() zoom(-0.1) end, { desc = "Zoom out" })
map(modes, "<C-0>", function() g.neovide_scale_factor = 1.0 end,
  { desc = "Reset zoom" })

-- Enable Chinese input when editing/searching or using the terminal;
-- keep Normal-mode keys available for navigation.
local group = vim.api.nvim_create_augroup("NeovideInput", { clear = true })
local function update_ime()
  local mode = vim.api.nvim_get_mode().mode
  g.neovide_input_ime = mode:match("^[ictR]") ~= nil
end
vim.api.nvim_create_autocmd("ModeChanged", { group = group, callback = update_ime })
update_ime()
