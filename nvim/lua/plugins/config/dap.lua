-- DAP (Debug Adapter Protocol) configuration
local ok, dap = pcall(require, "dap")
if not ok then
  return
end

-- Python debugging setup
require("dap-python").setup("python")

-- Add other language-specific debuggers here as needed
