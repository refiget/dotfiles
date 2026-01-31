local iron = require("iron.core")

------------------------------------------------------------
-- Helper: clear REPL before sending
------------------------------------------------------------
local function clear_then(fn)
  return function(...)
    iron.clear()
    fn(...)
  end
end

------------------------------------------------------------
-- REPL lifecycle  (<leader>ss = session)
------------------------------------------------------------
vim.keymap.set("n", "<leader>ss", iron.toggle_repl, { desc = "Iron: toggle REPL" })
vim.keymap.set("n", "<leader>sS", iron.restart_repl, { desc = "Iron: restart REPL" })
vim.keymap.set("n", "<leader>sk", iron.interrupt, { desc = "Iron: interrupt" })
vim.keymap.set("n", "<leader>sq", iron.exit, { desc = "Iron: exit REPL" })
vim.keymap.set("n", "<leader>sc", iron.clear, { desc = "Iron: clear REPL" })

------------------------------------------------------------
-- Send code (<leader>s = send)
------------------------------------------------------------
vim.keymap.set("n", "<leader>sl", iron.send_line, { desc = "Send line" })
vim.keymap.set("v", "<leader>sv", iron.visual_send, { desc = "Send visual" })
vim.keymap.set("n", "<leader>sf", iron.send_file, { desc = "Send file" })
vim.keymap.set("n", "<leader>sp", iron.send_paragraph, { desc = "Send paragraph" })
vim.keymap.set("n", "<leader>su", iron.send_until_cursor, { desc = "Send until cursor" })
vim.keymap.set("n", "<leader>sb", iron.send_code_block, { desc = "Send block / cell" })
vim.keymap.set("n", "<leader>sn", function()
  iron.send_code_block(true)
end, { desc = "Send block & move" })

------------------------------------------------------------
-- Clear → Send (<leader>sx)
------------------------------------------------------------
vim.keymap.set("n", "<leader>sxb",
  clear_then(iron.send_code_block),
  { desc = "Clear → send block" }
)

vim.keymap.set("n", "<leader>sxn",
  clear_then(function()
    iron.send_code_block(true)
  end),
  { desc = "Clear → send block & next" }
)

vim.keymap.set("v", "<leader>sxv",
  clear_then(function()
    iron.send(nil, iron.mark_visual())
  end),
  { desc = "Clear → send visual" }
)
