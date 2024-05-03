#!/bin/bash

set -e
source utils.sh

DATA_PATH=$1

NUM_FILES=$(find "$DATA_PATH" -type f -name '*.wav' -printf '.' | wc -c)
find "$DATA_PATH" -type f -name '*.wav' -print0 | \
	parallel -0 -n1 'ffmpeg -hide_banner -loglevel error -y -i {} -acodec libvorbis -f ogg {}_ && printf .' | \
	pv -s $NUM_FILES -N "$(printf 'Converting %5d *.wav files' $NUM_FILES)" -cfpte >/dev/null &

NUM_FILES=$(find "$DATA_PATH" -type f -name '*.mp3' -printf '.' | wc -c)
find "$DATA_PATH" -type f -name '*.mp3' -print0 | \
	parallel -0 -n1 'ffmpeg -hide_banner -loglevel error -y -i {} -acodec libmp3lame -f mp3 {}_ && printf .' | \
	pv -s $NUM_FILES -N "$(printf 'Converting %5d *.mp3 files' $NUM_FILES)" -cfpte >/dev/null &

wait
