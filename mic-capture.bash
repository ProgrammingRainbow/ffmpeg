#!/usr/bin/env bash

# Use date to generate a filename.
FILE="$(date '+%Y-%m-%d-%H-%M-%S').m4a"
DIRECTORY=~/Music

# pactl list short sources
A0_INPUT="alsa_input.usb-PreSonus_AudioBox_44_VSL_2256-00.analog-surround-40"

ffmpeg \
    -f pulse \
    -i "$A0_INPUT" \
    -ac 2 \
    -c:a aac \
    "$DIRECTORY/$FILE"
