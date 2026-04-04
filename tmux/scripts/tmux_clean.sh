#!/usr/bin/env bash
set -euo pipefail

tmux_cmd=(tmux)
if [[ -n "${TMUX_SOCKET_NAME:-}" ]]; then
  tmux_cmd+=( -L "$TMUX_SOCKET_NAME" )
elif [[ -n "${TMUX_SOCKET_PATH:-}" ]]; then
  tmux_cmd+=( -S "$TMUX_SOCKET_PATH" )
fi

current_target=()
if [[ -n "${TMUX_PANE:-}" ]]; then
  current_target=( -t "$TMUX_PANE" )
fi

current_info="$(${tmux_cmd[@]} display-message "${current_target[@]}" -p '#{session_id}	#{session_name}')"
current_id="${current_info%%$'\t'*}"
current_name="${current_info#*$'\t'}"

if [[ -z "$current_id" || -z "$current_name" ]]; then
  echo "tmuxclean: failed to detect current session" >&2
  exit 1
fi

label="$current_name"
if [[ "$label" =~ ^[0-9]+__(.*)$ ]]; then
  label="${BASH_REMATCH[1]}"
elif [[ "$label" =~ ^[0-9]+[:_-](.*)$ ]]; then
  label="${BASH_REMATCH[1]}"
elif [[ "$label" =~ ^[0-9]+$ ]]; then
  label="main"
fi

label="${label//:/-}"
label="${label//__/-}"
[[ -n "$label" ]] || label="main"
new_name="1__${label}"

cleanup_suspend() {
  "${tmux_cmd[@]}" set-option -gu @session_manager_suspended >/dev/null 2>&1 || true
}
trap cleanup_suspend EXIT

"${tmux_cmd[@]}" set-option -gq @session_manager_suspended 1

while IFS= read -r session_id; do
  [[ -n "$session_id" ]] || continue
  [[ "$session_id" == "$current_id" ]] && continue
  "${tmux_cmd[@]}" kill-session -t "$session_id" >/dev/null 2>&1 || true
done < <("${tmux_cmd[@]}" list-sessions -F '#{session_id}')

"${tmux_cmd[@]}" rename-session -t "$current_id" "$new_name"
"${tmux_cmd[@]}" switch-client -t "$current_id" >/dev/null 2>&1 || true

echo "tmuxclean: kept $new_name"
