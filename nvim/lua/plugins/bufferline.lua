-- akinsho/bufferline.nvim

return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "BufferLine: next" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "BufferLine: prev" },
    { "<localleader>bp", "<cmd>BufferLinePick<CR>", desc = "BufferLine: pick" },
    { "<localleader>bc", "<cmd>bdelete!<CR>", desc = "Buffer: close current" },
  },
  config = function()
    local ok, bufferline = pcall(require, "bufferline")
    if not ok then
      return
    end

    vim.opt.termguicolors = true
    vim.opt.showtabline = 2

    local base_bg = "#2C323B"
    local surface = "#3a414b"
    local text = "#cdd6f4"
    local muted = "#8b93a0"

    bufferline.setup({
      highlights = {
        fill = { bg = base_bg },
        background = { bg = base_bg, fg = muted },
        buffer_visible = { bg = base_bg, fg = muted },
        buffer_selected = { bg = base_bg, fg = text, bold = true, italic = false },

        separator = { bg = base_bg, fg = base_bg },
        separator_visible = { bg = base_bg, fg = base_bg },
        separator_selected = { bg = base_bg, fg = base_bg },

        tab = { bg = base_bg, fg = muted },
        tab_selected = { bg = surface, fg = text, bold = true },
        tab_separator = { bg = base_bg, fg = base_bg },
        tab_separator_selected = { bg = surface, fg = surface },

        close_button = { bg = base_bg, fg = muted },
        close_button_visible = { bg = base_bg, fg = muted },
        close_button_selected = { bg = base_bg, fg = text },
        indicator_selected = { fg = "#b294bb", bg = base_bg },
      },
      options = {
        mode = "buffers",
        numbers = "none",
        diagnostics = "nvim_lsp",
        -- 无分隔线
        separator_style = { "", "" },
        always_show_bufferline = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
        color_icons = true,
        indicator = {
          style = "none",
        },
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        -- 仅显示当前 tabpage 中“有窗口可见”的文件 buffer，避免残留
        custom_filter = function(bufnr)
          local bo = vim.bo[bufnr]
          if bo.buftype ~= "" or not bo.buflisted then
            return false
          end

          local name = vim.api.nvim_buf_get_name(bufnr)
          if name == "" then
            return false
          end

          local wins = vim.fn.win_findbuf(bufnr)
          return wins and #wins > 0
        end,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    })
  end,
}
