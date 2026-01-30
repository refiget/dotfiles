return {
  {
    "GCBallesteros/NotebookNavigator.nvim",
    keys = {
      {"]h", function() require("notebook-navigator").move_cell "d" end},
      {"[h", function() require("notebook-navigator").move_cell "u" end},
      {"<leader>X", "<cmd>lua require('notebook-navigator').run_cell()<cr>"},
      {"<leader>x", "<cmd>lua require('notebook-navigator').run_and_move()<cr>"},
    },
    event = "VeryLazy",
    config = function()
      local ok, nn = pcall(require, "notebook-navigator")
      if not ok then
        return
      end
      nn.setup({
        cell_markers = { python = "# %%", markdown = "%%" },
        repl_provider = "molten",
      })
    end,
  },
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    config = function()
      local ok, image = pcall(require, "image")
      if not ok then
        return
      end
      image.setup({
        backend = "kitty",
        max_width = 100,
        max_height = 12,
        window_overlap_clear_enabled = true,
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "markdown", "vimwiki" },
          },
        },
        max_width_window_percentage = nil,
        max_height_window_percentage = 50,
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "noice", "notify" },
        editor_only_render_when_focused = false,
        tmux_show_only_in_active_window = false,
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
      })
    end,
  },
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    event = "VeryLazy",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = true
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_lines_off_by_1 = true
    end,
  },
  {
    "GCBallesteros/jupytext.nvim",
    lazy = true,
    cmd = { "JupytextTo", "JupytextFrom", "JupytextSync" },
    config = function()
      local ok, jupytext = pcall(require, "jupytext")
      if not ok then
        return
      end
      jupytext.setup({
        style = "markdown",
        output_extension = "md",
        custom_formatting_ext = ".md",
      })
    end,
  },
  {
    "quarto-dev/quarto-nvim",
    dependencies = { "jmbuhr/otter.nvim", "nvim-treesitter/nvim-treesitter", "hrsh7th/nvim-cmp", "neovim/nvim-lspconfig" },
    event = "VeryLazy",
    config = function()
      local ok, quarto = pcall(require, "quarto")
      if not ok then
        return
      end
      quarto.setup({
        lspFeatures = {
          enabled = true,
          languages = { "python", "r", "julia", "bash", "rust" },
          diagnostics = { enabled = true, triggers = { "BufWritePost" } },
          completion = { enabled = true },
        },
        codeRunner = {
          enabled = true,
          default_method = "molten",
        },
      })
    end,
  },
}
