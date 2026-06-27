#!/bin/bash

DIR="$HOME/.config/archrice/wallpapers"
CACHE_WALL="$HOME/.cache/current_wallpaper"
WAYBAR_CONFIG="$HOME/.config/archrice/waybar/config"
WAYBAR_STYLE="$HOME/.config/archrice/waybar/style.css"
WAYBAR_MERGED="/tmp/waybar-merged.css"

if [ -n "$1" ]; then
    wall="$1"
else
    wall=$(find "$DIR" -type f \( \
        -iname "*.jpg"  -o \
        -iname "*.jpeg" -o \
        -iname "*.png"  -o \
        -iname "*.mp4"  \
    \) | shuf -n 1)
fi

if [ ! -f "$wall" ]; then
    echo "Erro: arquivo não encontrado → $wall"
    exit 1
fi

echo "$wall" > "$CACHE_WALL"
echo "Aplicando wallpaper: $(basename "$wall")"

ext_lc="${wall##*.}"
ext_lc="${ext_lc,,}"

if [ "$ext_lc" = "mp4" ]; then

    pkill -x swww-daemon 2>/dev/null
    pkill -x mpvpaper    2>/dev/null
    sleep 0.3

    mpvpaper -o "no-audio --loop" '*' "$wall" &

    # Nome único por vídeo — evita o cache errado do pywal
    video_base=$(basename "${wall%.*}" | tr -cs '[:alnum:]_-' '_')
    FRAME_CACHE="/tmp/wf_${video_base}.jpg"

    echo "Extraindo frame para paleta de cores..."
    if command -v ffmpeg &>/dev/null; then
        ffmpeg -i "$wall" -ss 00:00:03 -vframes 1 -y "$FRAME_CACHE" 2>/dev/null
        if [ -f "$FRAME_CACHE" ]; then
            wal -i "$FRAME_CACHE" -n -q
        else
            echo "Falha ao extrair frame — usando última paleta salva."
        fi
    else
        echo "ffmpeg não encontrado — instale com: sudo pacman -S ffmpeg"
    fi

else

    pkill -x mpvpaper 2>/dev/null
    sleep 0.2

    if ! pgrep -x swww-daemon &>/dev/null; then
        swww-daemon &
        sleep 0.5
    fi

    swww img "$wall" \
        --transition-type wipe \
        --transition-duration 1.2 \
        --transition-fps 60

    wal -i "$wall" -n -q
    sleep 0.4
fi

pkill -x waybar 2>/dev/null
sleep 0.3

if [ -f "$HOME/.cache/wal/colors-waybar.css" ]; then
    cat "$HOME/.cache/wal/colors-waybar.css" "$WAYBAR_STYLE" > "$WAYBAR_MERGED"
else
    cp "$WAYBAR_STYLE" "$WAYBAR_MERGED"
fi

waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_MERGED" &
disown

echo "Pronto."