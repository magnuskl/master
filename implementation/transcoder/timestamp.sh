#!/usr/bin/env bash

OUT_MPD='./livestream/out.mpd'
MANIFEST='./livestream/manifest.mpd'

inotifywait "$OUT_MPD"

sed -i "s/availabilityStartTime=\".*\"/availabilityStartTime=\"$(date --utc +%FT%TZ)\"/g" "$MANIFEST"
sed -i "s/publishTime=\".*\"/publishTime=\"$(date --utc +%FT%TZ)\"/g" "$MANIFEST"
