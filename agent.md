# Instruction and Task.
This is my structure of my nvim directory:
```               
›     ├── snippets
      │   ├── markdown.lua
      │   └── python.lua
      └── user
          ├── autocmds.lua
          ├── clipboard.lua
          ├── cmp.lua
          ├── core.lua
          ├── env.lua
          ├── ime.lua
          ├── keymaps
          │   ├── basic.lua
          │   ├── debugging.lua
          │   ├── delete.lua
          │   ├── lsp.lua
          │   ├── misc.lua
          │   ├── navigation.lua
          │   ├── run.lua
          │   └── telescope.lua
          ├── keymaps.lua
          ├── lsp_config.lua
          ├── options.lua
          ├── plugin_manager.lua
          ├── plugins
          │   ├── appearance.lua
          │   ├── completion.lua
          │   ├── debugging.lua
          │   ├── editing_helpers.l
          │   ├── file_explorer.lua
          │   ├── lsp.lua
          │   └── telescope.lua
          ├── plugins.lua.backup
          ├── snippets.lua
          ├── tmux.lua
          └── treesitter_config.lua
```        
It's too complex, and the following is my desired structure:
```
~/.config/nvim
├── init.lua
└── lua
    ├── config
    │   ├── init.lua
    │   ├── options.lua
    │   ├── autocmds.lua
    │   ├── clipboard.lua
    │   ├── env.lua
    │   └── core.lua
    │
    ├── keymaps
    │   ├── init.lua
    │   ├── basic.lua
    │   ├── navigation.lua
    │   ├── lsp.lua
    │   ├── telescope.lua
    │   ├── debugging.lua
    │   └── run.lua
    │
    ├── plugins
    │   ├── init.lua
    │   ├── appearance.lua
    │   ├── completion.lua
    │   ├── lsp.lua
    │   ├── treesitter.lua
    │   ├── telescope.lua
    │   ├── debugging.lua
    │   └── file_explorer.lua
    │
    ├── plugin_config
    │   ├── init.lua
    │   ├── cmp.lua
    │   ├── lsp.lua
    │   ├── treesitter.lua
    │   ├── telescope.lua
    │   ├── dap.lua
    │   └── appearance.lua
    │
    └── snippets
        ├── init.lua
        ├── python.lua
        └── markdown.lua
```
You need to organize my file by such dircotories, you can allocate the content of files to make it works.

