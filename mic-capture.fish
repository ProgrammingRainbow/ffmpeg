#!/usr/bin/env fish

# Use date to generate a filename.
set FILE "$(date '+%Y-%m-%d-%H-%M-%S').m4a"
set DIRECTORY ~/Music

# pactl list short sources
set A0_INPUT "alsa_input.usb-PreSonus_AudioBox_44_VSL_2256-00.analog-surround-40"

ffmpeg \
    -f pulse \
    -i "$A0_INPUT" \
    -ac 2 \
    -c:a aac \
    "$DIRECTORY/$FILE"

