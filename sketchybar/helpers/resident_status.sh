#!/usr/bin/env sh
set -eu

# Build a right-side glyph string like the left space preview.
# Output is sketchybar key=value lines.

running() {
  # $1 = extended regex for pgrep -f
  pgrep -f "$1" >/dev/null 2>&1
}

out=""
count=0

# Format: name|pattern_regex|glyph
# glyphs are sketchybar-app-font tokens (same style as left-side app glyphs)
cat <<'EOF' | while IFS='|' read -r name pattern glyph; do
Keyboard Maestro|Keyboard Maestro Engine|:keyboard_maestro:
kindaVim|kindaVim|:vim:
Karabiner-Elements|Karabiner-Menu|karabiner_console_user_server|Karabiner-Core-Service|:keyboard_maestro:
Clash Verge|clash-verge|verge-mihomo|clash-verge-service|:proton_vpn:
EOF
  # The Karabiner line contains extra '|' in the pattern; rebuild fields safely.
  if [ "$name" = "Karabiner-Elements" ]; then
    # Read the original full line from stdin is not available here; so hardcode the pattern.
    pattern='Karabiner-Menu|karabiner_console_user_server|Karabiner-Core-Service'
    glyph=':keyboard_maestro:'
  fi

  if running "$pattern"; then
    out="${out}${glyph}"
    count=$((count + 1))
  fi

done

# The loop runs in a subshell with the pipe, so we can't use out/count outside.
# Use a second pass without a pipe to keep state in this shell.
out=""
count=0

add_if_running() {
  name="$1"; pattern="$2"; glyph="$3"
  if running "$pattern"; then
    out="${out}${glyph}"
    count=$((count + 1))
  fi
}

add_if_running "Keyboard Maestro" "Keyboard Maestro Engine" ":keyboard_maestro:"
add_if_running "kindaVim" "kindaVim" ":vim:"
add_if_running "Karabiner-Elements" "Karabiner-Menu|karabiner_console_user_server|Karabiner-Core-Service" ":keyboard_maestro:"
add_if_running "Clash Verge" "clash-verge|verge-mihomo|clash-verge-service" ":proton_vpn:"

if [ "$count" -eq 0 ]; then
  echo "drawing=off"
  exit 0
fi

echo "drawing=on"
echo "label=$out"
