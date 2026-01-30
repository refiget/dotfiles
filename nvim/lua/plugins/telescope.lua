return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local ok, telescope = pcall(require, "telescope")
      if not ok then
        return
      end
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
            n = {
              ["j"] = "move_selection_next",
              ["k"] = "move_selection_previous",
            },
          },
        },
      })
    end,
  },
  { "nvim-lua/plenary.nvim" },
}
