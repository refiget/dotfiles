# Catppuccin Mocha theme for qutebrowser
# Matches the Mocha tones used in your tmux/nvim + SketchyBar.

from __future__ import annotations


def apply(c):
    # Catppuccin Mocha palette
    base = "#1e1e2e"
    mantle = "#181825"
    crust = "#11111b"

    text = "#cdd6f4"
    subtext0 = "#a6adc8"
    overlay0 = "#6c7086"

    surface0 = "#313244"
    surface1 = "#45475a"
    surface2 = "#585b70"

    blue = "#89b4fa"
    green = "#a6e3a1"
    peach = "#fab387"
    red = "#f38ba8"
    mauve = "#cba6f7"

    # --------- General UI ---------
    c.colors.webpage.bg = base

    # Completion
    c.colors.completion.fg = text
    c.colors.completion.odd.bg = mantle
    c.colors.completion.even.bg = mantle

    c.colors.completion.category.fg = mauve
    c.colors.completion.category.bg = mantle
    c.colors.completion.category.border.top = mantle
    c.colors.completion.category.border.bottom = mantle

    c.colors.completion.item.selected.fg = text
    c.colors.completion.item.selected.bg = surface0
    c.colors.completion.item.selected.border.top = surface0
    c.colors.completion.item.selected.border.bottom = surface0

    c.colors.completion.match.fg = peach

    c.colors.completion.scrollbar.fg = text
    c.colors.completion.scrollbar.bg = mantle

    # Downloads
    c.colors.downloads.bar.bg = mantle
    c.colors.downloads.start.fg = base
    c.colors.downloads.start.bg = blue
    c.colors.downloads.stop.fg = base
    c.colors.downloads.stop.bg = green
    c.colors.downloads.error.fg = base
    c.colors.downloads.error.bg = red

    # Hints
    c.colors.hints.fg = base
    c.colors.hints.bg = peach
    c.colors.hints.match.fg = blue

    # Keyhint
    c.colors.keyhint.fg = text
    c.colors.keyhint.suffix.fg = peach
    c.colors.keyhint.bg = mantle

    # Messages
    c.colors.messages.error.fg = base
    c.colors.messages.error.bg = red
    c.colors.messages.error.border = red

    c.colors.messages.warning.fg = base
    c.colors.messages.warning.bg = peach
    c.colors.messages.warning.border = peach

    c.colors.messages.info.fg = base
    c.colors.messages.info.bg = blue
    c.colors.messages.info.border = blue

    # Prompts
    c.colors.prompts.fg = text
    c.colors.prompts.bg = mantle
    c.colors.prompts.border = f"1px solid {surface1}"
    c.colors.prompts.selected.bg = surface0

    # --------- Statusbar ---------
    c.colors.statusbar.normal.bg = mantle
    c.colors.statusbar.normal.fg = text

    c.colors.statusbar.insert.bg = green
    c.colors.statusbar.insert.fg = base

    c.colors.statusbar.passthrough.bg = peach
    c.colors.statusbar.passthrough.fg = base

    c.colors.statusbar.private.bg = surface0
    c.colors.statusbar.private.fg = text

    c.colors.statusbar.command.bg = mantle
    c.colors.statusbar.command.fg = text
    c.colors.statusbar.command.private.bg = mantle
    c.colors.statusbar.command.private.fg = text

    c.colors.statusbar.url.fg = subtext0
    c.colors.statusbar.url.success.http.fg = green
    c.colors.statusbar.url.success.https.fg = green
    c.colors.statusbar.url.error.fg = red
    c.colors.statusbar.url.warn.fg = peach
    c.colors.statusbar.url.hover.fg = blue

    c.colors.statusbar.progress.bg = mauve

    # --------- Tabs ("tag bar") ---------
    # Premium look: slightly darker bar, soft inactive tabs, clear selected pill.
    c.tabs.background = True
    c.tabs.indicator.width = 3
    c.tabs.indicator.padding = {"top": 0, "bottom": 0, "left": 0, "right": 0}

    # Match the title-mask (mantle) and keep the strip cohesive.
    c.colors.tabs.bar.bg = mantle

    c.colors.tabs.odd.bg = mantle
    c.colors.tabs.odd.fg = subtext0
    c.colors.tabs.even.bg = mantle
    c.colors.tabs.even.fg = subtext0

    c.colors.tabs.selected.odd.bg = surface0
    c.colors.tabs.selected.odd.fg = text
    c.colors.tabs.selected.even.bg = surface0
    c.colors.tabs.selected.even.fg = text

    # Make the selected tab read as a "pill"
    c.colors.tabs.selected.odd.border.bottom = overlay0
    c.colors.tabs.selected.even.border.bottom = overlay0

    c.colors.tabs.indicator.start = peach
    c.colors.tabs.indicator.stop = mauve
    c.colors.tabs.indicator.error = red

    # Pinned tabs follow the same scheme
    c.colors.tabs.pinned.odd.bg = mantle
    c.colors.tabs.pinned.even.bg = mantle
    c.colors.tabs.pinned.selected.odd.bg = surface0
    c.colors.tabs.pinned.selected.even.bg = surface0

    # --------- Context menu ---------
    c.colors.contextmenu.menu.bg = mantle
    c.colors.contextmenu.menu.fg = text
    c.colors.contextmenu.selected.bg = surface0
    c.colors.contextmenu.selected.fg = text
    c.colors.contextmenu.disabled.bg = mantle
    c.colors.contextmenu.disabled.fg = overlay0

    # --------- Caret / selection ---------
    c.colors.selection.bg = surface2
    c.colors.selection.fg = text

    # Note: Keep fonts controlled in config.py; theme focuses on color.
