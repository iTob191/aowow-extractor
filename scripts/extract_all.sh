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

# error handling
ERROR_FILE=$(mktemp)

# extract mpq archives
bash extract_mpq.sh $IN_PATH $OUT_PATH $ERROR_FILE

# convert images & audio files in parallel
bash convert_blp.sh $OUT_PATH $ERROR_FILE &
sleep 1 # give the first pv some time to start so the progress bars appear in order
bash convert_audio.sh $OUT_PATH $ERROR_FILE &

wait

echo "Removing unneeded files ..."
find "$OUT_PATH" -type f \( -name '*.blp' -or -name '*.wav' -or -name '*.mp3' \) -delete

if [ -s "$ERROR_FILE" ]; then
	printf "\n${T_RED}There were errors during the extraction or conversion process:${T_RESET}\n\n"
	cat "$ERROR_FILE"
	printf "\n${T_YELLOW}See log the files in the output directory for more details.${T_RESET}\n"
fi

success "Done"
