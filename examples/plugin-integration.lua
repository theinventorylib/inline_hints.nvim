-- Example configuration for InlineHints
-- This shows various customization options

return {
  "theinventorylib/inline_hints.nvim",
  event = "VeryLazy",
  opts = {
    enable_combos = true,
    toggle_key = "<leader>ih",
    
    -- Custom colors
    hint_color = "#7aa2f7",
    icon_color = "#bb9af7",
    show_icon = true,
    
    -- Custom hints for regular contexts
    hints = {
      -- Override default navigation hints
      default = "[w] word  [b] back  [f] find  [/] search",
      
      -- Markdown-specific
      markdown = "[gx] open link  []] next heading  [[ prev heading  [<leader>p] preview",
      
      -- Code contexts
      function_def = "[gd] definition  [gr] references  [K] hover  [<leader>ca] actions",
      string = '[ci"] change inside  [di"] delete inside  [yi"] yank inside',
    },
  },
}

