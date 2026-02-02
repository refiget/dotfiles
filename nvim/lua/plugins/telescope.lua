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

          local projects = vim.fn.expand("~/Projects")
          local dotfiles = vim.fn.expand("~/dotfiles")

          builtin.find_files({
            search_dirs = { projects, dotfiles },
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
    },
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
