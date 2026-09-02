#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/wallpaper_list"
TRANSITION=(--transition-type grow --transition-pos center --transition-fps 60 --transition-duration 1)

mapfile -t IMAGES < <(find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.webp' \))
if [ "${#IMAGES[@]}" -eq 0 ]; then
    echo "No images found in $WALL_DIR" >&2
    exit 1
fi

outputs() {
    awww query | awk '{print $2}' | tr -d ':'
}

current_image() {
    awww query | grep -F " $1: " | sed 's/.*currently displaying: image: //'
}

pick_random() {
    local candidates=() img excl
    for img in "${IMAGES[@]}"; do
        for excl in "$@"; do
            [ "$img" = "$excl" ] && continue 2
        done
        candidates+=("$img")
    done
    [ "${#candidates[@]}" -eq 0 ] && candidates=("${IMAGES[@]}")
    echo "${candidates[RANDOM % ${#candidates[@]}]}"
}

case "${1:-random}" in
    next)
        monitor="${2:-$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')}"
        img=$(pick_random "$(current_image "$monitor")")
        awww img -o "$monitor" "${TRANSITION[@]}" "$img"
        ;;
    random)
        used=()
        while read -r monitor; do
            [ -z "$monitor" ] && continue
            img=$(pick_random "${used[@]}")
            used+=("$img")
            awww img -o "$monitor" "${TRANSITION[@]}" "$img" &
        done < <(outputs)
        wait
        ;;
    *)
        echo "Usage: $(basename "$0") [random|next [monitor]]" >&2
        exit 1
        ;;
esac
