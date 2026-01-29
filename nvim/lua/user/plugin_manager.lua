local fn = vim.fn
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  require("user.plugins.lsp"),
  require("user.plugins.completion"),
  require("user.plugins.debugging"),
  require("user.plugins.appearance"),
  require("user.plugins.file_explorer"),
  require("user.plugins.editing_helpers"),
  require("user.plugins.telescope"),
}

require("lazy").setup(plugins, {
  defaults = { lazy = true },
  ui = { border = "rounded" },
  install = {
    missing = true,
  },
})
