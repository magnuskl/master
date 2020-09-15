#!/usr/bin/env bash

INPUT='rtsp://localhost:8888/live.sdp'

/home/griff/Install/ffmpeg-nvenc/bin/ffmpeg                                                \
    -fflags                   nobuffer                                                     \
    -err_detect               ignore_err                                                   \
    -rtsp_transport           tcp                                                          \
    -rtsp_flags               +listen                                                      \
    -i                        $INPUT                                                       \
                                                                                           \
    -max_muxing_queue_size    1024                                                         \
                                                                                           \
    -map                      v:0                                                          \
    -map                      v:0                                                          \
    -map                      v:0                                                          \
                                                                                           \
    -s                        1080x1080                                                    \
    -c                        h264_nvenc                                                   \
      -preset                 ll                                                           \
      -flags                  +cgop                                                        \
      -g                      25                                                           \
                                                                                           \
    -b:v:0                    1000k                                                        \
    -maxrate:v:0              1200k                                                        \
    -bufsize:v:0              1000k                                                        \
                                                                                           \
    -b:v:1                    4000k                                                        \
    -maxrate:v:1              4800k                                                        \
    -bufsize:v:1              4000k                                                        \
                                                                                           \
    -b:v:2                    6000k                                                        \
    -maxrate:v:2              7200k                                                        \
    -bufsize:v:2              6000k                                                        \
                                                                                           \
    -media_seg_name           'chunk-stream$RepresentationID$-$Number$.m4s'                \
    -seg_duration             2                                                            \
    -window_size              0                                                            \
    -use_template             1                                                            \
    -use_timeline             0                                                            \
    -hls_playlist             0                                                            \
    -streaming                0                                                            \
    -index_correction         0                                                            \
    -dash_segment_type        mp4                                                          \
    -remove_at_exit           0                                                            \
                                                                                           \
    ./livestream/out.mpd
