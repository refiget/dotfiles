-- NvChad/nvim-colorizer.lua

return {
  "NvChad/nvim-colorizer.lua",
  event = "VeryLazy",
  config = function()
    local ok, colorizer = pcall(require, "colorizer")
    if not ok then
      return
    end
    colorizer.setup({
      filetypes = { "*" },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = true,
        AARRGGBB = true,
        mode = "virtualtext",
        virtualtext = "■",
      },
    })
  end,
}
