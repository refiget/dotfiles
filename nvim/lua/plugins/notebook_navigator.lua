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
          local utils = require("notebook-navigator.utils")
          local get_repl = require("notebook-navigator.repls")

          local function guard(fn)
            if not molten_ready() then
              vim.notify("Molten commands not available. Run :UpdateRemotePlugins and restart Neovim.",
                vim.log.levels.WARN)
              return
            end
            fn()
          end

          local function collect_cells(marker)
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local cells = {}
            local start_line = 1
            local pat = "^%s*" .. vim.pesc(marker)

            for i, line in ipairs(lines) do
              if line:match(pat) then
                local end_line = i - 1
                if start_line <= end_line then
                  table.insert(cells, { start_line, end_line })
                end
                start_line = i + 1
              end
            end

            if start_line <= #lines then
              table.insert(cells, { start_line, #lines })
            end

            return cells
          end

          local function get_marker_line(start_line)
            if start_line <= 1 then
              return nil
            end
            return vim.api.nvim_buf_get_lines(0, start_line - 2, start_line - 1, false)[1]
          end

          local function is_markdown_marker(line)
            if not line then
              return false
            end
            local lower = line:lower()
            return lower:find("%[markdown%]") or lower:find("%[md%]")
          end

          local function is_markdown_cell(start_line)
            return is_markdown_marker(get_marker_line(start_line))
          end

          local function current_cell(marker)
            local cells = collect_cells(marker)
            if #cells == 0 then
              return nil
            end
            local cur = vim.api.nvim_win_get_cursor(0)[1]
            for _, cell in ipairs(cells) do
              if cur >= cell[1] and cur <= cell[2] then
                return cell
              end
              if cur == cell[1] - 1 then
                return cell
              end
              if cur < cell[1] then
                return cell
              end
            end
            return cells[#cells]
          end

          local function init_kernel()
            local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
            if venv then
              local name = venv:match("([^/]+)$")
              vim.cmd("MoltenInit " .. name)
            else
              vim.cmd("MoltenInit python3")
            end
          end

          local function run_all_cells()
            local marker = utils.get_cell_marker(0, nn.config.cell_markers)
            local cells = collect_cells(marker)
            if #cells == 0 then
              return
            end

            local function run_cells(last_index)
              local last = last_index or #cells
              for i = 1, last do
                local cell = cells[i]
                if not is_markdown_cell(cell[1]) then
                  pcall(vim.fn.MoltenEvaluateRange, cell[1], cell[2])
                end
              end
            end

            local ok, kernels = pcall(vim.fn.MoltenRunningKernels, true)
            local has_kernel = ok and type(kernels) == "table" and #kernels > 0

            vim.api.nvim_create_autocmd("User", {
              pattern = "MoltenKernelReady",
              once = true,
              callback = function()
                run_cells()
              end,
            })

            if has_kernel then
              pcall(vim.cmd, "MoltenRestart!")
            else
              init_kernel()
            end
          end

          local function run_to_current_cell()
            local marker = utils.get_cell_marker(0, nn.config.cell_markers)
            local cells = collect_cells(marker)
            if #cells == 0 then
              return
            end

            local curline = vim.api.nvim_win_get_cursor(0)[1]
            local target = nil
            for i, cell in ipairs(cells) do
              if curline >= cell[1] and curline <= cell[2] then
                target = i
                break
              end
              if curline < cell[1] then
                target = i
                break
              end
            end
            if not target then
              target = #cells
            end

            while target > 0 and is_markdown_cell(cells[target][1]) do
              target = target - 1
            end
            if target == 0 then
              return
            end

            local function run_cells()
              for i = 1, target do
                local cell = cells[i]
                if not is_markdown_cell(cell[1]) then
                  pcall(vim.fn.MoltenEvaluateRange, cell[1], cell[2])
                end
              end
            end

            local ok, kernels = pcall(vim.fn.MoltenRunningKernels, true)
            local has_kernel = ok and type(kernels) == "table" and #kernels > 0

            vim.api.nvim_create_autocmd("User", {
              pattern = "MoltenKernelReady",
              once = true,
              callback = function()
                run_cells()
              end,
            })

            if has_kernel then
              pcall(vim.cmd, "MoltenRestart!")
            else
              init_kernel()
            end
          end

          local function run_cell_if_code()
            local marker = utils.get_cell_marker(0, nn.config.cell_markers)
            local cell = current_cell(marker)
            if not cell then
              return
            end
            if is_markdown_cell(cell[1]) then
              return
            end
            nn.run_cell()
          end

          local function run_and_move_if_code()
            local marker = utils.get_cell_marker(0, nn.config.cell_markers)
            local cell = current_cell(marker)
            if not cell then
              return
            end
            if is_markdown_cell(cell[1]) then
              nn.move_cell("d")
              return
            end
            nn.run_and_move()
          end

          local function mark_markdown_cell()
            local marker = utils.get_cell_marker(0, nn.config.cell_markers)
            local cell = current_cell(marker)
            if not cell then
              return
            end

            local start_line = cell[1]
            local end_line = cell[2]

            local marker_line = get_marker_line(start_line)
            if marker_line and marker_line:match("^%s*" .. vim.pesc(marker)) then
              vim.api.nvim_buf_set_lines(0, start_line - 2, start_line - 1, false, { marker .. " [markdown]" })
            else
              vim.api.nvim_buf_set_lines(0, start_line - 1, start_line - 1, false, { marker .. " [markdown]" })
              start_line = start_line + 1
              end_line = end_line + 1
            end

            local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
            for i, line in ipairs(lines) do
              if line == "" then
                lines[i] = "#"
              elseif line:match("^%s*#") then
                lines[i] = line
              else
                lines[i] = "# " .. line
              end
            end
            vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
          end

          vim.keymap.set("n", "<localleader>r", function()
            guard(run_cell_if_code)
          end, { buffer = true, silent = true, desc = "Notebook: run cell" })

          vim.keymap.set("n", "<localleader>R", function()
            guard(run_all_cells)
          end, { buffer = true, silent = true, desc = "Notebook: run all cells" })

          vim.keymap.set("n", "<localleader>c", function()
            guard(run_and_move_if_code)
          end, { buffer = true, silent = true, desc = "Notebook: run cell and move" })

          vim.keymap.set("n", "<localleader>j", nn.add_cell_below,
            { buffer = true, silent = true, desc = "Notebook: add cell below" })
          vim.keymap.set("n", "<localleader>k", nn.add_cell_above,
            { buffer = true, silent = true, desc = "Notebook: add cell above" })

          vim.keymap.set("n", "<localleader>m", function()
            guard(mark_markdown_cell)
          end, { buffer = true, silent = true, desc = "Notebook: mark cell as markdown" })

          vim.keymap.set("n", "<localleader>z", function()
            guard(function()
              pcall(vim.cmd, "MoltenDelete")
            end)
          end, { buffer = true, silent = true, desc = "Notebook: clear current cell output" })

          vim.keymap.set("n", "<localleader>Z", function()
            guard(function()
              pcall(vim.cmd, "MoltenDelete!")
            end)
          end, { buffer = true, silent = true, desc = "Notebook: clear all outputs" })

          vim.keymap.set("n", "<localleader>u", function()
            guard(run_to_current_cell)
          end, { buffer = true, silent = true, desc = "Notebook: clear + run to current cell" })

          vim.keymap.set("n", "<localleader>[", function()
            nn.move_cell("u")
          end, { buffer = true, silent = true, desc = "Notebook: previous cell" })
          vim.keymap.set("n", "<localleader>]", function()
            nn.move_cell("d")
          end, { buffer = true, silent = true, desc = "Notebook: next cell" })
        end,
      })
    end,
  },
}
