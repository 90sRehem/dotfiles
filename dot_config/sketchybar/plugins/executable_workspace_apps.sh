#!/usr/bin/env bash

app_icon() {
  case "$1" in
    "Ghostty"|"kitty"|"Alacritty"|"Warp"|"Terminal"|"iTerm2") printf '\xef\x92\x89' ;; #
    "Zen"|"Zen Browser"|"Safari"|"Firefox"|"Google Chrome"|"Brave Browser"|"Arc") printf '\xef\x82\xac' ;; #
    "Visual Studio Code"|"Code") printf '\xee\x9c\x8c' ;; #
    "Slack") printf '\xef\x86\x98' ;; #
    "Discord") printf '\xef\x8e\x92' ;; #
    "Spotify") printf '\xef\x86\xbc' ;; #
    "Finder") printf '\xef\x84\x95' ;; #
    "Mail") printf '\xef\x83\xa0' ;; #
    "Calendar") printf '\xef\x81\xb3' ;; #
    "Notes") printf '\xef\x89\x89' ;; #
    "Figma") printf '\xee\x97\xbc' ;; #
    "Telegram") printf '\xef\x8b\x86' ;; #
    "WhatsApp") printf '\xef\x88\xb2' ;; #
    *) printf '\xef\x84\xa8' ;; # ?
  esac
}

APPS=$(aerospace list-windows --workspace focused --format '%{app-name}' 2>/dev/null | sort -u)

ICONS=""
while IFS= read -r app; do
  [ -z "$app" ] && continue
  ICONS="$ICONS$(app_icon "$app") "
done <<< "$APPS"

ICONS="${ICONS% }"

sketchybar --set "$NAME" label="$ICONS" label.drawing=on
