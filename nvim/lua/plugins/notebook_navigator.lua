return {
  {
    "GCBallesteros/NotebookNavigator.nvim",
    ft = { "python" },
    dependencies = {
      "benlubas/molten-nvim",
    },
    config = function()
      local nn = require("notebook-navigator")
      local function molten_ready()
        return vim.fn.exists(":MoltenEvaluateOperator") == 2
      end

      nn.setup({
        repl_provider = "molten",
        cell_markers = { python = "# %%" },
        activate_hydra_keys = nil,
        syntax_highlight = false,
      })

      local group = vim.api.nvim_create_augroup("NotebookNavigatorKeys", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "python",
        callback = function()
          vim.keymap.set("n", "<localleader>c", function()
            if not molten_ready() then
              vim.notify("Molten commands not available. Run :UpdateRemotePlugins and restart Neovim.",
                vim.log.levels.WARN)
              return
            end
            nn.run_cell()
          end, { buffer = true, silent = true, desc = "Notebook: run cell" })
        end,
      })
    end,
  },
}
