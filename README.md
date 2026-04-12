# dotfiles（macOS）

这是一套以**键盘优先**为核心的个人开发环境配置，重点是：

- 终端工作流一致（zsh / tmux / Neovim / yazi / lazygit）
- 信息管理独立（Doom Emacs 仅用于 Org）
- 配置模块化、可回滚、可增量演进

---

## 设计原则

1. **单一职责**：每个工具只做自己最擅长的事。
2. **薄入口，厚模块**：顶层 loader 保持精简，行为放到子目录。
3. **兼容优先**：重构时尽量保留兼容入口，减少断裂升级。
4. **可观察**：关键行为有明确脚本入口，便于排查问题。

---

## 组件总览

- **Shell**: zsh + zimfw（启动链清晰，可本机局部覆盖）
- **Multiplexer**: tmux（事件分发、状态栏模块化、剪贴板统一）
- **Editor**: Neovim（LSP-first，插件与语言配置分层）
- **Org/PIM**: Doom Emacs（仅笔记/日程/收集）
- **Desktop**: yabai + Hammerspoon + Karabiner（窗口与输入增强）

---

## 仓库结构

```text
.
├── README.md
├── README-zsh.md
├── README-tmux.md
├── README-nvim.md
├── deploy.sh
├── zsh/
├── tmux/
├── nvim/
├── doom/
├── yabai/
├── hammerspoon/
├── scripts/
└── assets/
```

---

## 安装与部署

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
./deploy.sh
```

常用参数：

```bash
./deploy.sh --force   # 覆盖已存在链接
./deploy.sh --lazy    # 延迟/按需处理部分步骤
```

---

## 常用重载命令

- zsh: `exec zsh`
- tmux: `tmux source-file ~/.tmux.conf`
- Neovim: `:Lazy sync` / `:LspRestart`
- Doom Emacs（模块或包变更后）: `doom sync`

---

## 文档导航

- zsh 细节：`README-zsh.md`
- tmux 细节：`README-tmux.md`
- Neovim 细节：`README-nvim.md`

> README 只描述稳定约定；精确行为以实际配置与脚本为准。
