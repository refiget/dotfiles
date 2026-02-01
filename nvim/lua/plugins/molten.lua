return {
  {
    "benlubas/molten-nvim",
    ft = { "python", "markdown", "quarto" },
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
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = true
      vim.g.molten_auto_close_output = true
      vim.g.molten_virt_text_output = false

      -- Optional: reduce lag / make UI snappier
      -- vim.g.molten_tick_rate = 200
    end,

    config = function()
      local keymap = vim.keymap.set
      local opts = { silent = true }

      local function molten_api_available()
        return vim.fn.exists("*MoltenEvaluateRange") == 1
      end

      local function find_cell_bounds()
        if vim.bo.filetype ~= "python" then
          return nil, nil, "Only python buffers are supported for # %% cells"
        end

        local row = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        local start_marker = nil
        for i = row, 1, -1 do
          if lines[i] and lines[i]:match("^%s*#%s*%%") then
            start_marker = i
            break
          end
        end

        if not start_marker then
          return nil, nil, "No # %% cell marker found above the cursor"
        end

        local next_marker = nil
        for i = start_marker + 1, #lines do
          if lines[i] and lines[i]:match("^%s*#%s*%%") then
            next_marker = i
            break
          end
        end

        local start_line = start_marker + 1
        local end_line = next_marker and (next_marker - 1) or #lines

        if start_line > end_line then
          return nil, nil, "Empty # %% cell"
        end

        return start_line, end_line, nil
      end

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
      keymap("n", "<localleader>c", function()
        if not molten_api_available() then
          vim.notify("Molten API not available. Run :UpdateRemotePlugins and restart Neovim.",
            vim.log.levels.ERROR)
          return
        end

        local start_line, end_line, err = find_cell_bounds()
        if not start_line then
          vim.notify(err, vim.log.levels.WARN)
          return
        end

        vim.fn.MoltenEvaluateRange(start_line, end_line)
      end, vim.tbl_extend("force", opts, { desc = "Molten: eval # %% cell" }))

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
    end,
  },
}
