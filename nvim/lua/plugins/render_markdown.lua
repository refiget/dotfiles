-- MeanderingProgrammer/render-markdown.nvim

return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local ok, rm = pcall(require, "render-markdown")
    if not ok then
      return
    end

    -- Match current Catppuccin Mocha-ish UI.
    local function apply_render_markdown_hl()
      local okp, p = pcall(function()
        return require("catppuccin.palettes").get_palette("mocha")
      end)
      if not okp or not p then
        return
      end

      -- Keep heading foreground colors, but remove full-line background highlight.
      -- render-markdown uses RenderMarkdownH{n}Bg to highlight the whole heading line.
      -- Setting bg = NONE cancels that "whole line" effect.
      local function clear_bg(hl)
        vim.api.nvim_set_hl(0, hl, { bg = "NONE" })
      end

      clear_bg("RenderMarkdownH1Bg")
      clear_bg("RenderMarkdownH2Bg")
      clear_bg("RenderMarkdownH3Bg")
      clear_bg("RenderMarkdownH4Bg")
      clear_bg("RenderMarkdownH5Bg")
      clear_bg("RenderMarkdownH6Bg")

      -- Optional: nudge heading foregrounds toward theme accents (no background).
      vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = p.mauve, bg = "NONE", bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownH2", { fg = p.blue, bg = "NONE", bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownH3", { fg = p.teal, bg = "NONE", bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownH4", { fg = p.green, bg = "NONE" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH5", { fg = p.yellow, bg = "NONE" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH6", { fg = p.peach, bg = "NONE" })
    end

    apply_render_markdown_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("RenderMarkdownTheme", { clear = true }),
      callback = function()
        pcall(apply_render_markdown_hl)
      end,
    })

    rm.setup({
      preset = "none",
      -- Keep defaults; theme is handled via highlights above.
    })
  end,
}
