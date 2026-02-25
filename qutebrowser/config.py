# qutebrowser config
# Theme: Dracula (aligned with Neovim + Yazi)
# Location: ~/.config/qutebrowser/config.py

# Official-recommended approach: keep autoconfig enabled, and only put
# explicit overrides here.
config.load_autoconfig(True)

# Debug convenience
c.aliases['rc'] = 'config-source'
c.aliases['re'] = 'reload'


# Scroll-target helper (NO click): hint an element and only *hover* it.
# Most modern sites route wheel/trackpad scroll to the scroll container under the cursor,
# so hovering the sidebar/recommendations area is enough to choose where scrolling goes.
# This avoids any activation/click side effects some sites trigger when the element is focused.
# External browsers (for Google login / compatibility)
c.aliases['chrome'] = 'spawn --detach open -a "Google Chrome" {url}'
c.aliases['safari'] = 'spawn --detach open -a "Safari" {url}'

# ---------- Basics ----------
c.auto_save.session = True

# Dark mode for webpages (QtWebEngine)
# Note: some darkmode options require a restart depending on your Qt version.
c.colors.webpage.darkmode.enabled = False
c.colors.webpage.darkmode.algorithm = "lightness-cielab"
c.colors.webpage.darkmode.policy.images = "smart"

# 1) 自动配置机制（官方推荐：保留 autoconfig，显式覆盖写在这里）
# config.load_autoconfig(True) 已在文件顶部开启

# 2) 默认内容行为：开启 JS / 图片 / Cookie（提升兼容性）
c.content.javascript.enabled = True
c.content.images = True
c.content.cookies.accept = "all"
c.content.cookies.store = True

# 3) User-Agent（全局设置：官方推荐的最简单方式）
# 你确认这条 UA 能让 Google 正常登录。
config.set(
    "content.headers.user_agent",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7; rv:130.0) Gecko/20100101 Firefox/130.0",
)

# Messages / prompts UI polish
# Keep messages readable but unobtrusive.
c.messages.timeout = 2000
# Rounded corners for prompts (more modern than the default sharp rectangles)
c.prompt.radius = 10

c.completion.height = "35%"
# Always show completion when opening the commandline (so quickmarks appear even with empty input).
c.completion.show = "always"

# Completion: prefer bookmarks/quickmarks over history.
# Newer qutebrowser versions don't have completion.web_history; use exclude instead.
# For :open (o/O) completion, show: recent history (last 100), bookmarks, quickmarks.
# (No searchengines/filesystem to keep it focused.)
c.completion.web_history.exclude = []
c.completion.web_history.max_items = 100
# Order matters.
c.completion.open_categories = ["history", "bookmarks", "quickmarks"]

# 4) Hints 行为：更干净、可预测（配合主题的极简 hints 外观）
c.hints.mode = "letter"
c.hints.chars = "asdfghjkl"
# 自动跟随：只有唯一匹配时自动打开，避免误触
c.hints.auto_follow = "unique-match"
# 进入新页面加载时自动退出 hints（更像一次性工具）
c.hints.leave_on_load = True
# 更像 UI 组件：稍微圆角 + 适当 padding
c.hints.radius = 8
c.hints.padding = {"top": 2, "bottom": 2, "left": 6, "right": 6}

# ---------- UI (tabbar-first layout) ----------
# Make the tabbar feel more like a Neovim/tmux "tabline": taller, clearer.
c.tabs.show = "always"
c.tabs.position = "top"
# Increase perceived height via padding.
c.tabs.padding = {"top": 8, "bottom": 8, "left": 12, "right": 12}

# Tabs: remove automatic index numbering for a cleaner tabline.
c.tabs.title.format = "{audio}{current_title}"
c.tabs.title.format_pinned = "{audio}"
# Larger tab font (qutebrowser uses fonts.tabs.* for tabbar text)
c.fonts.tabs.selected = "14pt SF Pro Text"
c.fonts.tabs.unselected = "14pt SF Pro Text"
# Keep tabs readable when many are open.
c.tabs.min_width = 120
c.tabs.max_width = 320

# Command / completion UI readability
# Try system font (macOS look): SF Pro Text
c.fonts.prompts = "17pt SF Pro Text"
c.fonts.statusbar = "15pt SF Pro Text"
c.fonts.completion.entry = "14pt SF Pro Text"
c.fonts.completion.category = "13pt SF Pro Text"

# Downloads bar
c.fonts.downloads = "14pt SF Pro Text"

# Hide URL by default (show statusbar only when needed)
c.statusbar.show = "in-mode"

# Statusbar widgets
# Remove the "-- MODE --" (keypress widget) for a more premium look.
# Rely on subtle color changes + prompt/completion UI instead.
# Go ultra-minimal: no mode widget/keypress echoes.
c.statusbar.widgets = ["url", "progress"]

# Statusbar padding: pull left/right contents in a bit (more macOS-like, less edge-hugging)
# "2 grids" ~= 12px on Retina; tweak if you want more/less.
c.statusbar.padding = {"top": 1, "bottom": 1, "left": 12, "right": 12}

# Minimal chrome
c.scrolling.bar = "never"

# 5) 广告/跟踪拦截：hosts + ABP（更强力）
# qutebrowser 3.6+ 支持 Brave 的 ABP 引擎。
c.content.blocking.enabled = True
c.content.blocking.method = "both"

# Google sign-in is sensitive to blocked resources (reCAPTCHA/scripts). Disable blocking there.
config.set("content.blocking.enabled", False, "https://accounts.google.com/*")
config.set("content.blocking.enabled", False, "https://*.google.com/*")
config.set("content.blocking.enabled", False, "https://*.gstatic.com/*")

# Hosts lists (fast, good baseline)
# Hosts lists (fast, strong baseline)
# Keep it minimal to avoid breaking sites.
c.content.blocking.hosts.lists = [
    "https://big.oisd.nl/",
]

# ABP lists (precise)
# Minimal strong set: EasyList + EasyPrivacy.
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
]

# Use a sane default editor (matches your dotfiles)
c.editor.command = ["nvim", "{file}", "+{line}"]

# Downloads
c.downloads.location.directory = "~/Downloads"
# Show downloads at the bottom (less intrusive with a bottom tabbar) and auto-hide finished items.
c.downloads.position = "bottom"
# milliseconds; -1 = never remove
c.downloads.remove_finished = 15000
# When prompted for filename, show both path + filename (more usable than path-only)
c.downloads.location.suggestion = "both"


# Window chrome
c.window.transparent = True
c.window.hide_decoration = False
# window.title_format may not be empty; use a single space to effectively hide the title.
c.window.title_format = " "
# ---------- Theme ----------
# Make theme import robust regardless of qutebrowser's sys.path behaviour.
import os
import sys

_config_dir = os.path.dirname(os.path.abspath(__file__))
_themes_dir = os.path.join(_config_dir, "themes")
if _themes_dir not in sys.path:
    sys.path.insert(0, _themes_dir)

import dracula

dracula.apply(c)

# --- Custom light tab/theme color (#F1F3F5) ---
# Keep explicit overrides after theme apply() so they take effect.
c.colors.tabs.bar.bg = "#F1F3F5"
# Unselected tabs
c.colors.tabs.even.bg = "#ECEFF3"
c.colors.tabs.odd.bg = "#ECEFF3"
c.colors.tabs.even.fg = "#5B6470"
c.colors.tabs.odd.fg = "#5B6470"
# Selected/current tab (visible gray highlight)
c.colors.tabs.selected.even.bg = "#AEB6C2"
c.colors.tabs.selected.odd.bg = "#AEB6C2"
c.colors.tabs.selected.even.fg = "#0A0A0A"
c.colors.tabs.selected.odd.fg = "#0A0A0A"
# Indicator accent
c.colors.tabs.indicator.start = "#4B5563"
c.colors.tabs.indicator.stop = "#4B5563"
c.colors.statusbar.normal.bg = "#F1F3F5"
c.colors.statusbar.normal.fg = "#111111"
c.colors.completion.category.bg = "#F1F3F5"
c.colors.completion.category.fg = "#111111"

# Fonts (keep it conservative; rely on system defaults)
# c.fonts.default_family = 'Berkeley Mono'
# c.fonts.default_size = '12pt'

# ---------- mpv ----------
# Keep qutebrowser default keybindings (no overrides).
# qutebrowser launched as a GUI app may not inherit your shell PATH, so use an absolute path.
# Usage:
#   :mpv   -> play current page in mpv (detached)
#   :mpv!  -> play current page in mpv (foreground, for debugging)

c.aliases["mpv"] = "spawn --detach /Users/bob/.local/bin/mpv-url {url}"
c.aliases["mpv!"] = "spawn /Users/bob/.local/bin/mpv-url {url}"
# Explicit policy overrides (requested): b = bilibili/default, y = youtube(<=480)
c.aliases["mpvb"] = "spawn --detach /Users/bob/.local/bin/mpv-url b {url}"
c.aliases["mpvy"] = "spawn --detach /Users/bob/.local/bin/mpv-url y {url}"

# ---------- Keybindings ----------
# Convenience: make ';' act like ':' (enter command mode) so you don't need Shift.
# This mirrors common Vim setups.
config.bind(";", "cmd-set-text :")

# mpv: (keep it simple)
# Use :mpv / :mpvb / :mpvy to play current page.
# Also provide :mf for hint-pick-a-link then play in mpv (no userscripts).

# mpv link-hint (command aliases only; no normal-mode keybindings)
c.aliases['mf'] = 'hint links spawn --detach /Users/bob/.local/bin/mpv-url {hint-url}'
c.aliases['mF'] = 'hint all spawn --detach /Users/bob/.local/bin/mpv-url {hint-url}'

# External browser hint-open
c.aliases['sf'] = 'hint links spawn --detach open -a "Safari" {hint-url}'
c.aliases['sF'] = 'hint all spawn --detach open -a "Safari" {hint-url}'
