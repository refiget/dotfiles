local soft = "#88c0a0"
vim.g.rainbow_conf = {
  guifgs = {
    "#ff5555",
    "#f1fa8c",
    soft,
    "#bd93f9",
    "#50fa7b",
  },
  ctermfgs = { "Red", "Yellow", "Green", "Cyan", "Magenta" },
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        ok, configs = pcall(require, "nvim-treesitter.config")
      end

      if not ok or not configs or type(configs.setup) ~= "function" then
        vim.notify("未找到 nvim-treesitter 配置模块，已跳过 treesitter 配置", vim.log.levels.WARN)
        return
      end

      configs.setup({
        ensure_installed = {
          "lua", "vim", "markdown", "markdown_inline", "python", "json", "bash", "javascript", "c",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
