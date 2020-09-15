#!/usr/bin/env bash

# This scripts extends a DASH session by copying numbered segments.

LOOP=300   # Highest segment read in one loop
LOW=101    # Lowest segment generated
HIGH=1000  # Highest segment generated
REPS=3     # Number of representations

for i in {$LOW..$HIGH}
do
    for j in {0..$REPS}
    do
        cp chunk-stream$j-$((i % $LOOP + 1)).m4s chunk-stream$j-$i.m4s
    done
done
