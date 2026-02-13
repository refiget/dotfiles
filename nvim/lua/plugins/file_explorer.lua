return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function()
      local ok, nvim_tree = pcall(require, "nvim-tree")
      if not ok then
        vim.notify("nvim-tree 加载失败", vim.log.levels.ERROR, { title = "插件加载" })
        return
      end
      nvim_tree.setup({
        auto_reload_on_write = true,
        disable_netrw = true,
        hijack_netrw = true,
        hijack_cursor = true,
        update_cwd = true,
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        diagnostics = {
          enable = true,
          show_on_dirs = true,
        },
        git = {
          enable = true,
          ignore = false,
        },
        filters = {
          dotfiles = true,
        },
        actions = {
          open_file = {
            quit_on_open = false,
          },
        },
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          indent_markers = {
            enable = true,
          },
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = false,
              git = true,
            },
            glyphs = {
              folder = {
                arrow_closed = "",
                arrow_open = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
              },
            },
          },
        },
      })
      
      local ok_api, api = pcall(require, "nvim-tree.api")
      if ok_api then
        vim.api.nvim_create_autocmd("BufEnter", {
          pattern = "NvimTree_*",
          callback = function()
            local buf = vim.api.nvim_get_current_buf()
            local function opts(desc)
              return {
                desc = "nvim-tree: " .. desc,
                buffer = buf,
                noremap = true,
                silent = true,
                nowait = true,
              }
            end
            
            vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
            vim.keymap.set("n", "l", api.node.open.vertical, opts("Open in Vertical Split"))
            vim.keymap.set("n", "<CR>", api.node.open.vertical, opts("Open in Vertical Split"))
            vim.keymap.set("n", "q", api.tree.close, opts("Close"))
          end,
        })
      end
      
      -- Align nvim-tree palette with Yazi (folder icons are blue in your Yazi theme)
      local yazi_folder_blue = "#00ABF1" -- match Yazi directory icon color
      local dracula_fg = "#f8f8f2"
      local hl = vim.api.nvim_set_hl

      local function apply_tree_hl()
        hl(0, "NvimTreeFolderIcon", { fg = yazi_folder_blue })
        hl(0, "NvimTreeFolderName", { fg = yazi_folder_blue })
        hl(0, "NvimTreeRootFolder", { fg = yazi_folder_blue, bold = true })
        hl(0, "NvimTreeOpenedFolderName", { fg = yazi_folder_blue, bold = true })
        hl(0, "NvimTreeEmptyFolderName", { fg = yazi_folder_blue })
        hl(0, "NvimTreeSymlink", { fg = yazi_folder_blue })
        hl(0, "NvimTreeNormal", { fg = dracula_fg })
        hl(0, "NvimTreeNormalNC", { fg = dracula_fg })
      end

      apply_tree_hl()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = apply_tree_hl,
      })
    end,
  },
}
