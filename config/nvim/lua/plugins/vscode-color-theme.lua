return {
  "Mofiqul/vscode.nvim",
  lazy = false,      -- 主题插件必须在启动时立即加载
  priority = 1000,   -- 高优先级，确保在其他启动插件之前加载
  config = function()
    -- 设置背景为暗色（Neovim 默认，也可以显式声明）
    vim.o.background = "dark"

    -- 可选：在 setup 中微调主题行为
    require("vscode").setup({
      transparent = true,       -- 透明背景
      italic_comments = true,   -- 斜体注释
      italic_inlayhints = true, -- 斜体类型提示
      underline_links = true,   -- 下划线链接
    })

    -- 应用主题
    vim.cmd([[colorscheme vscode]])
  end,
}

