return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPost", "BufNewFile" },
  main = "ibl",
  config = function()
    local ok, ibl = pcall(require, "ibl")
    if not ok then
      return
    end

    ibl.setup({
      indent = {
        char = "│",
        highlight = { "IblIndent" },
      },
      whitespace = {
        remove_blankline_trail = false,
        highlight = { "IblWhitespace" },
      },
      scope = {
        enabled = true,
        char = "│",
        highlight = { "IblScope" },
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
        },
      },
    })
  end,
}
