return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    event = "VeryLazy",
    config = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 12
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
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "markdown", "vimwiki" },
          },
        },
        max_width = nil,
        max_height = nil,
        max_width_window_percentage = nil,
        max_height_window_percentage = 50,
        window_overlap_clear_enabled = false,
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "noice", "notify" },
        editor_only_render_when_focused = false,
        tmux_show_only_in_active_window = false,
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
      })
    end,
  },
  {
    "GCBallesteros/jupytext.nvim",
    event = "VeryLazy",
    config = function()
      local ok, jupytext = pcall(require, "jupytext")
      if not ok then
        return
      end
      jupytext.setup({
        style = "markdown",
        output_extension = "md",
      })
    end,
  },
}
