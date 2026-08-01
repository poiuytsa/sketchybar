#!/bin/sh

VOLUME=$(osascript -e "output volume of (get volume settings)")
MUTED=$(osascript -e "output muted of (get volume settings)")

if [ "$MUTED" = "true" ]; then
    ICON="􀊣"
elif [ "$VOLUME" -ge 70 ]; then
    ICON="􀊩"
elif [ "$VOLUME" -ge 35 ]; then
    ICON="􀊧"
elif [ "$VOLUME" -gt 0 ]; then
    ICON="􀊥"
else
    ICON="􀊣"
fi

sketchybar --set "$NAME" \
    icon="$ICON" \
    label="${VOLUME}%"