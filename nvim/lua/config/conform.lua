-- ===================== conform.lua =====================
-- Opinionated formatting: prefer dedicated formatters when available.
-- Falls back to LSP formatting when no external formatter is configured.

local ok, conform = pcall(require, "conform")
if not ok then
  return
end

conform.setup({
  notify_on_error = false,
  format_on_save = function(bufnr)
    -- Disable auto format on very large files
    local max = 200 * 1024
    local ok_stat, stat = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
    if ok_stat and stat and stat.size and stat.size > max then
      return
    end
    return { timeout_ms = 1500, lsp_fallback = true }
  end,
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "black" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
  },
})

-- Unified format key
vim.keymap.set(
  "n",
  "<leader>f",
  function()
    conform.format({ async = true, lsp_fallback = true })
  end,
  { silent = true, noremap = true, desc = "Format (conform, fallback to LSP)" }
)
