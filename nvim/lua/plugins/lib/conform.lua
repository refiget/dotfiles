-- ===================== conform.lua =====================
-- Opinionated formatting: prefer dedicated formatters when available.
-- Conform is the single formatting entrypoint (no LSP formatting fallback).

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
    return { timeout_ms = 2000, lsp_fallback = false }
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
    conform.format({ async = true, lsp_fallback = false })
  end,
  { silent = true, noremap = true, desc = "Format (conform)" }
)
