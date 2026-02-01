return {
  {
    "benlubas/molten-nvim",
    ft = { "python" },
    dependencies = {
      "3rd/image.nvim",
    },
    -- Remote plugin: after install/update you must run :UpdateRemotePlugins + restart
    build = ":UpdateRemotePlugins",

    -- Set globals BEFORE Molten initializes (remote plugin caches options)
    init = function()
      -- image provider
      vim.g.molten_image_provider = "image.nvim"

      -- output behavior (pick what you like)
      vim.g.molten_output_win_max_height = 30
      vim.g.molten_auto_open_output = true
      vim.g.molten_virt_text_output = false

      -- Optional: reduce lag / make UI snappier
      -- vim.g.molten_tick_rate = 200
    end,

    config = function()
      local keymap = vim.keymap.set
      local opts = { silent = true }

      -- 1) Init kernel (auto venv/conda)
      keymap("n", "<localleader>r", function()
        local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
        if venv then
          local name = venv:match("([^/]+)$")
          vim.cmd("MoltenInit " .. name)
        else
          vim.cmd("MoltenInit python3")
        end
      end, vim.tbl_extend("force", opts, { desc = "Molten: init kernel" }))

      -- 2) Run code
      keymap("n", "<localleader>e", ":MoltenEvaluateOperator<CR>",
        vim.tbl_extend("force", opts, { desc = "Molten: eval operator / cell" }))
      keymap("v", "<localleader>e", ":<C-u>MoltenEvaluateVisual<CR>gv",
        vim.tbl_extend("force", opts, { desc = "Molten: eval selection" }))
      keymap("n", "<localleader>E", ":MoltenEvaluateBuffer<CR>",
        vim.tbl_extend("force", opts, { desc = "Molten: eval buffer" }))

      -- 3) Output helpers
      keymap("n", "<localleader>o", ":MoltenShowOutput<CR>",
        vim.tbl_extend("force", opts, { desc = "Molten: show output" }))
      keymap("n", "<localleader>d", ":MoltenDelete<CR>",
        vim.tbl_extend("force", opts, { desc = "Molten: delete cell (cursor)" }))

      -- (Optional, README-style) attach extra buffer-local mappings after MoltenInit
      -- This mirrors the README suggestion using the MoltenInitPost user autocmd.  [oai_citation:3‡GitHub](https://github.com/benlubas/molten-nvim)
      vim.api.nvim_create_autocmd("User", {
        pattern = "MoltenInitPost",
        callback = function()
          -- buffer-local example: run line under cursor quickly
          vim.keymap.set("n", "<localleader>l", ":MoltenEvaluateLine<CR>",
            { buffer = true, silent = true, desc = "Molten: eval line" })
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MoltenInitPost",
        callback = function()
          vim.cmd([[
python3 << 'PY'
try:
    import molten.moltenbuffer as mb
except Exception:
    mb = None

if mb is not None and not getattr(mb.MoltenKernel.update_interface, "_show_done_patch", False):
    _orig_update_interface = mb.MoltenKernel.update_interface

    def _patched_update_interface(self):
        _orig_update_interface(self)
        if self.options.virt_text_output:
            return
        if self.selected_cell is None:
            return
        if not self.should_show_floating_win:
            return
        if self.selected_cell in self.outputs:
            self.outputs[self.selected_cell].show_floating_win(self.selected_cell.end)

    _patched_update_interface._show_done_patch = True
    mb.MoltenKernel.update_interface = _patched_update_interface
PY
          ]])
        end,
      })
    end,
  },
}
