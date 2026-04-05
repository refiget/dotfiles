return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = { { "K", false } },
        },
        lua_ls = {},
        pyright = {},
        bashls = {},
        jsonls = {},
        yamlls = {},
        ts_ls = {},
      },
    },
  },
}
