-- Root plugin spec entry.
-- We keep one-plugin-per-file under categorized subdirectories.

return {
  { import = "plugins.ui" },
  { import = "plugins.nav" },
  { import = "plugins.editor" },
  { import = "plugins.completion" },
  { import = "plugins.lsp" },
  { import = "plugins.tooling" },
  { import = "plugins.treesitter" },
  { import = "plugins.git" },
  { import = "plugins.markdown" },
  { import = "plugins.debug" },
}
