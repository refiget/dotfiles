local fn = vim.fn  -- Accessed Nvim functions
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"  -- `stdpath("data")` is the path where stores data of nvim.
if not vim.loop.fs_stat(lazypath) then  -- Check the existence of lazy.nvim and clone the repository by shell command.
  fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)  -- Ensure lazy.nvim is loaded early.

local plugins = {
  require("plugins.lsp"),
  require("plugins.completion"),
  require("plugins.debugging"),
  require("plugins.appearance"),
  require("plugins.file_explorer"),
  require("plugins.editing_helpers"),
  require("plugins.telescope"),
  require("plugins.markdown"),
  require("plugins.treesitter"),
	require("plugins.molten"),
	require("plugins.image"),
}

require("lazy").setup(plugins, {  -- Initialize lazy.nivm with plugins
  defaults = { lazy = true },   -- Makes all plugins lazy-loaded
  ui = { border = "rounded" },  -- UI of lazy.nvim
  install = {
    missing = true,  -- Auto Install missing plugins
  },
})
