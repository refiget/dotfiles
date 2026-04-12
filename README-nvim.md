# Neovim 配置说明

面向日常开发的 Neovim 配置，核心目标：**LSP-first、低摩擦、可演进**。

---

## 重点能力

- 以 LSP 为中心的语言支持
- Python 虚拟环境自动识别（优先项目本地环境）
- 诊断与导航遵循原生高效路径
- 插件配置尽量模块化，避免单文件失控

---

## 路径约定

- 仓库目录：`~/dotfiles/nvim/`
- 部署目录：`~/.config/nvim`
- 关键实现：`lua/config/`、`lua/plugins/`、`lua/lsp/`

---

## 快速初始化

1. 部署链接

```bash
cd ~/dotfiles
./deploy.sh
```

2. 准备 Python host（一次性）

```bash
python3 -m venv ~/venvs/nvim
~/venvs/nvim/bin/pip install -U pip pynvim
```

3. 安装/更新常见语言工具（示例）

```bash
npm i -g pyright
```

---

## 常用维护动作

- 同步插件：`:Lazy sync`
- 重启 LSP：`:LspRestart`
- 查看映射：`:map` / `:nmap` / `:imap`

---

## 故障排查（Python）

如果出现导入无法解析：

1. 确认项目存在 venv（推荐 `.venv`）
2. 打开项目根目录再启动 nvim
3. 执行 `:LspRestart`

---

## 说明

README 聚焦稳定使用方式；精确行为请以 Lua 配置源码为准。
