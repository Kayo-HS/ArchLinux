#!/bin/bash

WAYBAR_CONFIG="$HOME/.config/archrice/waybar/config"
WAYBAR_STYLE="$HOME/.config/archrice/waybar/style.css"
WAYBAR_MERGED="/tmp/waybar-merged.css"

sleep 0.5

# Descobre wallpaper atual pelo socket do mpvpaper
wall=$(python3 << 'PYEOF'
import socket, json, sys, os

candidates = ["/tmp/mpv-socket-All", "/tmp/mpvpaper"]

try:
    for f in sorted(os.listdir("/tmp")):
        if "mpv" in f.lower():
            p = f"/tmp/{f}"
            try:
                if os.stat(p).st_mode & 0o170000 == 0o140000:
                    if p not in candidates:
                        candidates.append(p)
            except:
                pass
except:
    pass

for sock_path in candidates:
    try:
        s = socket.socket(socket.AF_UNIX)
        s.settimeout(2)
        s.connect(sock_path)
        s.send(b'{"command":["get_property","path"]}\n')
        data = s.recv(4096).decode()
        s.close()
        result = json.loads(data).get("data", "")
        if result:
            print(result)
            sys.exit(0)
    except:
        continue

sys.exit(1)
PYEOF
)

if [ -z "$wall" ] || [ ! -f "$wall" ]; then
    echo "Erro: não foi possível determinar o wallpaper atual via socket."
    exit 1
fi

echo "Wallpaper detectado: $(basename "$wall")"

ext_lc="${wall##*.}"
ext_lc="${ext_lc,,}"

if [ "$ext_lc" = "mp4" ]; then
    if command -v ffmpeg &>/dev/null; then
        # Nome único por vídeo — evita o cache errado do pywal
        video_base=$(basename "${wall%.*}" | tr -cs '[:alnum:]_-' '_')
        FRAME_CACHE="/tmp/wf_${video_base}.jpg"

        ffmpeg -i "$wall" -ss 00:00:03 -vframes 1 -y "$FRAME_CACHE" 2>/dev/null
        [ -f "$FRAME_CACHE" ] && wal -i "$FRAME_CACHE" -n -q
    fi
else
    wal -i "$wall" -n -q
fi

sleep 0.3
pkill -x waybar 2>/dev/null
sleep 0.3

if [ -f "$HOME/.cache/wal/colors-waybar.css" ]; then
    cat "$HOME/.cache/wal/colors-waybar.css" "$WAYBAR_STYLE" > "$WAYBAR_MERGED"
else
    cp "$WAYBAR_STYLE" "$WAYBAR_MERGED"
fi

waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_MERGED" &
disown

echo "Cores atualizadas com sucesso."