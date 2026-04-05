return {
  {
    "folke/tokyonight.nvim",
    opts = {
      styles = {
        comments = { italic = true },
        keywords = { italic = false },
        functions = {},
        variables = {},
      },
      on_highlights = function(hl, _)
        -- 强制：只有注释斜体，其它常见组去掉斜体
        local no_italic = {
          "Keyword",
          "Conditional",
          "Repeat",
          "Exception",
          "Include",
          "PreProc",
          "StorageClass",
          "Typedef",
          "Type",
          "Function",
          "Identifier",
          "Statement",
        }
        for _, g in ipairs(no_italic) do
          hl[g] = vim.tbl_extend("force", hl[g] or {}, { italic = false })
        end

        hl.Comment = vim.tbl_extend("force", hl.Comment or {}, { italic = true })
      end,
    },
  },
}
