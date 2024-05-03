#!/bin/bash

set -e
source utils.sh

IN_PATH=/data
OUT_PATH=/out

if [ ! -d "$IN_PATH" ]; then
	error "cannot find the mpq-archives at $(highlight "$IN_PATH")"
fi

if [ ! -d "$OUT_PATH" ]; then
	error "output directory $(highlight "$OUT_PATH") does not exist"
fi

if ! mkdir -p "$OUT_PATH" ; then
	error "internal: could not create output folder $(highlight "$OUT_PATH")"
fi

# extract mpq archives
bash extract_mpq.sh $IN_PATH $OUT_PATH

# convert images & audio files in parallel
bash convert_blp.sh $OUT_PATH &
sleep 1 # give the first pv some time to start so the progress bars appear in order
bash convert_audio.sh $OUT_PATH &

wait

echo "Removing unneeded files ..."
find "$OUT_PATH" -type f \( -name '*.blp' -or -name '*.wav' -or -name '*.mp3' \) -delete

success "Done."
