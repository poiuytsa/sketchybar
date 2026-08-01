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

# Hover
case "$SENDER" in
    mouse.entered)
        sketchybar --animate tanh 20 \
            --set spotify_group \
                background.border_color=0x28f2e0c8 \
            --set spotify.back \
                alpha=1.0 \
            --set spotify.playpause \
                alpha=1.0 \
            --set spotify.forward \
                alpha=1.0
        exit
        ;;
    mouse.exited)
        sketchybar --animate tanh 20 \
            --set spotify_group \
                background.border_color=0x14f2e0c8 \
            --set spotify.back \
                alpha=0.75 \
            --set spotify.playpause \
                alpha=0.75 \
            --set spotify.forward \
                alpha=0.75
        exit
        ;;
esac

SONG=$(osascript -e 'tell application "Spotify" to get name of current track')
ARTIST=$(osascript -e 'tell application "Spotify" to get artist of current track')

LABEL="$SONG • $ARTIST"

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
        label.max_chars=40 \
        label.scroll_duration=35 \
        scroll_texts=on \
        click_script="open -a Spotify" \
    \
    --set spotify.back \
        drawing=on \
        icon="􀊊" \
        icon.color=0xff1DB954 \
        alpha=0.75 \
    \
    --set spotify.playpause \
        drawing=on \
        icon="$PLAY_ICON" \
        icon.color=0xff1DB954 \
        alpha=0.75 \
    \
    --set spotify.forward \
        drawing=on \
        icon="􀊌" \
        icon.color=0xff1DB954 \
        alpha=0.75