local keymap = vim.keymap.set

local function url_encode(text)
  return (text:gsub("([^%w%-_%.~])", function(c)
    return string.format("%%%02X", string.byte(c))
  end))
end

local function open_in_typora()
  vim.cmd("w")
  local file = vim.fn.expand("%:p")

  local layout = vim.g.typora_rectangle_layout or "markdown"
  local url = "rectangle-pro://execute-layout?name=" .. url_encode(layout)

  vim.g.markdown_autosave_enabled = true

  vim.fn.jobstart({ "open", "-a", "Typora", file }, { detach = true })
  vim.defer_fn(function()
    vim.fn.jobstart({ "open", url }, { detach = true })
    vim.fn.jobstart({ "yabai", "-m", "space", "--layout", "bsp" }, { detach = true })
  end, 200)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    keymap("n", "<localleader>t", open_in_typora, {
      buffer = true,
      silent = true,
      desc = "Typora: open + Rectangle layout",
    })
  end,
})
