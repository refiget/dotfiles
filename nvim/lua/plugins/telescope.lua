-- Telescope search paths (edit only the list below)
-- ```json
-- {
--   "telescope_search_paths": [
--     "~/Projects",
--     "~/dotfiles"
--   ]
-- }
-- ```
local TELESCOPE_SEARCH_PATHS = {
  "~/Projects",
  "~/dotfiles",
	"~/ml",
}

vim.g.telescope_search_paths = TELESCOPE_SEARCH_PATHS
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>w",
        function()
          local ok, builtin = pcall(require, "telescope.builtin")
          if not ok then
            vim.notify("Telescope 未安装或加载失败", vim.log.levels.WARN, { title = "Telescope" })
            return
          end

          -- Optional: set vim.g.telescope_search_paths as a comma-separated string or a list.
          local function get_search_dirs()
            local custom = vim.g.telescope_search_paths
            if type(custom) == "string" then
              custom = vim.split(custom, ",", { plain = true, trimempty = true })
            end
            if type(custom) ~= "table" or #custom == 0 then
              return { vim.fn.expand("~/Projects"), vim.fn.expand("~/dotfiles") }
            end
            local dirs = {}
            for _, p in ipairs(custom) do
              if type(p) == "string" and p ~= "" then
                table.insert(dirs, vim.fn.expand(p))
              end
            end
            return #dirs > 0 and dirs or { vim.fn.expand("~/Projects"), vim.fn.expand("~/dotfiles") }
          end

          builtin.find_files({
            search_dirs = get_search_dirs(),
            hidden = true,
            attach_mappings = function(prompt_bufnr, map)
              local actions = require("telescope.actions")
              local action_state = require("telescope.actions.state")

              local function open_path(cmd)
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection and selection.path then
                  vim.cmd({ cmd = cmd, args = { selection.path } })
                end
              end

              map({ "i", "n" }, "<CR>", function()
                open_path("tabe")
              end)

              map({ "i", "n" }, "<C-v>", function()
                open_path("vsplit")
              end)

              map({ "i", "n" }, "<C-x>", function()
                open_path("split")
              end)

              return true
            end,
          })
        end,
        desc = "Telescope: find file in Projects + dotfiles (open in new tab)",
        mode = "n",
      },
      {
        "<leader>g",
        function()
          local ok, builtin = pcall(require, "telescope.builtin")
          if not ok then
            vim.notify("Telescope 未安装或加载失败", vim.log.levels.WARN, { title = "Telescope" })
            return
          end

          local function get_search_dirs()
            local custom = vim.g.telescope_search_paths
            if type(custom) == "string" then
              custom = vim.split(custom, ",", { plain = true, trimempty = true })
            end
            if type(custom) ~= "table" or #custom == 0 then
              return { vim.fn.expand("~/Projects"), vim.fn.expand("~/dotfiles") }
            end
            local dirs = {}
            for _, p in ipairs(custom) do
              if type(p) == "string" and p ~= "" then
                table.insert(dirs, vim.fn.expand(p))
              end
            end
            return #dirs > 0 and dirs or { vim.fn.expand("~/Projects"), vim.fn.expand("~/dotfiles") }
          end

          builtin.live_grep({
            search_dirs = get_search_dirs(),
            additional_args = function()
              return { "--hidden", "--glob", "!.git/*" }
            end,
          })
        end,
        desc = "Telescope: live grep in Projects + dotfiles",
        mode = "n",
      },
    },
    config = function()
      local ok, telescope = pcall(require, "telescope")
      if not ok then
        return
      end

      local function normalize_paths(paths)
        local result = {}
        local seen = {}
        for _, p in ipairs(paths) do
          if type(p) == "string" and p ~= "" then
            local expanded = vim.fn.expand(p)
            if not seen[expanded] then
              seen[expanded] = true
              table.insert(result, expanded)
            end
          end
        end
        return result
      end

      local function ensure_paths()
        local current = vim.g.telescope_search_paths
        if type(current) == "string" then
          current = vim.split(current, ",", { plain = true, trimempty = true })
        end
        if type(current) ~= "table" then
          current = {}
        end
        vim.g.telescope_search_paths = current
      end

      vim.api.nvim_create_user_command("TelescopeAddPath", function(opts)
        ensure_paths()
        local input = opts.args
        if input == "" then
          input = vim.fn.input("Add search path(s), comma-separated: ")
        end
        if input == "" then
          return
        end
        local paths = vim.split(input, ",", { plain = true, trimempty = true })
        for i, p in ipairs(paths) do
          paths[i] = vim.fn.trim(p)
        end
        vim.g.telescope_search_paths = normalize_paths(vim.list_extend(vim.g.telescope_search_paths, paths))
      end, { nargs = "*", desc = "Telescope: add search path(s)" })

      vim.api.nvim_create_user_command("TelescopeListPaths", function()
        ensure_paths()
        if #vim.g.telescope_search_paths == 0 then
          vim.notify("Telescope search paths: (empty)", vim.log.levels.INFO)
          return
        end
        vim.notify("Telescope search paths:\n" .. table.concat(vim.g.telescope_search_paths, "\n"), vim.log.levels.INFO)
      end, { nargs = 0, desc = "Telescope: list search paths" })

      vim.api.nvim_create_user_command("TelescopeClearPaths", function()
        vim.g.telescope_search_paths = {}
      end, { nargs = 0, desc = "Telescope: clear search paths" })

      telescope.setup({
        defaults = {
          -- Premium centered layout, consistent with Noice/cmp popups
          layout_strategy = "vertical",
          layout_config = {
            width = 0.62,
            height = 0.62,
            prompt_position = "top",
            preview_cutoff = 120,
          },
          sorting_strategy = "ascending",
          border = true,
          borderchars = {
            prompt = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
            preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          },
          winblend = 10,
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
