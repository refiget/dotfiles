return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local function write_test_report(mode, items, tests)
        local ok_json, json = pcall(vim.json.encode, {
          ts = os.date("!%Y-%m-%dT%H:%M:%SZ"),
          mode = mode,
          file = vim.api.nvim_buf_get_name(0),
          passed = vim.tbl_map(function(t)
            return t.method or "<unknown>"
          end, vim.tbl_filter(function(t)
            return t and (not t.failed) and t.method ~= nil
          end, tests or {})),
          failed = vim.tbl_map(function(t)
            return t.method or (t.fq_class or "<unknown>")
          end, vim.tbl_filter(function(t)
            return t and t.failed
          end, tests or {})),
          total = #(tests or {}),
          failure_items = #(items or {}),
        })
        if not ok_json then
          vim.notify("Java test report JSON encode failed", vim.log.levels.ERROR)
          return
        end

        local report = vim.fn.stdpath("cache") .. "/java-test-report.jsonl"
        vim.fn.writefile({ json }, report, "a")

        local passed = vim.tbl_filter(function(t)
          return t and (not t.failed) and t.method ~= nil
        end, tests or {})

        local msg = string.format("Java tests done: pass %d / total %d (saved %s)", #passed, #(tests or {}), report)
        vim.notify(msg, vim.log.levels.INFO)
      end

      vim.api.nvim_create_user_command("JavaTestClassReport", function()
        local ok, jd = pcall(require, "jdtls.dap")
        if not ok then
          vim.notify("jdtls.dap not available", vim.log.levels.WARN)
          return
        end
        jd.test_class({
          after_test = function(items, tests)
            write_test_report("class", items, tests)
          end,
        })
      end, { desc = "Run Java test class and persist pass/fail report" })

      vim.api.nvim_create_user_command("JavaTestNearestReport", function()
        local ok, jd = pcall(require, "jdtls.dap")
        if not ok then
          vim.notify("jdtls.dap not available", vim.log.levels.WARN)
          return
        end
        jd.test_nearest_method({
          after_test = function(items, tests)
            write_test_report("nearest", items, tests)
          end,
        })
      end, { desc = "Run nearest Java test and persist pass/fail report" })
    end,
  },
}
