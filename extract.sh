#!/bin/bash

DATA_PATH=$1
OUT_PATH=$2
LOCALES=$3

function print_help {
	echo ""
	echo "Usage: $0 <data directory> <output directory> [locales]"
	echo ""
	echo "  data directory:     path to the data directory containing the mpq files"
	echo "  output directory:   path to the output directory"
	echo "  locales:            optional, comma-separated list of locales to extract (default: all locales)"
}

function print_error {
	echo "error: $1" >&2
}

if [[ "$(uname -s)" =~ ^MINGW64_NT ]]; then
	print_error "MinGW / Git Bash detected. Please use the PowerShell script when running on Windows as MinGW's automatic path conversion tends to not work well with docker."
	exit 1
fi

if [ -z "$DATA_PATH" ]; then
	print_error "parameter <data directory> missing"
	print_help
	exit 1
elif [ ! -d "$DATA_PATH" ]; then
	print_error "cannot find the data directory at $DATA_PATH"
	exit 1
fi

if [ -z "$OUT_PATH" ]; then
	print_error "parameter <output directory> missing"
	print_help
	exit 1
elif [ ! -d "$OUT_PATH" ]; then
	if ! mkdir -p "$OUT_PATH" ; then
		print_error "could not create output directory $OUT_PATH"
		exit 1
	fi
fi

echo "Building docker container ..."
docker build --quiet --tag=aowow-extractor . >/dev/null || exit 1

echo "Starting docker container ..."
docker run --rm -it -v "$DATA_PATH:/data:ro" -v "$OUT_PATH:/out:rw" aowow-extractor "$LOCALES" || exit 1
