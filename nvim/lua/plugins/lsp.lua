return {
  { "neovim/nvim-lspconfig", lazy = false },
  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach",
    config = function()
      local ok, lspsaga = pcall(require, "lspsaga")
      if not ok then
        return
      end
      lspsaga.setup({
        lightbulb = {
          enable = false,
          sign = false,
          virtual_text = false,
        },
        symbol_in_winbar = {
          enable = false,
        },
        ui = {
          border = "rounded",
        },
      })
    end,
  },
  {
    "folke/trouble.nvim",
    event = "LspAttach",
    config = function()
      local ok, trouble = pcall(require, "trouble")
      if not ok then
        return
      end
      trouble.setup({})
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvimtools/none-ls-extras.nvim" },
    config = function()
      local ok, null_ls = pcall(require, "null-ls")
      if not ok then
        return
      end
      local sources = {}
      local function has_exec(bin)
        return vim.fn.executable(bin) == 1
      end
      if has_exec("black") and null_ls.builtins.formatting.black then
        table.insert(sources, null_ls.builtins.formatting.black)
      end
      if has_exec("stylua") and null_ls.builtins.formatting.stylua then
        table.insert(sources, null_ls.builtins.formatting.stylua)
      end
      if has_exec("flake8") then
        local ok_flake8, flake8 = pcall(require, "none-ls.diagnostics.flake8")
        if ok_flake8 then
          table.insert(sources, flake8)
        elseif null_ls.builtins.diagnostics.flake8 then
          table.insert(sources, null_ls.builtins.diagnostics.flake8)
        end
      end
      null_ls.setup({
        sources = sources,
      })
    end,
  },
}
