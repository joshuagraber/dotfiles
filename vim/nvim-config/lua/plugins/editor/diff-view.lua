local status_ok, diffview = pcall(require, "diffview")
if not status_ok then
    return
end

-- Force close all diff windows and clear diff state
local function force_diff_close()
    -- First, close any floating windows
    for _, win in pairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= "" then
            vim.api.nvim_win_close(win, true)
        end
    end

    -- Turn off diff mode for all buffers
    vim.cmd('windo diffoff!')
    -- Close all windows except current
    vim.cmd('only')
    
    -- Clear all diff options for each window
    for _, win in pairs(vim.api.nvim_list_wins()) do
        vim.api.nvim_win_call(win, function()
            vim.opt.diff = false
            vim.opt.cursorbind = false
            vim.opt.scrollbind = false
            vim.opt.scrollopt = "ver,jump,cursor"
        end)
    end

    -- Reset all diff-related options
    vim.cmd('set nodiff noscrollbind nocursorbind')
    
    -- Clear any existing diff buffers
    local bufs = vim.api.nvim_list_bufs()
    for _, buf in ipairs(bufs) do
        if vim.api.nvim_buf_is_valid(buf) then
            local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
            if buftype == 'nofile' or buftype == 'nowrite' then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end
        end
    end
end

-- Ensure cleanup happens before any diffview operations
local function safe_diffview_open()
    force_diff_close()
    vim.defer_fn(function()
        vim.cmd('DiffviewOpen')
    end, 10)
end

diffview.setup({
    enhanced_diff_hl = true,
    view = {
        merge_tool = {
            layout = "diff3_mixed",
            disable_diagnostics = true,
        },
    },
    hooks = {
        view_opened = function()
            force_diff_close()
        end,
        view_closed = function()
            force_diff_close()
        end,
        diff_buf_read = function()
            vim.opt_local.wrap = false
            vim.opt_local.list = false
        end
    },
    keymaps = {
        disable_defaults = false,
        view = {
            ["<leader>co"] = function()
                safe_diffview_open()
            end,
            ["<leader>cc"] = function()
                vim.cmd("DiffviewClose")
                force_diff_close()
            end,
        },
    },
})

-- Create commands for manual cleanup
vim.api.nvim_create_user_command('DiffClean', force_diff_close, {})

-- Set up autocommands for cleanup
local group = vim.api.nvim_create_augroup("DiffviewCustom", { clear = true })

-- Cleanup on window close
vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    pattern = "*",
    callback = function()
        if vim.bo.filetype == "DiffviewFiles" then
            force_diff_close()
        end
    end,
})

-- Cleanup when leaving Neovim
vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = force_diff_close,
})

-- Add a command to manually cleanup diff buffers if needed
vim.api.nvim_create_user_command("DiffCleanup", force_diff_close, {})
