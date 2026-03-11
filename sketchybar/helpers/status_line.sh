#!/usr/bin/env sh
set -eu

SK=${SKETCHYBAR_BIN:-$(command -v sketchybar 2>/dev/null || true)}
if [ -z "$SK" ]; then
  if [ -x /opt/homebrew/bin/sketchybar ]; then
    SK=/opt/homebrew/bin/sketchybar
  elif [ -x /usr/local/bin/sketchybar ]; then
    SK=/usr/local/bin/sketchybar
  else
    exit 0
  fi
fi

TIME_STR=$(date '+%H:%M')

BATTERY_RAW=$(pmset -g batt 2>/dev/null | grep -Eo '[0-9]+%' | head -n1 || true)
BATTERY=${BATTERY_RAW:-'--%'}

MEM_GB=$(memory_pressure 2>/dev/null | awk -F': ' '/System-wide memory free percentage/ {gsub(/%/, "", $2); free=$2} END { if (free == "") exit 1; used=(100-free)*0.08; printf "%.1fG", used }' || true)
if [ -z "${MEM_GB:-}" ]; then
  MEM_GB=$(vm_stat 2>/dev/null | awk '
    /page size of/ {gsub(/[^0-9]/, "", $8); page_size=$8}
    /^Pages free/ {gsub(/\./, "", $3); free=$3}
    /^Pages active/ {gsub(/\./, "", $3); active=$3}
    /^Pages inactive/ {gsub(/\./, "", $3); inactive=$3}
    /^Pages speculative/ {gsub(/\./, "", $3); speculative=$3}
    /^Pages wired down/ {gsub(/\./, "", $4); wired=$4}
    /^Pages occupied by compressor/ {gsub(/\./, "", $5); compressed=$5}
    END {
      if (!page_size) page_size=4096;
      used_pages=active+inactive+speculative+wired+compressed;
      used_gb=used_pages*page_size/1024/1024/1024;
      printf "%.1fG", used_gb;
    }' || echo '?.?G')
fi

LABEL="时间:󰥔 ${TIME_STR}  状态󰾆 ${BATTERY}  󰍛 ${MEM_GB}"
"$SK" --set "$NAME" label="$LABEL"
