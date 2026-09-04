#!/usr/bin/env bash
# Screenshot-Menü: Auswahl in einem floating kitty (fzf), danach slurp/grim.
# Das kitty-Fenster schließt sich VOR dem slurp, damit es nicht im Bild ist.

dir="$HOME/Pictures/Screenshots"
stamp="$(date '+%Y-%m-%d %H-%M-%S')"

case "${1:-}" in
    --pick)
        printf '%s\n' "Clipboard" "Save" "Save as ..." \
            | fzf --prompt="Screenshot> " --reverse --no-info > "$2"
        exit 0
        ;;
    --name)
        # fzf als Eingabefeld: leere Liste, Enter liefert die getippte Query
        : | fzf --prompt="Dateiname> " --print-query --reverse --no-info > "$2" || true
        exit 0
        ;;
esac

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

kitty --class menu-float --title "Screenshot" -e "$0" --pick "$tmp"
choice=$(head -n1 "$tmp")

file=""
case "$choice" in
    "Clipboard") ;;
    "Save")
        file="$dir/Screenshot from $stamp.png"
        ;;
    "Save as ...")
        kitty --class menu-float --title "Screenshot" -e "$0" --name "$tmp"
        name=$(head -n1 "$tmp")
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
