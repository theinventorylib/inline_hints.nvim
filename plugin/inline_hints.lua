-- plugin/inline_hints.lua
-- Auto-loaded by Neovim before user config
-- This file runs when Neovim starts and the plugin is installed

-- Check Neovim version
if vim.fn.has("nvim-0.8.0") ~= 1 then
  vim.api.nvim_err_writeln("inline_hints.nvim requires Neovim >= 0.8.0")
  return
end

-- Prevent loading twice
if vim.g.loaded_inline_hints then
  return
end
vim.g.loaded_inline_hints = 1

-- Create user commands
vim.api.nvim_create_user_command("InlineHintsToggle", function()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b.hints_enabled == false then
    vim.b.hints_enabled = true
    local display = require("inline_hints.display")
    display.show_hints()
    vim.notify("InlineHints enabled", vim.log.levels.INFO)
  else
    vim.b.hints_enabled = false
    local display = require("inline_hints.display")
    display.clear(buf)
    vim.notify("InlineHints disabled", vim.log.levels.INFO)
  end
end, {
  desc = "Toggle inline hints on/off for current buffer",
})

vim.api.nvim_create_user_command("InlineHintsEnable", function()
  vim.b.hints_enabled = true
  local display = require("inline_hints.display")
  display.show_hints()
  vim.notify("InlineHints enabled", vim.log.levels.INFO)
end, {
  desc = "Enable inline hints for current buffer",
})

vim.api.nvim_create_user_command("InlineHintsDisable", function()
  vim.b.hints_enabled = false
  local display = require("inline_hints.display")
  display.clear(vim.api.nvim_get_current_buf())
  vim.notify("InlineHints disabled", vim.log.levels.INFO)
end, {
  desc = "Disable inline hints for current buffer",
})