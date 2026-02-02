# Instructions
希望实现的工作流是：

当我在 Neovim 中编辑 Markdown 文件时：
	1.	在 Neovim 里按下一个快捷键
	2.	自动完成：
	•	保存当前 Markdown 文件
	•	打开 Typora，并让 Typora 读取「当前正在编辑的这个文件」
	•	调用你已经设置好的 Rectangle Pro 快捷键（⌘⌃⌥M），应用布局
	3.	之后我继续只在 Neovim 里编辑
	4.	只要我在 Neovim 里发生「模式切换」（比如 Insert → Normal）
	•	Markdown 文件就会自动保存
	•	Typora 因为监听到文件变化而自动刷新预览

✅ Typora 只读，不编辑
✅ 同步方式 = 保存即同步
✅ 不需要真正的“逐键实时预览”
✅ 不想引入复杂或脆弱的插件体系

# 已知api
```bash
open -a Typora ~/dotfiles/README.md
```
上述命令可以通过shell命令用Typora打开指定目录的markdown文件。


```bash
open -g "rectangle-pro://execute-layout?name=markdown"
```
上述命令可以调整Typora和iterm2的布局
