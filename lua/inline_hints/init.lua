-- lua/inline_hints/init.lua
-- Main entry point for InlineHints plugin
--
-- InlineHints displays context-aware navigation hints inline in your buffer,
-- helping you discover and remember Vim/Neovim keybindings.
--
-- Usage:
--   require('inline_hints').setup({
--     enable_combos = true,
--     toggle_key = "<leader>ih",
--     hints = {},
--     combo_hints = {},
--     telescope_hints = {},
--     hint_color = "#7aa2f7",  -- Custom color (hex)
--     icon_color = "#bb9af7",  -- Custom icon color (hex)
--   })

local config = require("inline_hints.config")
local hints = require("inline_hints.hints")
local combos = require("inline_hints.combos")
local display = require("inline_hints.display")
local keys = require("inline_hints.keys")
local helpers = require("inline_hints.helpers")

local M = {}

-- Setup function
function M.setup(opts)
  opts = opts or {}

  -- Initialize configuration
  local cfg = config.setup(opts)

  -- Merge custom hints
  hints.merge(cfg.hints)
  combos.merge_combos(cfg.combo_hints)
  combos.merge_text_objects(cfg.text_object_hints)
  combos.merge_count_hints(cfg.count_hints)
  combos.merge_telescope(cfg.telescope_hints)

  -- Setup key tracking for combos
  if cfg.enable_combos then
    keys.setup_key_tracking()
  end

  -- Setup autocommands
  vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter", "ModeChanged" }, {
    callback = function()
      display.show_hints()
    end,
  })

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function()
      vim.defer_fn(function()
        if helpers.is_normal_mode() then
          display.show_hints()
        end
      end, 50)
    end,
  })

  vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter", "BufLeave" }, {
    callback = function()
      display.pending_keys = ""
      display.clear(vim.api.nvim_get_current_buf())
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "NvimTree",
    callback = function()
      vim.defer_fn(function()
        if helpers.is_normal_mode() then
          display.show_hints()
        end
      end, 50)
    end,
  })

  -- Setup toggle keybind if provided
  if cfg.toggle_key then
    vim.keymap.set("n", cfg.toggle_key, function()
      if vim.b.hints_enabled == false then
        vim.b.hints_enabled = true
        display.show_hints()
      else
        vim.b.hints_enabled = false
        display.clear(vim.api.nvim_get_current_buf())
      end
    end, { desc = "Toggle inline hints" })
  end
end

-- Public API
M.hints = hints
M.combos = combos
M.display = display
M.config = config

-- Convenience functions for runtime modification
M.override_hints = function(custom_hints)
  hints.override(custom_hints)
  display.show_hints()
end

M.disable_hint = function(context)
  hints.disable(context)
  display.show_hints()
end

M.reset_hints = function()
  hints.reset()
  display.show_hints()
end

return M
