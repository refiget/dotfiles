vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    vim.bo.autoindent = true
    vim.bo.smartindent = true
    vim.bo.cindent = true
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
    vim.bo.expandtab = true

    vim.schedule(function()
      if vim.bo.filetype == "java" then
        vim.bo.indentexpr = ""
      end
    end)
  end,
})
