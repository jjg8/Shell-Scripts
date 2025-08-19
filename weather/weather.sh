#!/bin/bash --noprofile
#
# Name         Jira Cloud Dashboards—dates in ydhm format
# Version      2025-08-19.1
# Description  Uses curl or wget to get the CLI-friendly weather from https://wttr.in very configurable with CLI options to control output.
# Author       Jeremy Gagliardi
# URL          https://github.com/jjg8/Shell-Scripts/tree/main/weather
# License      GPL-3.0
#
shopt -s xpg_echo 2>/dev/null		# Echo expands escape sequences automatically without -e (not available before Solaris 9)
shopt -s extglob			# Enables extended pattern matching, the same as ksh's File Name Generation syntax



#####
##### Initial Declarations:
#####

typeset -i	Age=0			# Populated below if --output-* and --age are used
typeset		Args=			# Args is set below in the Get Location & Options section
typeset -i	Clear=0			# Default off
typeset -i	Columns=0		# Width of the terminal (set below)
typeset		CommandLine=$(printf " %q" "${@}") # Preserve the command line arguments
typeset -i	Debug=0			# Default off
typeset		debug_str=" (since we're in Debug mode, this did not run)" # appended to Verbose output in Debug mode
typeset		Directory=		# Populated below if --output-* is used
typeset		EXEC_found=		# Populated by the FindCommand function
typeset		EXEC_get=		# Will be set below after options are processed
typeset		EXEC_tput=/usr/bin/tput	# Full path to the tput command (further testing below)
typeset -i	ExitCode=0		# Set to the exit value ${?} after executing the EXEC_get command
typeset -i	Follow=0		# The Follow line from the weather URL is off by default
typeset -i	Help=0			# Default off
typeset -i	IgnoreTput=0		# Default off
typeset		InputDefLoc=~/.weather.location	# Default for InputLoc if used
typeset		InputDefRmt=~/.weather.remote	# Default for InputRmt if used
typeset		InputLoc=		# Set below to the input file to use for location info, unless --no-locfile or --locfile is used
typeset		InputRmt=		# Set below to the input file to use for remote info, unless --no-rmtfile or --rmtfile is used
typeset -i	KeepError=0		# Default don't keep an error in an OutputFile
typeset		Language='en'		# Default is English
typeset		Location=		# If Location is left blank, it will infer it from your public IP address or get it from InputLoc if applicable
typeset		Method='curl wget'	# Default commands (in order of preference) for which to get the weather URL
typeset -i	Mins=0			# Populated below if --output-* and --age are used
typeset -i	NoTestError=0		# Default don't suppress errors if test conditions aren't met (if --no-test-error is used, this gets set to true)
typeset		None=':-( No weather data )-:' # Message to use if it's not possible to download the weather
typeset		OKStr='Weather report:'	# String to search for in OutputFile to indicate successful download of the weather URL
typeset -l	option=			# Set as each option is parsed below (-l converts all values to lower case)
typeset		Options='F'		# Default don't print the Follow line from the weather URL
typeset		OutputAuto='.weather'	# Default file to use if --output-auto is used
typeset		OutputFile=/dev/stdout	# Default output is standard out, unless changed with --output-auto or --output-file
typeset		OutputStr=		# Used to capture command output, error messages, or to format a message for Verbose output
typeset		RemoteExec=		# Used to hold the executable COMMAND portion of RemoteInfo if specified
typeset		RemoteHost=		# Used to hold the HOST portion of RemoteInfo if specified
typeset		RemoteInfo=		# Set to the USER@HOST:COMMAND to get the weather from remotely - see Get Weather Remotely below
typeset		RemoteSed=		# Set to the sed-friendly version of RemoteInfo if specified
typeset		RemoteUser=		# Used to hold the USER portion of RemoteInfo if specified
typeset -i	Run=1			# Used to signal below if the get URL command should run or not
typeset -i	SecsFile=0		# Populated below if --output-* and --age are used
typeset -i	SecsNow=0		# Populated below if --output-* and --age are used
typeset -i	Test=0			# Default off
typeset -i	Timeout=6		# Default number of seconds to wait for the weather URL to respond
typeset -i	Tries=1			# Default only 1 try to get the URL, changed with --tries
typeset		URL='wttr.in'		# The weather URL
typeset		UrlHelp='/:help'	# URL's help page
typeset -i	Verbose=0		# Default off



#####
##### Define Functions:
#####

function CheckInt { [[ "${1}" != +([0-9]) ]] && Error "An integer was expected after option '${option}', but '${1}' was entered" ;}
function CheckStr { [[ -z "${1}" ]] && Error "A parameter was expected after option '${option}', but the value is empty" ;}

function Error
{
	Exec "printf '%b\\\n' '\\\n:-( ERROR:  ${1} )-:\\\n'"
	printf "%b\n" "\n:-( ERROR:  ${1} )-:\n"
	Exec 'exit 1\n'
	exit 1
}

function Exec { Verbose "%b\n" "EXEC:  ${1}" ;}

function FindCommand
{
	typeset	CommandName="${1}"
	typeset CommandPath="${2}"

	for Try in "${CommandPath}/${CommandName}" which
	do
		if [[ ${Try} == which ]]
		then
			Verbose "%b\n" "Trying:  which ${CommandName}"
			EXEC_found=$(which ${CommandName} 2>/dev/null)
		else
			EXEC_found="${Try}"
		fi

		if [[ -x "${EXEC_found}" ]]
		then
			Success "${CommandName} was found at '${EXEC_found}' and is executable"
			return 1
		else
			if (( Verbose ))
			then
				if [[ -e "${EXEC_found}" ]]
				then
					Verbose "%b\n" "${CommandName} was found at '${EXEC_found}' but is not executable"
				else
					if [[ -n ${EXEC_found} ]]
					then
						Verbose "%b\n" "${CommandName} not found at '${EXEC_found}'"
					else
						Verbose "%b\n" "${CommandName} not found"
					fi
				fi
			fi
			return 0
		fi
	done #for Try
}

function GetFromFile
{
	typeset		Information="${1}"
	typeset		InputFile="${2}"
	typeset		Retrieved=


	if [[ -n ${InputFile} ]]
	then
		Verbose "%b\n" "Attempting to get ${Information} from file '${InputFile}'..."
		if [[ -f "${InputFile}" && -r "${InputFile}" ]]
		then
			Verbose "%b\n" "${Information} file '${InputFile}' exists and is readable"
			##### In case it contains multiple spaces &/or tabs, expand it with printf to get only one space between words (e.g. New York)...
			Retrieved=$(printf "%s\n" $(cat "${InputFile}"))
			Verbose "%b\n" "Got ${Information} '${Retrieved}'"
		else
			if (( Verbose ))
			then
				if [[ -e "${InputFile}" ]]
				then
					[[ ! -f "${InputFile}" ]] && Verbose "%b\n" "${Information} file '${InputFile}' is not a regular file...ignoring"
					[[ ! -r "${InputFile}" ]] && Verbose "%b\n" "${Information} file '${InputFile}' is not readable...ignoring"
				else
					Verbose "%b\n" "${Information} file '${InputFile}' doesn't exist"
				fi
			fi
		fi
	fi

	OutputStr="${Retrieved}"
}

function Help
{
	typeset BaseName="${0##*/}"

	(( Columns <= 80 )) && Columns=80

	Verbose "%s\n" "Printing help page..."
	cat <<END_OF_Usage | fold -s -w ${Columns}

NAME
  Bash script '${BaseName}' - display the weather from https://${URL}/ at the command line

SYNOPSIS
  ${BaseName} [options] [Location] [View Option(s)]

DESCRIPTION
  options can be entered either lower/upper case

  -a n
  --age n
	When using --output-*, check to see if the age of output file is >n seconds
	If so, remove it and create a new one
	Otherwise, simply return the contents of the file and exit
	n must be a positive integer
	If output file is /dev/*, this option is ignored

  -c
  --clear
	Clear the terminal screen first before any output
	This attempts to use 'clear -x' first, which does not clear the terminal's scrollback buffer
	However, if that attempt fails, it will run 'clear' (which may end up clearing the buffer)

  --columns n
	Specify the terminal columns as n

  --curl
	Only attempt to use the command 'curl' to get the weather URL
	Normally, this script attempts to find the 'curl' command first, and if not found, it attempts to find 'wget' next
	This option overrides that behavior by only attempting to use 'curl'
	Opposite of option --wget

  -d	
  --debug
	Enable Debug mode (no command will be executed)
	Debug mode automatically enables option --verbose

  -f
  --follow
	Normally, this script omits the 'Follow' line from the weather URL
	Use this option to re-enable it

  -h
  --help
	Print this help screen and exit
	This screen is optimized for a terminal width of at least 80 characters, so adjust your terminal accordingly

  --ignore-tput
	If tput doesn't exist or doesn't work, ignore it and keep going
	No checking of the terminal width will occur

  -k
  --keep-error
	Normally, when using --output-*, if an error is encountered, it will remove the output file immediately after displaying it
	This turns off that behavior, especially if you want to honor --age in all circumstances
	This option is ignored if output file begins with /dev/*
	
  -l x
  --lang x
  --language x
	Set the language manually to the value x
	x must be a supported 2-letter code as specified in https://${URL}${UrlHelp}
	The default language code is 'en' (i.e. English)

  --locfile x
	Get the location from file x
	Quote x if complex
	If x doesn't exist or isn't readable, it's ignored
	If not specified with this option, x defaults to '${InputDefLoc}'

  --no-locfile
	Do not use a location file (see --locfile above)

  --no-rmtfile
	Do not use a remote file (see --rmtfile below)

  --no-test-error
	Do not output an error if the weather cannot be downloaded
	If so, simply output the default reply '${None}' and exit
	Other errors may occur, however

  --output-auto
	Redirect output into file ~/${OutputAuto}
	See UMASK NOTE in --output-file below

  --output-file x
	Redirect output into file x
	Quote x if complex
	If x does not contain a directory path, it will assume ~/x
	UMASK NOTE:  if x doesn't already exist, it will be created with the existing umask, which at present is '$(umask)'
	If that umask is undesired, change umask prior to running this script

  --remote [USER@]HOST[:COMMAND]
	Get weather data via SSH from the user account USER on host HOST, using command COMMAND
	Quote COMMAND if complex - if COMMAND is a relative path, it will be relative to USER's home directory
	You must have a private key corresponding to that user's authorized_keys, otherwise, you'll be prompted for the password every time
	All of the same arguments to the local command will be sent to the remote command
	"@" and ":" are literal
	HOST is mandatory and can be a host name, fully qualified domain name, or an IP address
	If USER@ is omitted, the current user on this host is used
	If :COMMAND is omitted, the full path to this command on this host is used

  --rmtfile x
	Get the remote info from file x
	Quote x if complex
	If x doesn't exist or isn't readable, it's ignored
	If not specified with this option, x defaults to '${InputRmtLoc}'

  --test
	Test for the following conditions - if met, return 1, otherwise 0
	- tput exists and is executable (unless --ignore-tput is used)
	- One of curl or wget exists and is executable

  -t n
  --timeout n
	Set the timeout manually to the value n
	n must be a positive integer, and it represents the number of seconds to wait for the URL to respond
	n defaults to 5

  --tries n
	Set n to the total number of times to try to download the URL
	n defaults to 1

  -v
  --verbose
	Enable Verbose mode
	All variables and commands are printed to the screen prepended with 'V:' to distinguish it from regular output

  --wget
	Only attempt to use the command 'wget' to get the weather URL
	See the --curl option for default behavior
	Opposite of option --curl

  Location
	After all options have been processed, specify the Location as the next parameter.
	Omitting the Location causes ${URL} to get your location automatically from your public IP address.
	See the web page https://${URL}${UrlHelp} for supported location types.
	Do not enter the '/' character as part of the Location (it is automatically added).
	Quote Location if it contains whitespace (e.g. 'New York').
	To specify View Option(s) without specifying a Location, enter Location as ''.

  View Option(s)
	After all options and the Location have been entered, specify View Option(s) as the next paramter(s).
	See the web page https://${URL}${UrlHelp} for valid View Options.
	View Options may be entered as a single paramter (e.g. 0Fn) or separated (e.g. 0 F n).

	To view https://${URL}${UrlHelp} at the command line, run this script with the Location equal to :help

  Exit status:
	0	if OK,

	1	if any error with the script occurs,

	n	as value n if either the 'curl' or 'wget' command (whichever was chosen or found first) exits with a positive value.

AUTHOR
  This '${BaseName}' script was written by Jeremy Gagliardi.
  The '${URL}' web site was created by Igor Chubin.

COPYRIGHT
  This '${BaseName}' script is copyright © 2024 by Jeremy Gagliardi.  No license.  You may copy it if you give me full attribution as its creator.  See the '${URL}' web site for its copyright information.  Jeremy Gagliardi has no affiliation with Igor Chubin.  This '${BaseName}' script is absolutely free: you are free to change and redistribute it with proper attribution.  There is NO WARRANTY whatsoever.

END_OF_Usage

	Exec "exit 0\n"
	exit 0
}

function NoData
{
	Exec "printf '%b\\\n' '${None}'"
	printf "%b\n" "${None}"
	Exec "exit 1\n"
	exit 1
}

function Success { Verbose "%b\n" " (-: ${1} :-)" ;}

function Verbose { (( Verbose )) && printf "${1}" "V:${2}" ;}



#####
##### Set umask for newly crated files:
#####

umask 0022 # Revoke write from group & other


#####
##### Get Options:
#####

InputLoc="${InputDefLoc}"
InputRmt="${InputDefRmt}"

while (( ${#*} ))
do
	option="${1}"
	case "${option}" in
	  @(-a|--age))		shift;CheckInt "${1}"; Age=${1}; shift		;; # Age of OutputFile is checked with this
	  @(-c|--clear))	shift;Clear=1					;; # Clear the terminal screen first
	  --columns)		shift;Columns=${1}; shift			;;
	  --curl)		shift;Method='curl'				;; # Only attempt to use curl
	  @(-d|--debug))	shift;Debug=1					;; # Enable Debug mode (no command will be executed)
	  @(-f|--follow))	shift;Follow=1					;; # Enable the Follow line from the weather URL
	  @(-h|--help))		shift;Help=1					;; # Print the Help page and exit
	  --ignore-tput)	shift;IgnoreTput=1				;; # Ignore checking of tput and the terminal width
	  @(-k|--keep-error))	shift;KeepError=1				;; # Enable keeping an error in OutputFile
	  @(-l|--lang?(uage)))	shift;Language=${1}; shift			;; # Set the Language manually to the next parameter
	  --locfile)		shift;InputLoc="${1}"; shift			;; # Set InputLoc manually to the next parameter
	  --no-locfile)		shift;InputLoc=					;; # Don't use InputLoc
	  --no-rmtfile)		shift;InputRmt=					;; # Don't use InputRmt
	  --no-test-error)	shift;NoTestError=1				;; # Do not output an error if a test condition is unmet
	  --output-auto)	shift;OutputFile="${OutputAuto}"		;; # Set OutputFile to OutputAuto
	  --output-file)	shift;CheckStr "${1}"; OutputFile="${1}"; shift	;; # Set OutputFile manually to the next parameter
	  --remote)		shift;RemoteInfo="${1}"; shift			;; # The USER@HOST:COMMAND to get the weather remotely
	  --rmtfile)		shift;InputRmt="${1}"; shift			;; # Set InputRmt manually to the next parameter
	  --test)		shift;Test=1					;; # Enable test mode
	  @(-t|--timeout))	shift;CheckInt "${1}"; Timeout=${1}; shift	;; # Set the Timeout manually to the next parameter
	  --tries)		shift;CheckInt "${1}"; Tries=${1}; shift	;; # Set total Tries to the next parameter
	  @(-v|--verbose))	shift;Verbose=1					;; # Enable Verbose mode (all actions are printed to the screen)
	  --wget)		shift;Method='wget'				;; # Only attempt to use wget
	  *)			break						;; # If not recognized as an option, preserve the rest as parameters
	esac
done #while


#####
##### Process Options & Error Handling:
#####

##### Debug mode automatically enables Verbose mode...
(( Debug )) && Verbose=1

if (( Clear ))
then
	Exec 'clear -x 2>/dev/null'
	clear -x 2>/dev/null
	if (( ${?} ))
	then
		Verbose "%b\n" 'Above command failed'
		Exec 'clear'
		clear
	fi
fi

Verbose "\n%b\n" "Command Line:  '${0}'${CommandLine}"

(( Timeout < 1 )) && Error "Invalid timeout '${Timeout}'; timeout (in seconds) must be a positive integer"

(( Test )) && Verbose "%s\n" 'Option --test was used'

FindCommand tput /usr/bin
EXEC_tput="${EXEC_found}"
if [[ ! -x "${EXEC_tput}" ]]
then
	if (( IgnoreTput ))
	then
		Verbose "%b\n" "  ...but we're ignoring it since --ignore-tput was used"
	else
		if (( Test ))
		then
			Verbose "%s\n" 'echo 0'
			echo 0
			Verbose "%s\n\n" 'exit 0'
			exit 0
		elif (( ! Help ))
		then
			if (( NoTestError ))
			then
				NoData
			else
				Error "tput command not found"
			fi
		fi
	fi
fi

if (( Columns <= 0 ))
then
	if (( IgnoreTput ))
	then
		Verbose "%b\n" "Terminal width:  unknown since --ignore-tput was used"
	else
		Exec "Columns=\$('${EXEC_tput}' cols)"
		Columns=$("${EXEC_tput}" cols)
		Verbose "%b\n" "Terminal width:  '${Columns}'"
		  if (( Columns < 31 ))
		then
			(( ! Help )) && Error "Terminal width of '${Columns}' is not wide enough to display the weather.
Expand your terminal to at least 31 for the most basic weather.
Expand to at least 63 for 'narrow' output.
Expand to at least 125 for full output."
		elif (( Columns < 63 ))
		then
			Verbose "%b\n" "Terminal width<63, set Options+='0'"
			Options+='0'
		elif (( Columns < 125 ))
		then
			Verbose "%b\n" "Terminal width<125, set Options+='n'"
			Options+='n'
		fi
	fi
fi


(( Help )) && Help


##### If RemoteInfo is defined...
if [[ -n ${InputRmt} && -z ${RemoteInfo} ]]
then
	GetFromFile 'Remote Info' "${InputRmt}"
	RemoteInfo="${OutputStr}"
fi
if [[ -n ${RemoteInfo} ]]
then
	#####
	##### Get Weather Remotely:
	#####

	Verbose "%s\n" "RemoteInfo='${RemoteInfo}'"


	##### Remove RemoteInfo from CommandLine...

	RemoteSed="${RemoteInfo//\//\\/}"
	CommandLine=$( printf "%s" "${CommandLine}" | sed s/"--remote[[:space:]]${RemoteSed}"//g )
	Verbose "%b\n" "Command Line is now: ${CommandLine}"


	#####
	# Break up RemoteInfo into its 3 parts:
	#####

	##### USER...

	if [[ ${RemoteInfo} == *@* ]]
	then
		RemoteUser="${RemoteInfo%%@*}"
		RemoteInfo="${RemoteInfo#*@}"
	else
		RemoteUser=${USER}
	fi

	##### COMMAND...

	if [[ ${RemoteInfo} == *:* ]]
	then
		RemoteExec="${RemoteInfo##*:}"
		RemoteInfo="${RemoteInfo%%:*}"
	else
		RemoteExec="${0}"
	fi

	##### HOST...

	RemoteHost=${RemoteInfo}


	##### Show the results in Verbose mode...

	Verbose "%s\n" "RemoteUser=${RemoteUser}"
	Verbose "%s\n" "RemoteHost=${RemoteHost}"
	Verbose "%s\n" "RemoteExec=${RemoteExec}"


	##### Get the weather remotely...

	printf "%s" "From ${RemoteHost} "

	if (( Debug ))
	then
		Verbose "%b\n" "Need to execute:  ssh ${RemoteUser}@${RemoteHost} -- ${RemoteExec} --columns ${Columns}${CommandLine}"
	else
		Exec "ssh ${RemoteUser}@${RemoteHost} -- ${RemoteExec} --columns ${Columns}${CommandLine}"
		ssh ${RemoteUser}@${RemoteHost} -- ${RemoteExec} --columns ${Columns}${CommandLine}
	fi


	##### Exit here to skip the rest of the script...

	Exec "exit 0\n"
	exit 0
#else
	##### Proceed below...
fi

for Check in ${Method}
do
	case ${Check} in
	  curl)
		FindCommand curl /usr/bin
		##### If found, stop processing futher Methods...
		(( ${?} )) && break
		;;
	  wget)
		FindCommand wget /usr/bin
		##### If found, stop processing futher Methods...
		(( ${?} )) && break
		;;
	  *)
		##### Any other Method set...
		Error "Unknown method set to '${Check}'; check the Method variable in script '${0}'"
	esac
done #for Check
EXEC_get="${EXEC_found}"

if [[ -x "${EXEC_get}" ]]
then
	if (( Test ))
	then
		Verbose "%s\n" 'echo 1'
		echo 1
		Verbose "%s\n\n" 'exit 0'
		exit 0
	fi
else
	if (( Test ))
	then
		Verbose "%s\n" 'echo 0'
		echo 0
		Verbose "%s\n\n" 'exit 0'
		exit 0
	fi

	typeset	Commands=
	typeset ItThem=

	  if [[ ${Method} == *curl* && ${Method} != *wget* ]]
	then
		Commands='curl command'
		ItThem='it'
	elif [[ ${Method} != *curl* && ${Method} == *wget* ]]
	then
		Commands='wget command'
		ItThem='it'
	else
		Commands='Both curl & wget commands'
		ItThem='one of them'
	fi
	if (( NoTestError ))
	then
		NoData
	else
		Error "${Commands} not found; cannot get weather without ${ItThem}"
	fi
fi

if [[ -n ${Language} ]]
then
	if [[ ${Language} == auto ]]
	then
		Verbose "%b\n" 'Language is auto'
		Exec 'eval $(locale)'
		##### Get Language from the LANG variable outputted by the locale command...
		eval $(locale)
		##### Get first 2 letters of LANG only...
		Exec "Language=${LANG:0:2}"
		Language=${LANG:0:2}
	fi
	##### If Language does not equal exactly 2 letters...
	if [[ ${Language} != [[:alpha:]][[:alpha:]] ]]
	then
		Error "Invalid language code '${Language}'.\n  Code must be 2 letters (e.g. en).\n  See https://${URL}${UrlHelp} for a supported list."
	else
		##### Set the Language option for the get command...
		  if [[ ${EXEC_get##*/} == curl ]]
		then
			Exec "Language=\" -H 'Accept-Language: ${Language}'\""
			Language=" -H 'Accept-Language: ${Language}'"
		elif [[ ${EXEC_get##*/} == wget ]]
		then
			Exec "Language=\" --header='Accept-Language: ${Language}'\""
			Language=" --header='Accept-Language: ${Language}'"
		fi
	fi
fi

Verbose "%b\n" "Output (including errors) to:  '${OutputFile}'"
##### If OutputFile doesn't contain a directory, prepend the user's home directory...
[[ "${OutputFile}" != */* ]] && OutputFile="$(cd ~; /bin/pwd)/${OutputFile}"
Directory="${OutputFile%/*}"
Verbose "%b\n" "Output to directory:  '${Directory}/'"

if [[ ! -r "${OutputFile}" || ! -w "${OutputFile}" ]]
then
	if [[ -d "${Directory}" ]]
	then
		if [[ ! -r "${Directory}" || ! -w "${Directory}" || ! -x "${Directory}" ]]
		then
			Error "You have insufficient permissions to directory '${Directory}'"
		else
			Success "Directory '${Directory}' already exists and you have sufficient permissions to it"
		fi
	elif [[ -e "${Directory}" ]]
	then
		Error "Specified path '${Directory}' is not a directory"
	else
		if (( Debug ))
		then
			Verbose "%b\n" "Need to execute:  mkdir -p '${Directory}' 2>&1${debug_str}"
		else
			Exec "mkdir -p '${Directory}' 2>&1"
			OutputStr=$(mkdir -p "${Directory}" 2>&1)
			if [[ ! -d "${Directory}" || ! -r "${Directory}" || ! -w "${Directory}" || ! -x "${Directory}" ]]
			then
				Error "Make directory '${Directory}' failed with message '${OutputStr}'"
			else
				Success "Make directory '${Directory}' succeeded"
			fi
		fi
	fi
fi

if [[ -e "${OutputFile}" ]]
then
	if [[ "${Directory}" == '/dev' || -f "${OutputFile}" ]]
	then
		if [[ ! -r "${OutputFile}" || ! -w "${OutputFile}" ]]
		then
			Error "File '${OutputFile}' exists, but you have insufficient permissions to it"
		fi
	else
		Error "File '${OutputFile}' exists but is not a regular file"
	fi
else
	if (( Debug ))
	then
		Verbose "%b\n" "Need to execute:  touch '${OutputFile}' 2>&1${debug_str}"
	else
		Exec "touch '${OutputFile}' 2>&1"
		OutputStr=$(touch "${OutputFile}" 2>&1)
		if [[ ! -f "${OutputFile}" || ! -r "${OutputFile}" || ! -w "${OutputFile}" ]]
		then
			Error "Make file '${OutputFile}' failed with message '${OutputStr}'"
		else
			Success "Make file '${OutputFile}' succeeded"
		fi
		##### I created OutputFile, so set Age to 0 to skip checking it below...
		Age=0
	fi
fi

if [[ -r "${OutputFile}" && -w "${OutputFile}" ]]
then
	Success "File '${OutputFile}' exists and you have sufficient permissions to it"
	if [[ "${OutputFile}" == /dev/* ]]
	then
		Verbose "%b\n" "File '${OutputFile}' matches /dev/*...skipping age check"
		Age=0
	fi
	if (( Age > 0 ))
	then
		typeset -a LsArray=( $(ls -l --time-style +%s "${OutputFile}") )
		SecsFile=${LsArray[5]}
		SecsNow=$(( $(date +%s) - SecsFile ))

		##### When the weather is downloaded successfully, OKStr will be present, and if not, treat it as an error...
		if (( ! $(grep -c "${OKStr}" "${OutputFile}") ))
		then
			Verbose "%b\n" "File '${OutputFile}' does NOT contain '${OKStr}'...aging file automatically"
			if (( KeepError ))
			then
				Verbose "%b\n" '  ...but --keep-error was used, so ignoring'
			else
				##### Set SecsNow to Age+1, so it'll trigger removal below...
				SecsNow=$(( Age+1 ))
			fi
		fi

		if (( SecsNow > Age ))
		then
			##### OutputFile is more than Age seconds old, so remove it and it'll make a new one below...
			Verbose "%b\n" "Output file age '${SecsNow}s' exceeds --age '${Age}s'"
			if (( Debug ))
			then
				Verbose "%b\n" "Need to execute:  rm '${OutputFile}'${debug_str}"
			else
				Exec "rm '${OutputFile}'"
				rm "${OutputFile}"
				Verbose "%b\n" "File '${OutputFile}' removed"
			fi
			SecsNow=0
		else
			##### OutputFile is <=Age seconds old, so keep using that one.
			Verbose "%b\n" "Output file age '${SecsNow}s' <= --age '${Age}s'...keeping file"
			Run=0
		fi
	fi
fi


if (( Run ))
then
	#####
	##### Get Location & Options:
	#####

	GetFromFile 'Location' "${InputLoc}"
	Location="${OutputStr}"

	if [[ -z ${Location} ]]
	then
		Verbose "%b\n" 'Location is blank, so attempting to get it from the next parameter...'
		##### In case ${1} contains multiple spaces &/or tabs, expand it with printf to get only one space between words (e.g. New York)...
		Location=$(printf "%s\n" ${1})
	fi

	##### Now, replace all [[:space:]] character(s) with '+' (e.g. New+York)...
	Location="${Location//[[:space:]]/+}"
	if [[ -n ${Location} ]]
	then
		Verbose "%b\n" "Got location '${Location}'"
	else
		Verbose "%b\n" "Location is blank"
	fi
	shift

	##### If Follow is enabled, omit 'F' from Options, which would suppress the Follow line...
	(( Follow )) && Options="${Options//F/}"

	##### For all Options and command line paramters ${@}, append all to Args...
	for Parameter in ${Options} "${@}"; do Args+="${Parameter}"; done

	##### If Args is not null, prepend a '?'...
	[[ -n ${Args} ]] && Args="?${Args}"

	##### Setup Options according to the EXEC_get method...
	  if [[ ${EXEC_get##*/} == curl ]]
	then
		(( Tries > 0 )) && Tries+=-1
		Options="-fsS --retry ${Tries} --max-time ${Timeout}${Language} '${URL}/${Location}${Args}'"
	elif [[ ${EXEC_get##*/} == wget ]]
	then
		(( Tries < 1 )) && Tries=1
		Options="--no-verbose -O- --compression=auto --tries=${Tries} --timeout=${Timeout}${Language} '${URL}/${Location}${Args}'"
	fi


	#####
	##### Get the weather:
	#####

	Exec				"'${EXEC_get}' ${Options} 2>&1 | awk '{ if(\$0~/URL:http:/){} else { if(\$1=="Weather"){gsub(/\+/," ")}; print \$0 } }' >'${OutputFile}'"
	if (( ! Debug ))
	then
				eval	 "${EXEC_get}" ${Options} 2>&1 |\
						awk '{ if($0~/URL:http:/){} else { if($1=="Weather"){gsub(/\+/," ")}; print $0 } }' \
						>"${OutputFile}"
				ExitCode=${?}
	fi
fi

if [[ "${OutputFile}" != /dev/* ]]
then
	if (( Debug ))
	then
		Run=1
	else
		##### When the weather is downloaded successfully, OKStr will be present, and if not, treat it as an error...
		if (( $(grep -c "${OKStr}" "${OutputFile}" 2>/dev/null) ))
		then
			Success "File '${OutputFile}' contains '${OKStr}'"
			Run=1
		else
			Verbose "%b\n" "File '${OutputFile}' does NOT contain '${OKStr}'"
			##### Set Run to 0, so it'll trigger the error below
			Run=0
		fi
	fi

	if (( Run || KeepError ))
	then
		if (( SecsNow == 0 ))
		then
			OutputStr='just now'
		else
			OutputStr=
			Mins=$(( SecsNow/60 ))
			(( Mins > 0 )) && OutputStr="${Mins}m"
			SecsNow=$(( SecsNow - (Mins*60) ))
			OutputStr+="${SecsNow}s ago"
		fi
		Exec "printf '%s' '(${OutputStr}) '"
		printf "%s" "(${OutputStr}) "
	fi

	if (( Run ))
	then
		Verbose "%b:" "cat '${OutputFile}'"
		if (( Debug ))
		then
			if [[ -f "${OutputFile}" && -r "${OutputFile}" ]]
			then
				cat "${OutputFile}"
			else
				printf "%s\n" '•••••(output will go here)•••••'
			fi
		else
			cat "${OutputFile}"
		fi
	else
		##### There was most likely an error...
		Exec "printf '%s\\\n' ':-( Error downloading weather data )-:'"
		printf "%s\n" ':-( Error downloading weather data )-:'
		##### If OutputFile contains data, it most likely contains the error message, so print it indented with '/!\' before each line...
		if [[ -s "${OutputFile}" ]]
		then
			Exec "awk '{print \"    /!\  \"\$0}' '${OutputFile}'"
			awk '{print "    /!\\  "$0}' "${OutputFile}"
		fi
		##### Remove OutputFile, so we start fresh next time...
		if (( Debug ))
		then
			Verbose "%b\n" "Need to execute:  rm '${OutputFile}'${debug_str}"
		elif (( KeepError ))
		then
			Verbose "%b\n" "Would normally execute:  rm '${OutputFile}' but --keep-error was used, so ignoring"
		else
			Exec "rm '${OutputFile}'"
			rm "${OutputFile}"
		fi
	fi
fi


#####
##### The end.
#####

Exec "exit ${ExitCode}\n"
exit ${ExitCode}

