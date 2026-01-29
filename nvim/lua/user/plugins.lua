local fn = vim.fn
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- LSP 依赖检查：python3 host
local function check_lsp_deps()
  local warns = {}

  local function has_exec(bin)
    return fn.executable(bin) == 1
  end

  local host = vim.g.python3_host_prog or "python3"
  if fn.executable(host) ~= 1 then
    table.insert(warns, "未检测到 python3 host (" .. host .. ")，请安装对应解释器（Arch: pacman -S python；macOS: brew install python）")
  end

  -- 检查 LSP 服务器是否安装
  local lsp_servers = {
    { "pyright", "npm install -g pyright", "Python" },
    { "lua-language-server", "brew install lua-language-server (macOS) or npm install -g lua-language-server (Linux)", "Lua" },
    { "jsonls", "npm install -g vscode-langservers-extracted", "JSON" },
    { "yamlls", "npm install -g yaml-language-server", "YAML" },
    { "tsserver", "npm install -g typescript typescript-language-server", "TypeScript/JavaScript" },
    { "bashls", "npm install -g bash-language-server", "Shell" }
  }

  for _, server in ipairs(lsp_servers) do
    local bin, install_cmd, lang = server[1], server[2], server[3]
    if not has_exec(bin) then
      table.insert(warns, string.format("未检测到 %s (%s)，请安装：%s", lang, bin, install_cmd))
    end
  end

  if #warns > 0 then
    vim.schedule(function()
      vim.notify(table.concat(warns, "\n"), vim.log.levels.WARN, { title = "LSP 依赖检查" })
    end)
  end
end

-- 触发 LSP 依赖检查
local function trigger_lsp_deps_check()
  check_lsp_deps()
end

local plugins = {
  -- LSP / Completion
  { "neovim/nvim-lspconfig", lazy = false },
  { "hrsh7th/nvim-cmp", lazy = false },
  { "hrsh7th/cmp-nvim-lsp", lazy = false },
  { "hrsh7th/cmp-buffer", lazy = false },
  { "hrsh7th/cmp-path", lazy = false },
  { "hrsh7th/cmp-cmdline", lazy = false },
  { "L3MON4D3/LuaSnip", lazy = false },
  { "saadparwaiz1/cmp_luasnip", lazy = false },
  
  -- LSP Enhancements
  { "glepnir/lspsaga.nvim", event = "LspAttach" },
  { "folke/trouble.nvim", event = "LspAttach" },
  { "jose-elias-alvarez/null-ls.nvim", event = "BufReadPre" },

  -- Treesitter / icons
  { "nvim-treesitter/nvim-treesitter", event = { "BufReadPost", "BufNewFile" } },

  -- Appearance
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
      local purple = "#bd93f9"
      local hl = vim.api.nvim_set_hl
      hl(0, "CocExplorerFolderIcon", { fg = purple })
      hl(0, "CocExplorerFileDirectory", { fg = purple })
      hl(0, "CocExplorerFileDirectoryHidden", { fg = purple })
      hl(0, "CocExplorerSymbolicLink", { fg = purple })
      hl(0, "CocExplorerSymbolicLinkTarget", { fg = purple })
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local ok, telescope = pcall(require, "telescope")
      if not ok then
        return
      end
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
            n = {
              ["j"] = "move_selection_next",
              ["k"] = "move_selection_previous",
            },
          },
        },
      })
    end,
  },
  { "nvim-lua/plenary.nvim" },

  -- File Explorer (nvim-tree)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function()
      local ok, nvim_tree = pcall(require, "nvim-tree")
      if not ok then
        vim.notify("nvim-tree 加载失败", vim.log.levels.ERROR, { title = "插件加载" })
        return
      end
      nvim_tree.setup({
        auto_reload_on_write = true,
        disable_netrw = true,
        hijack_netrw = true,
        hijack_cursor = true,
        update_cwd = true,
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        diagnostics = {
          enable = true,
          show_on_dirs = true,
        },
        git = {
          enable = true,
          ignore = false,
        },
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          indent_markers = {
            enable = true,
          },
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              folder = {
                default = "",
                open = "",
                empty = "",
                empty_open = "",
              },
            },
          },
        },
      })
      
      -- Set up key mappings for nvim-tree buffers
      local ok_api, api = pcall(require, "nvim-tree.api")
      if ok_api then
        -- Add autocmd to set mappings when entering nvim-tree buffer
        vim.api.nvim_create_autocmd("BufEnter", {
          pattern = "NvimTree_*",
          callback = function()
            local buf = vim.api.nvim_get_current_buf()
            local function opts(desc)
              return {
                desc = "nvim-tree: " .. desc,
                buffer = buf,
                noremap = true,
                silent = true,
                nowait = true,
              }
            end
            
            -- Yazi-style mappings
            vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
            vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
            vim.keymap.set("n", "q", api.tree.close, opts("Close"))
          end,
        })
      end
      
      -- Set custom colors for nvim-tree (lighter purple icon to match status bar)
      vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = "#c7a5fb" })
    end,
  },

  -- Editing Helpers
  { "windwp/nvim-autopairs", event = "InsertEnter" },
  { "echasnovski/mini.surround", event = "VeryLazy" },
  { "junegunn/vim-after-object", event = "VeryLazy" },
  { "lukas-reineke/indent-blankline.nvim", event = { "BufReadPost", "BufNewFile" } },
  { "Vimjas/vim-python-pep8-indent", ft = "python" },

  -- Markdown Preview (browser)
  {
    "iamcco/markdown-preview.nvim",
    lazy = false,
    build = "cd app && npm install",
    ft = { "markdown" },
    init = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_browser = ""
    end,
  },

  -- LuaSnip
  { "L3MON4D3/LuaSnip", lazy = false },
  { "rafamadriz/friendly-snippets", lazy = false },
}

require("lazy").setup(plugins, {
  defaults = { lazy = true },
  ui = { border = "rounded" },
  install = {
    missing = true,  -- 启动时自动安装缺失插件
  },
})

local soft = "#88c0a0"
vim.g.rainbow_conf = {
  guifgs = {
    "#ff5555",
    "#f1fa8c",
    soft,
    "#bd93f9",
    "#50fa7b",
  },
  ctermfgs = { "Red", "Yellow", "Green", "Cyan", "Magenta" },
}

pcall(function()
  local ok, configs = pcall(require, "nvim-treesitter.configs")
  if not ok then
    ok, configs = pcall(require, "nvim-treesitter.config")
  end

  if not ok or not configs or type(configs.setup) ~= "function" then
    vim.notify("未找到 nvim-treesitter 配置模块，已跳过 treesitter 配置", vim.log.levels.WARN)
    return
  end

  configs.setup({
    ensure_installed = {
      "lua", "vim", "markdown", "markdown_inline", "python", "json", "bash", "javascript", "c",
    },
    highlight = { enable = true },
    indent = { enable = true },
  })
end)

-- LSP 配置
local function setup_lsp()
  local lspconfig = require("lspconfig")
  local cmp_nvim_lsp = require("cmp_nvim_lsp")
  
  -- 配置默认的 capabilities
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  
  -- 配置 pyright (Python)
  lspconfig.pyright.setup({
    capabilities = capabilities,
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          autoImportCompletions = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "openFilesOnly"
        }
      }
    }
  })
  
  -- 配置 lua_ls (Lua)
  lspconfig.lua_ls.setup({
    capabilities = capabilities,
    settings = {
      Lua = {
        diagnostics = {
          globals = {"vim"}
        }
      }
    }
  })
  
  -- 配置 jsonls (JSON)
  lspconfig.jsonls.setup({
    capabilities = capabilities
  })
  
  -- 配置 yamlls (YAML)
  lspconfig.yamlls.setup({
    capabilities = capabilities
  })
  
  -- 配置 tsserver (TypeScript/JavaScript)
  lspconfig.tsserver.setup({
    capabilities = capabilities
  })
  
  -- 配置 bashls (Shell)
  lspconfig.bashls.setup({
    capabilities = capabilities
  })
end

-- 配置 LSP 增强插件
local function setup_lsp_enhancements()
  -- 配置 lspsaga
  pcall(function()
    local ok, lspsaga = pcall(require, "lspsaga")
    if not ok then
      return
    end
    lspsaga.setup({
      symbol_in_winbar = {
        enable = true,
      },
      ui = {
        border = "rounded",
      },
    })
  end)
  
  -- 配置 trouble
  pcall(function()
    local ok, trouble = pcall(require, "trouble")
    if not ok then
      return
    end
    trouble.setup({})
  end)
  
  -- 配置 null-ls
  pcall(function()
    local ok, null_ls = pcall(require, "null-ls")
    if not ok then
      return
    end
    null_ls.setup({
      sources = {
        -- Formatters
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.stylua,
        -- Linters
        null_ls.builtins.diagnostics.flake8,
      },
    })
  end)
end

-- 设置 LSP
trigger_lsp_deps_check()
setup_lsp()
setup_lsp_enhancements()

