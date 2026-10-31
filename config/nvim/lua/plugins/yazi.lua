return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>y", "<cmd>Yazi<cr>", desc = "打开 Yazi" },
    { "<leader>Y", "<cmd>Yazi cwd<cr>", desc = "在 Yazi 中打开当前目录" },
  },
  opts = {
    open_for_directories = false,
  },
}
