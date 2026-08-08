#!/bin/sh
# Drives spotify.progress.fill / spotify.progress.track: two adjacent thin
# background bars whose widths are recalculated every tick so that, side by
# side, they read as a single progress line. No text, no icon — the two
# widths are the entire signal.

NOTCH_START=$(cat "$HOME/.config/sketchybar/.notch_start" 2>/dev/null)
[ -z "$NOTCH_START" ] && NOTCH_START=646

GROUP_END=$(sketchybar --query spotify_group 2>/dev/null | jq '(.bounding_rects."display-1".origin[0]) + (.bounding_rects."display-1".size[0])' 2>/dev/null)
case "$GROUP_END" in ''|*[!0-9.]*) GROUP_END=0 ;; esac

LEFT_MARGIN=20
RIGHT_MARGIN=30
MAX_WIDTH=240
MIN_WIDTH=20

AVAILABLE=$(awk \
  -v ns="$NOTCH_START" \
  -v ge="$GROUP_END" \
  -v lm="$LEFT_MARGIN" \
  -v rm="$RIGHT_MARGIN" \
  'BEGIN {
      w = ns - ge - lm - rm
      if (w < 0) w = 0
      printf "%d", w
  }')

if [ "$AVAILABLE" -lt "$MIN_WIDTH" ]; then
    sketchybar \
        --set spotify.progress.fill drawing=off width=0 \
        --set spotify.progress.track drawing=off width=0
    exit 0
fi
[ "$AVAILABLE" -gt "$MAX_WIDTH" ] && AVAILABLE=$MAX_WIDTH
TOTAL_WIDTH=$AVAILABLE

PLAYER_STATE=$(osascript -e 'tell application "Spotify" to get player state' 2>/dev/null)

# Nothing playing: hide both segments entirely.
if [ "$PLAYER_STATE" != "playing" ] && [ "$PLAYER_STATE" != "paused" ]; then
    sketchybar \
        --set spotify.progress.fill drawing=off width=0 \
        --set spotify.progress.track drawing=off width=0
    exit 0
fi

POSITION=$(osascript -e 'tell application "Spotify" to get player position' 2>/dev/null)
DURATION_MS=$(osascript -e 'tell application "Spotify" to get duration of current track' 2>/dev/null)

# Guard against blank/non-numeric values right at a track change.
case "$POSITION" in ''|*[!0-9.]*) POSITION=0 ;; esac
case "$DURATION_MS" in ''|*[!0-9]*) DURATION_MS=0 ;; esac

if [ "$DURATION_MS" -le 0 ] 2>/dev/null; then
    PERCENT=0
else
    PERCENT=$(awk -v pos="$POSITION" -v dur_ms="$DURATION_MS" 'BEGIN {
        p = pos / (dur_ms / 1000)
        if (p < 0) p = 0
        if (p > 1) p = 1
        print p
    }')
fi

FILL_WIDTH=$(awk -v p="$PERCENT" -v total="$TOTAL_WIDTH" 'BEGIN { printf "%d", p * total }')
TRACK_WIDTH=$((TOTAL_WIDTH - FILL_WIDTH))

echo "$(date +%T) pos=$POSITION dur=$DURATION_MS pct=$PERCENT fill=$FILL_WIDTH" >> /tmp/spotify_progress.log

# When paused, the position query above simply returns the same frozen
# value each tick, so the bar naturally stops advancing without any extra
# pause-specific branching.
sketchybar \
    --set spotify.progress.fill drawing=on width="$FILL_WIDTH" \
    --set spotify.progress.track drawing=on width="$TRACK_WIDTH"
