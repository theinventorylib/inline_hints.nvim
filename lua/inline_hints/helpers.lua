-- lua/inline_hints/helpers.lua
-- Helper functions for context detection

local M = {}

-- Structural characters that can anchor a fold boundary
M.structural_chars = {
  ["("] = true,
  [")"] = true,
  ["["] = true,
  ["]"] = true,
  ["{"] = true,
  ["}"] = true,
}

-- Fold-capable node types leveraged when treesitter drives folding
M.ts_fold_types = {
  default = {
    block = true,
    chunk = true,
    class_body = true,
    class_definition = true,
    class_declaration = true,
    compound_statement = true,
    function_definition = true,
    function_declaration = true,
    if_statement = true,
    for_statement = true,
    while_statement = true,
    method_definition = true,
    scoped_block = true,
    table_constructor = true,
  },
  lua = {
    block = true,
    chunk = true,
    function_definition = true,
    function_declaration = true,
    table_constructor = true,
  },
  python = {
    block = true,
    class_definition = true,
    function_definition = true,
    if_statement = true,
    for_statement = true,
    while_statement = true,
  },
}

-- Check if current mode is normal or operator-pending
function M.is_normal_mode()
  local mode = vim.api.nvim_get_mode().mode or ""
  return mode:sub(1, 1) == "n"
end

-- Check if current buffer is NvimTree
function M.is_nvimtree()
  local ft = vim.bo.filetype:lower()
  return ft == "nvimtree"
end

-- Check for plugin availability
function M.has_plugin(plugin_name)
  return pcall(require, plugin_name)
end

-- Get NvimTree context (file/dir/general)
function M.get_nvimtree_context()
  if not M.is_nvimtree() then
    return nil
  end
  
  local ok, api = pcall(require, "nvim-tree.api")
  if not ok then
    return "nvimtree_general"
  end

  local node = api.tree.get_node_under_cursor()
  if not node then
    return "nvimtree_general"
  end
  
  if node.nodes ~= nil then
    return "nvimtree_dir"
  else
    return "nvimtree_file"
  end
end

-- Check if search is active
function M.is_search_active()
  local search = vim.fn.getreg "/"
  if search ~= "" and vim.v.hlsearch == 1 then
    return "search_active"
  end
  return nil
end

-- Check for git hunks (gitsigns)
function M.get_git_context()
  if not M.has_plugin "gitsigns" then
    return nil
  end

  local ok, gitsigns = pcall(require, "gitsigns")
  if not ok then
    return nil
  end

  local hunks = vim.fn.getbufvar(vim.api.nvim_get_current_buf(), "gitsigns_status_dict")
  if hunks and (hunks.added and hunks.added > 0 or hunks.changed and hunks.changed > 0) then
    return "git_hunk"
  end

  return nil
end

-- Enhanced treesitter detection
function M.get_ts_context()
  local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
  if not ok then
    return nil
  end

  local node = ts_utils.get_node_at_cursor()
  if not node then
    return nil
  end

  local type_map = {
    -- Functions
    function_declaration = "function_def",
    function_definition = "function_def",
    method_declaration = "function_def",
    function_call = "function_call",
    call_expression = "function_call",
    method_call = "function_call",

    -- Variables & identifiers
    identifier = "variable",
    variable_declarator = "variable",

    -- Strings
    string = "string",
    string_content = "string",

    -- Comments
    comment = "comment",

    -- Imports
    import_statement = "import_statement",
    import_from_statement = "import_statement",

    -- Classes
    class_declaration = "class_def",
    class_definition = "class_def",
  }

  return type_map[node:type()]
end

-- Get position context (line start/end, structural chars)
function M.get_position_context(line, col)
  if #line == 0 then
    return nil
  end
  
  local trimmed_start = line:match "^%s*"
  local content_start = #trimmed_start
  local trimmed_end = line:match "%s*$"

  local char = line:sub(col + 1, col + 1)
  if char ~= "" then
    if char == "(" or char == ")" then
      return "inside_parens"
    end
    if char == "[" or char == "]" then
      return "inside_brackets"
    end
    if char == "{" or char == "}" then
      return "inside_braces"
    end
    if char == '"' or char == "'" then
      return "string"
    end
  end

  if col <= content_start then
    return "line_start"
  end
  if col >= #line - #trimmed_end - 1 then
    return "line_end"
  end

  return nil
end

-- Get line context (blank, comment, function, etc.)
function M.get_line_context(line)
  local trimmed = line:match "^%s*(.-)%s*$"
  if trimmed == "" then
    return "blank"
  end
  if trimmed:match "^%-%-" or trimmed:match "^#" or trimmed:match "^//" then
    return "comment"
  end
  if trimmed:match "^function%s+" or trimmed:match "^def%s+" or trimmed:match "^fn%s+" then
    return "function_def"
  end
  if trimmed:match "^import%s+" or trimmed:match "^from%s+" or trimmed:match "^require" then
    return "import_statement"
  end
  if trimmed:match "^class%s+" then
    return "class_def"
  end
  return nil
end

-- Get filetype context
function M.get_filetype_context()
  local ft = vim.bo.filetype
  local hints = require("inline_hints.hints")
  if hints.get(ft) then
    return ft
  end
  return nil
end

-- Check if treesitter indicates a foldable node at cursor
function M.ts_has_fold(buf, row, col)
  if vim.wo.foldmethod ~= "expr" then
    return false
  end

  local fold_expr = tostring(vim.wo.foldexpr or "")
  if not fold_expr:find("treesitter", 1, true) then
    return false
  end

  local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok_parsers then
    return false
  end

  local lang = parsers.get_buf_lang(buf)
  if not lang then
    return false
  end

  local ok_ts, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
  if not ok_ts then
    return false
  end

  local node = ts_utils.get_node_at_pos(buf, row, col, { ignore_injections = true })
  if not node then
    return false
  end

  local fold_types = M.ts_fold_types[lang] or M.ts_fold_types.default
  while node do
    if fold_types and fold_types[node:type()] then
      local start_row, start_col, end_row = node:range()
      if end_row > start_row and row == start_row and col >= start_col and col <= start_col + 1 then
        return true
      end
    end
    node = node:parent()
  end

  return false
end

-- Get fold context (foldable/folded)
function M.get_fold_context(row)
  if vim.wo.foldenable == false then
    return nil
  end

  local buf = vim.api.nvim_get_current_buf()
  local line_nr = row + 1
  local cursor_col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.fn.getline(line_nr)

  if vim.fn.foldclosed(line_nr) ~= -1 then
    return "folded"
  end

  if M.ts_has_fold(buf, row, cursor_col) then
    return "foldable"
  end

  local level = vim.fn.foldlevel(line_nr)
  local prev_level = vim.fn.foldlevel(math.max(line_nr - 1, 1))
  local next_level = vim.fn.foldlevel(math.min(line_nr + 1, vim.api.nvim_buf_line_count(buf)))
  local closed_end = vim.fn.foldclosedend(line_nr)
  local boundary_shift = prev_level ~= level or next_level ~= level

  local char = line:sub(cursor_col + 1, cursor_col + 1)
  local has_fold = level > 0 or closed_end ~= -1 or boundary_shift
  if not has_fold then
    return nil
  end

  if M.structural_chars[char] or boundary_shift or closed_end ~= -1 then
    return "foldable"
  end

  return nil
end

return M
