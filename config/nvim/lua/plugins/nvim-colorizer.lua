return {
  "NvChad/nvim-colorizer.lua", -- 注意：NvChad 是维护更活跃的 fork
  opts = {
    filetypes = { "*" }, -- 对所有文件类型生效
    user_default_options = {
      RGB = true,       -- 识别 #RGB
      RRGGBB = true,    -- 识别 #RRGGBB
      RRGGBBAA = true,  -- 识别 #RRGGBBAA
      AARRGGBB = true,  -- 识别 0xAARRGGBB
      names = true,     -- 识别 "Blue" 等颜色名
      mode = "background", -- 背景色模式，也可用 "foreground" / "virtualtext"
      tailwind = false, -- 是否启用 Tailwind 颜色
      no_hash = true,   -- 🎯 关键：识别不带 # 的 16 进制颜色（如 FF0000）
    },
  },
}
