return {
  {
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
          dim_inactive = {
            enabled = false,
          },
          integrations = {
            gitsigns = true,
            treesitter = true,
            telescope = true,
            trouble = true,
            native_lsp = {
              enabled = true,
            },
          },
        })
      end

      vim.cmd("silent! colorscheme catppuccin-mocha")

      -- Keep these plugin vars here (they're appearance-adjacent)
      vim.g.rainbow_active = 1
      vim.g.Illuminate_delay = 750
      vim.api.nvim_set_hl(0, "illuminatedWord", { undercurl = true })

      -- lightline disabled: eleline is the single statusline implementation
      vim.g.eleline_colorscheme = "catppuccin"
      vim.g.eleline_powerline_fonts = 0
    end,
  },
  {
    "petertriho/nvim-scrollbar",
    cond = function() return not vim.g.is_ssh end,
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
    cond = function() return not vim.g.is_ssh end,
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
  -- bufferline disabled: tmux status already provides a tab strip (avoid duplicate UI)
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
