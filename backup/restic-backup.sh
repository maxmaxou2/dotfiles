#!/bin/bash
# Back up $HOME with restic; prune old snapshots and verify the repository weekly.
#
#   restic-backup            back up now, then run maintenance if it is due
#   restic-backup maintain   run maintenance now
#   restic-backup <cmd> ...  any restic command on this Mac's repository,
#                            e.g. `restic-backup snapshots`, `restic-backup init`
#
# launchd runs the first form hourly. Repository, credentials and personal
# excludes live in ~/.config/restic (template: env.example), never in this repo.
set -uo pipefail

CONFIG_DIR="$HOME/.config/restic"
STATE_DIR="$HOME/.local/state/restic-backup"
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
MAINTENANCE_STAMP="$STATE_DIR/last-maintenance"
MAINTENANCE_INTERVAL_DAYS=7

# shellcheck source=env.example
source "$CONFIG_DIR/env"
mkdir -p "$STATE_DIR"

backup() {
    restic backup "$HOME" \
        --one-file-system --exclude-caches --skip-if-unchanged --retry-lock 1h \
        --exclude-file "$SCRIPT_DIR/excludes.txt" \
        --exclude-file "$CONFIG_DIR/excludes.local"
}

maintain() {
    restic unlock &&
        restic forget --prune --retry-lock 1h \
            --keep-within-hourly 2d --keep-within-daily 14d \
            --keep-within-weekly 2m --keep-within-monthly 1y &&
        restic check --read-data-subset 5% --retry-lock 1h
}

maintenance_due() {
    [ -z "$(find "$MAINTENANCE_STAMP" -mtime -"$MAINTENANCE_INTERVAL_DAYS" 2>/dev/null)" ]
}

# A laptop is often offline, so a failed run is only logged on healthchecks;
# the alert fires when no success arrives within the check's grace period.
# restic exits 3 when it could not read some files (on macOS usually a lost
# Full Disk Access grant), so only a clean 0 counts as success.
report() {
    local check_url="$1" job="$2" status="$3" log="$4"
    if [ "$status" -eq 0 ]; then
        tail -n 20 "$log" | curl -fsS --max-time 10 --retry 3 -o /dev/null --data-binary @- "$check_url"
    else
        { echo "exit code $status"; tail -n 50 "$log"; } |
            curl -fsS --max-time 10 --retry 3 -o /dev/null --data-binary @- "$check_url/log"
    fi
    printf '%s %s exit=%s\n' "$(date '+%F %T')" "$job" "$status" >>"$STATE_DIR/history.log"
}

run() {
    local job="$1" check_url="$2" status
    local log="$STATE_DIR/$job.log"
    if [ -t 1 ]; then
        export RESTIC_PROGRESS_FPS=0.0167
        "$job" 2>&1 | tee "$log"
        status=${PIPESTATUS[0]}
    else
        "$job" >"$log" 2>&1
        status=$?
    fi
    report "$check_url" "$job" "$status" "$log"
    return "$status"
}

case "${1:-}" in
"")
    run backup "$HC_BACKUP_URL" || exit
    if maintenance_due; then
        run maintain "$HC_MAINTAIN_URL" && touch "$MAINTENANCE_STAMP"
    fi
    ;;
maintain)
    run maintain "$HC_MAINTAIN_URL" && touch "$MAINTENANCE_STAMP"
    ;;
*)
    exec restic "$@"
    ;;
esac
