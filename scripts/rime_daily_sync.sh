#!/usr/bin/env bash
set -euo pipefail

SYNC_ROOT="$HOME/Library/Mobile Documents/com~apple~CloudDocs/RimeSync/sync"
LOG_FILE="$HOME/Library/Logs/rime-daily-sync.log"
LOCK_DIR="$SYNC_ROOT/.rime-daily-sync.lock"
BACKUP_ROOT="$SYNC_ROOT/_backups"

TARGET_FILES=(
  "custom_phrase.txt"
  "default.custom.yaml"
  "rime_ice.custom.yaml"
  "double_pinyin_flypy.custom.yaml"
  "squirrel.custom.yaml"
)

log() {
  mkdir -p "$(dirname "$LOG_FILE")"
  printf '[%s] %s\n' "$(date '+%F %T')" "$*" | tee -a "$LOG_FILE"
}

# Skip if not within scheduled window (missed runs should be skipped)
# Set RIME_SYNC_FORCE=1 for manual runs.
NOW_HOUR="$(date +%H)"
NOW_MIN="$(date +%M)"
if [[ "${RIME_SYNC_FORCE:-0}" != "1" ]]; then
  if [[ "$NOW_HOUR" != "08" ]] || (( 10#$NOW_MIN > 10 )); then
    log "skip: outside execution window (08:00-08:10), now=${NOW_HOUR}:${NOW_MIN}"
    exit 0
  fi
fi

# lock
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  log "skip: lock exists, another sync is running"
  exit 0
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

if [[ ! -d "$SYNC_ROOT" ]]; then
  log "error: sync root not found: $SYNC_ROOT"
  exit 1
fi

mapfile -t DEV_DIRS < <(find "$SYNC_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name '_backups' ! -name '.rime-daily-sync.lock' | sort)
if (( ${#DEV_DIRS[@]} < 2 )); then
  log "error: need at least 2 device dirs under $SYNC_ROOT"
  exit 1
fi

# only sync first two device dirs (your current two devices)
DEV_A="${DEV_DIRS[0]}"
DEV_B="${DEV_DIRS[1]}"

log "start sync: A=$(basename "$DEV_A") B=$(basename "$DEV_B")"

TS="$(date +%Y%m%d-%H%M%S)"
BK_DIR="$BACKUP_ROOT/$TS"
mkdir -p "$BK_DIR/$(basename "$DEV_A")" "$BK_DIR/$(basename "$DEV_B")"

copy_if_exists() {
  local src="$1" dst="$2"
  if [[ -f "$src" ]]; then
    cp -p "$src" "$dst"
  fi
  return 0
}

# backup current files
for f in "${TARGET_FILES[@]}"; do
  copy_if_exists "$DEV_A/$f" "$BK_DIR/$(basename "$DEV_A")/$f"
  copy_if_exists "$DEV_B/$f" "$BK_DIR/$(basename "$DEV_B")/$f"
done
log "backup created: $BK_DIR"

# merge custom_phrase.txt from A+B -> merged
MERGED_CP="$(mktemp)"
{
  echo '# Rime table'
  echo '# coding: utf-8'
  echo '#@/db_name\tcustom_phrase.txt'
  echo '#@/db_type\ttabledb'
  echo
} > "$MERGED_CP"

python3 - "$DEV_A/custom_phrase.txt" "$DEV_B/custom_phrase.txt" "$MERGED_CP" <<'PY'
import sys, re
from pathlib import Path

srcs=[Path(sys.argv[1]), Path(sys.argv[2])]
out=Path(sys.argv[3])

best={}  # term -> (code, quality)

def parse_line(line):
    line=line.strip('\n')
    if not line or line.lstrip().startswith('#'):
        return None
    parts=line.split('\t')
    if len(parts)<2:
        return None
    term=parts[0].strip()
    code=parts[1].strip() if len(parts)>=2 else ''
    q=1
    if len(parts)>=3:
        try:
            q=int(parts[2].strip())
        except:
            q=1
    if not term:
        return None
    return term,code,q

for p in srcs:
    if not p.exists():
        continue
    for line in p.read_text(errors='ignore').splitlines():
        row=parse_line(line)
        if not row:
            continue
        term,code,q=row
        prev=best.get(term)
        if prev is None or q>prev[1] or (q==prev[1] and len(code)>len(prev[0])):
            best[term]=(code,q)

with out.open('a', encoding='utf-8') as f:
    for term in sorted(best.keys()):
        code,q=best[term]
        f.write(f"{term}\t{code}\t{q}\n")
PY

# write merged custom phrase to both devices atomically
for d in "$DEV_A" "$DEV_B"; do
  tmp="$d/custom_phrase.txt.tmp.$$"
  cp "$MERGED_CP" "$tmp"
  mv "$tmp" "$d/custom_phrase.txt"
done
rm -f "$MERGED_CP"
log "custom_phrase merged and synced"

# for yaml files: pick newer one (mtime) and copy to both
mtime() { stat -f %m "$1" 2>/dev/null || echo 0; }
for f in "default.custom.yaml" "rime_ice.custom.yaml" "double_pinyin_flypy.custom.yaml" "squirrel.custom.yaml"; do
  A="$DEV_A/$f"
  B="$DEV_B/$f"
  if [[ ! -f "$A" && ! -f "$B" ]]; then
    continue
  fi

  src=""
  if [[ -f "$A" && -f "$B" ]]; then
    ma="$(mtime "$A")"
    mb="$(mtime "$B")"
    if (( ma >= mb )); then src="$A"; else src="$B"; fi
  elif [[ -f "$A" ]]; then
    src="$A"
  else
    src="$B"
  fi

  for d in "$DEV_A" "$DEV_B"; do
    tmp="$d/$f.tmp.$$"
    cp "$src" "$tmp"
    mv "$tmp" "$d/$f"
  done
  log "synced $f from $(basename "$(dirname "$src")")"
done

# prune backups older than 7 days
mkdir -p "$BACKUP_ROOT"
find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -mtime +7 -exec rm -rf {} +
log "pruned backups older than 7 days"

# reload squirrel on this Mac
if [[ -x "/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" ]]; then
  /Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel --reload >/dev/null 2>&1 || true
  log "squirrel reloaded"
fi

log "done"
