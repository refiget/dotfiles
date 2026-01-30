return {
  -- Molten: run code via Jupyter kernels
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
    end,
  },

  -- Image.nvim: render plots and images inline
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",                   -- use Kitty's graphics protocol; works in iTerm2 with fallback
      max_width = 100,
      max_height = 12,
      max_width_window_percentage  = math.huge,
      max_height_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },

  -- Jupytext.nvim: convert .ipynb files to plain text
  {
    "GCBallesteros/jupytext.nvim",
    config = true,
    lazy = false,                          -- don't lazy‑load, so notebooks open correctly `https://github.com/GCBallesteros/jupytext.nvim/blob/main/README.md#:~:text=Installation`
  },
}
