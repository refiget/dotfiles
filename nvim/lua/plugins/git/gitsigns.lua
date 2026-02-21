-- lewis6991/gitsigns.nvim

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local ok, gs = pcall(require, "gitsigns")
    if not ok then
      return
    end
    gs.setup({})
  end,
}
