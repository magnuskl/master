#!/usr/bin/env bash

/home/griff/Install/ffmpeg-nvenc/bin/ffmpeg \
    -probesize       50M                    \
    -analyzeduration 50M                    \
    -i               "$1"
