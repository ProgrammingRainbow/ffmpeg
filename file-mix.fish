#!/usr/bin/fish

# Use date to generate a filename.
set FILE "$(date '+%Y-%m-%d-%H-%M-%S').m4a"
set DIRECTORY ~/Music

# argv is the list of arguments passed to the shell script.
# Fish lists are 1 based. Allows passing in an audio filename.
set A0_INPUT "$argv[1]"

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
    afftdn=nr=18:nf=-55"

# Click remover.
set A0_CLICK "adeclick"

set A0_DEESSER "deesser"

# FIR Equalizer. entry(frequency,gain);
set A0_EQUALIZER "firequalizer=gain_entry='\
    entry(100,0);\
    entry(125,-9);\
    entry(160,-12);\
    entry(200,-7);\
    entry(250,-5);\
    entry(315,-9);\
    entry(400,-14);\
    entry(500,-11);\
    entry(630,-12);\
    entry(800,-5);\
    entry(1000,-2);\
    entry(1250,-5);\
    entry(1600,-6);\
    entry(2000,-3);\
    entry(2500,-3);\
    entry(3150,-4);\
    entry(4000,-4);\
    entry(5000,-6);\
    entry(6300,0);\
    entry(8000,-2);\
    entry(10000,0);\
    entry(12500,0);\
    entry(16000,0)'"

# Compressor and expander. 2 channels attack|attack:release|release in seconds.
# in dB/out dB|in dB/out dB.
set A0_COMPRESSOR "compand=0.01|0.01:0.02|0.02:\
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

# Limit output in dB. Don't auto level/normalize.
set A0_LIMIT "alimiter=level=false:limit=-3dB"

# A comma separated filter chain.
# [0:a] label is the first audio stream from the first file as the input.
# [aout] is a user defined label for the output of the first filter chain.
set A0_FILTER "\
    [0:a]\
    $A0_PASS,\
    $A0_DENOISER,\
    $A0_CLICK,\
    $A0_DEESSER,\
    $A0_EQUALIZER,\
    $A0_COMPRESSOR,\
    $A0_LIMIT,\
    $A0_STEREO\
    [aout]"


ffmpeg \
    -i $A0_INPUT \
    -filter_complex $A0_FILTER \
    -c:a aac \
    -map "[aout]" \
        "$DIRECTORY/$FILE"

