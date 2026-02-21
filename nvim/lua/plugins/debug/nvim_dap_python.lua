-- mfussenegger/nvim-dap-python

return {
  "mfussenegger/nvim-dap-python",
  ft = "python",
  dependencies = { "mfussenegger/nvim-dap" },

  --  ____  _               _             _
  -- / ___|| |__   ___  ___| | _____ _ __| |_ ___
  -- \___ \| '_ \ / _ \/ __| |/ / _ \ '__| __/ __|
  --  ___) | | | |  __/ (__|   <  __/ |  | |_\__ \
  -- |____/|_| |_|\___|\___|_|\_\___|_|   \__|___/
  keys = {
    {
      "<localleader>df",
      function()
        local dap = require("dap")
        local fn = vim.fn

        local function exists(path)
          return path and path ~= "" and fn.filereadable(path) == 1
        end

        local function find_project_python()
          local venv = vim.env.VIRTUAL_ENV
          if venv and venv ~= "" then
            local p = venv .. "/bin/python"
            if exists(p) then
              return p
            end
          end

          local root = fn.getcwd()
          for _, p in ipairs({
            root .. "/.venv/bin/python",
            root .. "/.venv/bin/python3",
            root .. "/venv/bin/python",
            root .. "/venv/bin/python3",
          }) do
            if exists(p) then
              return p
            end
          end

          local mason_py = fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
          if exists(mason_py) then
            return mason_py
          end

          return vim.g.python3_host_prog or "python3"
        end

        dap.run({
          type = "python",
          request = "launch",
          name = "Launch current file",
          program = fn.expand("%:p"),
          cwd = fn.getcwd(),
          pythonPath = find_project_python(),
          justMyCode = true,
          console = "integratedTerminal",
        })
      end,
      desc = "DAP: debug current file (Python)",
      mode = "n",
    },
    {
      "<localleader>dt",
      function()
        require("dap-python").test_method()
      end,
      desc = "DAP: debug pytest method",
      mode = "n",
    },
    {
      "<localleader>dT",
      function()
        require("dap-python").test_class()
      end,
      desc = "DAP: debug pytest class",
      mode = "n",
    },
  },

  config = function()
    local ok, dap_python = pcall(require, "dap-python")
    if not ok then
      return
    end

    local fn = vim.fn

    local function exists(path)
      return path and path ~= "" and fn.filereadable(path) == 1
    end

    local function find_project_python()
      local venv = vim.env.VIRTUAL_ENV
      if venv and venv ~= "" then
        local p = venv .. "/bin/python"
        if exists(p) then
          return p
        end
      end

      local root = fn.getcwd()
      local candidates = {
        root .. "/.venv/bin/python",
        root .. "/.venv/bin/python3",
        root .. "/venv/bin/python",
        root .. "/venv/bin/python3",
      }
      for _, p in ipairs(candidates) do
        if exists(p) then
          return p
        end
      end

      local mason_py = fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      if exists(mason_py) then
        return mason_py
      end

      return vim.g.python3_host_prog or "python3"
    end

    local mason_adapter_py = fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
    if exists(mason_adapter_py) then
      dap_python.setup(mason_adapter_py)
    else
      dap_python.setup(find_project_python())
    end
  end,
}
