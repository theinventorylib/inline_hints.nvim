-- lua/inline_hints/combos.lua
-- Combo/Sequential keybind hints with multi-step support

local M = {}

-- =========================================================
-- 🔗 Multi-step combo system (like which-key)
-- =========================================================
-- This system supports progressive hints at each step of a combo.
-- Examples:
--   "d" → shows operators
--   "da" → shows text objects (around)
--   "di" → shows text objects (inside)
--   "3" → shows count-based operations
--   "d3" → shows motions for "delete 3..."

-- =========================================================
-- Step 1: Primary operators and prefixes
-- =========================================================
M.combo_hints = {
  -- g prefix (goto/git)
  g = "[gd] def  [gr] refs  [gf] file  [gg] top  [gc] comment  [g*] search  [g;] last change",

  -- d prefix (delete) - shows common completions + text object triggers
  d = "[dd] line  [dw] word  [d$] to end  [da] around  [di] inside  [dt] till  [df] find  [#] count",

  -- c prefix (change) - shows common completions + text object triggers
  c = "[cc] line  [cw] word  [c$] to end  [ca] around  [ci] inside  [ct] till  [cf] find  [#] count",

  -- y prefix (yank/copy) - shows common completions + text object triggers
  y = "[yy] line  [yw] word  [y$] to end  [ya] around  [yi] inside  [#] count",

  -- v prefix (visual) - text object triggers
  v = "[vap] para  [vi)] inside  [va)] around  [viw] word  [vit] tag  [vi{] block",

  -- z prefix (fold/view)
  z = "[zz] center  [zt] top  [zb] bottom  [za] toggle fold  [zR] open all  [zM] close all",

  -- [ prefix (prev)
  ["["] = "[[c] prev change  [[m] prev method  [[[] prev section  [[d] prev diagnostic",

  -- ] prefix (next)
  ["]"] = "[]c] next change  []m] next method  []] next section  []d] next diagnostic",

  -- <leader> prefix (telescope/custom)
  ["<leader>"] = "[f] telescope  [g] git  [b] buffers  [h] help  [r] refactor  [d] debug",
}

-- =========================================================
-- Step 2: Text objects (after 'a' or 'i')
-- =========================================================
M.text_object_hints = {
  -- "around" text objects (after 'da', 'ca', 'ya', 'va')
  a = "[ap] para  [aw] word  [a)] paren  [a]] bracket  [a}] brace  [a'] quote  [at] tag  [ab] block",
  
  -- "inside" text objects (after 'di', 'ci', 'yi', 'vi')
  i = "[ip] para  [iw] word  [i)] paren  [i]] bracket  [i}] brace  [i'] quote  [it] tag  [ib] block",
}

-- =========================================================
-- Step 3: Count-based hints (after number)
-- =========================================================
M.count_hints = {
  -- After typing a number (e.g., "3")
  default = "[dd] del lines  [j/k] move  [w] words  [x] chars  [yy] yank lines  [G] goto line",
  
  -- After typing number + operator (e.g., "d3")
  d = "[w] words  [j] lines down  [k] lines up  [e] end of word  [$] to end",
  c = "[w] words  [j] lines down  [k] lines up  [e] end of word  [$] to end",
  y = "[w] words  [j] lines down  [k] lines up  [e] end of word  [$] to end",
}

-- =========================================================
-- Step 4: Special sequences
-- =========================================================
-- Telescope-specific hints
M.telescope_hints = {
  ["<leader>f"] = "[ff] files  [fg] grep  [fb] buffers  [fh] help  [fr] recent  [fc] commands",
  ["<leader>g"] = "[gs] status  [gc] commits  [gb] branches  [gh] hunks",
}

-- Fold contexts reuse the `z` combo definitions
M.fold_hints = {
  foldable = M.combo_hints.z,
  folded = "[zo] open  [zO] open all  [zc] close  [zj] next fold  [zk] prev fold",
}

-- =========================================================
-- Combo key categories
-- =========================================================
-- Keys that trigger combo mode
M.combo_keys = {
  g = true,
  d = true,
  c = true,
  y = true,
  v = true,
  z = true,
  ["["] = true,
  ["]"] = true,
}

-- Operators that can take text objects
M.operator_keys = {
  d = true,
  c = true,
  y = true,
  v = true,
}

-- Text object modifiers
M.text_object_modifiers = {
  a = true,  -- around
  i = true,  -- inside
}

-- =========================================================
-- Progressive hint lookup
-- =========================================================
-- Get hint for current key sequence
function M.get(key_sequence)
  -- Direct match in combo_hints or telescope_hints
  local direct = M.combo_hints[key_sequence] or M.telescope_hints[key_sequence]
  if direct then
    return direct
  end

  -- Multi-step combo detection
  if #key_sequence >= 2 then
    local first = key_sequence:sub(1, 1)
    local second = key_sequence:sub(2, 2)
    local rest = key_sequence:sub(3)

    -- Pattern: operator + text_object_modifier (e.g., "da", "di", "ca", "ci")
    if M.operator_keys[first] and M.text_object_modifiers[second] then
      return M.text_object_hints[second]
    end

    -- Pattern: operator + count (e.g., "d3", "c5")
    if M.operator_keys[first] and second:match("^%d$") then
      return M.count_hints[first] or M.count_hints.default
    end

    -- Pattern: count + operator (e.g., "3d", "5c")
    if first:match("^%d$") and M.operator_keys[second] then
      return M.count_hints[second] or M.count_hints.default
    end

    -- Pattern: just count (e.g., "3", "15")
    if key_sequence:match("^%d+$") then
      return M.count_hints.default
    end
  end

  return nil
end

-- =========================================================
-- Key validation functions
-- =========================================================
-- Check if key is a combo starter
function M.is_combo_key(key)
  return M.combo_keys[key] == true
end

-- Check if key is an operator
function M.is_operator_key(key)
  return M.operator_keys[key] == true
end

-- Check if key is a text object modifier
function M.is_text_object_modifier(key)
  return M.text_object_modifiers[key] == true
end

-- Check if sequence should continue (return true to keep tracking)
function M.should_continue_sequence(key_sequence, new_key)
  if not key_sequence or key_sequence == "" then
    return false
  end

  -- Continue if new_key is a number
  if new_key:match("^%d$") then
    return true
  end

  -- Continue if we have an operator and new key is a text object modifier
  local first = key_sequence:sub(1, 1)
  if M.operator_keys[first] and M.text_object_modifiers[new_key] then
    return true
  end

  -- Continue if we have a number and new key is an operator
  if key_sequence:match("^%d+$") and M.operator_keys[new_key] then
    return true
  end

  return false
end

-- =========================================================
-- Configuration merging
-- =========================================================
-- Merge custom combo hints
function M.merge_combos(custom_combos)
  if custom_combos then
    M.combo_hints = vim.tbl_deep_extend("force", M.combo_hints, custom_combos)
  end
end

-- Merge custom text object hints
function M.merge_text_objects(custom_text_objects)
  if custom_text_objects then
    M.text_object_hints = vim.tbl_deep_extend("force", M.text_object_hints, custom_text_objects)
  end
end

-- Merge custom count hints
function M.merge_count_hints(custom_count_hints)
  if custom_count_hints then
    M.count_hints = vim.tbl_deep_extend("force", M.count_hints, custom_count_hints)
  end
end

-- Merge custom telescope hints
function M.merge_telescope(custom_telescope)
  if custom_telescope then
    M.telescope_hints = vim.tbl_deep_extend("force", M.telescope_hints, custom_telescope)
  end
end

return M
