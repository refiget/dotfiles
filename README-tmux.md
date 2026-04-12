# tmux 配置说明

这套 tmux 配置强调三件事：

1. **结构化脚本分层**（hooks / session / pane / window / status）
2. **稳定的剪贴板行为**（复制与粘贴统一入口）
3. **低抖动状态栏**（模块化 segment + 可控动态信息）

---

## 目录与入口

- 主配置：`~/.tmux.conf`（来自 `~/dotfiles/.tmux.conf`）
- 模块配置：`tmux/conf.d/*.conf`
- 脚本根：`~/.config/tmux/scripts/`（链接到仓库 `tmux/scripts/`）
- 状态栏脚本：`tmux/tmux-status/`

### 架构文档

- 总览：`tmux/ARCHITECTURE.md`
- 契约：`tmux/docs/contracts/*.md`

---

## Hook 架构（重构后）

统一由 dispatcher 处理：

- `scripts/hooks/dispatch.sh`
- 事件脚本：`scripts/hooks/events/*.sh`

这样可以把 tmux hook 与业务逻辑解耦，降低配置文件复杂度。

---

## 剪贴板策略

- 复制入口：`scripts/copy_to_clipboard.sh`
- 粘贴入口：`scripts/paste_from_clipboard.sh`
- 目标：键盘复制、鼠标复制、复制模式复制都走统一后端

额外处理：对换行做安全处理，减少“粘贴即执行”的误触风险。

---

## 状态栏策略

- 右侧状态栏已拆分为 `tmux-status/lib/*` 与 `right.sh`
- 动态信息默认“低干扰”，避免频繁跳变
- 主题更新与刷新间隔脚本已独立到 `scripts/status/`

---

## 常用命令

```bash
tmux source-file ~/.tmux.conf   # 重载配置
tmux list-keys                  # 查看最终绑定
tmux show -g                    # 查看全局选项
```

---

## 兼容性说明

重构后采用了新的子系统路径；旧脚本路径保留 wrapper，以降低外部调用和历史绑定断裂风险。
