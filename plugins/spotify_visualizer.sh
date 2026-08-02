#!/bin/sh

PLAYER_STATE=$(osascript -e 'tell application "Spotify" to get player state' 2>/dev/null)

if [ "$PLAYER_STATE" != "playing" ]; then
    sketchybar --set "$NAME" label="⣀⣀⣀⣀⣀"
    exit
fi

CHARS=(
"⣀⣄⣶⣤⣀"
"⣄⣶⣿⣶⣄"
"⣶⣤⣄⣶⣷"
"⣤⣶⣤⣄⣀"
"⣀⣤⣶⣄⣀"
"⣶⣿⣶⣤⣄"
"⣄⣄⣶⣷⣤"
"⣤⣀⣄⣶⣿"
)

LABEL=${CHARS[$((RANDOM % ${#CHARS[@]}))]}

sketchybar --set "$NAME" label="$LABEL"