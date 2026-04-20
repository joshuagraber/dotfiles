--[[
 _   _-
| | / /
| |/ /  ___ _   _ _ __ ___   __ _ _ __  ___
|    \ / _ \ | | | '_ ` _ \ / _` | '_ \/ __|
| |\  \  __/ |_| | | | | | | (_| | |_) \__ \
\_| \_/\___|\__, |_| |_| |_|\__,_| .__/|___/
             __/ |               | |
            |___/                |_|
--]]
local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader><leader>b", ":Telescope buffers<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader><leader>g", ":Telescope live_grep<CR>", opts)
vim.api.nvim_set_keymap(
  "n",
  "<leader><leader>G",
  '<cmd>lua require("telescope.builtin").live_grep({ additional_args = { "--hidden", "--no-ignore" } })<CR>',
  opts
)
vim.api.nvim_set_keymap("n", "<leader><leader>w", ":Telescope workspaces<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader><leader>c", ":CommentToggle<CR>", opts)

-- Stay in indent mode
vim.api.nvim_set_keymap("v", "<", "<gv", opts)
vim.api.nvim_set_keymap("v", ">", ">gv", opts)

-- visual block comment
vim.api.nvim_set_keymap("v", "<leader><leader>c", ":CommentToggle<CR>", opts)

-- Paste over selection without yanking replaced text (uses black hole register)
vim.api.nvim_set_keymap("v", "<leader>p", '"_dP', opts)

-- Markdown Preview
vim.api.nvim_set_keymap('n', '<leader>mp', ':MarkdownPreview<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ms', ':MarkdownPreviewStop<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>mt', ':MarkdownPreviewToggle<CR>', { noremap = true, silent = true })

local function diffget_from(dir)
  if not vim.wo.diff then
    return
  end
  local winnr = vim.fn.winnr(dir)
  if winnr == 0 then
    return
  end
  local winid = vim.fn.win_getid(winnr)
  if winid == 0 then
    return
  end
  local buf = vim.api.nvim_win_get_buf(winid)
  -- Save current position
  local current_line = vim.fn.line(".")
  local current_col = vim.fn.col(".")
  
  -- Move to the start of the current hunk
  vim.cmd("normal! [c")
  local hunk_start = vim.fn.line(".")
  
  -- Move to the start of the next hunk (or end of file)
  vim.cmd("normal! ]c")
  local next_hunk_start = vim.fn.line(".")
  
  -- If we didn't move (we're at the last hunk), use end of file
  if next_hunk_start == hunk_start then
    next_hunk_start = vim.fn.line("$") + 1
  end
  
  -- Restore cursor position
  vim.fn.cursor(current_line, current_col)
  
  -- The current hunk is from hunk_start to next_hunk_start - 1
  local hunk_end = next_hunk_start - 1
  if hunk_end < hunk_start then
    hunk_end = hunk_start
  end
  
  -- Get only the current hunk, not all changes
  vim.cmd(hunk_start .. "," .. hunk_end .. "diffget " .. buf)
end

vim.keymap.set("n", "<leader>2", function()
  diffget_from("h")
end, { silent = true })

vim.keymap.set("n", "<leader>3", function()
  diffget_from("l")
end, { silent = true })

vim.keymap.set("n", "]c", function()
  if vim.wo.diff then
    -- Use vim's built-in diff navigation
    vim.fn.execute("normal! ]c")
    return
  end
  local ok, gs = pcall(require, "gitsigns")
  if ok then
    pcall(gs.next_hunk)
    return
  end
  vim.fn.search("^<<<<<<<", "W")
end, { silent = true, desc = "Next diff hunk or conflict" })

vim.keymap.set("n", "[c", function()
  if vim.wo.diff then
    -- Use vim's built-in diff navigation
    vim.fn.execute("normal! [c")
    return
  end
  local ok, gs = pcall(require, "gitsigns")
  if ok then
    pcall(gs.prev_hunk)
    return
  end
  vim.fn.search("^<<<<<<<", "bW")
end, { silent = true, desc = "Previous diff hunk or conflict" })

vim.keymap.set("n", "<leader>gm", function()
  if _G._MERGETOOL_TOGGLE then
    _G._MERGETOOL_TOGGLE()
  end
end, { silent = true })

-- Open git remote
vim.api.nvim_set_keymap('n', '<leader>gb', '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".open_in_browser})<cr>', {silent = true})
vim.api.nvim_set_keymap('v', '<leader>gb', '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".open_in_browser})<cr>', {})
-- As a side note, some additional keymaps exist in the handlers.lua file
-- for the language server commands such as gd for go to definition

