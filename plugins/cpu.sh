#!/bin/sh

# ---------- Settings ----------

HISTORY_FILE="/tmp/sketchybar_cpu_history"
TEMP_FILE="/tmp/cpu_history_tmp"

# ---------- Initialize History ----------

if [ ! -f "$HISTORY_FILE" ]; then
    yes 0 | head -n 12 > "$HISTORY_FILE"
fi

# ---------- Current CPU ----------

CPU=$(top -l 2 -n 0 | awk '/^CPU/ {usage=$3+$5} END {printf "%.0f", usage}')

# ---------- CPU Icon Color ----------

if [ "$CPU" -lt 40 ]; then
    COLOR=0xff34C759
elif [ "$CPU" -lt 75 ]; then
    COLOR=0xffFFD60A
else
    COLOR=0xffFF453A
fi

# ---------- Update History ----------

tail -n 11 "$HISTORY_FILE" > "$TEMP_FILE"
echo "$CPU" >> "$TEMP_FILE"
mv "$TEMP_FILE" "$HISTORY_FILE"

# ---------- Smooth History (3-point moving average) ----------

VALUES=($(cat "$HISTORY_FILE"))
GRAPH=""

for ((i=0; i<12; i++)); do

    PREV=${VALUES[$((i-1))]}
    CUR=${VALUES[$i]}
    NEXT=${VALUES[$((i+1))]}

    [ -z "$PREV" ] && PREV=$CUR
    [ -z "$NEXT" ] && NEXT=$CUR

    AVG=$(((PREV + CUR + NEXT) / 3))

    if [ "$AVG" -lt 13 ]; then
        CHAR="▁"
    elif [ "$AVG" -lt 26 ]; then
        CHAR="▂"
    elif [ "$AVG" -lt 39 ]; then
        CHAR="▃"
    elif [ "$AVG" -lt 52 ]; then
        CHAR="▄"
    elif [ "$AVG" -lt 65 ]; then
        CHAR="▅"
    elif [ "$AVG" -lt 78 ]; then
        CHAR="▆"
    elif [ "$AVG" -lt 91 ]; then
        CHAR="▇"
    else
        CHAR="█"
    fi

    GRAPH="${GRAPH}${CHAR}"

done

# ---------- Update SketchyBar ----------

sketchybar --set "$NAME" \
    icon="􀧓" \
    icon.color="$COLOR" \
    label.color=0xffffffff \
    label="$GRAPH ${CPU}%"