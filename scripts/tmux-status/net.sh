#!/usr/bin/env bash
set -euo pipefail

# Detect primary interface: try route default, fall back to en0/eth0
detect_iface() {
  if command -v route >/dev/null 2>&1; then
    # macOS/BSD
    local gw
    gw=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}' | head -n1)
    if [[ -n "$gw" ]]; then
      echo "$gw"
      return
    fi
  fi
  if command -v ip >/dev/null 2>&1; then
    local gw
    gw=$(ip route 2>/dev/null | awk '/default/ {print $5; exit}')
    if [[ -n "$gw" ]]; then
      echo "$gw"
      return
    fi
  fi
  for cand in en0 eth0 wlan0; do
    if [[ -d "/sys/class/net/$cand" || -n "$(ifconfig $cand 2>/dev/null)" ]]; then
      echo "$cand"
      return
    fi
  done
  echo ""
}

read_bytes() {
  local iface="$1"
  # Linux sysfs
  if [[ -r "/sys/class/net/$iface/statistics/rx_bytes" ]]; then
    cat "/sys/class/net/$iface/statistics/rx_bytes"
    cat "/sys/class/net/$iface/statistics/tx_bytes"
    return
  fi
  # macOS/BSD: use netstat -ib
  if command -v netstat >/dev/null 2>&1; then
    local line
    line=$(netstat -ib 2>/dev/null | awk -v dev="$iface" 'NR>1 && $1==dev {rx+=$7; tx+=$10} END {print rx, tx}')
    if [[ -n "$line" ]]; then
      echo "$line"
      return
    fi
  fi
  echo ""
}

format_rate() {
  local bytes="$1"
  local out=""
  if command -v python3 >/dev/null 2>&1; then
    out=$(python3 - "$bytes" <<'PY'
import sys
b=float(sys.argv[1])
units="BKMGT"
idx=0
while b>=1024 and idx<len(units)-1:
    b/=1024
    idx+=1
print(f"{b:.1f}{units[idx]}")
PY
    )
  else
    # awk fallback with one decimal
    if command -v awk >/dev/null 2>&1; then
      out=$(awk -v b="$bytes" 'BEGIN{u="BKMGT";i=1;v=b+0;while(v>=1024&&i<length(u)){v/=1024;i++}printf("%.1f%s",v,substr(u,i,1))}')
    else
      out="${bytes}B"
    fi
  fi
  printf '%6s' "$out"
}

iface=$(detect_iface)
if [[ -z "$iface" ]]; then
  exit 0
fi

read1=($(read_bytes "$iface"))
if [[ ${#read1[@]} -ne 2 ]]; then
  exit 0
fi
rx1=${read1[0]}
tx1=${read1[1]}
sleep 1
read2=($(read_bytes "$iface"))
if [[ ${#read2[@]} -ne 2 ]]; then
  exit 0
fi
rx2=${read2[0]}
tx2=${read2[1]}

# guard negative values
if (( rx2 < rx1 )); then rx2=$rx1; fi
if (( tx2 < tx1 )); then tx2=$tx1; fi

drx=$(( rx2 - rx1 ))
dtx=$(( tx2 - tx1 ))

rx_rate=$(format_rate "$drx")
tx_rate=$(format_rate "$dtx")

printf '%s %s' "$rx_rate" "$tx_rate"
