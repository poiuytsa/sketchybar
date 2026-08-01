#!/bin/sh

ART_DIR="/tmp/sketchybar_spotify"
RAW="$ART_DIR/raw.jpg"
OUT="$ART_DIR/art.png"
CACHE="$ART_DIR/color"

mkdir -p "$ART_DIR"

DATA=$(nowplaying-cli get artworkData 2>/dev/null)

[ -z "$DATA" ] && exit 0
[ "$DATA" = "null" ] && exit 0

echo "$DATA" | base64 -d > "$RAW" 2>/dev/null || exit 0

# Create a perfectly square album cover
magick "$RAW" \
    -gravity center \
    -resize 256x256^ \
    -extent 256x256 \
    -resize 32x32 \
    -bordercolor none \
    -border 1 \
    -blur 0x0.10 \
    "$OUT"
# Find the first non-dark dominant colour
HEX=$(magick "$RAW" \
    -resize 128x128 \
    -colors 8 \
    -format "%c\n" histogram:info: | \
    grep -oE '#[0-9A-Fa-f]{6}' | \
    while read H; do
        R=$((16#${H:1:2}))
        G=$((16#${H:3:2}))
        B=$((16#${H:5:2}))

        # Skip colours that are basically black
        if [ $((R+G+B)) -gt 90 ]; then
            echo "$H"
            break
        fi
    done)

[ -z "$HEX" ] && HEX="#242731"

HEX=${HEX#"#"}

R=$((16#${HEX:0:2}))
G=$((16#${HEX:2:2}))
B=$((16#${HEX:4:2}))

# Darken slightly (about 60%)
R=$((R * 75 / 100))
G=$((G * 75 / 100))
B=$((B * 75 / 100))

printf -v COLOR "0xdd%02X%02X%02X" "$R" "$G" "$B"

# Don't spam SketchyBar if nothing changed
OLD=""

if [ -f "$CACHE" ]; then
    OLD=$(cat "$CACHE")
fi

if [ "$COLOR" != "$OLD" ]; then
    echo "$COLOR" > "$CACHE"

    sketchybar \
        --set spotify_group \
            background.color="$COLOR"
fi

sketchybar \
    --set spotify.art \
        background.image="$OUT"