# InlineHints.nvim - Plugin Structure

## 📁 Directory Structure

```
inline_hints/
├── .gitignore                  # Git ignore rules
├── .stylua.toml                # Lua formatter config
├── CHANGELOG.md                # Version history
├── CUSTOMIZATION.md            # Customization guide
├── LICENSE                     # MIT License
├── README.md                   # Main documentation
├── STRUCTURE.md                # This file
├── doc/
│   └── inline_hints.txt       # Vim help docs
├── examples/
│   └── plugin-integration.lua # Example configs
├── lua/
│   └── inline_hints/
│       ├── combos.lua          # Multi-step combo/sequential hints
│       ├── config.lua          # Configuration management
│       ├── display.lua         # Display & rendering logic
│       ├── helpers.lua         # Context detection helpers
│       ├── hints.lua           # Contextual hint definitions
│       ├── init.lua            # Main entry point & setup
│       └── keys.lua            # Progressive key sequence tracking
└── plugin/
    └── inline_hints.lua        # Auto-loaded plugin commands
```

## 🏗️ Architecture

### Module Dependencies

```
init.lua
  ├── config.lua        (configuration + hint customization)
  ├── hints.lua         (contextual hint definitions)
  ├── combos.lua        (multi-step combo hints + progressive lookup)
  ├── helpers.lua       (context detection utilities)
  ├── display.lua       (rendering with sequence priority)
  │   ├── helpers.lua   (context detection)
  │   ├── hints.lua     (fallback hints)
  │   ├── combos.lua    (sequence hints - highest priority)
  │   └── config.lua    (rendering configuration)
  └── keys.lua          (progressive sequence tracking)
      ├── combos.lua    (sequence validation)
      ├── helpers.lua   (mode detection)
      └── display.lua   (hint updates)
```

### Hint Priority System

Hints are displayed based on the following priority order:
1. **Active key sequence** (highest priority) - Multi-step combo hints
2. **Buffer/plugin context** - NvimTree, special buffers
3. **Cursor syntax context** - Treesitter-based detection
4. **Line/position context** - Line start/end, brackets, etc.
5. **Filetype context** - Language-specific hints
6. **Default hints** (lowest priority) - Fallback generic hints

## 📦 Dependencies

### Required
- Neovim >= 0.8.0

### Optional (Auto-detected via pcall)
- **nvim-treesitter**: Enhanced code structure detection
- **gitsigns.nvim**: Git hunk hints
- **nvim-tree.lua**: File tree hints
- **which-key.nvim**: Combo integration

**All optional dependencies are gracefully handled** - the plugin works perfectly fine without them!

## 🔌 Plugin Manager Compatibility

### ✅ Lazy.nvim
```lua
{ 'theinventorylib/inline_hints.nvim', opts = {} }
```

### ✅ Packer.nvim
```lua
use { 'theinventorylib/inline_hints.nvim', config = function() require('inline_hints').setup() end }
```

### ✅ Vim-plug
```vim
Plug 'theinventorylib/inline_hints.nvim'
lua require('inline_hints').setup()
```

### ✅ Manual
```bash
git clone https://github.com/theinventorylib/inline_hints.nvim ~/.local/share/nvim/site/pack/plugins/start/inline_hints.nvim
```

## 📚 Publishing to GitHub

1. Create GitHub repo: `inline_hints.nvim`
2. The current `lua/inline_hints/` directory is the plugin root
3. Upload the entire directory structure as-is (doc/, lua/, plugin/, examples/, *.md files)
4. Users install as: `'theinventorylib/inline_hints.nvim'`

The plugin is already structured for distribution - all files use relative imports and optional dependencies are detected automatically.

## 🎓 Key Improvements Over Monolithic Design

1. **Maintainability**: Easy to find and modify specific functionality
2. **Testability**: Each module can be tested independently
3. **Extensibility**: Clear API for adding features
4. **Documentation**: Proper README, help docs, and inline comments
5. **Standards**: Follows Neovim plugin conventions
6. **Distribution**: Ready for GitHub/plugin manager installation
7. **No Dependencies**: Works standalone with optional enhancements

## 🔌 Usage Examples

### Basic Setup
```lua
require('inline_hints').setup()
```

### With Options
```lua
require('inline_hints').setup({
  enable_combos = true,
  toggle_key = "<leader>ih",
  priority = 5000,
  hl_group = "Comment",
  hints = {
    custom_context = "[custom] hint",
  },
})
```

### In lazy.nvim
```lua
{
  dir = vim.fn.stdpath("config") .. "/lua/inline_hints",
  name = "inline_hints.nvim",
  event = "VeryLazy",
  opts = {
    enable_combos = true,
    toggle_key = "<leader>ih",
    hint_color = "#7aa2f7",
    icon_color = "#bb9af7",
  },
}
```

## 🎯 Design Principles

Following best practices from Comment.nvim:

1. **Modular Design**: Each module has a single responsibility
2. **Public API**: Main module exports all sub-modules for extensibility
3. **Configuration First**: Centralized config with sensible defaults
4. **Plugin Standards**: Follows Neovim plugin conventions
5. **Documentation**: Comprehensive README and inline docs

## 🔄 Module Dependencies

```
init.lua
  ├── config.lua        (configuration + text_object/count hints)
  ├── hints.lua         (contextual hint definitions)
  ├── combos.lua        (multi-step combo hints + state machine)
  ├── helpers.lua       (context detection utilities)
  ├── display.lua       (rendering with sequence priority)
  └── keys.lua          (progressive sequence tracking)
```

## 🚀 Extension Points

Users can extend the plugin through setup configuration:

```lua
require('inline_hints').setup({
  -- Context-based hints
  hints = { 
    my_context = '[custom] hint text' 
  },
  
  -- First-step combo hints
  combo_hints = { 
    x = '[xx] custom  [xy] action' 
  },
  
  -- Text object hints (after 'a' or 'i')
  text_object_hints = {
    a = '[ap] para  [CUSTOM]',
    i = '[ip] para  [CUSTOM]',
  },
  
  -- Count-based hints
  count_hints = {
    default = '[dd] lines  [CUSTOM]',
    x = '[w] words  [CUSTOM]',
  },
})
```

### Public API

The main module exports sub-modules for advanced usage:

```lua
local inline_hints = require('inline_hints')

-- Access internal modules if needed
inline_hints.hints      -- Hint definitions module
inline_hints.combos     -- Combo system module
inline_hints.display    -- Display module
inline_hints.config     -- Configuration module
```

## 📦 Publishing

To publish as a standalone plugin:

1. The current `lua/inline_hints/` directory contains everything needed
2. Create a new repository named `inline_hints.nvim`
3. Upload the entire directory structure to the repository root
4. Push to GitHub: `github.com/theinventorylib/inline_hints.nvim`
5. Users install with:
   ```lua
   { 'theinventorylib/inline_hints.nvim', opts = {} }
   ```

## 🎓 Key Improvements Over Original

1. **Maintainability**: Easy to find and modify specific functionality
2. **Testability**: Each module can be tested independently
3. **Extensibility**: Clear API for adding features
4. **Documentation**: Proper README and inline docs
5. **Standards**: Follows Neovim plugin conventions
6. **Reusability**: Can be easily shared and installed by others

## 🎯 Key Features

### Multi-Step Combo System
Progressive keybind hints that update at each keystroke:

1. **Operators** (`d`, `c`, `y`, `v`) → Shows common operations and next steps
2. **Text Objects** (`a`, `i`) → Shows available text objects after operators
3. **Counts** (`1-9`) → Shows count-based operations (supports both `d3w` and `3dw`)

### Context Detection
Automatic hint selection based on:
- Active key sequences (highest priority)
- Buffer type (NvimTree, special buffers)
- Treesitter syntax nodes (functions, strings, etc.)
- Cursor position (line start/end, brackets)
- File type
- Default fallback hints

## 💡 Future Enhancements

- [ ] Vim health checks (`:checkhealth inline_hints`)
- [ ] Help documentation (`:help inline-hints`)
- [ ] Telescope integration for hint browsing
- [ ] Per-buffer/per-filetype configuration
- [ ] Visual mode combo hints
- [ ] Support for `t`/`f` character selection hints
