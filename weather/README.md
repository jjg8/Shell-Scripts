# Shell Scripts

Hello and welcome to my Shell Scripts repository.

These are some of my more useful shell scripts, all written in Bash.

- **weather**
  - Uses curl or wget to get the CLI-friendly weather from https://wttr.in and is very configurable with CLI options to control output.

Example usage in ~/.bashrc, assuming you put it in ~/bin/...
```
##### Print the weather:
[[ -n ${PS1} && ${SHLVL} == 1 ]] && ~/bin/weather.sh --output-auto --age 3600 --no-test-error --ignore-tput --keep-error '' 0
```
This does the following...
 - `--output-auto` —  Redirect output into file ~/.weather
 - `--age 3600` — When using --output-*, check to see if the age of output file is >**n** (in this example _3600_) seconds.  If so, remove it and create a new one.  Otherwise, simply return the contents of the file and exit.  **n** must be a positive integer.  If output file is /dev/*, this option is ignored.
 - `--no-test-error` — Do not output an error if the weather cannot be downloaded.  If so, simply output the default reply ':-( No weather data )-:' and exit.  Other errors may occur, however.
 - `--ignore-tput` — If tput doesn't exist or doesn't work, ignore it and keep going.  No checking of the terminal width will occur.
 - `--keep-error` — Normally, when using --output-*, if an error is encountered, it will remove the output file immediately after displaying it.  This turns off that behavior, especially if you want to honor --age in all circumstances.  This option is ignored if output file begins with /dev/*.
 - `''` — Specifies the first parameter (Location) as empty (i.e. it will automatically infer if from your public IP's geolocation).
 - `0` — Specified the second parameter (View option(s)) as `0`, See the web page https://wttr.in/:help for valid View Options.

Complete Help page...

```
NAME
  Bash script 'weather' - display the weather from https://wttr.in/ at the command line

SYNOPSIS
  weather [options] [Location] [View Option(s)]

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
        x must be a supported 2-letter code as specified in https://wttr.in/:help
        The default language code is 'en' (i.e. English)

  --locfile x
        Get the location from file x
        Quote x if complex
        If x doesn't exist or isn't readable, it's ignored
        If not specified with this option, x defaults to '/home/jjg/.weather.location'

  --no-locfile
        Do not use a location file (see --locfile above)

  --no-rmtfile
        Do not use a remote file (see --rmtfile below)

  --no-test-error
        Do not output an error if the weather cannot be downloaded
        If so, simply output the default reply ':-( No weather data )-:' and exit
        Other errors may occur, however

  --output-auto
        Redirect output into file ~/.weather
        See UMASK NOTE in --output-file below

  --output-file x
        Redirect output into file x
        Quote x if complex
        If x does not contain a directory path, it will assume ~/x
        UMASK NOTE:  if x doesn't already exist, it will be created with the existing umask, which at present is '0022'
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
        If not specified with this option, x defaults to ''

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
        Omitting the Location causes wttr.in to get your location automatically from your public IP address.
        See the web page https://wttr.in/:help for supported location types.
        Do not enter the '/' character as part of the Location (it is automatically added).
        Quote Location if it contains whitespace (e.g. 'New York').
        To specify View Option(s) without specifying a Location, enter Location as ''.

  View Option(s)
        After all options and the Location have been entered, specify View Option(s) as the next paramter(s).
        See the web page https://wttr.in/:help for valid View Options.
        View Options may be entered as a single paramter (e.g. 0Fn) or separated (e.g. 0 F n).

        To view https://wttr.in/:help at the command line, run this script with the Location equal to :help

  Exit status:
        0       if OK,

        1       if any error with the script occurs,

        n       as value n if either the 'curl' or 'wget' command (whichever was chosen or found first) exits with a positive value.

AUTHOR
  This 'weather' script was written by Jeremy Gagliardi.
  The 'wttr.in' web site was created by Igor Chubin.

COPYRIGHT
  This 'weather' script is copyright © 2024-2025 by Jeremy Gagliardi.  License GPL-3.0.  You may copy it if you give me full attribution as its creator.
See the 'wttr.in' website for its copyright information.  Jeremy Gagliardi has no affiliation with Igor Chubin or the 'wttr.in' website.  This 'weather'
script is absolutely free: you are free to change and redistribute it with proper attribution.  There is NO WARRANTY whatsoever.
```

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
