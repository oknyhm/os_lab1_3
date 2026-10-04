#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 SHOW_SCRIPT OUTPUT_PNG" >&2
  exit 2
fi

show_script=$1
output_png=$2
plasma_pid=$(pgrep -u "$(id -u)" -x plasmashell | head -n 1)
test -n "$plasma_pid"

read_env() {
  tr '\0' '\n' < "/proc/$plasma_pid/environ" | sed -n "s/^$1=//p" | head -n 1
}

export DISPLAY="$(read_env DISPLAY)"
export XAUTHORITY="$(read_env XAUTHORITY)"
export DBUS_SESSION_BUS_ADDRESS="$(read_env DBUS_SESSION_BUS_ADDRESS)"

test -n "$DISPLAY"
test -n "$XAUTHORITY"
test -n "$DBUS_SESSION_BUS_ADDRESS"
test -x "$show_script"
command -v xdotool >/dev/null

window_title="OSLAB3-EVIDENCE-$$"
nohup konsole --separate --geometry 1120x700+20+20 \
  -e env OSLAB3_TITLE="$window_title" "$show_script" \
  >/tmp/oslab3-evidence-konsole.log 2>&1 &
konsole_pid=$!
window_id=$(xdotool search --sync --onlyvisible --pid "$konsole_pid" | tail -n 1)
xdotool windowsize --sync "$window_id" 1120 700
xdotool windowmove --sync "$window_id" 20 20
xdotool windowactivate --sync "$window_id"
xdotool windowraise "$window_id"
sleep 2
spectacle -b -n -o "$output_png"
test -s "$output_png"
file "$output_png"
