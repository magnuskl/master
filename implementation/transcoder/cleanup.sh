#!/usr/bin/env bash

FILES="./livestream/*.m4s ./livestream/*.tmp ./livestream/*.m3u8"

for FILE in $(echo "$FILES")
do
    if test -e "$FILE"
    then
        rm -rf "$FILE"
    fi
done
