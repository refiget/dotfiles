# qutebrowser config
# Theme: Dracula (aligned with Neovim + Yazi)
# Location: ~/.config/qutebrowser/config.py

config.load_autoconfig(False)

# ---------- Basics ----------
c.auto_save.session = True
c.completion.height = "35%"

# Use a sane default editor (matches your dotfiles)
c.editor.command = ["nvim", "{file}", "+{line}"]

# Downloads
c.downloads.location.directory = "~/Downloads"

# 去除标题栏（无边框窗口）
c.window.hide_decoration = True
# ---------- Theme ----------
# Make theme import robust regardless of qutebrowser's sys.path behaviour.
import os
import sys

_config_dir = os.path.dirname(os.path.abspath(__file__))
_themes_dir = os.path.join(_config_dir, "themes")
if _themes_dir not in sys.path:
    sys.path.insert(0, _themes_dir)

import catppuccin_mocha

catppuccin_mocha.apply(c)

# Tabs (bottom "tag bar")
c.tabs.position = "bottom"
# Slightly more padding for a premium look
c.tabs.padding = {"top": 6, "bottom": 6, "left": 8, "right": 8}
# Keep separators subtle
c.tabs.favicons.scale = 1.0

# Fonts (avoid missing "SF Pro 65" warning + keep UI consistent)
c.fonts.default_family = "JetBrainsMono Nerd Font"
c.fonts.default_size = "12pt"

# ---------- Stability (macOS QtWebEngine) ----------
# Workaround for crashes when pasting clipboard *images* into web inputs on some QtWebEngine builds.
# If this causes rendering/perf issues, remove it and upgrade qutebrowser instead.
c.qt.args += ["disable-gpu"]

# ---------- Workaround: Trusted Types breaking caret/"v" mode on some sites ----------
# Some pages enforce Trusted Types and block qutebrowser's injected helper JS from using innerHTML,
# which can break caret/visual navigation (v-mode) and show errors about TrustedHTML.
# This disables Trusted Types enforcement in Chromium.
# Security tradeoff: slightly weaker DOM XSS mitigations on those pages.
# Trusted Types workaround is handled by patching qutebrowser's caret.js on this machine.

# ---------- Ad blocking (lists) ----------
# Note: This mainly blocks page/asset ads & trackers. YouTube video ads may still appear.
c.content.blocking.enabled = True
c.content.blocking.method = "both"  # auto|adblock|hosts|both
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
]

# ---------- Input / IME (macOS) ----------
# Reduce IME friction by forwarding unbound keys to the page/IME.
# This helps with Chinese/Japanese IME composition getting interrupted.
c.input.forward_unbound_keys = "all"

# Make sure we reliably enter insert mode when focusing editable elements.
c.input.insert_mode.auto_enter = True
# IME candidate windows can momentarily shift focus; auto-leave can interrupt composition.
c.input.insert_mode.auto_leave = False

# ---------- Quality-of-life bindings ----------
# Keep defaults; add a couple of convenient ones.
config.bind("J", "tab-next")
config.bind("K", "tab-prev")

# Quickly open config in nvim
config.bind("<leader>ec", "edit-config")
config.bind("<leader>rc", "config-source")
