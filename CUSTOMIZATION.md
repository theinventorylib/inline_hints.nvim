# Customization Guide

## Overriding Hints

InlineHints allows you to **completely override** any default hint. Custom hints will replace the defaults, not merge with them.

### During Setup

```lua
require('inline_hints').setup({
  hints = {
    -- Override default hints
    blank = "[o] insert below  [O] insert above  [p] paste",
    function_def = "[gd] goto  [K] docs  [<leader>r] rename",
    
    -- Disable hints (set to empty string)
    comment = "",
    
    -- Add custom contexts
    my_context = "[x] custom action",
  },
  
  combo_hints = {
    -- Override combo sequences
    g = "[gd] definition  [gr] references  [gi] implementation",
    d = "[dd] line  [dw] word  [dap] paragraph",
    
    -- Add new combo sequences
    ["<leader>f"] = "[ff] files  [fg] git  [fb] buffers",
  },
  
  text_object_hints = {
    -- Override text object hints
    a = "[ap] paragraph  [aw] word  [CUSTOM]",
    i = "[ip] paragraph  [iw] word  [CUSTOM]",
  },
})
```

### At Runtime

Change hints dynamically after the plugin is loaded:

```lua
local ih = require('inline_hints')

-- Override multiple hints at once
ih.override_hints({
  blank = "[o] new line below",
  string = "[ci'] change inside quotes",
})

-- Disable a specific hint
ih.disable_hint('comment')

-- Reset all hints to defaults
ih.reset_hints()
```

## Available Contexts

You can override any of these contexts:

### General
- `default` - General navigation
- `cursor_line` - Line navigation
- `blank` - Blank lines
- `comment` - Comment lines

### Code Structure
- `function_def` - Function definitions
- `function_call` - Function calls
- `string` - String literals
- `variable` - Variables
- `class_def` - Class definitions
- `import_statement` - Import/require statements

### Structural Elements
- `inside_parens` - Inside `()`
- `inside_brackets` - Inside `[]`
- `inside_braces` - Inside `{}`

### Line Positions
- `line_start` - Start of line
- `line_end` - End of line

### States
- `search_active` - When search is active
- `foldable` - Foldable code
- `folded` - Folded code

### File Types
- `markdown` - Markdown files
- `lua` - Lua files
- `python` - Python files
- Custom file types (add your own!)

### Plugin Integrations
- `nvimtree_file` - NvimTree on files
- `nvimtree_dir` - NvimTree on directories
- `nvimtree_general` - NvimTree general
- `git_hunk` - Git hunks (gitsigns)

## Combo Sequences

Override these combo starters:

- `g` - Goto operations
- `d` - Delete operations
- `c` - Change operations
- `y` - Yank operations
- `z` - View/fold operations
- `[` - Previous operations
- `]` - Next operations
- Custom combos (add your own!)

## Examples

### Minimal Setup

```lua
require('inline_hints').setup({
  hints = {
    -- Only show hints for blank lines and functions
    blank = "[o] below  [O] above",
    function_def = "[gd] goto  [K] docs",
    
    -- Disable all other hints
    default = "",
    cursor_line = "",
    comment = "",
  },
})
```

### Filetype-Specific Hints

```lua
require('inline_hints').setup({
  hints = {
    lua = "[gd] def  [:so %] source  [:lua %] execute",
    python = "[gd] def  [:!python3 %] run",
    javascript = "[gd] def  [:!node %] run",
    rust = "[gd] def  [:RustRun] run  [:RustTest] test",
  },
})
```

### Custom Leader Combos

```lua
require('inline_hints').setup({
  combo_hints = {
    ["<leader>f"] = "[ff] find files  [fg] find git  [fb] buffers  [fh] help",
    ["<leader>g"] = "[gg] status  [gc] commits  [gb] branches  [gp] pull",
    ["<leader>l"] = "[ll] LSP info  [ld] diagnostics  [lr] rename",
  },
})
```

### Disabling Hints for Specific Plugins

Disable hints when using plugins with their own UI:

```lua
require('inline_hints').setup({
  -- Completely disable for these contexts
  disable_for = {
    "copilot-chat",
    "avante",
    "TelescopePrompt",
    "noice",
    function()
      -- Custom logic to disable
      return vim.bo.buftype == "prompt"
    end,
  },
  
  -- Or provide custom hints for plugins
  plugin_hints = {
    ["copilot-chat"] = "[<CR>] send  [<C-c>] cancel  [q] quit",
    ["avante"] = "[<CR>] apply  [y] accept  [n] reject  [q] close",
  },
})
```

### Dynamic Override Based on Conditions

```lua
require('inline_hints').setup()

-- Override hints for specific filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    require('inline_hints').override_hints({
      function_def = "[gd] def  [:RustRun] run  [:RustTest] test",
      variable = "[gd] def  [:RustHoverActions] actions",
    })
  end,
})

-- Override hints in git commit messages
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = function()
    require('inline_hints').override_hints({
      default = "[<C-n>] next  [<C-p>] prev  [:wq] commit",
    })
  end,
})
```

### Disable Unwanted Hints

```lua
require('inline_hints').setup({
  hints = {
    -- Disable specific contexts
    comment = "",
    line_start = "",
    line_end = "",
    cursor_line = "",
  },
})
```

## API Reference

### `require('inline_hints').override_hints(custom_hints)`
Override hints at runtime and refresh display.

### `require('inline_hints').disable_hint(context)`
Disable a specific hint context.

### `require('inline_hints').reset_hints()`
Reset all hints to their default values.

### `require('inline_hints').hints.set(context, hint)`
Set a single hint.

### `require('inline_hints').hints.get(context)`
Get a hint for a specific context.

## See Also

- `:help inline-hints-configuration` - Full configuration reference
- `:help inline-hints-examples` - More examples
- `:help inline-hints-api` - Complete API documentation
