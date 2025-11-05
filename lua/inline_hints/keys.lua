-- lua/inline_hints/keys.lua
-- Key tracking for multi-step combo sequences

local combos = require("inline_hints.combos")
local helpers = require("inline_hints.helpers")
local display = require("inline_hints.display")

local M = {}

-- Maximum length for a key sequence (prevent infinite sequences)
local MAX_SEQUENCE_LENGTH = 10

-- Setup key tracking for progressive combo mode
function M.setup_key_tracking()
  vim.on_key(function(typed_key)
    if not helpers.is_normal_mode() then
      return
    end

    local key_str = vim.fn.keytrans(typed_key)

    -- Leader key: always reset combo
    if key_str == "<leader>" then
      display.pending_keys = ""
      if pcall(require, "which-key") then
        vim.g.which_key_disable = false
      end
      display.show_hints()
      return
    end

    -- Escape key: clear combo
    if key_str == "<Esc>" then
      display.pending_keys = ""
      if pcall(require, "which-key") then
        vim.g.which_key_disable = false
      end
      display.show_hints()
      return
    end

    -- If pressed key is a combo starter (like 'd', 'c', 'g', etc.)
    if combos.is_combo_key(key_str) then
      -- Hide which-key popup if it's currently visible
      local ok_wk, wk = pcall(require, "which-key")
      if ok_wk and wk and wk.hide then
        pcall(wk.hide, { immediate = true })
      end

      -- Disable which-key while combo is active
      if pcall(require, "which-key") then
        vim.g.which_key_disable = true
      end

      display.pending_keys = key_str
      -- Render immediately
      display.show_hints()
      vim.cmd("redraw")

      -- Refresh on next tick for reliability
      vim.schedule(function()
        if display.pending_keys == key_str then
          display.show_hints()
          vim.cmd("redraw")
        end
      end)

      return
    end

    -- Handle number keys (can start a sequence or continue one)
    if key_str:match("^%d$") then
      if display.pending_keys == "" then
        -- Starting a count sequence
        display.pending_keys = key_str
        display.show_hints()
        vim.cmd("redraw")
        return
      elseif display.pending_keys:match("^%d+$") or combos.is_operator_key(display.pending_keys:sub(1, 1)) then
        -- Continuing a number sequence or adding count after operator
        display.pending_keys = display.pending_keys .. key_str
        display.show_hints()
        vim.cmd("redraw")
        return
      end
    end

    -- Handle multi-step sequences (e.g., 'd' -> 'a' -> shows text objects)
    if display.pending_keys ~= "" and #display.pending_keys < MAX_SEQUENCE_LENGTH then
      -- Check if we should continue the sequence
      if combos.should_continue_sequence(display.pending_keys, key_str) then
        display.pending_keys = display.pending_keys .. key_str
        display.show_hints()
        vim.cmd("redraw")

        -- Refresh on next tick
        vim.schedule(function()
          if display.pending_keys:find(key_str, 1, true) then
            display.show_hints()
            vim.cmd("redraw")
          end
        end)

        return
      end

      -- Any other key: sequence is complete, clear it
      display.pending_keys = ""
      if pcall(require, "which-key") then
        vim.g.which_key_disable = false
      end
      display.show_hints()
    end
  end)
end

return M
