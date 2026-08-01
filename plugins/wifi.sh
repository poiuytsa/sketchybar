#!/bin/sh

if ipconfig getsummary en0 | grep -q "LinkStatusActive : TRUE"; then
    sketchybar --set "$NAME" \
        icon="􀙇" \
        label=""
else
    sketchybar --set "$NAME" \
        icon="􀙈" \
        label=""
fi