#!/bin/bash

set -e
source utils.sh

DATA_PATH=$1
ERROR_FILE=$2
LOG_FILE="$DATA_PATH/blp.log"

NUM_FILES=$(find "$DATA_PATH" -type f -name '*.blp' -printf '.' | wc -c)

find "$DATA_PATH" -type f -name '*.blp' -print0 | \
	parallel -0 -n1 '/extract/BLPConverter -o {//} {}' > >(tee -a $LOG_FILE) 2> >(tee -a $ERROR_FILE) | \
	pv -ls $NUM_FILES -N "$(printf 'Converting %5d *.blp files' $NUM_FILES)" -cfpte >/dev/null
