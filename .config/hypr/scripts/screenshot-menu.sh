#!/usr/bin/env bash

dir="$HOME/Pictures/Screenshots"
stamp="$(date '+%Y-%m-%d %H-%M-%S')"

choice=$(printf '%s\n' "Clipboard" "Save" "Save as ..." \
    | rofi -dmenu -p "Screenshot" -l 3) || exit 0

file=""
case "$choice" in
    "Clipboard") ;;
    "Save")
        file="$dir/Screenshot from $stamp.png"
        ;;
    "Save as ...")
        name=$(rofi -dmenu -p "Filename" -l 0 </dev/null) || exit 0
        [ -z "$name" ] && exit 0
        case "$name" in *.png) ;; *) name="$name.png" ;; esac
        file="$dir/$name"
        ;;
    *) exit 0 ;;
esac

geom=$(slurp) || exit 0

if [ -z "$file" ]; then
    grim -g "$geom" - | wl-copy \
        && notify-send -a Screenshot "Screenshot" "Copied to clipboard"
else
    mkdir -p "$dir"
    grim -g "$geom" "$file" \
        && notify-send -a Screenshot -i "$file" "Screenshot saved" "$file"
fi
