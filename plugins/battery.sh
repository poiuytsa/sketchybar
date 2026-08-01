#!/bin/sh

PERCENTAGE=$(pmset -g batt | grep -Eo '[0-9]+%' | tr -d '%')
CHARGING=$(pmset -g batt | grep "AC Power")

[ -z "$PERCENTAGE" ] && exit 0

if [ -n "$CHARGING" ]; then
    ICON="􀢋"
    COLOR="0xff34C759"          # Green
elif [ "$PERCENTAGE" -ge 20 ]; then
    ICON="􀛨"
    COLOR="0xffffffff"          # White
elif [ "$PERCENTAGE" -ge 10 ]; then
    ICON="􀺸"
    COLOR="0xffFFD60A"          # Yellow
else
    ICON="􀛪"
    COLOR="0xffFF453A"          # Red
fi

# Hide percentage when battery is almost full and not charging
if [ "$PERCENTAGE" -ge 95 ] && [ -z "$CHARGING" ]; then
    LABEL=""
else
    LABEL="${PERCENTAGE}%"
fi

sketchybar --set "$NAME" \
    icon="$ICON" \
    icon.color="$COLOR" \
    label="$LABEL"