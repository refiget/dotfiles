# Dracula theme for qutebrowser
# Aligned with Neovim Dracula + Yazi Dracula Pro vibe.

from __future__ import annotations

def apply(c):
    # Dracula palette
    bg = '#282a36'
    fg = '#f8f8f2'
    sel_bg = '#44475a'
    sel_fg = fg

    purple = '#bd93f9'
    cyan = '#8be9fd'
    green = '#50fa7b'
    yellow = '#f1fa8c'
    orange = '#ffb86c'
    red = '#ff5555'
    pink = '#ff79c6'

    # Statusbar
    c.colors.statusbar.normal.bg = bg
    c.colors.statusbar.normal.fg = fg
    c.colors.statusbar.insert.bg = green
    c.colors.statusbar.insert.fg = '#282a36'
    c.colors.statusbar.command.bg = bg
    c.colors.statusbar.command.fg = fg
    c.colors.statusbar.command.private.bg = bg
    c.colors.statusbar.command.private.fg = fg

    c.colors.statusbar.url.fg = fg
    c.colors.statusbar.url.success.http.fg = green
    c.colors.statusbar.url.success.https.fg = green
    c.colors.statusbar.url.error.fg = red
    c.colors.statusbar.url.warn.fg = orange
    c.colors.statusbar.url.hover.fg = cyan

    c.colors.statusbar.progress.bg = purple

    # Tabs
    c.tabs.background = True
    c.tabs.indicator.width = 3
    c.tabs.indicator.padding = {'top': 0, 'bottom': 0, 'left': 0, 'right': 0}

    c.colors.tabs.bar.bg = bg

    c.colors.tabs.odd.bg = bg
    c.colors.tabs.odd.fg = fg
    c.colors.tabs.even.bg = bg
    c.colors.tabs.even.fg = fg

    c.colors.tabs.selected.odd.bg = sel_bg
    c.colors.tabs.selected.odd.fg = fg
    c.colors.tabs.selected.even.bg = sel_bg
    c.colors.tabs.selected.even.fg = fg

    c.colors.tabs.indicator.start = pink
    c.colors.tabs.indicator.stop = purple
    c.colors.tabs.indicator.error = red

    # Completion
    c.colors.completion.fg = fg
    c.colors.completion.odd.bg = bg
    c.colors.completion.even.bg = bg

    c.colors.completion.category.fg = purple
    c.colors.completion.category.bg = bg
    c.colors.completion.category.border.top = bg
    c.colors.completion.category.border.bottom = bg

    c.colors.completion.item.selected.fg = sel_fg
    c.colors.completion.item.selected.bg = sel_bg
    c.colors.completion.item.selected.border.top = sel_bg
    c.colors.completion.item.selected.border.bottom = sel_bg

    c.colors.completion.match.fg = yellow

    c.colors.completion.scrollbar.fg = fg
    c.colors.completion.scrollbar.bg = bg

    # Hints
    c.hints.border = f'1px solid {purple}'
    c.colors.hints.fg = '#282a36'
    c.colors.hints.bg = yellow
    c.colors.hints.match.fg = red

    # Messages
    c.colors.messages.error.bg = red
    c.colors.messages.error.fg = '#282a36'
    c.colors.messages.warning.bg = orange
    c.colors.messages.warning.fg = '#282a36'
    c.colors.messages.info.bg = bg
    c.colors.messages.info.fg = fg

    # Downloads
    c.colors.downloads.bar.bg = bg
    c.colors.downloads.start.bg = cyan
    c.colors.downloads.start.fg = '#282a36'
    c.colors.downloads.stop.bg = green
    c.colors.downloads.stop.fg = '#282a36'
    c.colors.downloads.error.bg = red
    c.colors.downloads.error.fg = '#282a36'

    # Prompt
    c.colors.prompts.bg = bg
    c.colors.prompts.fg = fg
    c.colors.prompts.border = f'1px solid {purple}'
    c.colors.prompts.selected.bg = sel_bg

    # Keyhint
    c.colors.keyhint.fg = fg
    c.colors.keyhint.bg = bg
    c.colors.keyhint.suffix.fg = cyan

    # Webpage (dark mode is a separate feature; keep it off by default)
    c.colors.webpage.bg = bg
