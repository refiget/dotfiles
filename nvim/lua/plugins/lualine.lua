return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- 获取编辑区背景（Normal）
      local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
      normal_bg = normal_bg and string.format("#%06x", normal_bg)

      -- 自定义 theme（核心）
      local my_theme = {
        normal = {
          a = { bg = normal_bg, fg = "#7aa2f7" },
          b = { bg = normal_bg, fg = "#c0caf5" },
          c = { bg = normal_bg, fg = "#a9b1d6" },
        },
        insert = {
          a = { bg = normal_bg, fg = "#9ece6a" },
        },
        visual = {
          a = { bg = normal_bg, fg = "#bb9af7" },
        },
        replace = {
          a = { bg = normal_bg, fg = "#f7768e" },
        },
      }

      opts.options = opts.options or {}
      opts.options.theme = my_theme
    end,
  },
}
