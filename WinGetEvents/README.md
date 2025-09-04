# Shell Scripts

Hello and welcome to my Shell Scripts repository.

These are some of my more useful shell scripts.  In this folder...

- **WinGetEvents** -- PowerShell
  - Filters Windows event logs based on severity (-l), date/interval (-d, -r), excluded event IDs (-x), and outputs results in XML format with a summary. Event exclusions (-x) are passed as a quoted comma-separated list. Date range (-r) must include exactly two dates (from,to) in "yyyy-mm-dd,yyyy-mm-dd" format.

Complete Help page...
```
.SYNOPSIS
  Advanced Windows Event Log Filter Script
.DESCRIPTION
  Filters Windows event logs based on severity level (-l), date/interval (-d or -r), by log names (-n) or System by default, excluding event IDs (-x), and outputs results formatted in
  either XML or Text with -t with a summary above. Log name inclusions (-n) are passed as a quoted comma-separated list. Event exclusions (-x) are passed as a quoted comma-separated
  list. Date range (-r) must include exactly 2 dates (from,to) in "yyyy-mm-dd,yyyy-mm-dd" format. With -t, always quote field contents with -q, -qo, or -qc. Output by default goes to
  the console or to an output file path (-o).
.PARAMETER d or Days
  Number of days ago to include (mutually exclusive with -r).
.PARAMETER h or Help
  Output this help screen and exit.
.PARAMETER l or MaxLevel
  Max log level (1=Critical, 2=Error, 3=Warning, 4=Information, 5=Verbose). The number you choose will retrieve that level and below.
.PARAMETER n Names
  Quoted comma-separated list of log names to include (e.g. "Application,Security,System") (includes System if omitted).
.PARAMETER o or OutFile
  Output file path (writes to the console if omitted).
.PARAMETER q or Quote
  Always quote field contents with double quotes* in plain text format (-t).
  * Or specify the opening & closing quotes with -qo & -qc.
.PARAMETER qo or QuoteOpening
  With -t, specify the opening quote with this option (e.g. -qo "«").
.PARAMETER qc or QuoteClosing
  With -t, specify the closing quote with this option (e.g. -qc "»").
.PARAMETER r or Range
  Comma-separated date range: start,end (e.g. "2025-08-01,2025-08-31").
.PARAMETER t or Text
  By default, output is XML. Use this to output events in plain text format.
.PARAMETER v or Verbosity
  Set verbosity level (0=none, 1=basic, 2=very) to indicate what it's doing. With -o, verbose messages are not included in the output file.
  Very verbose output may exceed the History Size of your terminal. If so...
    1. Capture output to a file by appending this to the end of script execution:
      script.ps1 6>&1 | Out-File -FilePath "log.txt" -Encoding Unicode
    2. Increase the History Size of your terminal to something much larger.
.PARAMETER x or ExcludeIDs
  Quoted comma-separated list of Event IDs to exclude (e.g. "7034,7039").
.EXAMPLE
  WinGetEvents.ps1 -l 3 -d 1 -x "7034,7039" -o "events.xml"
.EXAMPLE
  WinGetEvents.ps1 -l 2 -r "2025-08-01,2025-08-31"
.EXAMPLE
  WinGetEvents.ps1 -l 2 -d 1 -t
.AUTHOR
  Jeremy Gagliardi
.VERSION
  2025-09-03.2
.LINK
  https://github.com/jjg8/Shell-Scripts/tree/main/WinGetEvents
```

View the script for more details.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
