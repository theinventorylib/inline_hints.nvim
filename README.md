# 💡 InlineHints.nvim

⚡ Smart and context-aware inline navigation hints for Neovim ⚡

InlineHints displays small, unobtrusive hints at the end of your current line, showing you relevant keybindings based on your cursor context. It's like having a friendly guide that helps you discover and remember Vim motions and commands.

## ✨ Features

- 🎯 **Context-aware hints**: Shows relevant keybindings based on cursor position, syntax nodes, and file type
- 🔗 **Multi-step combo support**: Progressive hints that adapt at each keystroke (like which-key, but inline!)
  - Text object sequences: `d` → `a` → shows text objects
  - Count operations: `3` → `d` → shows motions
  - Works both ways: `d3w` and `3dw` both show hints
- 🌳 **Treesitter integration**: Detects code structure for smarter hint suggestions
- 📁 **NvimTree support**: Special hints when navigating file trees
- 🔍 **Search context**: Different hints when search is active
- 🎨 **Git integration**: Shows git hunk operations when using gitsigns
- ⚙️ **Fold detection**: Smart fold hints using treesitter or traditional methods
- 🔌 **Which-key integration**: Automatically hides which-key popups during combo sequences
- 🎛️ **Highly configurable**: Customize hints, combos, and behavior to your liking

## � Requirements

- **Neovim** >= 0.8.0
- No required dependencies!

### Optional Dependencies (for enhanced features)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - For smart code structure detection
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) - For git hunk hints
- [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) - For file tree hints
- [which-key.nvim](https://github.com/folke/which-key.nvim) - For better combo integration

**Note:** The plugin works perfectly fine without any of these! Optional dependencies are detected automatically using `pcall()` - if they're not installed, those specific features are simply skipped.

## 🚀 Installation

### With [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'theinventorylib/inline_hints.nvim',
  event = "VeryLazy",
  opts = {
    enable_combos = true,
    toggle_key = "<leader>ih",
    hint_color = "#7aa2f7",  -- Optional: custom hint color
    icon_color = "#bb9af7",  -- Optional: custom icon color
  },
}
```

### With [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'theinventorylib/inline_hints.nvim',
  config = function()
    require('inline_hints').setup({
      toggle_key = "<leader>ih",
    })
  end
}
```

### With [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'theinventorylib/inline_hints.nvim'

" In your init.vim or after plug#end()
lua << EOF
  require('inline_hints').setup({
    toggle_key = "<leader>ih",
  })
EOF
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/theinventorylib/inline_hints.nvim ~/.local/share/nvim/site/pack/plugins/start/inline_hints.nvim
```

2. Add to your config:
```lua
require('inline_hints').setup()
```

## ⚒️ Setup

### Basic setup

```lua
require('inline_hints').setup()
```

### Advanced configuration

```lua
require('inline_hints').setup({
  enable_combos = true,
  toggle_key = "<leader>ih",
  
  -- Custom colors (optional)
  hint_color = "#7aa2f7",  -- Custom hint color (hex format)
  icon_color = "#bb9af7",  -- Custom icon color (hex format)
  show_icon = true,
  icon = "💡",
  
  -- Priority for virtual text
  priority = 5000,
  
  -- Custom hints
  hints = {
    my_context = "[custom] hint text",
  },
  
  -- Multi-step combo customization
  combo_hints = {
    d = "[dd] line  [dw] word  [CUSTOM]",
  },
  
  text_object_hints = {
    a = "[ap] para  [CUSTOM]",
    i = "[ip] para  [CUSTOM]",
  },
  
  count_hints = {
    default = "[dd] lines  [CUSTOM]",
    d = "[w] words  [CUSTOM]",
  },
})
```

## 🔥 Usage

InlineHints works automatically once setup is called. Hints will appear at the end of your current line based on context.

### Commands

The plugin also provides user commands:
- `:InlineHintsToggle` - Toggle hints on/off
- `:InlineHintsEnable` - Enable hints
- `:InlineHintsDisable` - Disable hints

### Context-based hints

- **Blank lines**: Shows `[o] below  [O] above  [p] paste  [cc] change`
- **Function definitions**: Shows `[gd] def  [gr] refs  [K] hover  [%] bracket`
- **Strings**: Shows `[ci"] change  [di"] delete  [vi"] select`
- **Brackets/Braces**: Shows `[%] match  [ci)] change  [z] folds`
- **Search active**: Shows `[n] next  [N] prev  [*] word  [#] back`

### Multi-step combo hints

When you press a combo starter key, InlineHints shows follow-up options and adapts progressively at each step:

#### Operators (Step 1)
- **`d`**: `[dd] line  [dw] word  [d$] to end  [da] around  [di] inside  [#] count`
- **`c`**: `[cc] line  [cw] word  [c$] to end  [ca] around  [ci] inside  [#] count`
- **`y`**: `[yy] line  [yw] word  [y$] to end  [ya] around  [yi] inside  [#] count`
- **`g`**: `[gd] def  [gr] refs  [gf] file  [gg] top  [gc] comment`
- **`z`**: `[zz] center  [zt] top  [za] toggle fold  [zR] open all`

#### Text Objects (Step 2 - after `da`, `di`, etc.)
- **`da`**: `[ap] para  [aw] word  [a)] paren  [a]] bracket  [a}] brace  [a'] quote`
- **`di`**: `[ip] para  [iw] word  [i)] paren  [i]] bracket  [i}] brace  [i'] quote`

#### Count Operations (supports both `d3w` and `3dw`)
- **`3`**: `[dd] del lines  [j/k] move  [w] words  [x] chars  [G] goto line`
- **`d3`**: `[w] words  [j] lines down  [k] lines up  [e] end of word`

**Example sequences:**
- `d` → `a` → `p` executes `dap` (delete around paragraph)
- `3` → `d` → `d` executes `3dd` (delete 3 lines)
- `c` → `i` → `"` executes `ci"` (change inside quotes)

### File-type specific hints

- **Markdown**: `[gx] link  []] next head  [[ prev head`
- **Lua**: `[gd] def  [K] hover  [gr] refs  [:lua %] run`
- **Python**: `[gd] def  [K] hover  [gr] refs  [:!python %] run`

### NvimTree hints

When in NvimTree:
- **On files**: `[<CR>] open  [v] vsplit  [s] split  [a] new  [d] del`
- **On directories**: `[<CR>] toggle  [a] new  [d] del  [<BS>] close`

## 🎨 Customization

### Overriding Hints

All hints can be **completely overridden** via the setup function. Custom hints will replace the defaults:

```lua
require('inline_hints').setup({
  hints = {
    -- Override default blank line hint
    blank = "[o] insert below  [O] insert above  [CUSTOM]",
    
    -- Override function definition hints
    function_def = "[gd] goto  [K] docs  [<leader>r] rename",
    
    -- Disable a hint by setting it to empty string
    comment = "",
    
    -- Add new custom context
    my_context = "[x] my action",
  },
  
  combo_hints = {
    -- Override 'g' combo hints
    g = "[gd] definition  [gr] references  [CUSTOM]",
  },
})
```

### Runtime Modifications

Change hints dynamically after setup:

```lua
local ih = require('inline_hints')

-- Override hints at runtime
ih.override_hints({
  blank = "[o] new line",
  string = "[ci'] change",
})

-- Disable a specific hint
ih.disable_hint('comment')

-- Reset all hints to defaults
ih.reset_hints()
```

### Context-Specific Hints

Set different hints based on filetype or conditions:

```lua
require('inline_hints').setup({
  hints = {
    lua = "[gd] def  [:so %] source  [:lua %] run",
    python = "[gd] def  [:!python3 %] run",
    typescript = "[gd] def  [:!ts-node %] run",
  },
})

-- Or use autocmds for more control
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    require('inline_hints').override_hints({
      function_def = "[gd] def  [:RustRun] run",
    })
  end,
})
```

For more customization examples, see `:help inline-hints-examples`

## 🌳 Treesitter Support

InlineHints has native treesitter support for detecting:
- Function definitions and calls
- Variables and identifiers
- Strings and comments
- Import statements
- Class definitions
- Foldable code blocks

Works best with [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) installed.

## 🔌 Integrations

All integrations are **completely optional** and work via automatic detection using `pcall()`:

- **[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)**: Enhanced code detection
- **[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)**: Git hunk hints
- **[nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)**: File tree hints  
- **[which-key.nvim](https://github.com/folke/which-key.nvim)**: Combo integration

The plugin works perfectly fine without any of these!

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Request features
- Submit PRs to add more hints or improve context detection

## 📺 Similar Projects

- [which-key.nvim](https://github.com/folke/which-key.nvim) - Shows popup with keybindings
- [legendary.nvim](https://github.com/mrjones2014/legendary.nvim) - Command palette for Neovim

InlineHints differs by being inline and context-aware, showing hints without requiring popup interactions.

## 📄 License

MIT License - feel free to use and modify!

## 💐 Credits

Inspired by the need for better keybinding discovery in Neovim. Built with love for the Vim community.
# inline_hints.nvim
