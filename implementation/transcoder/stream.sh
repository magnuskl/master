#!/usr/bin/env bash

# INPUT_STREAM='rtsp://root:2mmy10ger@192.168.0.20/live1s1.sdp'
INPUT_STREAM='./assets/video.mp4'

/home/griff/Install/ffmpeg-nvenc/bin/ffmpeg                                    \
    -fflags                   nobuffer                                         \
    -err_detect               ignore_err                                       \
    -rtsp_transport           tcp                                              \
    -i                        "$INPUT_STREAM"                                  \
                                                                               \
    -map                      0:v                                              \
    -map                      0:v                                              \
    -map                      0:v                                              \
                                                                               \
    -max_muxing_queue_size    1024                                             \
    -preset                   ll                                               \
    -codec                    h264_nvenc                                       \
    -s                        1080x1080                                        \
    -flags                    +cgop                                            \
    -g                        30                                               \
                                                                               \
    -b:v:0                    1000k                                            \
    -maxrate:v:0              1200k                                            \
    -bufsize:v:0              1000k                                            \
                                                                               \
    -b:v:1                    4000k                                            \
    -maxrate:v:1              4800k                                            \
    -bufsize:v:1              4000k                                            \
                                                                               \
    -b:v:2                    6000k                                            \
    -maxrate:v:2              7200k                                            \
    -bufsize:v:2              6000k                                            \
                                                                               \
    -hls_time                 2                                                \
    -hls_list_size            60                                               \
    -hls_delete_threshold     5                                                \
    -hls_allow_cache          0                                                \
                                                                               \
    -var_stream_map           'v:0 v:1 v:2'                                    \
    -hls_segment_filename     './livestream/stream_%v/segment_%d.ts'           \
    -hls_segment_type         mpegts                                           \
    -hls_flags                delete_segments+append_list+independent_segments \
    -master_pl_name           master.m3u8                                      \
                                                                               \
    -f                        hls                                              \
                                                                               \
    ./livestream/stream_%v/stream.m3u8
