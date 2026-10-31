return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      signs = {
        add          = { text = "┃" }, -- 新增行（通常映射为绿色）
        change       = { text = "┃" }, -- 修改行（通常映射为黄色）
        delete       = { text = "_" }, -- 删除行（通常映射为红色）
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" }, -- 未跟踪文件
      },
      signs_staged_enable = true, -- 同时显示已暂存更改的标记
      signcolumn = true,
      current_line_blame = false, -- 可改为 true 在行尾显示 blame
      -- 常用快捷键：跳转到上/下一个更改块
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        map("n", "]h", gs.next_hunk, "下一个更改")
        map("n", "[h", gs.prev_hunk, "上一个更改")
        map("n", "<leader>hs", gs.stage_hunk, "暂存更改块")
        map("n", "<leader>hr", gs.reset_hunk, "撤销更改块")
        map("n", "<leader>hp", gs.preview_hunk, "预览更改块")
      end,
    })
  end,
}
