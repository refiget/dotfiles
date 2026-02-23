-- kamykn/spelunker.vim

return {
  "kamykn/spelunker.vim",
  ft = { "markdown", "text" },
  config = function()
    vim.g.spelunker_check_type = 2
    vim.g.spelunker_highlight_type = 2
    vim.g.spelunker_enable_word_check = 1
    vim.g.spelunker_ignore_patterns = {
      [[`[^`]+`]],
      [[```.*```]],
    }

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "text" },
      callback = function()
        vim.opt_local.spell = true
      end,
    })
  end,
}
