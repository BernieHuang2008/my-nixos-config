local opt = vim.opt

-- 代码编辑
opt.number = true       -- 行号
opt.cursorline = true	-- 高亮光标所在行
opt.colorcolumn = "80"  -- 80 列边界

-- 缩进
opt.expandtab = true    -- tab -> space
opt.tabstop = 4
opt.shiftwidth = 0

-- 搜索
opt.ignorecase = true
opt.smartcase = true

-- 其他常用
opt.autoread = true      -- 自动重载外部更改
opt.mouse = "a"          -- 启用鼠标
opt.termguicolors = true -- 真彩色，很多主题依赖
opt.clipboard = "unnamedplus" -- 与系统剪贴板互通
opt.scrolloff = 8        -- 光标上下保留 8 行
opt.updatetime = 250     -- 更快触发 CursorHold

