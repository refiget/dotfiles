return {
  {
    "GCBallesteros/NotebookNavigator.nvim",
    ft = { "python" },
    config = function()
      local nn = require("notebook-navigator")
      local utils = require("notebook-navigator.utils")
      local jtext_ok, jtext = pcall(require, "keymaps.jtext")

      utils.available_repls = { "no_repl" }

      nn.setup({
        repl_provider = "no_repl",
        cell_markers = { python = "# %%" },
        activate_hydra_keys = nil,
        syntax_highlight = false,
      })

      local group = vim.api.nvim_create_augroup("NotebookNavigatorKeys", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "python",
        callback = function()
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

          local function toggle_markdown_cell()
            local marker = utils.get_cell_marker(0, nn.config.cell_markers)
            local cell = current_cell(marker)
            if not cell then
              return
            end

            local start_line = cell[1]
            local end_line = cell[2]

            local marker_line = get_marker_line(start_line)
            local has_marker = marker_line and marker_line:match("^%s*" .. vim.pesc(marker))
            local is_markdown = is_markdown_marker(marker_line)

            if is_markdown then
              -- convert markdown -> code
              if has_marker then
                vim.api.nvim_buf_set_lines(0, start_line - 2, start_line - 1, false, { marker })
              end
              local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
              for i, line in ipairs(lines) do
                if line:match("^%s*#%s") then
                  lines[i] = line:gsub("^%s*#%s?", "", 1)
                elseif line:match("^%s*#") then
                  lines[i] = line:gsub("^%s*#", "", 1)
                end
              end
              vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
              if jtext_ok then
                jtext.sync_current_py({ notify = false })
              end
              return
            end

            -- convert code -> markdown
            if has_marker then
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
              else
                lines[i] = "# " .. line
              end
            end
            vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
            if jtext_ok then
              jtext.sync_current_py({ notify = false })
            end
          end

          local function move_n(dir, count)
            for _ = 1, count do
              nn.move_cell(dir)
            end
            if jtext_ok then
              jtext.sync_current_py({ notify = false })
            end
          end

          vim.keymap.set("n", "<localleader>j", function()
            nn.move_cell("d")
            if jtext_ok then
              jtext.sync_current_py({ notify = false })
            end
          end, { buffer = true, silent = true, desc = "Notebook: next cell" })

          vim.keymap.set("n", "<localleader>k", function()
            nn.move_cell("u")
            if jtext_ok then
              jtext.sync_current_py({ notify = false })
            end
          end, { buffer = true, silent = true, desc = "Notebook: previous cell" })

          vim.keymap.set("n", "<localleader>J", function()
            move_n("d", 5)
          end, { buffer = true, silent = true, desc = "Notebook: next 5 cells" })

          vim.keymap.set("n", "<localleader>K", function()
            move_n("u", 5)
          end, { buffer = true, silent = true, desc = "Notebook: previous 5 cells" })

          vim.keymap.set("n", "<localleader>m", toggle_markdown_cell,
            { buffer = true, silent = true, desc = "Notebook: toggle markdown" })

          vim.keymap.set("n", "<localleader>[", function()
            nn.add_cell_above()
            if jtext_ok then
              jtext.sync_current_py({ notify = false })
            end
          end, { buffer = true, silent = true, desc = "Notebook: add cell above" })
          vim.keymap.set("n", "<localleader>]", function()
            nn.add_cell_below()
            if jtext_ok then
              jtext.sync_current_py({ notify = false })
            end
          end, { buffer = true, silent = true, desc = "Notebook: add cell below" })
        end,
      })
    end,
  },
}
