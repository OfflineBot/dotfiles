#!/bin/sh

action=${1:?usage: player.sh <play-pause|next|previous>}

players=$(playerctl -l 2>/dev/null) || exit 0
[ -n "$players" ] || exit 0

target=$(printf '%s\n' "$players" | grep -im1 spotify)

if [ -z "$target" ]; then
    for wanted in Playing Paused; do
        for p in $players; do
            [ "$(playerctl -p "$p" status 2>/dev/null)" = "$wanted" ] || continue
            target=$p
            break 2
        done
    done
fi

[ -n "$target" ] || target=$(printf '%s\n' "$players" | head -1)

exec playerctl -p "$target" "$action"
