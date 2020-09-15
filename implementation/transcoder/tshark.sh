#!/usr/bin/env bash

tshark                                     \
    -i enp2s0                              \
    -f "tcp or udp"                        \
    -f "dst port 80 or 443"                \
    -n                                     \
    -T fields                              \
    -E header=y                            \
    -E separator=,                         \
    -E quote=d                             \
    -e "frame.time_epoch"                  \
    -e "tcp.len"                           \
    -e "frame.len"                         \
    -e "ip.src"                            \
    -e "ip.dst"                            \
    -e "ipv6.src"                          \
    -e "ipv6.dst"                          \
    -e "tcp.srcport"                       \
    -e "tcp.dstport"                       \
    -e "tcp.analysis.ack_rtt"              \
    -e "tcp.analysis.lost_segment"         \
    -e "tcp.analysis.out_of_order"         \
    -e "tcp.analysis.fast_retransmission"  \
    -e "tcp.analysis.duplicate_ack"        \
    >> ./logs/tshark.csv
