local fn = vim.fn


-- ===================== Plugin Section =====================
vim.cmd([[
call plug#begin('$HOME/.config/nvim/plugged')

" LSP / Completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'fannheyward/coc-pyright'

" Modern Markdown renderer
Plug 'MeanderingProgrammer/render-markdown.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-tree/nvim-web-devicons'
		
" === Appearance ===
Plug 'theniceboy/nvim-deus'
Plug 'petertriho/nvim-scrollbar'
Plug 'HiPhish/rainbow-delimiters.nvim'
Plug 'theniceboy/eleline.vim'
Plug 'RRethy/vim-illuminate'
Plug 'NvChad/nvim-colorizer.lua'
Plug 'kevinhwang91/nvim-hlslens'
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
Plug 'nvim-tree/nvim-web-devicons'


" === Telescope  ===
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'


" === Editing Helpers ===
Plug 'windwp/nvim-autopairs'
Plug 'echasnovski/mini.surround'
Plug 'junegunn/vim-after-object'
Plug 'godlygeek/tabular'
Plug 'junegunn/goyo.vim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'dkarter/bullets.vim'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'mzlogin/vim-markdown-toc'
Plug 'dhruvasagar/vim-table-mode'

" === Jupyter / Markdown ===
Plug 'goerz/jupytext.vim'
Plug 'dccsillag/magma-nvim'
Plug 'iamcco/markdown-preview.nvim'

" === LuaSnip ===
Plug 'L3MON4D3/LuaSnip'
Plug 'rafamadriz/friendly-snippets'

call plug#end()
]])

-- 自动检查关键插件是否缺失（类似 PlugInstall），缺失时自动运行 PlugInstall --sync
local function ensure_core_plugins()
  local plug_home = fn.expand("$HOME/.config/nvim/plugged")
  local required = { "coc.nvim", "coc-pyright", "telescope.nvim", "plenary.nvim" }
  local missing = {}
  for _, name in ipairs(required) do
    if fn.empty(fn.glob(plug_home .. "/" .. name)) == 1 then
      table.insert(missing, name)
    end
  end
  if #missing > 0 then
    vim.schedule(function()
      vim.notify(
        "检测到缺少插件: " .. table.concat(missing, ", ") .. "，将自动执行 :PlugInstall --sync",
        vim.log.levels.WARN,
        { title = "Plugin install" }
      )
      vim.cmd("silent! PlugInstall --sync")
    end)
  end
end

-- CoC 依赖检查：Node、npm/pnpm/yarn、python3 host
local function check_coc_deps()
  local warns = {}

  local function has_exec(bin)
    return fn.executable(bin) == 1
  end

  if not has_exec("node") then
    table.insert(warns, "未检测到 node，请安装 nodejs（Arch: pacman -S nodejs npm；macOS: brew install node）")
  else
    local ok, out = pcall(fn.systemlist, { "node", "-v" })
    if ok and out and out[1] then
      local major = tonumber((out[1]:match("v(%d+)") or "0"))
      if major < 14 then
        table.insert(warns, "Node 版本过低(" .. out[1] .. ")，建议 >=16 以保证 coc 稳定")
      end
    end
  end

  if not (has_exec("npm") or has_exec("pnpm") or has_exec("yarn")) then
    table.insert(warns, "未检测到 npm/pnpm/yarn，无法安装/更新 coc 扩展（Arch: pacman -S npm；macOS: brew install node）")
  end

  local host = vim.g.python3_host_prog or "python3"
  if fn.executable(host) ~= 1 then
    table.insert(warns, "未检测到 python3 host (" .. host .. ")，请安装对应解释器（Arch: pacman -S python；macOS: brew install python）")
  end

  if #warns > 0 then
    vim.schedule(function()
      vim.notify(table.concat(warns, "\n"), vim.log.levels.WARN, { title = "CoC 依赖检查" })
    end)
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    ensure_core_plugins()
    check_coc_deps()
  end,
})

-- ===================== Telescope =====================
pcall(function()
  local telescope = require("telescope")
  telescope.setup({
    defaults = {
      -- 轻量一点的按键，不和你现有习惯冲突
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
end)
-- ===================== UI / Appearance =====================

vim.opt.termguicolors = true
vim.cmd("silent! colorscheme deus")

vim.api.nvim_set_hl(0, "NonText", { fg = "grey10" })
vim.g.rainbow_active = 1
vim.g.Illuminate_delay = 750
vim.api.nvim_set_hl(0, "illuminatedWord", { undercurl = true })

vim.g.lightline = {
  active = {
    left = {
      { 'mode', 'paste' },
      { 'readonly', 'filename', 'modified' },
    },
  },
}

-- ===================== Plugin Configurations =====================

pcall(function()
  require("scrollbar").setup()
  require("scrollbar.handlers.search").setup()
end)

pcall(function()
  require("colorizer").setup({
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
end)

vim.g.bullets_enabled_file_types = { 'markdown', 'text', 'gitcommit' }
vim.g.bullets_auto_indent_after_enter = 1

vim.g.vmt_cycle_list_item_markers = 1
vim.g.vmt_fence_text = 'TOC'
vim.g.vmt_fence_closing_text = '/TOC'

vim.g.instant_markdown_slow = 0
vim.g.instant_markdown_autostart = 0
vim.g.instant_markdown_autoscroll = 1

vim.keymap.set("n", "<leader>tm", ":TableModeToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>gy", ":Goyo<CR>", { noremap = true, silent = true })
vim.keymap.set("v", "ga", ":Tabularize /", { noremap = true })

-- ===================== Final tweaks =====================
vim.opt.re = 0
vim.cmd("nohlsearch")
vim.g.eleline_colorscheme = 'deus'
vim.g.eleline_powerline_fonts = 1


-- =============================
-- Safe rainbow delimiter colors
-- =============================
local soft = "#88c0a0"   -- 散光友好颜色

vim.g.rainbow_conf = {
  guifgs = {
    "#ff5555",  -- red
    "#f1fa8c",  -- yellow
    soft,       -- blue → 柔和青绿
    "#bd93f9",  -- purple
    "#50fa7b",  -- green
  },
  ctermfgs = { "Red", "Yellow", "Green", "Cyan", "Magenta" },
}

-- render-markdown.nvim config
pcall(function()
  require("render-markdown").setup({
    -- 默认配置就很好看，你可以以后再改主题
  })
end)

pcall(function()
  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "lua","vim","markdown","markdown_inline","python","json","bash","javascript","c"
    },
    highlight = { enable = true },
    indent = { enable = true },
  })
end)
-- ========================
-- Bufferline (Beautiful Tabs)
-- ========================
pcall(function()
  require("bufferline").setup({
    options = {
      numbers = "ordinal",
      diagnostics = "coc",   -- 你用 coc.nvim，所以这里用 coc
      separator_style = "slant", -- "slant" | "padded_slant" | "thick" | "thin"
      show_close_icon = false,
      show_buffer_close_icons = false,
      color_icons = true,
      always_show_bufferline = true,
    }
  })
end)
