#!/bin/bash

set -e
source utils.sh

IN_PATH=$1
OUT_PATH=$2
ERROR_FILE=$3
SELECTED_LOCALES=$4
LOG_FILE="$OUT_PATH/mpq.log"

###############
# definitions #
###############

PATTERNS_SHARED=(
	"sound\\*"
)

PATTERNS_LOCALE_SHARED=(
	"interface\\talentframe\\*.blp"
	"interface\\icons\\*.blp"
	"interface\\spellbook\\*.blp"
	"interface\\paperdoll\\*.blp"
	"interface\\pictures\\*.blp"
	"interface\\PvPRankBadges\\*.blp"
	"interface\\FlavorImages\\*.blp"
	"interface\\glues\\charactercreate\\*.blp"
	"interface\\calendar\\holidays\\*.blp"
	"interface\\pvpframe\\*.blp"
)

PATTERNS_LOCALE=(
	"dbfilesclient\\*.dbc"
	"interface\\worldmap\\*.blp"
	"interface\\framexml\\globalstrings.lua*" # * at end to suppress error if not found
	"sound\\*"
)

MPQS_SHARED=(
	"common.MPQ"
	"expansion.MPQ"
	"lichking.MPQ"
	"patch.MPQ"
	"patch-2.MPQ"
	"patch-3.MPQ"
)

generate_locale_mpqs() {
	eval MPQS_LOCALE_$1=\( \
		"locale-$1.MPQ" \
		"speech-$1.MPQ" \
		"expansion-locale-$1.MPQ" \
		"expansion-speech-$1.MPQ" \
		"lichking-locale-$1.MPQ" \
		"lichking-speech-$1.MPQ" \
		"patch-$1.MPQ" \
		"patch-$1-2.MPQ" \
		"patch-$1-3.MPQ" \
	\)
}

#############
# execution #
#############

AVAILABLE_LOCALES=()
if [ -n "$SELECTED_LOCALES" ]; then
	MISSING_LOCALES=()
	IFS=',' read -ra SELECTED_LOCALES_ARR <<< "$SELECTED_LOCALES"
	for locale in "${SELECTED_LOCALES_ARR[@]}"; do
		if [ -d "$IN_PATH/$locale" ]; then
			AVAILABLE_LOCALES+=("$locale")
			generate_locale_mpqs "$locale"
		else
			MISSING_LOCALES+=("$locale")
		fi
	done
	if [ ${#MISSING_LOCALES[@]} -gt 0 ]; then
		error "could not find the following locale(s): ${MISSING_LOCALES[@]}"
	fi
else
	AVAILABLE_LOCALES=( $(find "$IN_PATH" -regextype posix-extended -maxdepth 1 -type d -regex ".*/[a-z]{2}[A-Z]{2}$" | grep -Po "[a-z]{2}[A-Z]{2}$") ) || true # suppress error if grep fails to find anything
fi

if [ ${#AVAILABLE_LOCALES[@]} -eq 0 ]; then
	error "no valid locale data found"
fi

echo "Found locale(s): ${AVAILABLE_LOCALES[@]}" | tee -a $LOG_FILE

for locale in "${AVAILABLE_LOCALES[@]}"; do
	generate_locale_mpqs "$locale"
done

generate_locale_mpqs test
NUM_JOBS=$(( ${#MPQS_SHARED[@]} * ${#PATTERNS_SHARED[@]} + ${#MPQS_LOCALE_test[@]} * ${#PATTERNS_LOCALE_SHARED[@]} + ${#MPQS_LOCALE_test[@]} * ${#PATTERNS_LOCALE[@]} * ${#AVAILABLE_LOCALES[@]}))

progress_start mpq $NUM_JOBS "Extracting MPQ archives"

function extractAll { # input, output, name of global variable with patterns
	inPath=$1
	eval inputs=\( \${$2[@]} \)
	outPath=$3
	eval patterns=\( \${$4[@]} \)

	if [ ! -r "$inPath" ]; then
		error "could not read archive $(highlight "$inPath")"
	fi

	for input in "${inputs[@]}"; do
		printf "%s\0" "${patterns[@]}" | \
			parallel -0 -n1 --halt now,fail=1 \
				"/extract/MPQExtractor -f -c -o \"$outPath\" -e {} \"$inPath/$input\"" > >(tee -a $LOG_FILE) 2> >(tee -a $LOG_FILE >> $ERROR_FILE) | \
				grep --line-buffered "^Opening" | xargs -I{} printf . >> "$(progress_increment_file mpq)"
	done
}

function extract_shared {
	extractAll "$IN_PATH" MPQS_SHARED "$OUT_PATH" PATTERNS_SHARED

	firstLocale=${AVAILABLE_LOCALES[0]}
	extractAll "$IN_PATH/$firstLocale" "MPQS_LOCALE_$firstLocale" "$OUT_PATH" PATTERNS_LOCALE_SHARED
}

function extract_locale {
	locale=$1
	outPath="$OUT_PATH/$locale"
	if ! mkdir -p "$outPath" ; then
		error "failed to create locale output folder $(highlight $outPath)"
	fi

	extractAll "$IN_PATH/$locale" "MPQS_LOCALE_$locale" "$outPath" PATTERNS_LOCALE
}

# start extraction jobs in parallel
extract_shared &

for locale in "${AVAILABLE_LOCALES[@]}"; do
	extract_locale "$locale" &
done

# wait for all jobs to finish
wait

progress_end mpq
