local keymap = vim.keymap.set
local opts = { silent = true }

local function run_python()
  vim.cmd("w")
  local file = vim.fn.expand("%")
  vim.cmd("botright 10split | term python3 " .. file)
end

keymap("n", "R", run_python, { silent = true, desc = "Run Python file" })

vim.keymap.set("n", "<localleader>ip", function()
  local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
  if venv ~= nil then
    -- in the form of /home/benlubas/.virtualenvs/VENV_NAME
    venv = string.match(venv, "/.+/(.+)")
    vim.cmd(("MoltenInit %s"):format(venv))
  else
    vim.cmd("MoltenInit python3")
  end
end, { desc = "Initialize Molten for python3", silent = true })
