-- lua/inline_hints/hints.lua
-- Contextual hint definitions for various contexts

local M = {}

-- =========================================================
-- 🎯 Contextual hint definitions
-- =========================================================
-- Base hints keyed by high-level context such as syntax nodes, filetype, or
-- special locations (line_start, blank, etc.).
M.hints = {
  -- General navigation
  default = "[w] word  [b] back  [0] start  [$] end  [f/F] find  [gg] top  [G] bottom  [{/}] para",
  cursor_line = "[j] down  [k] up  [0] start  [$] end  [{] prev para  [}] next para",
  blank = "[o] below  [O] above  [p] paste  [cc] change  [dd] delete  [gg/G] top/bottom",
  comment = "[gc] toggle  [V] select  [{/}] para  [gg/G] top/bottom",

  -- Code-aware
  function_def = "[gd] def  [gr] refs  [K] hover  [%] bracket  [{/}] para",
  function_call = "[gd] def  [K] hover  [%] bracket  [ci)] change args",
  string = '[ci"] change  [di"] delete  [vi"] select  [%] quote',
  variable = "[gd] def  [gr] refs  [<leader>ra] rename  [*] search",
  import_statement = "[gd] def  [gf] file  [<C-]>] back",
  class_def = "[gd] def  [gr] refs  [[]m/]m] methods",

  -- Pair contexts
  inside_parens = "[%] match  [ci)] change  [di)] delete  [vi)] select  [z] folds",
  inside_brackets = "[%] match  [ci]] change  [di]] delete  [vi]] select  [z] folds",
  inside_braces = "[%] match  [ci}] change  [di}] delete  [vi}] select  [z] folds",

  -- Line positions
  line_start = "[i] insert  [A] end  [w] word  [f] find  [gg/G] top/bottom",
  line_end = "[a] append  [i] insert  [x] del  [D] del-end  [b] back",

  -- Search mode
  search_active = "[n] next  [N] prev  [*] word  [#] back  [/] search  [gg/G] top/bottom",

  -- Filetypes
  markdown = "[gx] link  []] next head  [[ prev head  [{/}] para",
  lua = "[gd] def  [K] hover  [gr] refs  [:lua %] run",
  python = "[gd] def  [K] hover  [gr] refs  [:!python %] run",

  -- NvimTree
  nvimtree_file = "[<CR>] open  [<Tab>] preview  [v] vsplit  [s] split  [t] tab  [a] new  [d] del  [r] rename",
  nvimtree_dir = "[<CR>] toggle  [<Tab>] preview  [a] new  [d] del  [r] rename  [<BS>] close  [P] parent",
  nvimtree_general = "[a] new  [d] del  [r] rename  [x] cut  [c] copy  [p] paste  [y] name  [R] refresh  [H] hidden",

  -- Git hunks (gitsigns)
  git_hunk = "[]c] next hunk  [[c] prev hunk  [<leader>hs] stage  [<leader>hr] reset  [<leader>hp] preview",
}

-- Get hint for a specific context
function M.get(context)
  return M.hints[context]
end

-- Set hint for a specific context
function M.set(context, hint)
  M.hints[context] = hint
end

-- Merge custom hints with defaults (custom hints override defaults)
function M.merge(custom_hints)
  if custom_hints then
    M.hints = vim.tbl_deep_extend("force", M.hints, custom_hints)
  end
end

-- Override specific hints (alias for merge, more explicit name)
function M.override(custom_hints)
  M.merge(custom_hints)
end

-- Reset a hint to empty (disable it)
function M.disable(context)
  M.hints[context] = nil
end

-- Reset all hints to defaults
function M.reset()
  M.hints = {
    default = "[w] word  [b] back  [0] start  [$] end  [f/F] find  [gg] top  [G] bottom  [{/}] para",
    cursor_line = "[j] down  [k] up  [0] start  [$] end  [{] prev para  [}] next para",
    blank = "[o] below  [O] above  [p] paste  [cc] change  [dd] delete  [gg/G] top/bottom",
    comment = "[gc] toggle  [V] select  [{/}] para  [gg/G] top/bottom",
    function_def = "[gd] def  [gr] refs  [K] hover  [%] bracket  [{/}] para",
    function_call = "[gd] def  [K] hover  [%] bracket  [ci)] change args",
    string = '[ci"] change  [di"] delete  [vi"] select  [%] quote',
    variable = "[gd] def  [gr] refs  [<leader>ra] rename  [*] search",
    import_statement = "[gd] def  [gf] file  [<C-]>] back",
    class_def = "[gd] def  [gr] refs  [[]m/]m] methods",
    inside_parens = "[%] match  [ci)] change  [di)] change  [vi)] select  [z] folds",
    inside_brackets = "[%] match  [ci]] change  [di]] delete  [vi]] select  [z] folds",
    inside_braces = "[%] match  [ci}] change  [di}] delete  [vi}] select  [z] folds",
    line_start = "[i] insert  [A] end  [w] word  [f] find  [gg/G] top/bottom",
    line_end = "[a] append  [i] insert  [x] del  [D] del-end  [b] back",
    search_active = "[n] next  [N] prev  [*] word  [#] back  [/] search  [gg/G] top/bottom",
    markdown = "[gx] link  []] next head  [[ prev head  [{/}] para",
    lua = "[gd] def  [K] hover  [gr] refs  [:lua %] run",
    python = "[gd] def  [K] hover  [gr] refs  [:!python %] run",
    nvimtree_file = "[<CR>] open  [<Tab>] preview  [v] vsplit  [s] split  [t] tab  [a] new  [d] del  [r] rename",
    nvimtree_dir = "[<CR>] toggle  [<Tab>] preview  [a] new  [d] del  [r] rename  [<BS>] close  [P] parent",
    nvimtree_general = "[a] new  [d] del  [r] rename  [x] cut  [c] copy  [p] paste  [y] name  [R] refresh  [H] hidden",
    git_hunk = "[]c] next hunk  [[c] prev hunk  [<leader>hs] stage  [<leader>hr] reset  [<leader>hp] preview",
  }
end

return M
