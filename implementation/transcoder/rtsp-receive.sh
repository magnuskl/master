#!/usr/bin/env bash

INPUT='rtsp://localhost:8888/live.sdp'

/home/griff/Install/ffmpeg-nvenc/bin/ffplay                                    \
    -rtsp_flags listen                                                         \
                                                                               \
    $INPUT
