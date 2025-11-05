-- lua/inline_hints/display.lua
-- Display logic for showing hints

local helpers = require("inline_hints.helpers")
local hints_module = require("inline_hints.hints")
local combos = require("inline_hints.combos")
local config = require("inline_hints.config")

local M = {}

-- Namespace for virtual text
local ns = vim.api.nvim_create_namespace("InlineHints")

-- Pending keys state
M.pending_keys = ""

-- Clear all hints from buffer
function M.clear(buf)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
end

-- Main display function
function M.show_hints()
  -- Check if in normal mode
  if not helpers.is_normal_mode() then
    M.clear(vim.api.nvim_get_current_buf())
    return
  end

  -- Check if manually disabled for this buffer
  if vim.b.hints_enabled == false then
    M.clear(vim.api.nvim_get_current_buf())
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  M.clear(buf)

  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""

  -- Check for combo hints
  local hint
  if M.pending_keys ~= "" then
    hint = combos.get(M.pending_keys)
    if not hint then
      M.pending_keys = ""
    end
  end

  -- If no combo hint, use context-based hints
  if not hint then
    local context = helpers.get_nvimtree_context()
      or helpers.is_search_active()
      or helpers.get_git_context()
      or helpers.get_fold_context(row)
      or helpers.get_position_context(line, col)
      or helpers.get_ts_context()
      or helpers.get_line_context(line)
      or helpers.get_filetype_context()
      or "cursor_line"

    -- Get fold hints if context is foldable/folded
    if context == "foldable" then
      hint = combos.fold_hints.foldable
    elseif context == "folded" then
      hint = combos.fold_hints.folded
    else
      hint = hints_module.get(context) or hints_module.get("default")
    end
  end

  local cfg = config.get()

  -- Build virtual text with optional icon and colors
  local virt_text = {}
  if cfg.show_icon then
    table.insert(virt_text, { "  " .. cfg.icon .. " ", config.get_icon_hl() })
    table.insert(virt_text, { hint, config.get_hint_hl() })
  else
    table.insert(virt_text, { "  " .. hint, config.get_hint_hl() })
  end

  -- Display hint
  if helpers.is_nvimtree() then
    -- For NvimTree, use virt_lines with proper formatting
    local virt_line_text = {}
    if cfg.show_icon then
      table.insert(virt_line_text, { cfg.icon .. " ", config.get_icon_hl() })
      table.insert(virt_line_text, { hint, config.get_hint_hl() })
    else
      table.insert(virt_line_text, { hint, config.get_hint_hl() })
    end
    
    vim.api.nvim_buf_set_extmark(buf, ns, math.max(0, row - 1), 0, {
      virt_lines = { virt_line_text },
      virt_lines_above = false,
      priority = cfg.priority,
    })
  else
    vim.api.nvim_buf_set_extmark(buf, ns, row, -1, {
      virt_text = virt_text,
      virt_text_pos = "eol",
      priority = cfg.priority,
    })
  end
end

return M
