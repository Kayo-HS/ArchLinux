#!/bin/bash

WAL_FILE="$HOME/.cache/wal/colors-waybar.css"
WAYBAR_CONFIG="$HOME/.config/archrice/waybar/config"
WAYBAR_STYLE="$HOME/.config/archrice/waybar/style.css"
WAYBAR_MERGED="/tmp/waybar-merged.css"

reload_waybar() {
    pkill -x waybar 2>/dev/null
    sleep 0.3

    # Mesmo merge que o changewallpaper.sh usa
    if [ -f "$WAL_FILE" ]; then
        cat "$WAL_FILE" "$WAYBAR_STYLE" > "$WAYBAR_MERGED"
    else
        cp "$WAYBAR_STYLE" "$WAYBAR_MERGED"
    fi

    waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_MERGED" &
    disown
}

# Garante que o Waybar está rodando na inicialização
if ! pgrep -x waybar &>/dev/null; then
    reload_waybar
fi

until [ -f "$WAL_FILE" ]; do
    sleep 1
done

inotifywait -m -e modify "$WAL_FILE" 2>/dev/null | while IFS= read -r _; do
    echo "$(date '+%H:%M:%S') Paleta atualizada → Recarregando Waybar..."
    reload_waybar
done