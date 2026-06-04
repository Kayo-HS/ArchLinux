#!/bin/bash

# 1. Caminhos
DIR="$HOME/.config/archrice/wallpapers"
CACHE_WALL="$HOME/.cache/current_wallpaper"
WAYBAR_CONFIG="$HOME/.config/archrice/waybar/config"
WAYBAR_STYLE="$HOME/.config/archrice/waybar/style.css"

# 2. Seleção
if [ -n "$1" ]; then
    wall="$1"
else
    wall=$(find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.mp4" \) | shuf -n 1)
fi

[ ! -f "$wall" ] && exit 1
echo "$wall" > "$CACHE_WALL"

# 3. Identificar tipo
ext_lc=$(echo "${wall##*.}" | tr '[:upper:]' '[:lower:]')

# 4. Alternância e Pywal (Lógica corrigida para não travar)
if [ "$ext_lc" = "mp4" ]; then
    pkill swww
    pkill mpvpaper
    mpvpaper -o "no-audio --loop" '*' "$wall" &
    
    # IMPORTANTE: Se for vídeo, NÃO rodamos o 'wal -i'.
    # Mantemos as cores anteriores ou usamos uma imagem padrão para não travar o PC.
    echo "Vídeo detectado: Pulando extração de cores para evitar travamento."
else
    pkill mpvpaper
    swww query || swww init
    swww img "$wall" --transition-type wipe
    
    # Se for imagem estática, o Pywal funciona perfeitamente e rápido.
    wal -i "$wall"
fi

# 5. Reiniciar Waybar
pkill waybar
while pgrep -u $USER -x waybar >/dev/null; do sleep 0.1; done
waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &

