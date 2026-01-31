return {
  {
    "hkupty/iron.nvim",
    event = "VeryLazy",
    config = function()
      local ok, iron = pcall(require, "iron")
      if not ok then
        return
      end
      
      iron.setup {
        config = {
          scratch_repl = true,
          repl_definition = {
            sh = {
              command = { "zsh" },
            },
            python = {
              command = { "python3" },
            },
            ipython = {
              command = { "ipython" },
            },
            node = {
              command = { "node" },
            },
          },
          repl_open_cmd = "vertical botright 80 split",
        },
        keymaps = {
          send_motion = "<leader>sc",
          visual_send = "<leader>ss",
          send_file = "<leader>sf",
          send_line = "<leader>sl",
          send_mark = "<leader>sm",
          mark_motion = "<leader>mc",
          mark_visual = "<leader>mc",
          remove_mark = "<leader>md",
          cr = "<leader>s<cr>",
          interrupt = "<leader>s<space>",
          exit = "<leader>sq",
          clear = "<leader>cl",
        },
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true,
      }
    end,
  },
}
