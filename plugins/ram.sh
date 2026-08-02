#!/bin/sh

# ---------- Settings ----------

HISTORY_FILE="/tmp/sketchybar_ram_history"

# ---------- Initialize History ----------

if [ ! -f "$HISTORY_FILE" ]; then
    printf "0\n0\n0\n0\n0\n" > "$HISTORY_FILE"
fi

# ---------- Current RAM ----------

RAM=$(memory_pressure | awk '/System-wide memory free percentage/ {print 100-$5}' | tr -d '%')

# ---------- Update History ----------

tail -n 4 "$HISTORY_FILE" > /tmp/ram_history_tmp
echo "$RAM" >> /tmp/ram_history_tmp
mv /tmp/ram_history_tmp "$HISTORY_FILE"

# ---------- Build Graph ----------

GRAPH=""

while read VALUE; do

    if [ "$VALUE" -lt 13 ]; then
        CHAR="▁"
    elif [ "$VALUE" -lt 26 ]; then
        CHAR="▂"
    elif [ "$VALUE" -lt 39 ]; then
        CHAR="▃"
    elif [ "$VALUE" -lt 52 ]; then
        CHAR="▄"
    elif [ "$VALUE" -lt 65 ]; then
        CHAR="▅"
    elif [ "$VALUE" -lt 78 ]; then
        CHAR="▆"
    elif [ "$VALUE" -lt 91 ]; then
        CHAR="▇"
    else
        CHAR="█"
    fi

    GRAPH="${GRAPH}${CHAR}"

done < "$HISTORY_FILE"

# ---------- Update ----------
sketchybar --set "$NAME" \
    icon="􀫦" \
    icon.color=0xffffffff \
    label="${RAM}% $GRAPH" \
    label.color=0xff64A8FF \
    label.highlight="${RAM}%" \
    label.highlight_color=0xffffffff
