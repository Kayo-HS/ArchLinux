#!/bin/bash

WAL_FILE="$HOME/.cache/wal/colors-waybar.css"
WAYBAR_STYLE="$HOME/.config/archrice/waybar/style.css"

# Função para recarregar o Waybar
reload_waybar() {
    pkill waybar
    sleep 0.3
    waybar -c "$HOME/.config/archrice/waybar/config" -s "$WAYBAR_STYLE" &
}

# Monitora mudanças no arquivo de cores
inotifywait -m -e modify "$WAL_FILE" | while read; do
    echo "Cores atualizadas! Recarregando Waybar..."
    reload_waybar
done

# Força o Waybar a recarregar
pkill -SIGUSR2 waybar 2>/dev/null || {
    # Se não estiver rodando, inicia
    waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &
}