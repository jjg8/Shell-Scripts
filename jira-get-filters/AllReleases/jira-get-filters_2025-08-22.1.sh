#!/bin/bash
#####
#
# Name         jira-get-filters.sh
# Description  Export all of the filters owned by you in Jira Cloud, and format it in a GitHub-style README.md file using markdown syntax.
# Author       Jeremy Gagliardi
# Version      2025-08-22.1
# URL          https://github.com/jjg8/Shell-Scripts/blob/main/jira-get-filters
# License      GPL-3.0
# IMPORTANT    This script requires initial setup — See the Setting Up Your Config File section below.
#
#####
##### Script Conventions...
#####
#
# • The layout of this script is optimized for a terminal width of at least 155.
# • All variable & function names are unique throughout the script for easy search/replace.
# • Any global variable that is not read-only (typeset -r) can be overriden in your personal ConfigFile.
#   • For this reason, it attempts to source your ConfigFile at the very beginning of the script.
# • Boolean variables are of type integer (-i) and are 0 (false) or non-0 (true).
# • All variables are written in the form ${...} (e.g. ${1}, ${?}, ${Verbose}, etc) for both readability and better functionality.
# • Banners were made using https://www.bagill.com/ascii-sig.php
#   • Add a space before and after the Text.
#   • Font:  Banner3-D
#   • I added an extra row of colons before and after each word.
#   • I also added the same text after each one, so it's searchable.
# • This will print the final output to the terminal.
#   • If you want it to go into a file, simply redirect STDOUT to a file name.
#   • If you use option -v for Verbose output, it prints to STDERR, so you can easily redirect STDOUT & STDERR to different files, as e.g....
#       >README.md 2>errors.txt
#
#####
##### Setting Up Your Config File...
#####
#
# This script requires you to setup a configuration file containing all necessary parameters to function.
#
#####
# JiraEmail — The email address YOU use to access Jira Cloud, which this script will use to authenticate — define it as for example...
#
#	JiraEmail='you@example.com'
#
#####
# JiraToken — A unique API authentication token that you need to create as follows...
#  • If you already know your API token, skip to the LAST STEP.
#  • Otherwise, launch the Jira Cloud website in your browser.
#  • In the upper right corner of the page, click your profile icon.
#  • Click on Account settings.
#  • Along the top row, click on the Security tab.
#  • Click on the Create and manage API tokens link.
#    • Whenever you access this page in a new session, Atlassian will send you an 8-digit verification code.
#    • Enter the 8-digit verification code, and click the Verify button.
#  • Click the Create API token button.
#    • Name it.
#    • Choose an Expires on date (which must be <= 1 year).
#    • IMPORTANT — After you generate a token, you have only one chance to copy it, so don't click Done until you've recorded it.
#      • For some reason, you can't retrieve an already-generated token after the fact.
#    • Click the Create button, which will generate a 193-character string.
#    • Once generated, DON'T CLICK DONE YET, click the Copy button.
#  • LAST STEP:  Edit your configuration file, and define the JiraToken variable, as for example...
#
#	JiraToken='**PASTE**YOUR**TOKEN**HERE**'
#
#    • Save your configuration file.
#    • Now you can go back to the Atlassian account browser tab, and click the Done button.
#####
# JiraSubdomain — This is the portion of the fully-qualified domain name in the URL that your organization uses to access Jira Cloud.
#  • For example, if the URL is https://YOUR-ORGANIZATION.atlassian.net/jira, define this variable as for example...
#
#	JiraSubdomain='YOUR-ORGANIZATION'
#
#####
# Awk_rules Array Structure
#####
#  • Define it as for example...
#
#	Awk_rules=(
#		**ENTER**YOUR**RULES**HERE**
#	)
#
#  • This is an indexed array, defined in the ConfigFile...
#  • These rules are used to describe/redact several custom elements in Jira, specific to your organization/users.
#    • When in doubt, redact!
#    ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗
#    ❗ PLEASE USE THESE RULES TO REDACT ANYTHING SENSITIVE YOU OR YOUR ORGANIZATION SHOULDN'T SHARE TO OTHERS.❗
#    ❗ PROOFREAD, PROOFREAD, PROOFREAD.  DON'T JUST TRUST THAT YOUR RULES WORKED.  VERIFY ALL OF THEM.        ❗
#    ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗
#    • You've been warned.
#  • It's a pseudo-2-dimensional array.
#    • Dimension 1 contains the rules.
#      • Each individual rule must be on its own line (i.e. rules are newline-delimited).
#    • Dimension 2 contains the individual elements of each rule, the number and composition of which varies for each TYPE.
#      • All elements within a rule are colon-delimited.
#      • If an element contains a : in it, you must replace it with __COLON__ (2 underbars on either end, all caps), so it's not seen as the dimension-2 delimiter.
#      • Each element should be properly quoted, except for Element[0], which is a single-word TYPE indicator.
#      • Element[0] must be one of the following TYPE indicators (in all caps):  FIELD, SPACE, or USERS
#        • If it doesn't match one of these TYPES, it'll just be ignored.
#  • Special characters must be properly escaped (especially in all elements marked "original", which is used in the regular expression portion of the gsub assembly).
#    • Each element marked "original" should not contain the beginning & ending / of the regular expression; they'll be added automatically (e.g. 're' will become /re/).
#  • If a string contains text that could be interpreted as markdown formatting, escape them, so they're not interpreted (e.g. \*\*string\*\*, \_string\_, or \<ins\>).
#    • For a list of all markdown formatting syntax rules GitHub supports, visit...
#        https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax
#  • For the 3 defined TYPE indicators, use the following structures...
#    • Make your redacted replacement strings something generic you and your organization don't mind sharing.  When in doubt, redact!
#    • If you don't want to redact, simply set the "redacted replacement" field to same thing as the "original" field, or don't include it at all in the Awk_rules.
#    • For all elements that are marked (MANDATORY), if you leave it blank, the script will print an error(s) & exit.
#    • For all elements that are marked (optional ), if you leave it blank, it will simply delete the original, rather than replace it.
#    • For proper placement in the notes summary, you need keep all rules for each TYPE grouped together.
#  #####
#  ##### Element[0]=FIELD to describe/redact a Jira custom field
#  #####
#   • Element[1] (MANDATORY) = original custom field JQL reference in the form 'cf\[#####\]', where ##### is the custom field index number
#   • Element[2] (optional ) = redacted replacement
#   • Element[3] (MANDATORY) = common name for it
#   • Element[4] (MANDATORY) = its content type
#   • E.g. 'cf\[54321\]':'cf[12345]':'Scheduled Maintenance':'date/timestamp'
#
#  #####
#  ##### Element[0]=SPACE to describe/redact a Jira Space (formerly Project)
#  #####
#   • Element[1] (MANDATORY) = original Space Key
#   • Element[2] (optional ) = redacted replacement
#   • Element[3] (MANDATORY) = original Space Name
#   • Element[4] (optional ) = redacted replacement
#   • E.g. 'ABC':'CBA':'ABC Issues Queue':'CBA Tickets'
#
#  #####
#  ##### Element[0]=USERS to describe/redact a user's name & Account ID
#  #####
#   • Element[1] (MANDATORY) = original Display Name (user's full name)
#   • Element[2] (optional ) = redacted replacement
#   • Element[3] (MANDATORY) = original First Name(s) or Nickname(s) you might use in your filter's Name or Description fields
#     • If Element[3] is a vertical bar-delimited list — e.g. Bill|Billy — it will match each string in the list for replacement
#   • Element[4] (optional ) = redacted replacement
#   • Element[5] (MANDATORY) = original Account ID
#   • Element[6] (optional ) = redacted replacement
#   • E.g. 'Samuel L\. Jackson':'John Doh':'Sam|Sammy':'John':'123456__COLON__a1b23c45-1a2b-3cde-4f56-a1234b5c6d78':'-some-account-id-string1-'
#####



#       :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#       ::::'######:::'##::::::::'#######::'########:::::'###::::'##:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#       :::'##... ##:: ##:::::::'##.... ##: ##.... ##:::'## ##::: ##:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#       ::: ##:::..::: ##::::::: ##:::: ##: ##:::: ##::'##:. ##:: ##:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#       ::: ##::'####: ##::::::: ##:::: ##: ########::'##:::. ##: ##:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#       ::: ##::: ##:: ##::::::: ##:::: ##: ##.... ##: #########: ##:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#       ::: ##::: ##:: ##::::::: ##:::: ##: ##:::: ##: ##.... ##: ##:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#       :::. ######::: ########:. #######:: ########:: ##:::: ##: ########:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#       ::::......::::........:::.......:::........:::..:::::..::........::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#       :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#       :::'########::'########::'######::'##::::::::::'###::::'########:::::'###::::'########:'####::'#######::'##::: ##::'######:::::
#       ::: ##.... ##: ##.....::'##... ##: ##:::::::::'## ##::: ##.... ##:::'## ##:::... ##..::. ##::'##.... ##: ###:: ##:'##... ##::::
#       ::: ##:::: ##: ##::::::: ##:::..:: ##::::::::'##:. ##:: ##:::: ##::'##:. ##::::: ##::::: ##:: ##:::: ##: ####: ##: ##:::..:::::
#       ::: ##:::: ##: ######::: ##::::::: ##:::::::'##:::. ##: ########::'##:::. ##:::: ##::::: ##:: ##:::: ##: ## ## ##:. ######:::::
#       ::: ##:::: ##: ##...:::: ##::::::: ##::::::: #########: ##.. ##::: #########:::: ##::::: ##:: ##:::: ##: ##. ####::..... ##::::
#       ::: ##:::: ##: ##::::::: ##::: ##: ##::::::: ##.... ##: ##::. ##:: ##.... ##:::: ##::::: ##:: ##:::: ##: ##:. ###:'##::: ##::::
#       ::: ########:: ########:. ######:: ########: ##:::: ##: ##:::. ##: ##:::: ##:::: ##::::'####:. #######:: ##::. ##:. ######:::::
#       :::........:::........:::......:::........::..:::::..::..:::::..::..:::::..:::::..:::::....:::.......:::..::::..:::......::::::
#       :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#       GLOBAL DECLARATIONS



shopt -s extglob			# Enables extended pattern matching rules — e.g. one of this set @(1|2|3)

typeset -l	Hostname=$( /usr/bin/hostname -s )
typeset		ScriptBase=${0##*/}

typeset -A	Emoji=(
	     ['OK']='🟢'
	     ['NO']='❌'
	['Neutral']='🔵'
)
typeset -A	EXEC=(
	           ['awk']='/usr/bin/awk'
	           ['cat']='/usr/bin/cat'
	          ['curl']='/usr/bin/curl'
	          ['date']='/usr/bin/date'
	          ['find']='/usr/bin/find'
	            ['jq']='/usr/bin/jq'
	       ['timeout']='/usr/bin/timeout'
	            ['tr']='/usr/bin/tr'
)
typeset -A	OptionalExec=(
	         ['xclip']='/usr/bin/xclip'
	          ['xsel']='/usr/bin/xsel'
	       ['wl-copy']='/usr/bin/wl-copy'
	['Win,powershell']='/Windows/System32/WindowsPowerShell/v1.0/powershell.exe'
)

typeset		ConfigFile="$( cd ~; /bin/pwd )/.config/${ScriptBase}.${Hostname}.conf"
typeset		Date=$( "${EXEC[date]}" +%Y-%m-%d )
typeset		Line=
typeset -l	option=
typeset -i	Verbose=0

typeset		JiraAccountID=
typeset -l	JiraEmail=
typeset		JiraFilters=
typeset -l	JiraSubdomain=
typeset		JiraSummary=
typeset		JiraToken=
typeset		JiraURL_Base='.atlassian.net/rest/api/3/'
typeset		JiraUserName=

typeset -a	Awk_rules=()
typeset -i	DoExit=0
typeset		ErrorBlank=' is blank/undefined'
typeset -i	ExitCode=0
typeset		RawResult=
typeset		Ruleset=



#       ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#       :::'########:'##::::'##:'##::: ##::'######::'########:'####::'#######::'##::: ##::'######:::::
#       ::: ##.....:: ##:::: ##: ###:: ##:'##... ##:... ##..::. ##::'##.... ##: ###:: ##:'##... ##::::
#       ::: ##::::::: ##:::: ##: ####: ##: ##:::..::::: ##::::: ##:: ##:::: ##: ####: ##: ##:::..:::::
#       ::: ######::: ##:::: ##: ## ## ##: ##:::::::::: ##::::: ##:: ##:::: ##: ## ## ##:. ######:::::
#       ::: ##...:::: ##:::: ##: ##. ####: ##:::::::::: ##::::: ##:: ##:::: ##: ##. ####::..... ##::::
#       ::: ##::::::: ##:::: ##: ##:. ###: ##::: ##:::: ##::::: ##:: ##:::: ##: ##:. ###:'##::: ##::::
#       ::: ##:::::::. #######:: ##::. ##:. ######::::: ##::::'####:. #######:: ##::. ##:. ######:::::
#       :::..:::::::::.......:::..::::..:::......::::::..:::::....:::.......:::..::::..:::......::::::
#       ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#       FUNCTIONS



function AwkRules_ErrorChecks
{
	typeset -i	index=0


	##### Go through the entire Awk_rules array...
	while (( index <= $((${#Awk_rules[*]}-1)) ))
	do
		##### Assign the current element to the Element array using ':' as the delimiter...
		shopt -u extglob # This must be temporarily disabled, otherwise certain elements in the array try to match to file names in the current directory.
		IFS=:
		Element=( ${Awk_rules[index]} )
		IFS="${IFS_Orig}"
		shopt -s extglob # Re-enable

		##### Depending on the type as Element[0] (see the Awk_rules Array Structure above)...
		case "${Element[0]}" in
		  'FIELD')
			[[ -z "${Element[1]}" ]] && Error_Mandatory 1 ${index} "${Awk_rules[index]}"
			[[ -z "${Element[3]}" ]] && Error_Mandatory 3 ${index} "${Awk_rules[index]}"
			[[ -z "${Element[4]}" ]] && Error_Mandatory 4 ${index} "${Awk_rules[index]}"
			;;
		  'SPACE')
			[[ -z "${Element[1]}" ]] && Error_Mandatory 1 ${index} "${Awk_rules[index]}"
			[[ -z "${Element[3]}" ]] && Error_Mandatory 3 ${index} "${Awk_rules[index]}"
			;;
		  'USERS')
			[[ -z "${Element[1]}" ]] && Error_Mandatory 1 ${index} "${Awk_rules[index]}"
			[[ -z "${Element[3]}" ]] && Error_Mandatory 3 ${index} "${Awk_rules[index]}"
			[[ -z "${Element[5]}" ]] && Error_Mandatory 5 ${index} "${Awk_rules[index]}"
			;;
		esac

		##### Get the next index number to continue looping...
		index=index+1
	done #while
}

function AwkRules_GetGsubs
{
	typeset -i	count=0
	typeset		FirstName=
	typeset -i	index=0
	typeset		NickName=


	##### Go through the entire Awk_rules array...
	while (( index <= $((${#Awk_rules[*]}-1)) ))
	do
		##### Assign the current element to the Element array using ':' as the delimiter...
		shopt -u extglob # This must be temporarily disabled, otherwise certain elements in the array try to match to file names in the current directory.
		IFS=:
		Element=( ${Awk_rules[index]} )
		IFS="${IFS_Orig}"
		shopt -s extglob # Re-enable

		##### Depending on the type as Element[0] (see the Awk_rules Array Structure above)...
		case "${Element[0]}" in
		  'FIELD')
			#####
			##### Each FIELD type:
			#####

			#####
			# If Element[1] is not null, print each Element[1]:Element[2] pair as an awk gsub replacement, prefixed by \t and suffixed by \n...
			#  • Element[2] is optional or may be empty.
			#  • E.g. 'cf\[54321\]':'cf[12345]' becomes "\tgsub(/cf\[54321\]/, \"cf[12345]\")\n".
			#####
			Element[1]="${Element[1]//__COLON__/:}"
			Element[2]="${Element[2]//__COLON__/:}"
			[[ -n "${Element[1]}" ]] && printf "\t%s\n" "gsub(/${Element[1]}/, \"${Element[2]}\")"
			;;
		  'SPACE')
			#####
			##### Each SPACE type:
			#####

			#####
			# If Element[1] is not null, print each Element[1]:Element[2] pair as an awk gsub replacement, prefixed by \t and suffixed by \n...
			#  • Element[2] is optional or may be empty.
			#  • E.g. 'ABC':'CBA' becomes "\tgsub(/ABC/, \"CBA\")\n"
			#####
			Element[1]="${Element[1]//__COLON__/:}"
			Element[2]="${Element[2]//__COLON__/:}"
			[[ -n "${Element[1]}" ]] && printf "\t%s\n" "gsub(/${Element[1]}/, \"${Element[2]}\")"
			#####
			# If Element[3] is not null, print each Element[3]:Element[4] pair as an awk gsub replacement, prefixed by \t and suffixed by \n...
			#  • Element[4] is optional or may be empty.
			#  • E.g. 'ABC Issues Queue':'CBA Tickets' becomes "\tgsub(/ABC Issues Queue/, \"CBA Tickets\")\n"
			#####
			Element[3]="${Element[3]//__COLON__/:}"
			Element[4]="${Element[4]//__COLON__/:}"
			[[ -n "${Element[3]}" ]] && printf "\t%s\n" "gsub(/${Element[3]}/, \"${Element[4]}\")"
			;;
		  'USERS')
			#####
			##### Each USERS type:
			#####

			#####
			# If Element[1] is not null, print each Element[1]:Element[2] pair as an awk gsub replacement, prefixed by \t and suffixed by \n...
			#  • Element[2] is optional or may be empty.
			#  • E.g. 'Samuel L\. Jackson':'John Doh' becomes "\tgsub(/Samuel L\. Jackson/, \"John Doh\")\n"
			#####
			Element[1]="${Element[1]//__COLON__/:}"
			Element[2]="${Element[2]//__COLON__/:}"
			[[ -n "${Element[1]}" ]] && printf "\t%s\n" "gsub(/${Element[1]}/, \"${Element[2]}\")"
			#####
			# If Element[3] is not null, print each Element[3]:Element[4] pair as an awk gsub replacement, prefixed by \t and suffixed by \n...
			#  • Element[4] is optional or may be empty.
			#  • E.g. '(Sam|Sammy)':'John' becomes
			#      "\tgsub(/Sam/, \"John\")\n"
			#      "\tgsub(/Sammy/, \"John\")\n"
			#####
			Element[3]="${Element[3]//__COLON__/:}"
			Element[4]="${Element[4]//__COLON__/:}"
			FirstName="${Element[1]%% *}"
			[[ "${FirstName}" != "${Element[3]}" ]] && printf "\t%s\n" "gsub(/${FirstName}/, \"${Element[4]}\")"
			if [[ -n "${Element[3]}" ]]
			then
				##### If Element[3] is a vertical bar-separated list of nicknames...
				if [[ "${Element[3]}" =~ ([^|]+\|){1,}[^|]+ ]]
				then
					##### Assign Element[3] to the Nickname array using '|' as the delimiter...
					shopt -u extglob # Temporarily disable
					IFS=$'|'
					Nickname=( ${Element[3]} )
					IFS="${IFS_Orig}"
					shopt -s extglob # Re-enable
				else
					##### Assign Element[3] to the Nickname array as a single element...
					Nickname=( ${Element[3]} )
				fi

				count=0
				while (( count <= $((${#Nickname[*]}-1)) ))
				do
					printf "\t%s\n" "gsub(/${Nickname[count]}/, \"${Element[4]}\")"
					##### Get the next count number to continue looping...
					count=count+1
				done #while
			fi
			#####
			# If Element[5] is not null, print each Element[5]:Element[6] pair as an awk gsub replacement, prefixed by \t and suffixed by \n...
			#  • Element[6] is optional or may be empty.
			#  • E.g. '123456__COLON__a1b23c45-1a2b-3cde-4f56-a1234b5c6d78':'-some-account-id-string1-' becomes
			#      "\tgsub(/123456:a1b23c45-1a2b-3cde-4f56-a1234b5c6d78/, \"-some-account-id-string1-\")\n"
			#####
			Element[5]="${Element[5]//__COLON__/:}"
			Element[6]="${Element[6]//__COLON__/:}"
			[[ -n "${Element[5]}" ]] && printf "\t%s\n" "gsub(/${Element[5]}/, \"${Element[6]}\")"
			;;
		esac

		##### Get the next index number to continue looping...
		index=index+1
	done #while
}

function AwkRules_GetNotes
{
	##### 
	##### Each type — Field, Space, Users — are initially set to 0 (false) to indicate the header for that type has not yet been printed...
	#####
	typeset -i	Field=0
	typeset -i	Space=0
	typeset -i	Users=0

	typeset -i	index=0
	typeset -i	next=0


	##### Go through the entire Awk_rules array...
	while (( index <= $((${#Awk_rules[*]}-1)) ))
	do
		##### Assign the current element to the Element array using ':' as the delimiter...
		shopt -u extglob # This must be temporarily disabled, otherwise certain elements in the array try to match to file names in the current directory.
		IFS=:
		Element=( ${Awk_rules[index]} )
		IFS="${IFS_Orig}"
		shopt -s extglob # Re-enable

		##### Depending on the type as Element[0] (see the Awk_rules Array Structure above)...
		case "${Element[0]}" in
		  'FIELD')
			#####
			##### Each FIELD type:
			#####
			if (( ! Field ))
			then
				Field=1
				printf "%s\n"	'   - The following is a custom field JQL reference "our name for it" (what it contains)...'
			fi
			Element[1]="${Element[1]//__COLON__/:}"
			Element[2]="${Element[2]//__COLON__/:}"
			Element[3]="${Element[3]//__COLON__/:}"
			Element[4]="${Element[4]//__COLON__/:}"
				printf "%s"	'     - `'
			[[ -n "${Element[2]}" ]] && next=2 || next=1
				printf "%s%s"	"${Element[next]}"	'` "'
				printf "%s%s"	"${Element[3]}"		'" ('
				printf "%s%s"	"${Element[4]}"		')'
			;;
		  'SPACE')
			#####
			##### Each SPACE type:
			#####
			if (( ! Space ))
			then
				Space=1
   				printf "%s\n"	'   - The following is a (formerly Project) Space Key "Space Name"...'
			fi
			Element[1]="${Element[1]//__COLON__/:}"
			Element[2]="${Element[2]//__COLON__/:}"
			Element[3]="${Element[3]//__COLON__/:}"
			Element[4]="${Element[4]//__COLON__/:}"
				printf "%s"	'     - `'
			[[ -n "${Element[2]}" ]] && next=2 || next=1
				printf "%s%s"	"${Element[next]}"	'` "'
			[[ -n "${Element[4]}" ]] && next=4 || next=3
				printf "%s%s"	"${Element[next]}"	'"'
			;;
		  'USERS')
			#####
			##### Each USERS type:
			#####
			if (( ! Users ))
			then
				Users=1
   				printf "%s\n"	'   - The following is a user display name (first/nickname) [Account ID reference]...'
				printf "%s\n"   '     - Additional notes...'
				printf "%s\n"   '       - When searching for yourself, you can use the built-in function `currentUser()`.'
				printf "%s\n"   '       - But when searching for other users, you can search for them by name, and in the filter interface, it'"'"'ll show their profile badge and name, but in the actual JQL code, it stores them as account IDs only.'
			fi
			Element[1]="${Element[1]//__COLON__/:}"
			Element[2]="${Element[2]//__COLON__/:}"
			Element[3]="${Element[3]//__COLON__/:}"
			Element[4]="${Element[4]//__COLON__/:}"
			Element[5]="${Element[5]//__COLON__/:}"
			Element[6]="${Element[6]//__COLON__/:}"
				printf "%s"	'     - '
			[[ -n "${Element[2]}" ]] && next=2 || next=1
				printf "%s%s"	"${Element[next]}"	' ('
			[[ -n "${Element[4]}" ]] && next=4 || next=3
				printf "%s%s"	"${Element[next]}"	') ['
			[[ -n "${Element[6]}" ]] && next=6 || next=5
				printf "%s%s"	"${Element[next]}"	']'
			;;
		esac
				printf "\n"

		##### Get the next index number to continue looping...
		index=index+1
	done #while
}

function CheckCommands
{
	typeset		RequiredList="${1}"
	typeset		OptionalList="${2}"


	#####
	##### REQUIRED Commands...
	#####

	(( Verbose )) && printf "\n%s\n" "Checking for REQUIRED commamds..." >&2
	for CommandName in ${RequiredList}
	do
		(( Verbose )) && printf "%s" "  Checking '${EXEC[${CommandName}]}'..." >&2
		if [[ -x "${EXEC[${CommandName}]}" ]]
		then
			(( Verbose )) && printf "%s" "${Emoji[OK]} Found." >&2
		else
			(( Verbose )) && printf "%s" "${Emoji[NO]} NOT FOUND." >&2
			ErrorOutput "Required command '${EXEC[${CommandName}]}' was not found." 0
			DoExit=DoExit+1
		fi
		(( Verbose )) && printf "\n" >&2
	done #for ExecCommand
	(( DoExit )) && ErrorOutput '' 1
	(( Verbose )) && printf "%s\n" "${Emoji[OK]} Found all REQUIRED commands." >&2


	#####
	##### OPTIONAL Commands...
	#####

	(( Verbose )) && printf "%s\n" "Checking for any OPTIONAL commamds..." >&2
	for CommandName in ${OptionalList}
	do
		[[ "${CommandName}" == 'Win,powershell' ]] && continue #to next item in the list

		(( Verbose )) && printf "%s" "  Checking '${OptionalExec[${CommandName}]}'..." >&2
		if [[ -x "${OptionalExec[${CommandName}]}" ]]
		then
			(( Verbose )) && printf "%s" "${Emoji[OK]} Found." >&2
		else
			(( Verbose )) && printf "%s" "${Emoji[NO]} NOT FOUND." >&2
			##### Clear the variable, so it doesn't try to use this command...
			OptionalExec[${CommandName}]=
		fi
		(( Verbose )) && printf "\n" >&2
	done #for ExecCommand
	(( Verbose )) && printf "%s\n" "${Emoji[Neutral]} Done checking for OPTIONAL commands." >&2
}

function Copied
{
	typeset		Message="${Emoji[OK]} This output was automatically copied to the clipboard using ${1} ${Emoji[OK]}"
	typeset -i	ErrorCode=${2}

	typeset -i	Width=$(( ${#Message} + 3 ))

	typeset		Spaces=$(	DrawLine ' ' ${Width} )
	typeset		Underbars=$(	DrawLine '_' ${Width} )


	if (( ErrorCode ))
	then
		(( Verbose )) && printf "%s\n" "${Emoji[NO]} Copy to clipboard using powershell was unsuccessful." >&2
	else
		"${EXEC[cat]}" <<END_OF_NOTE >&2

   ${Underbars}
╲ ╱${Spaces}╲ ╱
 ╳ ${Message} ╳
╱ ╲${Underbars}╱ ╲


END_OF_NOTE
	fi
}

function DrawLine
{
	typeset		Character="${1}"
	typeset -i	Length=${2:-80}
	typeset -i	Count=1


	while (( Count < Length ))
	do
		printf "%s" "${Character}"
		Count=Count+1
	done #while
	printf "\n"
}

function ErrorOutput
{
	typeset -i	ExitCode=${2:-1}
	typeset		Indent='  '
	typeset		Intro=
	typeset		Plural='it'; (( DoExit > 1 )) && Plural='them'


	if (( ! DoExit ))
	then
		printf "\n%s\n"		':-('
	fi
	if [[ -n "${1}" ]]
	then
		printf "%b"		"ERROR:  ${1}" | "${EXEC[awk]}" -v Indent="${Indent}" '{ print Indent $0 }'
	fi
	if (( ExitCode ))
	then
		Intro="Please define ${Plural} in your config file"
		(( ExitCode == 10 )) && Intro='Your config file must be defined in'
		printf "%b"		"${Intro}...\n  '${ConfigFile}'"  | "${EXEC[awk]}" -v Indent="${Indent}" '{ print Indent $0 }'
		printf "%s\n\n\b"	')-:'
		exit ${ExitCode}
	fi
}
function Error_Blank		{ ErrorOutput "Your '${1}' variable${ErrorBlank}."							;}
function Error_Mandatory	{ ErrorOutput "Mandatory Element[${1}]${ErrorBlank} in awk rule #${2}...\n  '${3}'" 0; DoExit=DoExit+1	;}



#       ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#       :::'##::::'##::::'###::::'####:'##::: ##::::'########:::'#######::'########::'##:::'##::::
#       ::: ###::'###:::'## ##:::. ##:: ###:: ##:::: ##.... ##:'##.... ##: ##.... ##:. ##:'##:::::
#       ::: ####'####::'##:. ##::: ##:: ####: ##:::: ##:::: ##: ##:::: ##: ##:::: ##::. ####::::::
#       ::: ## ### ##:'##:::. ##:: ##:: ## ## ##:::: ########:: ##:::: ##: ##:::: ##:::. ##:::::::
#       ::: ##. #: ##: #########:: ##:: ##. ####:::: ##.... ##: ##:::: ##: ##:::: ##:::: ##:::::::
#       ::: ##:.:: ##: ##.... ##:: ##:: ##:. ###:::: ##:::: ##: ##:::: ##: ##:::: ##:::: ##:::::::
#       ::: ##:::: ##: ##:::: ##:'####: ##::. ##:::: ########::. #######:: ########::::: ##:::::::
#       :::..:::::..::..:::::..::....::..::::..:::::........::::.......:::........::::::..::::::::
#       ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#       MAIN BODY



#####
##### Process options...
#####

while (( ${#*} ))
do
	option="${1}"
	case "${option}" in
	  -@(v|-verbose))	Verbose=1;	shift	;;
	  *)			break			;;
	esac
done #while

#####
##### Source the ConfigFile...
#####

[[ ! -e "${ConfigFile}" ]] && ErrorOutput "You must setup your configuration file prior to using this script.\nRead the comments at the top of this script for details." 10
[[ ! -r "${ConfigFile}" ]] && ErrorOutput 'Your configuration file is not readable by you.' 10
(( Verbose )) && printf "\n%s\n" "Sourcing config file '${ConfigFile}'..." >&2
   .   "${ConfigFile}"

#####
##### Check for all required commands...
#####

CheckCommands "${!EXEC[*]}" "${!OptionalExec[*]}"


##### For some strange reason, to make the shell built-in variable COLUMNS populate, you need to immediately precede it with an external command...
"${EXEC[cat]}" /dev/null # This is as quick and do-nothing as possible.
Line=$( DrawLine '─' ${COLUMNS} )

#####
##### Detect if we're running inside a container with access to Windows...
#####

(( Verbose )) && printf "%s\n%s\n"	'Looking for the Windows powershell.exe command...' \
					'  (If running in a container, powershell is used to copy the final output to the Windows clipboard.)' >&2

##### If OptionalExec[Win,powershell] still begins with /Windows...
if [[ "${OptionalExec[Win,powershell]}" =~ ^'/Windows' ]]
then
	##### Try for Windows Subsystem for Linux (WSL) /mnt/[a-z] and Cygwin /cygdrive/[a-z] mount paths...
	RawResult=$( "${EXEC[find]}" /mnt/[a-z] /cygdrive/[a-z] -type d -prune 2>/dev/null )

	##### If we found 1 or more paths...
	if [[ -n "${RawResult}" ]]
	then
		RawResult=$( printf " %s" ${RawResult} )
		RawResult="${RawResult#* }"

		(( Verbose )) && printf "%s\n" "  Found possible Windows mount path list '${RawResult}'." >&2

		##### Iterate through each Path from RawResult...
		for Path in ${RawResult}
		do
			(( Verbose )) && printf "%s" "  Trying path '${Path}${OptionalExec[Win,powershell]}'..." >&2

			##### If OptionalExec[Win,powershell] is found in this Path...
			if [[ -x "${Path}${OptionalExec[Win,powershell]}" ]]
			then
				##### Assign it and stop here...
				(( Verbose )) && printf "%s\n" "${Emoji[OK]} Found." >&2
				OptionalExec[Win,powershell]="${Path}${OptionalExec[Win,powershell]}" >&2
				break #from the for Path loop
			else
				(( Verbose )) && printf "%s\n" "${Emoji[NO]} NOT FOUND." >&2
			fi
		done #for Path
	fi
fi
if [[ -x "${OptionalExec[Win,powershell]}" ]]
then
	(( Verbose )) && printf "%s\n" "${Emoji[OK]} Found '${OptionalExec[Win,powershell]}'." >&2
else
	(( Verbose )) && printf "%s\n" "${Emoji[NO]} The Windows powershell.exe command could not be found, so it will be ignored." >&2
fi

#####
##### Process all variables from ConfigFile...
#####

#####
# JiraEmail...
#####
# Debug tests:
#  • Uncomment below to test for it being blank or unassigned...
#JiraEmail=
#  • Uncomment below to test for an invalid email address assigned...
#JiraEmail='Me@Somewhere'
#####

(( Verbose )) && printf "%s\n" "JiraEmail     = '${JiraEmail}'" >&2
[[  -z	"${JiraEmail}"							]] && Error_Blank 'JiraEmail'
[[   !	"${JiraEmail}" =~ ^[a-z0-9._%+-]+@([a-z0-9_-]+\.)+[a-z]{2,}$	]] && ErrorOutput "JiraEmail '${JiraEmail}' is not a valid email address."

#####
# JiraSubdomain...
#####
# Debug tests:
#  • Uncomment below to test for it being blank or unassigned...
#JiraSubdomain=
#  • Uncomment below to test for http:// prefix included...
#JiraSubdomain='http://databridgesites.atlassian.net'
#  • Uncomment below to test for https:// prefix included...
#JiraSubdomain='https://databridgesites.atlassian.net'
#  • Uncomment below to test for FQDN specified...
#JiraSubdomain='databridgesites.atlassian.net'
#####

RawResult="${JiraSubdomain}"
(( Verbose )) && printf "%s\n" "JiraSubdomain = '${JiraSubdomain}'" >&2
[[  -z	"${JiraSubdomain}"			]] && Error_Blank 'JiraSubdomain'
[[	"${JiraSubdomain}" == 'http://'*	]] && JiraSubdomain="${JiraSubdomain#http:\/\/*}"
[[	"${JiraSubdomain}" == 'https://'*	]] && JiraSubdomain="${JiraSubdomain#https:\/\/*}"
[[	"${JiraSubdomain}" == *\.* 		]] && JiraSubdomain="${JiraSubdomain%%.*}"
(( Verbose )) && [[ "${JiraSubdomain}" != "${RawResult}" ]] && printf "%s\n" "JiraSubdomain = '${JiraSubdomain}'" >&2

#####
# JiraToken...
#####
# Debug tests:
#  • Uncomment below to test for it being blank or unassigned...
#JiraToken=
#####

(( Verbose )) && printf "%s\n" "JiraToken     = '${JiraToken}'" >&2
[[ -z "${JiraToken}" ]] && Error_Blank 'JiraToken'

#####
# Awk_rules...
#####
# Debug tests:
#  • Uncomment below to test for it being blank or unassigned...
#Awk_rules=()
#  • Uncomment these lines below to test for blank/undefined mandatory elements in individual rules...
#Awk_rules=(
#	FIELD::'cf[12345]':'Schedule Date':'date/timesamp'
#	FIELD:'cf\[54321\]':'cf[12345]'::'date/timesamp'
#	FIELD:'cf\[54321\]':'cf[12345]':'Schedule Date'
#	SPACE::'CBA':'ABC Issues Queue':'CBA Tickets'
#	SPACE:'ABC':'CBA'::'CBA Tickets'
#	USERS::'John Doh':'Sam|Sammy':'John':'123456__COLON__a1b23c45-1a2b-3cde-4f56-a1234b5c6d78':'-some-account-id-string1-'
#	USERS:'Samuel L\. Jackson':'John Doh'::'John':'123456__COLON__a1b23c45-1a2b-3cde-4f56-a1234b5c6d78':'-some-account-id-string1-'
#	USERS:'Samuel L\. Jackson':'John Doh':'Sam|Sammy':'John'::'-some-account-id-string1-'
#)
#####
(( Verbose )) && printf "%s\n%s\n%s\n" 'Awk_rules     = (' "${Awk_rules[@]}" ')' >&2
[[ -z "${Awk_rules[*]}" ]] && Error_Blank 'Awk_rules'
AwkRules_ErrorChecks
(( DoExit )) && ErrorOutput '' 1


#####
##### Assemble JiraURL_Base to its final form...
#####

JiraURL_Base="https://${JiraSubdomain}${JiraURL_Base}"
(( Verbose )) && printf "%s\n" "JiraURL_Base  = '${JiraURL_Base}'" >&2


#####
##### Get Jira .displayName and .accountId...
#####

(( Verbose )) && printf "\n%s\n" 'Getting Jira .displayName and .accountId...' >&2
RawResult=$( "${EXEC[curl]}" -s -u "${JiraEmail}:${JiraToken}" -H 'Accept: application/json' "${JiraURL_Base}myself" )
(( Verbose )) && printf "%s'\n%s\n'\n" 'RawResult     = ' "${RawResult}" >&2

JiraUserName=$(  printf "%s\n" "${RawResult}" | "${EXEC[jq]}" -r '.displayName' )
(( Verbose )) && printf "\n%s\n" "JiraUserName  = '${JiraUserName}'" >&2
JiraAccountID=$( printf "%s\n" "${RawResult}" | "${EXEC[jq]}" -r '.accountId' | "${EXEC[tr]}" -d '\r\n' | "${EXEC[jq]}" -sRr @uri )
(( Verbose )) && printf "%s\n" "JiraAccountID = '${JiraAccountID}'" >&2


#####
##### Get all filters owned by JiraAccountID...
#####

(( Verbose )) && printf "\n%s\n" "Getting all filters owned by '${JiraUserName}', email '${JiraEmail}', account ID '${JiraAccountID}'..." >&2
JiraFilters=$( "${EXEC[curl]}" -s -u "${JiraEmail}:${JiraToken}" -H 'Accept: application/json' "${JiraURL_Base}filter/search?accountId=${JiraAccountID}&expand=jql,description" )
if (( Verbose ))
then
	printf "%s\n%s'\n%s\n'\n" '(Raw JSON)' 'JiraFilters   = ' "${JiraFilters}" >&2

	printf "\n%s\n" 'Jira filters ID & Name summary...' >&2
	printf "%s" $( printf "%s\n" "${JiraFilters}" | "${EXEC[jq]}" -r '.values[] | [.id, .name] | @csv' ) >&2
	printf "\n" >&2
fi


#####
##### Process all redacted replacements...
#####

Ruleset='
{
'$( AwkRules_GetGsubs )'
	print $0
}'
(( Verbose )) && printf "\n%s\n%s\n%s'%s\n'\n" "${Line}" '(For awk)' 'Ruleset       = ' "${Ruleset}" >&2
JiraFilters=$( printf "%s\n" "${JiraFilters}" | "${EXEC[awk]}" "${Ruleset}" )
(( Verbose )) && printf "\n%s\n%s\n%s'\n%s\n'\n" "${Line}" '(After awk processing for all redacted replacements)' 'JiraFilters   = ' "${JiraFilters}" >&2


#####
##### Process the filters into a summary list...
#####

JiraSummary=$(
	printf "%s\n" "${JiraFilters}" |
	"${EXEC[jq]}" \
	  -r \
	  '
		.values[]
		| [ (.name // "") ]
		| [ " - `" + .[0] + "`" ]
		| .[]
	  '
)


#####
##### Process the filters into markdown syntax...
#####

JiraFilters=$(
	printf "%s\n" "${JiraFilters}" |
	"${EXEC[jq]}" \
	  -r \
	  '
		.values[]
		| [
			(.name // ""),
			(if .description == "" then "" else .description // "" | gsub("\n"; " ") end),
			(.jql // "" | gsub("\n"; " "))
		  ]
		| [
			"| FIELD | VALUE |",
			"|---|---|",
			"| **Name** | `" + .[0] + "` |",
			"| **Description** | `" + .[1] + "` |",
			"| **JQL** | `" + .[2] + "` |",
			"<br>",
			"<br>",
			""
		  ]
		| .[]
	  '
)
(( Verbose )) && printf "\n%s\n%s\n%s'\n%s\n'\n" "${Line}" '(Processed with jq into markdown syntax)' 'JiraFilters   = ' "${JiraFilters}" >&2


#####
##### Output README.md header...
#####

Ruleset=$( AwkRules_GetNotes )
(( Verbose )) && printf "\n%s\n%s\n%s'\n%s\n'\n" "${Line}" '(For notes)' 'Ruleset       = ' "${Ruleset}" >&2
(( Verbose )) && printf "\n%s\n%s\n" "${Line}" '(FINAL OUTPUT)' >&2
RawResult=$( "${EXEC[cat]}" <<END_OF_HEADER
# My Collection of Jira Cloud Filters

By ${JiraUserName} │ As of ${Date} | No license; these are free to copy and use.<br>
_This was generated using script_ \`${ScriptBase}\`.<br>

Find what you need and copy these into the **Name**, **Description**, and **JQL** fields, respectively, to create your filter. To update the **Name** and **Description**, you need to click on the _Filter details_ button and then _Edit name and description_. To update the JQL code, you need to switch from _Basic_ to _JQL_, enter the JQL code from below, and press **Enter** to execute it. Don't forget to click **Save filter** when you're all done.<br>

 - Please note some organization-specific quirks in the following tables, which I swapped out for these generic terms. I kept them included, so you can see my examples to give you ideas for your own setup.
${Ruleset}
 - You'll also see references to status lists that may or may not match what your organization uses.
 - You'll need to customize these to your organization's keys, names, or IDs.
 - All newlines in the _Description_ or _JQL_ fields have been collapsed into spaces for proper table alignment presented here.
   - Jira lets you enter newlines in these fields by pressing Shift+Enter; you can only have up to 3 lines in the _JQL_ field.
 - The JQL clause \`statusCategory != Done\` is far superior to any \`status = "whatever"\`, because it'll work for every type of ticket, even when there are multiple _done_ statuses.

Here's a summary of all filters detailed below in the tables...
${JiraSummary}

Now, the detailed tables...<br>
<br>
END_OF_HEADER
)
JiraFilters="${RawResult}
${JiraFilters}"

#####
##### Output README.md Jira Filters list...
#####

printf "%s\n" "${JiraFilters}"

#####
##### If these OptionalExec[*] are defined, copy the output to the clipboard automatically using one of these commands (whichever one works)...
#####

if [[ -n "${OptionalExec[Win,powershell]}" ]]
then
	 "${OptionalExec[Win,powershell]}" -noprofile -command "Set-Clipboard -Value @'
${JiraFilters}

'@"
	ExitCode=${?}
	Copied 'powershell' ${ExitCode}
else
	ExitCode=1
fi

if (( ExitCode )) && [[ -n "${OptionalExec[xclip]}" ]]
then
	printf "%s\n" | "${EXEC[timeout]}" 2s "${OptionalExec[xclip]}" -selection clipboard
	ExitCode=${?}
	Copied 'xclip' ${ExitCode}
fi

if (( ExitCode )) && [[ -n "${OptionalExec[xsel]}" ]]
then
	printf "%s\n" | "${EXEC[timeout]}" 2s "${OptionalExec[xsel]}" --clipboard --input
	ExitCode=${?}
	Copied 'xsel' ${ExitCode}
fi

if (( ExitCode )) && [[ -n "${OptionalExec[wl-copy]}" ]]
then
	printf "%s\n" | "${EXEC[timeout]}" 2s "${OptionalExec[wl-copy]}"
	ExitCode=${?}
	Copied 'wl-copy' ${ExitCode}
fi



#####
##### The end.
#####



