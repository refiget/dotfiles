return {
  {
    "nvim-lua/plenary.nvim",
    ft = "java",
    config = function()
      local sign_name = "JavaTestRunSign"
      local sign_group = "JavaTestRunSignGroup"

      vim.fn.sign_define(sign_name, {
        text = "",
        texthl = "DiagnosticSignHint",
        linehl = "",
        numhl = "",
      })
      vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = "#a6e3a1" })

      local function next_method_line(lines, from)
        for j = from + 1, #lines do
          local l = lines[j] or ""
          local is_blank = l:match("^%s*$") ~= nil
          local is_annotation = l:match("^%s*@") ~= nil
          if not is_blank and not is_annotation then
            return j
          end
        end
        return nil
      end

      local function refresh_java_test_signs(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        if vim.bo[bufnr].filetype ~= "java" then
          return
        end

        vim.fn.sign_unplace(sign_group, { buffer = bufnr })

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local id = 1

        for i, line in ipairs(lines) do
          if line:match("^%s*@Test%s*$") or line:match("^%s*@Test%f[%W]") then
            local target = next_method_line(lines, i)
            if target then
              vim.fn.sign_place(id, sign_group, sign_name, bufnr, { lnum = target, priority = 10 })
              id = id + 1
            end
          end
        end
      end

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged", "TextChangedI" }, {
        group = vim.api.nvim_create_augroup("JavaTestRunSignAutocmd", { clear = true }),
        pattern = "*.java",
        callback = function(args)
          refresh_java_test_signs(args.buf)
        end,
      })

      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].filetype == "java" then
          refresh_java_test_signs(b)
        end
      end
    end,
  },
}
