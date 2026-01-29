return {
  {
    "theniceboy/nvim-deus",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true
      vim.cmd("silent! colorscheme deus")
      vim.api.nvim_set_hl(0, "NonText", { fg = "grey10" })
      vim.g.rainbow_active = 1
      vim.g.Illuminate_delay = 750
      vim.api.nvim_set_hl(0, "illuminatedWord", { undercurl = true })
      vim.g.lightline = {
        active = {
          left = {
            { "mode", "paste" },
            { "readonly", "filename", "modified" },
          },
        },
      }
      vim.g.eleline_colorscheme = "deus"
      vim.g.eleline_powerline_fonts = 0
    end,
  },
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local ok, scrollbar = pcall(require, "scrollbar")
      if not ok then
        return
      end
      scrollbar.setup()
      local ok_search, search = pcall(require, "scrollbar.handlers.search")
      if ok_search then
        search.setup()
      end
    end,
  },
  { "HiPhish/rainbow-delimiters.nvim", event = "VeryLazy" },
  { "theniceboy/eleline.vim", branch = "no-scrollbar", lazy = false },
  { "RRethy/vim-illuminate", event = "BufReadPost" },
  {
    "NvChad/nvim-colorizer.lua",
    event = "VeryLazy",
    config = function()
      local ok, colorizer = pcall(require, "colorizer")
      if not ok then
        return
      end
      colorizer.setup({
        filetypes = { "*" },
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = true,
          AARRGGBB = true,
          mode = "virtualtext",
          virtualtext = "■",
        },
      })
    end,
  },
  { "kevinhwang91/nvim-hlslens", event = "CmdlineEnter" },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VimEnter",
    config = function()
      local ok, bufferline = pcall(require, "bufferline")
      if not ok then
        return
      end
      bufferline.setup({
        options = {
          mode = "tabs",
          numbers = "ordinal",
          diagnostics = "nvim_lsp",
          separator_style = "slant",
          show_close_icon = false,
          show_buffer_close_icons = false,
          color_icons = true,
          always_show_bufferline = true,
        },
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local ok, gitsigns = pcall(require, "gitsigns")
      if not ok then
        return
      end
      gitsigns.setup({
        signs = {
          add = { hl = "GitSignsAdd", text = "▎", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
          change = { hl = "GitSignsChange", text = "░", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
          delete = { hl = "GitSignsDelete", text = "_", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
          topdelete = { hl = "GitSignsDelete", text = "▔", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
          changedelete = { hl = "GitSignsChange", text = "▒", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
          untracked = { hl = "GitSignsAdd", text = "┆", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
        },
      })
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    config = function()
      local ok, devicons = pcall(require, "nvim-web-devicons")
      if not ok then
        return
      end
      devicons.setup({
        color_icons = true,
        default = true,
        override = {
          folder = { icon = "", color = "#bd93f9", name = "folder" },
          folder_open = { icon = "", color = "#bd93f9", name = "folder_open" },
          default_icon = { icon = "", color = "#bd93f9", name = "folder" },
        },
      })
      local purple = "#a77fd9"
      local hl = vim.api.nvim_set_hl
      hl(0, "CocExplorerFolderIcon", { fg = purple })
      hl(0, "CocExplorerFileDirectory", { fg = purple })
      hl(0, "CocExplorerFileDirectoryHidden", { fg = purple })
      hl(0, "CocExplorerSymbolicLink", { fg = purple })
      hl(0, "CocExplorerSymbolicLinkTarget", { fg = purple })
    end,
  },
  { "nvim-treesitter/nvim-treesitter", event = { "BufReadPost", "BufNewFile" } },
}
