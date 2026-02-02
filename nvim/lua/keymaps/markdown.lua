local keymap = vim.keymap.set

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO)
end

local function url_encode(text)
  return (text:gsub("([^%w%-_%.~])", function(c)
    return string.format("%%%02X", string.byte(c))
  end))
end

local function open_in_typora()
  vim.cmd("w")

  if vim.bo.filetype ~= "markdown" then
    notify("Not a markdown buffer", vim.log.levels.WARN)
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    notify("No file path for current buffer", vim.log.levels.WARN)
    return
  end

  local layout = vim.g.typora_rectangle_layout or "markdown"
  local url = "rectangle-pro://execute-layout?name=" .. url_encode(layout)

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
