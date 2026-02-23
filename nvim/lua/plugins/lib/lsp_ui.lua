local M = {}

M.lspsaga = {
  lightbulb = {
    enable = false,
    sign = false,
    virtual_text = false,
  },
  symbol_in_winbar = {
    enable = false,
  },
  ui = {
    border = "rounded",
  },
}

M.trouble = {}

local diag_signs = {
  [vim.diagnostic.severity.ERROR] = "●",
  [vim.diagnostic.severity.WARN] = "●",
  [vim.diagnostic.severity.INFO] = "·",
  [vim.diagnostic.severity.HINT] = "·",
}

M.diagnostics = {
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },
    spacing = 2,
    prefix = "·",
    format = function(d)
      local code = d.code and tostring(d.code) or ""
      local src = d.source and tostring(d.source) or ""
      local head = ""
      if code ~= "" and src ~= "" then
        head = string.format("[%s:%s] ", src, code)
      elseif src ~= "" then
        head = string.format("[%s] ", src)
      elseif code ~= "" then
        head = string.format("[%s] ", code)
      end

      local msg = (d.message or ""):gsub("\n", " ")
      local out = head .. msg
      local max = 80
      if #out > max then
        out = out:sub(1, max - 1) .. "…"
      end
      return out
    end,
  },
  signs = {
    text = diag_signs,
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
}

return M
