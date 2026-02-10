#!/usr/bin/env bash
set -euo pipefail

# hide entire right status if terminal width is below threshold
min_width=${TMUX_RIGHT_MIN_WIDTH:-90}
width=$(tmux display-message -p '#{client_width}' 2>/dev/null || true)
if [[ -z "${width:-}" || "$width" == "0" ]]; then
  width=$(tmux display-message -p '#{window_width}' 2>/dev/null || true)
fi
if [[ -z "${width:-}" || "$width" == "0" ]]; then
  width=${COLUMNS:-}
fi
if [[ -n "${width:-}" && "$width" =~ ^[0-9]+$ ]]; then
  if (( width < min_width )); then
    exit 0
  fi
fi

status_bg=$(tmux show -gqv status-bg)
[[ -z "$status_bg" || "$status_bg" == "default" ]] && status_bg="default"

# Keep segments on the terminal background to avoid color blocks on transparent themes
segment_bg="$status_bg"
segment_fg=$(tmux show -gqv '@status_fg')
[[ -z "$segment_fg" ]] && segment_fg="#ffb86c"  # 橙色前景
# 固定时间段为橙色，背景透明
host_bg="$status_bg"
host_fg="#ffb86c"
time_fmt="${TMUX_TIME_FMT:-%H:%M %a %m-%d}"
separator=""
right_cap=""
rainbarf_bg="#2e3440"
rainbarf_segment=""

# UI choice: default OFF to keep the right side stable (no width jitter)
rainbarf_toggle="${TMUX_RAINBARF:-0}"

case "$rainbarf_toggle" in
  0|false|FALSE|off|OFF|no|NO)
    rainbarf_toggle="0"
    ;;
  *)
    rainbarf_toggle="1"
    ;;
esac

if [[ "$rainbarf_toggle" == "1" ]] && command -v rainbarf >/dev/null 2>&1; then
  rainbarf_output=$(rainbarf --no-battery --no-remaining --no-bolt --tmux --rgb 2>/dev/null || true)
  rainbarf_output=${rainbarf_output//$'\n'/}
  if [[ -n "$rainbarf_output" ]]; then
    rainbarf_segment=$(printf '#[fg=%s,bg=%s]%s#[fg=%s,bg=%s]%s' \
      "$rainbarf_bg" "$status_bg" "$separator" \
      "$segment_fg" "$rainbarf_bg" "$rainbarf_output")
  fi
fi

# Input method (macOS): show EN/CN as a boxed pill
# Prefer im-select if available; otherwise read HIToolbox and infer from history.
im_segment=""
label=""

if command -v im-select >/dev/null 2>&1; then
  src=$(im-select -n 2>/dev/null || true)
  if [[ -n "${src:-}" ]]; then
    case "$src" in
      com.apple.keylayout.*)
        label="EN"
        ;;
      *)
        label="CN"
        ;;
    esac
  fi
else
  label=$(python3 - <<'PY'
import plistlib, os, sys
p=os.path.expanduser('~/Library/Preferences/com.apple.HIToolbox.plist')
try:
    with open(p,'rb') as f:
        d=plistlib.load(f)
except Exception:
    sys.exit(0)

# Prefer most-recent entry in AppleInputSourceHistory
hist = d.get('AppleInputSourceHistory') or []
cur = hist[0] if hist else None
cur_id = d.get('AppleCurrentKeyboardLayoutInputSourceID') or ''

def decide_from_entry(e):
    if not isinstance(e, dict):
        return ''
    kind = (e.get('InputSourceKind') or '')
    bundle = (e.get('Bundle ID') or '')
    mode = (e.get('Input Mode') or '')
    name = (e.get('KeyboardLayout Name') or '')
    if kind == 'Keyboard Layout':
        return 'EN'
    if 'SCIM' in bundle or 'Pinyin' in cur_id or 'Shuangpin' in mode:
        return 'CN'
    return ''

label = decide_from_entry(cur)
if not label:
    # fallback to current ID heuristics
    if cur_id.startswith('com.apple.keylayout.') and 'Pinyin' not in cur_id:
        label = 'EN'
    else:
        label = 'CN'

sys.stdout.write(label)
PY
)
fi

if [[ -n "${label:-}" ]]; then
  im_segment=$(printf '#[fg=#ffb86c,bg=#2e3440,bold] %s #[default]' "$label")
fi

now=$(date +"$time_fmt")
# Use a light separator to match the overall bar language
# Order: (optional) rainbarf -> IM -> time
if [[ -n "$im_segment" ]]; then
  time_text=" ${im_segment} · ${now}"
else
  time_text=" · ${now}"
fi

# Build a connector into the time segment using host colors
host_connector_bg="$status_bg"
if [[ -n "$rainbarf_segment" ]]; then
  host_connector_bg="$rainbarf_bg"
fi
host_prefix=$(printf '#[fg=%s,bg=%s,bold]%s#[fg=%s,bg=%s]' \
  "$host_fg" "$host_bg" "$time_text" \
  "$host_bg" "$status_bg")

printf '%s%s%s' \
  "$rainbarf_segment" \
  "$host_prefix" \
  "$right_cap"
