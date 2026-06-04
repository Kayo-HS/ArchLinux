#!/bin/bash
hyprpaper -m ~/.config/archrice/wallpapers/rainy-street-mirror.3840x2160.mp4 &

swww img "$1"          # Ou o comando que você usa para mudar o wallpaper
wal -i "$1"            # Comando do Pywal para extrair as cores da imagem
