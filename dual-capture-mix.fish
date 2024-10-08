#!/usr/bin/env fish

# Use date to generate a filename.
set FILE "$(date '+%Y-%m-%d-%H-%M-%S').m4a"
set DIRECTORY ~/Music

# pactl list short sources
# The input is mic, output .monitor is the system sound.
set A0_INPUT "alsa_input.usb-PreSonus_AudioBox_44_VSL_2256-00.analog-surround-40"
set A1_INPUT "alsa_output.usb-PreSonus_AudioBox_44_VSL_2256-00.analog-surround-40.monitor"

# Mono to Stereo.
# Use pan to map channel 0 to channel 0 and 1.
set A0_STEREO "pan=stereo|c0=c0|c1=c0"

# High-pass and low-pass filters.
set A0_PASS "highpass=f=80, lowpass=f=15000"

# Record a noise profile from start to stop in seconds.
# Set noise floor with nf and noise reduction with nr.
set A0_DENOISER "\
    asendcmd=0 afftdn sn start,\
    asendcmd=1 afftdn sn stop,\
    afftdn=nr=20:nf=-55"

# Click remover.
set A0_CLICK "adeclick"

set A0_DEESSER "deesser"

# FIR Equalizer. entry(frequency,gain);
set A0_EQUALIZER "firequalizer=gain_entry='\
    entry(100,-1);\
    entry(156,-2);\
    entry(220,-1);\
    entry(311,-3);\
    entry(440,-6);\
    entry(622,-7);\
    entry(880,-5);\
    entry(1250,-2);\
    entry(1750,-5);\
    entry(2500,-2);\
    entry(3500,-1);\
    entry(5000,0);\
    entry(10000,0);\
    entry(20000,0)'"

# Compressor and expander. 2 channels attack|attack:release|release in seconds.
# in dB/out dB|in dB/out dB.
set A0_COMPRESSOR "compand=0.01|0.01:0.05|0.05:\
-180/-180|\
-54/-90|\
-51/-51|\
-48/-35|\
-42/-18|\
-36/-16|\
-30/-14|\
-24/-12|\
-18/-10|\
-12/-8|\
-6/-6|\
0/-6|\
20/-3"

set A0_VOLUME "volume=3dB"

# Limit output in dB. Don't auto level/normalize.
set A0_LIMIT "alimiter=level=false:limit=-3dB"

# A comma separated filter chain.
# [0:a] label is the first audio stream from the first file as the input.
# [aout] is a user defined label for the output of the first filter chain.
set A0_FILTER "\
    [0:a]\
    $A0_STEREO,\
    $A0_PASS,\
    $A0_DENOISER,\
    $A0_CLICK,\
    $A0_DEESSER,\
    $A0_EQUALIZER,\
    $A0_COMPRESSOR,\
    $A0_LIMIT\
    [mic]"

# Mix two labeled audio streams with specified weights.
set MIX_AUDIO "amix=inputs=2:weights=0.5 1"

# Resample audio with asynchronous mode.
set RESAMPLE "aresample=async=1"

# Second filter chain for additional processing.
set A1_FILTER "\
    [1:a]\
    [mic] $MIX_AUDIO,\
    $RESAMPLE\
    [aout]"

# Multiple colon separated filter chains.
set FILTER_COMPLEX "$A0_FILTER; $A1_FILTER"

ffmpeg \
    -f pulse \
    -i "$A0_INPUT" \
    -f pulse \
    -i "$A1_INPUT" \
    -filter_complex "$FILTER_COMPLEX" \
    -map "[aout]" \
    -ac 2 \
    -c:a aac \
    "$DIRECTORY/$FILE"


