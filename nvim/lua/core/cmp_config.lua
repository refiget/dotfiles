-- ===================== cmp.lua =====================
-- nvim-cmp 配置
local cmp = require("cmp")
local luasnip = require("luasnip")

local kind_icons = {
  Text = "",
  Method = "󰆧",
  Function = "󰊕",
  Constructor = "",
  Field = "󰇽",
  Variable = "󰂡",
  Class = "󰠱",
  Interface = "",
  Module = "",
  Property = "󰜢",
  Unit = "",
  Value = "󰎠",
  Enum = "",
  Keyword = "󰌋",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "󰅲",
}

cmp.setup({
  performance = {
    max_view_entries = 8,
  },
  window = {
    completion = cmp.config.window.bordered({
      -- Use Pmenu highlights so the completion menu always has contrast even with
      -- transparent backgrounds.
      winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
      scrollbar = false,
      col_offset = -1,
      side_padding = 1,
    }),
    documentation = cmp.config.window.bordered({
      winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,Search:None",
    }),
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = function(entry, vim_item)
      vim_item.kind = (kind_icons[vim_item.kind] or "") .. " " .. vim_item.kind
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        luasnip = "[Snip]",
        buffer = "[Buf]",
        path = "[Path]",
        cmdline = "[Cmd]",
        nvim_lua = "[Lua]",
        spell = "[Spell]",
      })[entry.source.name] or ("[" .. entry.source.name .. "]")
      return vim_item
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  })
})

cmp.setup.filetype({ "markdown", "text" }, {
  sources = cmp.config.sources({
    { name = "spell" },
    { name = "buffer" },
    { name = "path" },
  }),
})

-- 配置命令行补全
cmp.setup.cmdline({":"}, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  })
})

-- 配置搜索补全
cmp.setup.cmdline({"/", "?"}, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  }
})
