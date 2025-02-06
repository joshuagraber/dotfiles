-- Check if packer is available
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

return {
  "iamcco/markdown-preview.nvim",
  run = "cd app && npx --yes yarn install",
  ft = { "markdown" },
  setup = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_browser = ""
      vim.g.mkdp_echo_preview_url = 0
      vim.g.mkdp_page_title = '「${name}」'
  end
}

