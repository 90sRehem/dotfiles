#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

if [ "$1" = "$FOCUSED" ]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color=0xffe1e3e4 \
    label.color=0xff1e2030
else
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color=0x33ffffff \
    label.color=0xffffffff
fi
