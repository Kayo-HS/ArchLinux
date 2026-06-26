#!/bin/bash

# ──────────────────────────────────────────────────────────────
#  changewallpaper.sh
#  Suporta .jpg / .jpeg / .png  →  swww  + pywal
#          .mp4                 →  mpvpaper + pywal via frame
# ──────────────────────────────────────────────────────────────

DIR="$HOME/.config/archrice/wallpapers"
CACHE_WALL="$HOME/.cache/current_wallpaper"
WAYBAR_CONFIG="$HOME/.config/archrice/waybar/config"
WAYBAR_STYLE="$HOME/.config/archrice/waybar/style.css"
WAYBAR_MERGED="/tmp/waybar-merged.css"   # CSS final (cores + estilo fundidos)
FRAME_CACHE="/tmp/wallpaper_frame.jpg"

# ── Seleção ────────────────────────────────────────────────────
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

# ── Tipo ───────────────────────────────────────────────────────
ext_lc="${wall##*.}"
ext_lc="${ext_lc,,}"

# ── Aplicar wallpaper e gerar paleta ──────────────────────────
if [ "$ext_lc" = "mp4" ]; then

    pkill -x swww-daemon 2>/dev/null
    pkill -x mpvpaper    2>/dev/null
    sleep 0.3

    mpvpaper -o "no-audio --loop" '*' "$wall" &

    echo "Extraindo frame para paleta de cores..."
    if command -v ffmpeg &>/dev/null; then
        ffmpeg -i "$wall" -ss 00:00:03 -vframes 1 -y "$FRAME_CACHE" 2>/dev/null
        if [ -f "$FRAME_CACHE" ]; then
            wal -i "$FRAME_CACHE" -n
        else
            echo "Falha ao extrair frame — usando última paleta salva."
        fi
    else
        echo "ffmpeg não encontrado — instale com: sudo pacman -S ffmpeg"
        echo "Usando última paleta salva."
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

# ── Recarregar Waybar com as novas cores ──────────────────────
pkill -x waybar 2>/dev/null
sleep 0.3

# Funde cores + estilo em um único arquivo para evitar cache do @import
if [ -f "$HOME/.cache/wal/colors-waybar.css" ]; then
    cat "$HOME/.cache/wal/colors-waybar.css" "$WAYBAR_STYLE" > "$WAYBAR_MERGED"
else
    echo "Aviso: paleta não encontrada, iniciando waybar sem cores."
    cp "$WAYBAR_STYLE" "$WAYBAR_MERGED"
fi

waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_MERGED" &
disown

echo "Pronto."