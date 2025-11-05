-- lua/inline_hints/config.lua
-- Configuration and default settings for InlineHints

local M = {}

-- Default configuration
M.config = {
  -- Enable combo hints (g, d, c, y, z, [, ])
  enable_combos = true,
  
  -- Optional toggle key mapping
  toggle_key = nil,
  
  -- Custom hints (merged with defaults)
  hints = {},
  
  -- Custom combo hints (merged with defaults)
  combo_hints = {},
  
  -- Custom text object hints (merged with defaults)
  text_object_hints = {},
  
  -- Custom count hints (merged with defaults)
  count_hints = {},
  
  -- Custom telescope hints (merged with defaults)
  telescope_hints = {},
  
  -- Priority for virtual text
  priority = 5000,
  
  -- Highlight group for hints (fallback if no custom colors)
  hl_group = "Comment",
  
  -- Custom colors (hex format: "#RRGGBB")
  hint_color = nil,  -- Color for hint text (nil = use hl_group)
  icon_color = nil,  -- Color for icon (nil = use hl_group)
  
  -- Show icon before hints
  show_icon = true,
  icon = "💡",

}

-- Merge user options with defaults
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)
  
  -- Create custom highlight groups if colors are specified
  if M.config.hint_color or M.config.icon_color then
    M.setup_highlights()
  end
  
  return M.config
end

-- Setup custom highlight groups
function M.setup_highlights()
  -- Create highlight group for hint text
  if M.config.hint_color then
    vim.api.nvim_set_hl(0, "InlineHintsText", {
      fg = M.config.hint_color,
      italic = true,
    })
  end
  
  -- Create highlight group for icon
  if M.config.icon_color then
    vim.api.nvim_set_hl(0, "InlineHintsIcon", {
      fg = M.config.icon_color,
    })
  end
end

-- Get highlight group for hint text
function M.get_hint_hl()
  return M.config.hint_color and "InlineHintsText" or M.config.hl_group
end

-- Get highlight group for icon
function M.get_icon_hl()
  return M.config.icon_color and "InlineHintsIcon" or M.config.hl_group
end

-- Get current configuration
function M.get()
  return M.config
end

return M
