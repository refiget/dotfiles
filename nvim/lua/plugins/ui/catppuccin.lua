-- catppuccin theme

return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  config = function()
    vim.opt.termguicolors = true

    local ok, catppuccin = pcall(require, "catppuccin")
    if ok then
      catppuccin.setup({
        flavour = "mocha",
        transparent_background = true,
        term_colors = true,
        dim_inactive = { enabled = false },
        integrations = {
          gitsigns = true,
          treesitter = true,
          telescope = true,
          trouble = true,
          native_lsp = { enabled = true },
          notify = true,
          noice = true,
          cmp = true,
        },
      })
    end

    vim.cmd("silent! colorscheme catppuccin")

    -- Statusline: eleline
    vim.g.eleline_colorscheme = "catppuccin"
    vim.g.eleline_powerline_fonts = 0
  end,
}
