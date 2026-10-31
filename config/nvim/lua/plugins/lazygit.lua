return {
  "kdheepak/lazygit.nvim",
  lazy = true,
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>lg", "<cmd>LazyGit<cr>", desc = "打开 Lazygit" },
    { "<leader>lf", "<cmd>LazyGitCurrentFile<cr>", desc = "Lazygit (当前文件)" },
  },
  init = function()
    -- 浮动窗口设置（可选）
    vim.g.lazygit_floating_window_scaling_factor = 0.9
    vim.g.lazygit_floating_window_winblend = 0
  end,
}
