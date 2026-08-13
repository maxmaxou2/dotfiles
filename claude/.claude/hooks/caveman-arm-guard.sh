#!/bin/sh
# caveman-arm-guard — honor CAVEMAN_DEFAULT_MODE before any caveman hook runs.
#
# Both caveman hooks route through one global flag file, ~/.claude/.caveman-active:
# the activator deletes it under `off`, and the tracker re-reads it on every single
# prompt to decide whether to re-inject the ruleset. With two sessions open on
# opposite arms that file is shared mutable state, so each corrupts the other — the
# vanilla session picks up injections it was launched to avoid, and the caveman one
# silently loses its per-turn reinforcement while still looking caveman-active in
# the transcript. That second case is the dangerous one: correctly labelled,
# quietly under-treated, and it biases any measurement of compliance decay.
#
# CAVEMAN_DEFAULT_MODE is per-process and inherited from the shell that launched
# the session, so no other session can reach it. Gate on that instead, and let a
# vanilla session touch nothing global at all.
#
# Usage: caveman-arm-guard.sh [--badge] <command> [args...]
#   --badge   on the vanilla arm, print a statusline badge instead of nothing

badge=0
if [ "$1" = "--badge" ]; then
  badge=1
  shift
fi

# Any arm but `off` behaves exactly as before — including an unset variable, so
# sessions launched outside the alternating wrapper keep the normal default.
if [ "$CAVEMAN_DEFAULT_MODE" != "off" ]; then
  exec "$@"
fi

# Vanilla arm: no flag read, no flag write, no injection.
[ "$badge" -eq 1 ] && printf '\033[38;5;244m[VANILLA]\033[0m'
exit 0
