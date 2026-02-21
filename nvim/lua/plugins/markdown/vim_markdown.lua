-- preservim/vim-markdown

return {
  "preservim/vim-markdown",
  ft = "markdown",
  dependencies = { "godlygeek/tabular" },
  config = function()
    vim.g.vim_markdown_auto_insert_bullets = 1
    vim.g.vim_markdown_conceal = 1
    vim.g.vim_markdown_conceal_code_blocks = 0
    vim.g.vim_markdown_folding = 1
    vim.g.vim_markdown_heading_anchors = 1
    vim.g.vim_markdown_toc_autofit = 1
    vim.g.vim_markdown_frontmatter = 1
    vim.g.vim_markdown_strikethrough = 1
    vim.g.vim_markdown_url_inline = 1
  end,
}
