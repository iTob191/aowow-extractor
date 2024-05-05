#!/bin/bash

set -e
source utils.sh

DATA_PATH=$1
ERROR_FILE=$2
LOG_FILE_WAV="$DATA_PATH/wav.log"
LOG_FILE_MP3="$DATA_PATH/mp3.log"

NUM_FILES=$(find "$DATA_PATH" -type f -name '*.wav' -printf '.' | wc -c)
find "$DATA_PATH" -type f -name '*.wav' -print0 | \
	parallel -0 -n1 'echo {} && ffmpeg -hide_banner -loglevel error -y -i {} -acodec libvorbis -f ogg {}_' > >(tee -a $LOG_FILE_WAV) 2> >(tee -a $LOG_FILE_WAV >> $ERROR_FILE) | \
	pv -ls $NUM_FILES -N "$(printf 'Converting %5d *.wav files' $NUM_FILES)" -cfpte >/dev/null &

NUM_FILES=$(find "$DATA_PATH" -type f -name '*.mp3' -printf '.' | wc -c)
find "$DATA_PATH" -type f -name '*.mp3' -print0 | \
	parallel -0 -n1 'echo {} && ffmpeg -hide_banner -loglevel error -y -i {} -acodec libmp3lame -f mp3 {}_' > >(tee -a $LOG_FILE_MP3) 2> >(tee -a $LOG_FILE_MP3 >> $ERROR_FILE) | \
	pv -ls $NUM_FILES -N "$(printf 'Converting %5d *.mp3 files' $NUM_FILES)" -cfpte >/dev/null &

wait
