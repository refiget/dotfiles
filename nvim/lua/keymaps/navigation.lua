local keymap = vim.keymap.set
local opts = { silent = true }

keymap("n", "<leader>e", function()
  local ok, api = pcall(require, "nvim-tree.api")
  if not ok then
    vim.notify("nvim-tree 未安装或加载失败", vim.log.levels.WARN, { title = "nvim-tree" })
    return
  end
  api.tree.toggle({ find_file = true, focus = true })
end, { silent = true, noremap = true, desc = "Toggle file explorer" })

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
