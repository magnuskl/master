#!/usr/bin/env bash

# INPUT='./assets/sporty-woman.mov'
INPUT='./assets/video.mp4'

/home/griff/Install/ffmpeg-nvenc/bin/ffmpeg                                    \
    -re                                                                        \
    -stream_loop -1                                                            \
    -i $INPUT                                                                  \
    -c copy                                                                    \
    -f rtsp                                                                    \
    -rtsp_transport tcp                                                        \
                                                                               \
    rtsp://localhost:8888/live.sdp
