#!/bin/sh

forward() {
    osascript -e 'tell application "Spotify" to play next track'
}
back() {
    osascript -e 'tell application "Spotify" to play previous track'
}
play() {
    osascript -e 'tell application "Spotify" to playpause'
}

PLAYER_STATE=$(osascript -e 'tell application "Spotify" to get player state' 2>/dev/null)

# Nothing playing
if [ "$PLAYER_STATE" != "playing" ] && [ "$PLAYER_STATE" != "paused" ]; then
    sketchybar \
        --set spotify drawing=off \
        --set spotify.back drawing=off \
        --set spotify.playpause drawing=off \
        --set spotify.forward drawing=off
    exit 0
fi

# Button clicks
case "$NAME" in
    spotify.back)
        back
        exit
        ;;
    spotify.playpause)
        play
        exit
        ;;
    spotify.forward)
        forward
        exit
        ;;
esac

SONG=$(osascript -e 'tell application "Spotify" to get name of current track')
ARTIST=$(osascript -e 'tell application "Spotify" to get artist of current track')
LABEL="$SONG • $ARTIST"


# Hard-clip the label to a fixed character budget so the item (and the
# capsule around it) never resizes based on title length. This replaces
# the old scroll_texts approach, which auto-sized to the full text before
# animating and could still push the item wider than its fixed `width`.
MAX_LEN=25
if [ "${#LABEL}" -gt "$MAX_LEN" ]; then
    LABEL="$(printf '%s' "$LABEL" | cut -c1-$((MAX_LEN - 1)))…"
fi

if [ "$PLAYER_STATE" = "playing" ]; then
    PLAY_ICON="􀊘"
else
    PLAY_ICON="􀊄"
fi

sketchybar \
    --set spotify \
        drawing=on \
        icon="" \
        icon.color=0xff1DB954 \
        label="$LABEL" \
        scroll_texts=off \
        click_script="open -a Spotify" \
    \
    --set spotify.back \
        drawing=on \
        icon="􀊊" \
        icon.color=0xff1DB954 \
    \
    --set spotify.playpause \
        drawing=on \
        icon="$PLAY_ICON" \
        icon.color=0xff1DB954 \
    \
    --set spotify.forward \
        drawing=on \
        icon="􀊌" \
        icon.color=0xff1DB954 \
