#!/usr/bin/env sh
set -eu

# Update the right-side resident pill to mimic the left app-glyph style.
# This script is executed by sketchybar with $NAME set.

SK=${SKETCHYBAR_BIN:-$(command -v sketchybar 2>/dev/null || echo /opt/homebrew/bin/sketchybar)}

running() {
  pgrep -f "$1" >/dev/null 2>&1
}

out=""
count=0

add_if_running() {
  pattern="$1"; glyph="$2"
  if running "$pattern"; then
    out="${out}${glyph}"
    count=$((count + 1))
  fi
}

add_if_running "Keyboard Maestro Engine" ":keyboard_maestro:"
add_if_running "kindaVim" ":vim:"
# Karabiner-Elements intentionally hidden (too noisy)
add_if_running "clash-verge|verge-mihomo|clash-verge-service" ":proton_vpn:"
add_if_running "AutoSwitchInput Pro|AutoSwitchInputTool" ":keyboard:"

if [ "$count" -eq 0 ]; then
  "$SK" --set "$NAME" drawing=off
  exit 0
fi

"$SK" --set "$NAME" drawing=on label="$out"
