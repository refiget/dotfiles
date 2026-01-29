-- ===================== keymaps.lua =====================
vim.g.mapleader = " "
local keymap = vim.keymap.set
local opts = { silent = true }

-- Basic
keymap("n", ";", ":", { desc = "Command mode" })
keymap("n", "Q", ":q<CR>", opts)
keymap("n", "Y", '"+yy', opts)     -- 行复制到系统剪贴板
keymap("v", "Y", '"+y', opts)      -- 选区复制到系统剪贴板
keymap("n", "<leader><CR>", ":nohlsearch<CR>", opts)

-- Advanced
keymap("n", "J", "5j", opts)
keymap("n", "K", "5k", opts)

-- Insert-mode undo breakpoints for finer-grained undo
for _, key in ipairs({ ",", ".", "!", "?", ";", ":" }) do
  keymap("i", key, key .. "<C-g>u", opts)
end

-- Splits
keymap("n", "s", "<nop>")

keymap("n", "<leader>l", "<C-w>l", opts)
keymap("n", "<leader>k", "<C-w>k", opts)
keymap("n", "<leader>j", "<C-w>j", opts)
keymap("n", "<leader>h", "<C-w>h", opts)

-- File tree (nvim-tree) - Toggle open/close
keymap("n", "<leader>e", function()
  local ok, api = pcall(require, "nvim-tree.api")
  if not ok then
    vim.notify("nvim-tree 未安装或加载失败", vim.log.levels.WARN, { title = "nvim-tree" })
    return
  end
  -- Use built-in toggle function
  api.tree.toggle({ find_file = true, focus = true })
end, { silent = true, noremap = true, desc = "Toggle file explorer" })

-- Markdown preview (browser)
keymap("n", "<leader>mp", ":MarkdownPreview<CR>", { silent = true, noremap = true, desc = "Markdown preview" })
keymap("n", "<leader>mP", ":MarkdownPreviewStop<CR>", { silent = true, noremap = true, desc = "Markdown preview stop" })

-- Tabs: 原生 gt/gT，支持循环切换，数字前缀生效
local function tab_cycle(delta)
  local total = vim.fn.tabpagenr("$")
  if total <= 1 then
    return
  end
  local current = vim.fn.tabpagenr()
  local count = vim.v.count1
  local target = ((current - 1 + delta * count) % total) + 1
  vim.cmd("tabnext " .. target)
end

keymap("n", "gt", function()
  tab_cycle(1)
end, { silent = true, noremap = true, desc = "Tab next (wrap)" })

keymap("n", "gT", function()
  tab_cycle(-1)
end, { silent = true, noremap = true, desc = "Tab prev (wrap)" })


-- LSP format --
vim.keymap.set(
  "n",
  "<leader>f",
  function()
    vim.lsp.buf.format({ async = true })
  end,
  { silent = true, noremap = true, desc = "Format document with LSP" }
)
keymap("n", "cr", "<cmd>Lspsaga rename<CR>", { silent = true, desc = "Rename with LSP" })
-- Markdown + Wrap toggle
keymap("n", "<leader>sw", ":set wrap!<CR>", { desc = "Toggle wrap" })

-- LSP 相关快捷键 (使用 LSP Saga)
keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { silent = true, desc = "Go to definition" })
keymap("n", "gi", "<cmd>Lspsaga goto_implementation<CR>", { silent = true, desc = "Go to implementation" })
keymap("n", "gr", "<cmd>Lspsaga lsp_finder<CR>", { silent = true, desc = "Go to references" })
keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true, desc = "Show hover information" })
keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { silent = true, desc = "Code action" })
keymap("n", "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true, desc = "Show line diagnostics" })
keymap("n", "<leader>xx", "<cmd>TroubleToggle<CR>", { silent = true, desc = "Toggle trouble" })


-- Compile/Run
-- ii-0o-9i
-- Python-only Run
local function run_python()
  vim.cmd("w")  -- save file
  local file = vim.fn.expand("%")

  -- Use term but avoid split issues on SSH
  vim.cmd("botright 10split | term python3 " .. file)
end

-- Map to "r"
keymap("n", "r", run_python, { silent = true, desc = "Run Python file" })


-- Terminal
keymap("t", "<C-N>", "<C-\\><C-N>", opts)
-- ===================== Delete behavior enhancements =====================

-- ① d / D —— 正常删除（写入默认寄存器 "）
keymap({ "n", "x" }, "d", "d", opts)
keymap({ "n", "x" }, "D", "D", opts)

-- ② x / X —— 删一个字符，不污染寄存器（写入黑洞寄存器 "_）
keymap("n", "x", '"_x', opts)
keymap("n", "X", '"_X', opts)

-- ③ c / C —— 修改也不写入寄存器（防止干扰 y）
keymap("n", "c", '"_c', opts)
keymap("n", "C", '"_C', opts)
keymap("x", "c", '"_c', opts)
keymap("x", "C", '"_C', opts) 




-- ===================== Telescope: Projects + dotfiles 文件搜索 =====================
vim.keymap.set("n", "<leader>w", function()
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("Telescope 未安装或加载失败", vim.log.levels.WARN, { title = "Telescope" })
    return
  end

  local projects = vim.fn.expand("~/Projects")
  local dotfiles = vim.fn.expand("~/dotfiles")

  builtin.find_files({
    -- 同时在 Projects 和 dotfiles 里搜
    search_dirs = { projects, dotfiles },
    hidden = true,  -- 包含隐藏文件（.gitignore 之类）
    
    -- 添加这个配置，让文件在新标签页打开
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local function open_path(cmd)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection and selection.path then
          vim.cmd({ cmd = cmd, args = { selection.path } })
        end
      end

      -- 覆盖默认的打开方式，i/n 模式一致
      map({ "i", "n" }, "<CR>", function()
        open_path("tabe")
      end)
      
      -- 保持其他快捷键
      map({ "i", "n" }, "<C-v>", function()
        open_path("vsplit")
      end)
      
      map({ "i", "n" }, "<C-x>", function()
        open_path("split")
      end)
      
      return true
    end,
  })
end, { silent = true, noremap = true, desc = "Telescope: find file in Projects + dotfiles (open in new tab)" })
