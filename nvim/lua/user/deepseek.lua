-- ===================== deepseek.lua =====================
-- DeepSeek CLI 集成（调用 ds-nvim 命令版本）
-- 此文件包含所有 DeepSeek 相关的 Neovim 集成功能
-- 适用于放置在 ~/dotfiles/nvim/lua/user/ 目录下的模块化配置结构

-- 检查 ds-nvim 命令是否存在
local function ensure_ds_nvim()
  if vim.fn.executable("ds-nvim") ~= 1 then
    vim.notify(
      "ds-nvim 命令未找到，请确保已安装 DeepSeek CLI",
      vim.log.levels.WARN,
      { title = "DeepSeek CLI" }
    )
    return false
  end
  return true
end

-- 在右侧新建终端窗口，宽度固定 30
local function open_ds_split(cmd)
  if not ensure_ds_nvim() then
    return
  end
  vim.cmd("botright 30vnew")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_width(win, 30)
  local buf = vim.api.nvim_get_current_buf()
  pcall(vim.api.nvim_buf_set_name, buf, "deepseek_cli_terminal")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "buftype", "")
  vim.fn.termopen({ "bash", "-lc", cmd })
  vim.cmd("startinsert")
end

-- 获取可视模式选区文本（使用寄存器方式，更可靠）
local function get_visual_selection()
  -- 保存当前寄存器内容
  local original_register = vim.fn.getreg('"')
  local original_register_type = vim.fn.getregtype('"')
  
  -- 执行 yank 操作，将选中内容保存到默认寄存器
  vim.cmd('noau normal! "*y')
  
  -- 获取寄存器内容
  local selection = vim.fn.getreg('"')
  
  -- 恢复原寄存器内容
  vim.fn.setreg('"', original_register, original_register_type)
  
  -- 移除首尾空白（可选，根据需要调整）
  return vim.trim(selection)
end

-------------------------------------------------
-- 1) 在 Neovim 里向 DeepSeek 提问（普通问答）
--    普通模式按：<leader>dq   （空格 d q）
-------------------------------------------------
local function ds_ask_in_term()
  local q = vim.fn.input("DeepSeek（请直接问）> ")
  if q == nil or q == "" then
    return
  end
  
  local cmd = string.format("ds-nvim ask --concise %s", vim.fn.shellescape(q))
  open_ds_split(cmd)
end

-------------------------------------------------
-- 2) 选中一段代码让 DeepSeek 查错 + 给修改建议
--    可视模式按：<leader>dr   （空格 d r）
-------------------------------------------------
local function ds_review_visual_in_term()
  local code = get_visual_selection()
  if code == nil or code == "" then
    vim.notify("No visual selection", vim.log.levels.WARN, { title = "DeepSeek Review" })
    return
  end

  local ft = vim.bo.filetype
  
  local cmd = string.format("ds-nvim review --filetype %s --code %s", 
                            vim.fn.shellescape(ft), 
                            vim.fn.shellescape(code))
  open_ds_split(cmd)
end

-------------------------------------------------
-- 3) 生成 doctest 示例并插入当前缓冲区
--    普通模式按：<leader>dt   （空格 d t）
-------------------------------------------------
local function ds_doctest_current_buffer()
  -- 把当前 buffer 的所有内容拼成一段文本
  local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local buf_text = table.concat(buf_lines, "\n")
  if buf_text == "" then
    vim.notify("当前缓冲区为空，无法生成 doctest", vim.log.levels.WARN, { title = "DeepSeek Doctest" })
    return
  end

  local ft = vim.bo.filetype
  
  -- 显示正在生成的提示
  local progress_id = 12345
  vim.notify("正在生成 doctest...", vim.log.levels.INFO, { 
    title = "DeepSeek Doctest",
    icon = "⏳",
    timeout = false,
    replace_id = progress_id
  })

  local stdout, stderr = {}, {}
  local cmd = string.format("ds-nvim doctest --filetype %s --code %s", 
                            vim.fn.shellescape(ft), 
                            vim.fn.shellescape(buf_text))
  
  vim.fn.jobstart({ "bash", "-lc", cmd }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.list_extend(stdout, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(stderr, data)
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        vim.notify("Doctest 生成完成", vim.log.levels.INFO, { 
          title = "DeepSeek Doctest",
          icon = "✅",
          replace_id = progress_id
        })

        if code ~= 0 then
          vim.notify("DeepSeek doctest 生成失败: " .. table.concat(stderr, ""), 
                    vim.log.levels.ERROR, { title = "DeepSeek Doctest" })
          return
        end

        local output = table.concat(stdout, "\n")
        if output == nil or output == "" then
          vim.notify("未获取到可插入的 doctest 内容", vim.log.levels.WARN, { title = "DeepSeek Doctest" })
          return
        end

        -- 过滤 ANSI 颜色、主题说明、Markdown 代码围栏
        local function clean_lines(raw)
          local cleaned = {}
          for _, line in ipairs(raw) do
            line = line:gsub("\27%[[0-9;]*m", "")  -- ESC 开头
            line = line:gsub("%[[0-9;]*m", "")     -- 部分 CLI 直接渲染出的 [90m 形式
            if not line:match("^```") and not line:match("^%s*%-%-%-") then
              table.insert(cleaned, line)
            end
          end
          return cleaned
        end

        local cleaned = clean_lines(vim.split(output, "\n", { plain = true, trimempty = true }))

        if #cleaned == 0 then
          vim.notify("未获取到可插入的 doctest 内容", vim.log.levels.WARN, { title = "DeepSeek Doctest" })
          return
        end

        local function get_shiftwidth()
          local sw = vim.bo.shiftwidth
          if sw == 0 or sw == nil then
            sw = vim.o.shiftwidth
          end
          if sw == 0 or sw == nil then
            sw = 2
          end
          return sw
        end

        -- 忽略光标，尽量把 doctest 放到第一个 def/class 等块的内部（下一层缩进）
        local function decide_insert_pos()
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          for i, line in ipairs(lines) do
            local trimmed = vim.trim(line)
            if trimmed ~= "" and trimmed:sub(-1) == ":" then
              local base_indent = line:match("^(%%s*)") or ""
              local indent = base_indent .. string.rep(" ", get_shiftwidth())
              return i, indent  -- i 是 0-based，插在该行之后
            end
          end
          return 0, ""  -- 没找到块，放到文件开头，无缩进
        end

        local insert_row, indent = decide_insert_pos()

        local function with_indent(line)
          if indent == "" then
            return line
          end
          if line == "" then
            return indent
          end
          return indent .. line
        end

        local insert_lines = { with_indent('"""') }
        for _, line in ipairs(cleaned) do
          table.insert(insert_lines, with_indent(line))
        end
        table.insert(insert_lines, with_indent('"""'))

        vim.api.nvim_buf_set_lines(0, insert_row + 1, insert_row + 1, false, insert_lines)
      end)
    end,
  })
end

-- 设置键盘映射
local function setup_keymaps()
  local keymap = vim.keymap.set
  
  -- 在 Neovim 里向 DeepSeek 提问（普通问答）
  keymap(
    "n",
    "<leader>dq",
    ds_ask_in_term,
    { silent = true, noremap = true, desc = "DeepSeek: ask question (terminal)" }
  )

  -- 选中一段代码让 DeepSeek 查错 + 给修改建议
  keymap(
    "v",
    "<leader>dr",
    ds_review_visual_in_term,
    { silent = true, noremap = true, desc = "DeepSeek: review selected code (terminal)" }
  )

  -- 生成 doctest 示例并插入当前缓冲区
  keymap(
    "n",
    "<leader>dt",
    ds_doctest_current_buffer,
    { silent = true, noremap = true, desc = "DeepSeek: generate doctest for buffer" }
  )
end

-- 导出函数，供其他文件使用
local deepseek_module = {
  setup = setup_keymaps,
  ds_ask = ds_ask_in_term,
  ds_review = ds_review_visual_in_term,
  ds_doctest = ds_doctest_current_buffer
}

-- 自动执行setup函数，当require('deepseek')时自动加载所有功能
setup_keymaps()

return deepseek_module
