###########################
# color sequences & error #
###########################

T_ERROR="\033[0;31m"
T_SUCCESS="\033[0;32m"
T_HIGHLIGHT="\033[01;36m"
T_RESET="\033[0m"

function error {
	echo -e "${T_ERROR}[ERROR]${T_RESET} $1" >&2
	exit 1
}

function success {
	echo -e "[${T_SUCCESS}OK${T_RESET}] $1"
}

function highlight {
	echo -e "${T_HIGHLIGHT}$1${T_RESET}"
}


################
# progress bar #
################

declare -A __PROGRESS_PID=()
declare -A __PROGRESS_FILE=()
function progress_start {
	FILE=$(mktemp)
	tail -f -n +1 $FILE > >(pv -s "$2" -N "$3" -cfpte >/dev/null) &
	__PROGRESS_PID[$1]=$!
	__PROGRESS_FILE[$1]=$FILE
	disown $!
}

function progress_increment {
	if [ -z ${__PROGRESS_PID[$1]} ]; then
		error "internal: progress bar $1 not started"
	fi

	printf . >> ${__PROGRESS_FILE[$1]}
}

function progress_increment_file {
	if [ -z ${__PROGRESS_PID[$1]} ]; then
		error "internal: progress bar $1 not started"
	fi

	echo ${__PROGRESS_FILE[$1]}
}

function progress_end {
	if [ -z ${__PROGRESS_PID[$1]} ]; then
		error "internal: progress bar $1 not started"
	fi

	sleep 2 # give the last increment a chance to be displayed (otherwise progress bar might end before 100%)
	kill ${__PROGRESS_PID[$1]}
	rm ${__PROGRESS_FILE[$1]}
	unset '__PROGRESS_PID[$1]'
	unset '__PROGRESS_FILE[$1]'
}

function __progress_cleanup {
	for pid in "${__PROGRESS_PID[@]}"; do
		kill $pid
	done
	for file in "${__PROGRESS_FILE[@]}"; do
		rm $file
	done
}
trap __progress_cleanup EXIT
