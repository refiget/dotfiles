# zsh 配置说明

基于 zimfw 的模块化 zsh 配置，目标是：**启动顺序可预测、覆盖点明确、工具集成不冲突**。

---

## 你会得到什么

- 清晰启动链：`.zshenv → .zprofile → .zshrc`
- 模块加载：`zsh/conf.d/*.conf`
- 稳定 `Ctrl-R`：Atuin 可用时优先，否则回退原生历史搜索
- `fzf` 单 Provider 加载，避免重复 source
- Python venv 辅助与 OpenClaw 快捷命令

---

## 启动文件关系

- `~/.zshenv`（全局环境）← `~/dotfiles/.zshenv`
- `~/.zprofile`（login shell）← `~/dotfiles/.zprofile`
- `~/.zshrc`（interactive）← `~/dotfiles/.zshrc`
- `~/.zimrc` ← `~/dotfiles/.zimrc`

---

## 本机覆盖（推荐方式）

### 1) 早期覆盖：`~/.zshrc.pre.local`
由 `zsh/conf.d/80_local_overrides.conf` 加载。

适合放“会影响后续模块行为”的变量，例如：

```bash
export ZSH_SKIP_DEP_CHECKS=1
export ZSH_SKIP_TMUX_AUTOSTART=1
```

### 2) 末端覆盖：`~/.zshrc.local`
由 `zsh/conf.d/99_local_overrides.conf` 加载。

适合放最终 alias、绑定、prompt 微调等。

> 注意：若 `95_autostart_tmux.conf` 触发 `exec tmux`，末端覆盖不会继续执行。

---

## tmux 自动进入

- 逻辑位置：`zsh/conf.d/95_autostart_tmux.conf`
- 禁用方式（推荐放 pre local）：

```bash
export ZSH_SKIP_TMUX_AUTOSTART=1
```

---

## 排障建议

- 查看当前 `Ctrl-R` 行为：`bindkey '^R'`
- 重载 shell：`exec zsh`
- 检查模块加载顺序：按 `conf.d` 文件名前缀（10/20/30/...）
