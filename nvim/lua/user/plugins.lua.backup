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
    { "pyright-langserver", "npm install -g pyright", "Python" },
    { "lua-language-server", "brew install lua-language-server (macOS) or npm install -g lua-language-server (Linux)", "Lua" },
    { "vscode-json-language-server", "npm install -g vscode-langservers-extracted", "JSON" },
    { "yaml-language-server", "npm install -g yaml-language-server", "YAML" },
    { "typescript-language-server", "npm install -g typescript typescript-language-server", "TypeScript/JavaScript" },
    { "bash-language-server", "npm install -g bash-language-server", "Shell" }
  }
  local tools = {
    { "black", "pip install black", "Python formatter" },
    { "flake8", "pip install flake8", "Python linter" },
    { "stylua", "brew install stylua (macOS) or cargo install stylua", "Lua formatter" },
  }

  for _, server in ipairs(lsp_servers) do
    local bin, install_cmd, lang = server[1], server[2], server[3]
    if not has_exec(bin) then
      table.insert(warns, string.format("未检测到 %s (%s)，请安装：%s", lang, bin, install_cmd))
    end
  end
  for _, tool in ipairs(tools) do
    local bin, install_cmd, name = tool[1], tool[2], tool[3]
    if not has_exec(bin) then
      table.insert(warns, string.format("未检测到 %s (%s)，请安装：%s", name, bin, install_cmd))
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

  -- Debugging (Python)
  { "mfussenegger/nvim-dap", lazy = false },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local ok, dap_python = pcall(require, "dap-python")
      if not ok then
        return
      end
      local python = vim.g.python3_host_prog or "python3"
      dap_python.setup(python)
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    lazy = false,
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local ok_dap, dap = pcall(require, "dap")
      local ok_ui, dapui = pcall(require, "dapui")
      if not ok_dap or not ok_ui then
        return
      end
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  
  -- LSP Enhancements
  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach",
    config = function()
      local ok, lspsaga = pcall(require, "lspsaga")
      if not ok then
        return
      end
      lspsaga.setup({
        symbol_in_winbar = {
          enable = false,
        },
        ui = {
          border = "rounded",
        },
      })
    end,
  },
  {
    "folke/trouble.nvim",
    event = "LspAttach",
    config = function()
      local ok, trouble = pcall(require, "trouble")
      if not ok then
        return
      end
      trouble.setup({})
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvimtools/none-ls-extras.nvim" },
    config = function()
      local ok, null_ls = pcall(require, "null-ls")
      if not ok then
        return
      end
      local sources = {}
      local function has_exec(bin)
        return vim.fn.executable(bin) == 1
      end
      if has_exec("black") and null_ls.builtins.formatting.black then
        table.insert(sources, null_ls.builtins.formatting.black)
      end
      if has_exec("stylua") and null_ls.builtins.formatting.stylua then
        table.insert(sources, null_ls.builtins.formatting.stylua)
      end
      if has_exec("flake8") then
        local ok_flake8, flake8 = pcall(require, "none-ls.diagnostics.flake8")
        if ok_flake8 then
          table.insert(sources, flake8)
        elseif null_ls.builtins.diagnostics.flake8 then
          table.insert(sources, null_ls.builtins.diagnostics.flake8)
        end
      end
      null_ls.setup({
        sources = sources,
      })
    end,
  },

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
      local purple = "#a77fd9"
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
              folder_arrow = false,
              git = true,
            },
            glyphs = {
              folder = {
                arrow_closed = "",
                arrow_open = "",
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
      
      -- Set custom colors for nvim-tree (dimmer purple)
      local purple = "#a77fd9"
      local hl = vim.api.nvim_set_hl
      hl(0, "NvimTreeFolderIcon", { fg = purple })
      hl(0, "NvimTreeFolderName", { fg = purple })
      hl(0, "NvimTreeRootFolder", { fg = purple })
      hl(0, "NvimTreeOpenedFolderName", { fg = purple })
      hl(0, "NvimTreeEmptyFolderName", { fg = purple })
      hl(0, "NvimTreeSymlink", { fg = purple })
    end,
  },

  -- Editing Helpers
  { "windwp/nvim-autopairs", event = "InsertEnter" },
  { "echasnovski/mini.surround", event = "VeryLazy" },
  { "junegunn/vim-after-object", event = "VeryLazy" },
  { "lukas-reineke/indent-blankline.nvim", event = { "BufReadPost", "BufNewFile" } },
  { "Vimjas/vim-python-pep8-indent", ft = "python" },

  -- LuaSnip
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
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  local servers = {
    pyright = {
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            autoImportCompletions = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "openFilesOnly",
          },
        },
      },
    },
    lua_ls = {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
    },
    jsonls = {},
    yamlls = {},
    ts_ls = {},
    bashls = {},
  }

  local ok_new = pcall(function()
    for name, cfg in pairs(servers) do
      cfg.capabilities = capabilities
      vim.lsp.config(name, cfg)
    end
    vim.lsp.enable(vim.tbl_keys(servers))
  end)

  if not ok_new then
    local lspconfig = require("lspconfig")
    for name, cfg in pairs(servers) do
      cfg.capabilities = capabilities
      lspconfig[name].setup(cfg)
    end
  end
end

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

setup_lsp()
vim.defer_fn(trigger_lsp_deps_check, 200)
