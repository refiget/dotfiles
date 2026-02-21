-- nvim-tree.lua

return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local ok, tree = pcall(require, "nvim-tree")
    if not ok then
      return
    end
    tree.setup({
      view = { width = 32 },
      renderer = { highlight_git = true, icons = { show = { git = true } } },
      filters = { dotfiles = false },
      git = { enable = true },
    })
  end,
}
