#!/bin/bash

# ──────────────────────────────────────────────────────────────
#  autostart.sh
#  Chamado pelo hyprland.conf via:
#    exec-once = ~/.config/archrice/scripts/autostart.sh
#
#  Re-aplica o último wallpaper usado (ou sorteia um novo).
# ──────────────────────────────────────────────────────────────

CACHE_WALL="$HOME/.cache/current_wallpaper"
SCRIPT="$HOME/.config/archrice/scripts/changewallpaper.sh"

if [ -f "$CACHE_WALL" ]; then
    last_wall=$(cat "$CACHE_WALL")
    if [ -f "$last_wall" ]; then
        bash "$SCRIPT" "$last_wall"
        exit 0
    fi
fi

# Nenhum wallpaper anterior encontrado → sorteia um
bash "$SCRIPT"