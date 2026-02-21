-- telescope.nvim

return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },

  --  ____  _               _             _
  -- / ___|| |__   ___  ___| | _____ _ __| |_ ___
  -- \___ \| '_ \ / _ \/ __| |/ / _ \ '__| __/ __|
  --  ___) | | | |  __/ (__|   <  __/ |  | |_\__ \
  -- |____/|_| |_|\___|\___|_|\_\___|_|   \__|___/
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help" },
  },

  config = function()
    local ok, telescope = pcall(require, "telescope")
    if not ok then
      return
    end

    local function apply_telescope_hl()
      vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })
      vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
      vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
      vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })
    end

    apply_telescope_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        pcall(apply_telescope_hl)
      end,
    })

    telescope.setup({
      defaults = {
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      },
    })
  end,
}
