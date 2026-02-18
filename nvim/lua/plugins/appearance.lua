return {
  {
    -- Primary theme
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

      -- Ensure popup UI has readable contrast even with transparent_background=true
      pcall(function()
        local p = require("catppuccin.palettes").get_palette("mocha")
        vim.api.nvim_set_hl(0, "Pmenu", { fg = p.text, bg = p.mantle })
        vim.api.nvim_set_hl(0, "PmenuSel", { fg = p.text, bg = p.surface0 })
        vim.api.nvim_set_hl(0, "NormalFloat", { fg = p.text, bg = p.mantle })
        vim.api.nvim_set_hl(0, "FloatBorder", { fg = p.surface2, bg = p.mantle })
      end)

      -- Keep these plugin vars here (they're appearance-adjacent)
      vim.g.rainbow_active = 1

      -- lightline disabled: eleline is the single statusline implementation
      vim.g.eleline_colorscheme = "catppuccin"
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
  -- Rainbow parentheses (Treesitter-based)
  { "HiPhish/rainbow-delimiters.nvim", event = { "BufReadPost", "BufNewFile" } },
  { "theniceboy/eleline.vim", branch = "no-scrollbar", lazy = false },
  -- Word-under-cursor highlight (modern + minimal). Prefer this over vim-illuminate.
  {
    "echasnovski/mini.cursorword",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local ok, cw = pcall(require, "mini.cursorword")
      if not ok then
        return
      end
      cw.setup({ delay = 600 })
      -- Subtle underline; let colorscheme decide foreground.
      vim.api.nvim_set_hl(0, "MiniCursorword", { underline = true })
      vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", { underline = true })
    end,
  },
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

  -- Unified message/cmdline UI (centered cmdline) + better notifications
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      local ok, notify = pcall(require, "notify")
      if not ok then
        return
      end
      notify.setup({
        stages = "fade",
        timeout = 2500,
        background_colour = "#000000",
        render = "minimal",
        max_width = function()
          return math.floor(vim.o.columns * 0.4)
        end,
      })
      vim.notify = notify
    end,
  },
  { "MunifTanjim/nui.nvim", event = "VeryLazy" },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      local ok, noice = pcall(require, "noice")
      if not ok then
        return
      end
      noice.setup({
        lsp = {
          -- Let noice render hover/signature in a consistent UI.
          hover = { enabled = true },
          signature = { enabled = true },
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        cmdline = {
          enabled = true,
          view = "cmdline_popup",
          format = {
            cmdline = { pattern = "^:", icon = ":", lang = "vim" },
            search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
            search_up = { kind = "search", pattern = "^\\?", icon = " ", lang = "regex" },
          },
        },
        views = {
          cmdline_popup = {
            position = {
              row = "45%",
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            win_options = {
              winblend = 10,
            },
          },
          popupmenu = {
            relative = "editor",
            position = {
              row = "55%",
              col = "50%",
            },
            size = {
              width = 60,
              height = 10,
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            win_options = {
              winblend = 10,
            },
          },
        },
        presets = {
          bottom_search = false,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
        routes = {
          -- Reduce noise
          { filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } },
          { filter = { event = "msg_show", kind = "wmsg" }, opts = { skip = true } },
        },
      })
    end,
  },
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
