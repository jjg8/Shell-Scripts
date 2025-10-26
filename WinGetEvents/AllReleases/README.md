# Shell Scripts

Hello and welcome to my Shell Scripts repository.

These are some of my more useful shell scripts.  In this folder...

- **WinGetEvents** — PowerShell
  - Filters Windows event logs based on severity level (-l), date/interval (-d or -r), by log names (-n) or System by default, excluding event IDs (-x), and outputs results formatted in
  either XML or Text with -t with a summary above. Log name inclusions (-n) are passed as a quoted comma-separated list. Event exclusions (-x) are passed as a quoted comma-separated
  list. Date range (-r) must include exactly 2 dates (from,to) in "yyyy-mm-dd,yyyy-mm-dd" format. With -t, always quote field contents with -q, -qo, or -qc. Output by default goes to
  the console or to an output file path (-o).

Complete Help & Release Notes pages...
```
SYNOPSIS
  Advanced Windows Event Log filter output script
DESCRIPTION
  Filters Windows Event Logs based on severity level (-l|-MaxLevel), date/interval (-d|-Days or -r|-Range), by log names (-n) or System by default, excluding event IDs
  (-x|-ExcludeIDs), & outputs results formatted in either XML or Text with -t|-Text with a summary above. Log name inclusions (-n) are passed as a quoted comma-separated list. Event
  exclusions (-x|-ExcludeIDs) are passed as a quoted comma-separated list. Date range (-r|-Range) must include exactly 2 dates (from,to) in 'yyyy-mm-dd,yyyy-mm-dd' format. With
  -t|-Text, always quote field contents with -q|-Quote, -qo|-QuoteOpening, or -qc|-QuoteClosing. Output by default goes to the console or to an output file path with -o|-Out|-OutFile.
  If the script encounters an error it can't handle (whichever it encounters first)...
   • Usage error, it will exit with code 1.
   • Coding error, it will exit with code 2.
   • Missing requirements in -NonInteractive mode, it will exit with code 3.
  Parameters are processed in the following order of precedence...
    1. -dbg|-Debugging takes precedence over -v|-Verbosity.
    2. -Silent (also triggered by -niv|-ni|-NonInteractive).
    3. -niv takes precedence over -ni|-NonInteractive, ignores -h|-Help.
    4. -h|-Help takes precedence over -Releases|-ReleaseNotes, & if either is used, it's processed immediately & exits.
    5. From this point, all other parameters are processed in alphabetical order.
       5a. -d|-Days takes precedence over -r|-Range.
       5b. -qo|-QuoteOpening & -qc|-QuoteClosing both take precedence over -q|-Quote.
INPUTS
  This script does not accept pipeline input, it requires certain CLI parameters (at least -l|-MaxLevel & one of -d|-Days or -r|-Range), & it can use other parameters to get the
  proper info & format it to the desired state. For all parameters that take a quoted argument (e.g. -r 'yyyy-mm-dd,yyyy-mm-dd'), the examples in this help page all show the use of
  single quotes, which takes all text within the quotes as literal plain text. That's fine if your content doesn't contain any single quotes & you don't use any variables (e.g.
  "${varName}"), but if so, you're better off using double quotes. If you use double quotes, keep in mind that certain references are no longer taken as literal text, & certain
  characters must be escaped using ` — if your content contains any double quotes, escape each " as `". If your content contains something that looks like code, such as a variable
  reference, like ${varName} or $varName, & you want it taken as literal text, not interpreted as code, also escape each $ as `$ (e.g. -o "${pathTo}\`$sToDonuts.txt").
OUTPUTS
  Output is sent to the following...
   • All normal text: the Success stream, 1, using Write-Output, & this does not support color.
   • Everything else: [Console], using Write-Host (includes all Error, Warning, Verbose, & Debug messages), & this supports color.
     • Error, Warning, Verbose, & Debug go to [Console], because if they went to stream 1, output would be captured as return statuses from functions.
     • Streams 2-6 can't be used, because Write-Host (to support -BackgroundColor & -ForegroundColor) cannot be redirected to those streams.

-d|-Days N
  Specify the number of days ago  as N, an Integer >=0, to include (mutually exclusive with -r|-Range). With this parameter, it will get all events from midnight of the date equal to
  N days ago up to the present date & time, where 0 is today, 1 is yesterday, etc. One of -d|-Days or -r|-Range is required.
-dbg|-Debugging
  Enables Verbosity to its max+1 & it will not write any changes. Since this sets the Verbosity level automatically, parameter -v|-Verbosity is ignored.
-h|-Help
  Output this help page & exit.
-l|-MaxLevel N
  Specify the max log level as N (1=Critical, 2=Error, 3=Warning, 4=Information, 5=Verbose). The number you choose will retrieve that level & below (e.g. -l 2 will get all Critical &
  Error events). This parameter is required.
-n|-Names 'Name1,Name2,...,NameN'
  Specify the event log names to be included as a quoted comma-separated list of log names (e.g. -n 'Application,Security,System'). Only 'System' is used by default if this parameter
  is not used. Each log name you specify must match exactly how it appears in the Event Viewer (e.g. -n 'Hardware Events'). See INPUTS above regarding proper quoting.
-o|-Out|-OutFile 'C:\path\to\outfile.xml'
  Specify the output file path, including directory, file name, & extension desired. If this parameter is not used, it only outputs in the console. See INPUTS above regarding proper
  quoting.
-q|-Quote
  Only relevant with parameter -t|-Text, always quote field contents using double quotes*. Unlike the next 2 parameters, this parameter does not take an argument, since you're using
  the default of double quotes.
  * Or customize the opening & closing quotes used with -qo|-QuoteOpening & -qc|-QuoteClosing.
-qo|-QuoteOpening 'X'
  Only relevant with parameter -t|-Text, & most likely used in conjunction with -qc|-QuoteClosing, specify the opening quote as 'X' (e.g. -qo '«'). If you use parameter -q|-Quote
  instead of -qo|-QuoteOpening & -qc|-QuoteClosing, it uses double quotes around each field's contents. See INPUTS above regarding proper quoting.
-qc|-QuoteClosing 'X'
  Only relevant with parameter -t|-Text, & most likely used in conjunction with -qo|-QuoteOpening, specify the closing quote as 'X' (e.g. -qc '»'). If you use parameter -q|-Quote
  instead of -qo|-QuoteOpening & -qc|-QuoteClosing, it uses double quotes around each field's contents. See INPUTS above regarding proper quoting.
-r|-Range 'yyyy-mm-dd,yyyy-mm-dd'
  Specify a quoted comma-separated date range in from,to order (e.g. -r '2025-08-01,2025-08-31'). See INPUTS above regarding proper quoting.
-Releases|-ReleaseNotes
  Output the release notes page & exit.
-Silent
  Normally, any warning or error message also beeps in the console, but by using this parameter, the beep is silenced.
-t|-Text
  By default, output is XML. Use this parameter to output events in plain text format instead.
-v|-Verbosity N
  Set the verbosity level to N (0=none, 1=basic, 2=very) to indicate what it's doing. Verbose messages are not included in the output if you use parameter -o|-Out|-OutFile.
  Very verbose output may exceed the history size of your console, & if so, you can...
   1.  Redirect the Information stream (6) to a file by appending this to the end of script execution:
         WinGetEvents.ps1 6>'log.txt'
   2a. Newer systems — Increase the History Size of your console to something much larger (e.g. my default is 2000000, i.e. 2 million lines).
   2b. Older systems — Increase the Screen Buffer Size, Height, of your console to 9999 (the max it supports; if it isn't enough see 1).
-x|-ExcludeIDs 'ID1,ID2,...,IDN'
  Specify a quoted comma-separated list of Event ID numbers to exclude (e.g. -x '7034,7039'). Without this parameter, all Event ID numbers are included.

EXAMPLE
  WinGetEvents.ps1 -l 3 -d 1 -x '7034,7039' -o 'events.xml'
  WinGetEvents.ps1 -l 2 -r '2025-08-01,2025-08-31'
  WinGetEvents.ps1 -l 2 -d 1 -t

AUTHOR  Jeremy Gagliardi
VERSION 2025-10-21.3
LINK    https://github.com/jjg8/Shell-Scripts/tree/main/WinGetEvents

NOTES
 • PowerShell does not allow direct script execution by default. To enable, you need to...
   • Launch the PowerShell console using "Run as Administrator", & execute one of the following commands, depending on your needed scope...
     • Set-ExecutionPolicy Bypass -Scope CurrentUser
     • Set-ExecutionPolicy Bypass -Scope LocalMachine
   • Usually, when you download a script from the Internet, it'll be blocked by default, & you can unblock it with this command...
     • Unblock-File -Path 'C:\path\to\WinGetEvents.ps1'
 • Unicode characters & encoding...
   • This script has many UTF-8 characters in it above and beyond the Basic Latin block.
   • Sometimes, data sources from other services (e.g. Event Log data) may have UTF-8 characters in them you might not be aware of.
   • Many modern text & document editors use more than Basic Latin (what many old-timers might call ASCII), probably without many even realizing it...
     • E.g. Word, Confluence, and I'm sure others, automatically use En Dash, Em Dash, bullets, curved quotes, and other special characters, all of which aren't in Basic Latin, and
     much of which end up in email messages & documents.
   • If a UTF character doesn't render, it's your font, not your app or OS, unless your app doesn't let you choose the best font, then it's your app.
 • You can read the comments in the script for a lot more detail.

Release Notes for WinGetEvents.ps1, below Script Conventions, most recent at the bottom:

 Script Conventions (best effort)...
 • I use the term "console", rather than terminal, because that's how PowerShell refers to it using the "[Console]::" directive.
 • For the best viewing experience, expand your window to be at least 155 characters wide, until these lines are no longer wrapped...
        10        20        30        40        50        60        70        80        90       100       110       120       130       140       150  155
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345
   • That means all code & comment lines in this script will not exceed 155 & will be manually wrapped to the next line(s) to avoid awkward auto-wrapping, except for the help &
   release notes blocks, which will be auto-wrapped by using the -h|-Help or -Releases|-ReleaseNotes CLI parameters.
 • All variable & function names are unique throughout the script for easy search & replace.
 • All function names use Word1-...-WordN syntax (e.g. Do-Output-Error or Do-Get-Var-Quoted).
 • All variables are written in the form ${...} (e.g. ${_}, ${exitCode}, etc.) for both readability & better functionality — By bracing all variable names, aside from distinguishing
 them better, it's also possible to embed them in text (e.g. abc${def}ghi) without the outer text being confused for part of the variable name, & global search & replace is much
 easier (e.g. {exitCode} & -exitCode are far less likely to be confused for other text).
 • Global variables use the ${Script:VarName} (upper-case V) syntax and all using the Script: Namespace, while function local variables all use the ${varName} (lower-case v) syntax, &
 key names are always KeyName (title-case) syntax.
   • ${Script:VarName} makes it globally accessible within the script but must always be referenced inside functions as ${Script:VarName} & not just ${VarName}, otherwise ${VarName}
   will be treated as if it's a local variable inside the function, & it won't work.
   • All variables named like ${varName} (lower-case v) within a function are local only to that function.
   • PowerShell's ${Global:VarName} definitions survive after script execution in the console session, & there are no such variables in this script.
   • PowerShell's ${Script:VarName} is global within the script, but it doesn't survive into the console session after the script exits.
 • All common Do-* functions are listed first in alphabetical order, followed by all other functions unique to this script in alphabetical order.
 • I made an effort to comment what a closing } belongs to if the opening { is more than a typical screenful away & for all for|foreach loops.
   • So, if you don't see "} # END of blahblahblah", the opening { is probably easily found nearby.
 • Notes on Unicode characters used & handled by this script...
   • Not all Unicode characters will render in all text editors & consoles or by all fonts.
   • I recommend the DejaVu Sans Mono font if any Unicode characters aren't rendering in your text editor or console.
   • If you see any of the following:  a diamond with a ? in it or a tall rectangle with ?, X, /, \, or empty, then those are the so-called "tofu" characters (depending on which font
   you're using), meaning a Unicode character isn't rendering with the font used.
   • Also, any FullWidth characters may appear slightly wider than standard-width characters, which means, even when using a monospace (fixed-width)
      font, they may not line up with the standard-width characters.
   • If a UTF character doesn't render, it's your font, not your app or OS, unless your app doesn't let you choose the best font, then it's your app.
 • Banners were made using https://www.bagill.com/ascii-sig.php
   • To re-create, choose font Banner3-D, & add a space before & after the text you generate.
   • I manually added an extra row of colons before & after each word to give it more of a uniform background.
   • I also added the same text after each one, so it's searchable.
 • All of my scripts are laid out into the following 3 major sections, each with a large banner as above for greater visibility...
   1. GLOBAL DECLARATIONS
      • First is always to Declare All CLI Parameters.
      • Next is Console Encoding.
      • Last is always to Declare All Global Variables, all using the Script: Namespace.
   2. FUNCTIONS
      • First, all common Do-* functions are defined in alphabetical order.
      • Next, all other functions unique to this script are defined in alphabetical order.
   3. MAIN BODY
      • First is always Parameter Processing.
      • Next is always main code to run the script.
      • Any exit point from the script is handled via Do-Process-Exit, no matter the exit code or reason.
 • I use the following version number syntax:  yyyy-mm-dd.# (e.g. 2025-10-14.1)
   • If there is a functional change, but basically the same format, I'll add a 2nd # (e.g. 2025-10-15.1.2).
   • If there is a minor change that doesn't impact functionality, I'll add a 3rd # (e.g. 2025-10-16.1.2.3).

2025-08-24.1
 • Initial release.
 • Very basic functionality, just CLI parameters:  -d, -l, -o, -r, & -x.

2025-09-03.2
 • Rewritten from the ground up.
 • Added longer, more meaningful, CLI parameter names:  -d|-Days, -l|-MaxLevel, -o|-Out|-OutFile, -r|-Range, & -x|-ExcludeIDs
 • Added more CLI parameters:  -h|-Help, -n|-Names, -q|-Quote, -qo|-QuoteOpening, -qc|-QuoteClosing, -t|-Text, & -v|-Verbosity
 • Wrote a complete help page & 2 functions to display it.

2025-09-09.2.0.1
 • Minor bug fix — Replaced all ${Global:VarName} Namespace references with ${Script:VarName}.
   • Having just learned PowerShell (after a lifetime of Linux shell scripting), I didn't know that a Global: Namespace reference meant it survives past script execution in the
   console session & learned that a Script: Namespace reference is the same as a global scope but only within the script itself.

2025-09-09.2.0.2
 • Minor bug fix — Replaced logic for getting the script's own directory with code that actually worked.

2025-10-10.3
 • Common functions...
   • Replaced a lot of common functions with better-written versions.
   • When copying a lot of the common functions between scripts, I noticed ways to improve them & rename them all beginning with Do- to distinguish them from all other functions that
   are unique to each script.
   • I began ordering all Do-* functions first alphabetically, followed by all other functions unique to this script next alphabetically.
   • Added function Do-Auto-Plural to handle automatic word choice based on an Integer, singular if 1|-1 or plural otherwise.
 • Release Notes...
   • Added this Release Notes page.
   • Added a -releaseNotes switch to function Do-Output-Help-Page.
   • Added CLI parameter -Releases|-ReleaseNotes.
 • Rewrote the help page from the ground up.
 • Added CLI parameter -dbg|-Debugging.
 • Improved comments throughout the script.
 • Replaced all references to WinGetEvents in the help block with WinGetEvents, & re-wrote the function Do-Output-Help-Page logic to replace it dynamically with
 ${Script:RuntimeTable}.BareName, so the same function can be copied from script-to-script & work in each without any rewrites necessary.
 • Replaced all of the ${Script:*} variables with hash tables ${Script:EventLogTable}, ${Script:RegExTable}, & ${Script:RuntimeTable}.
 • Incorporated the Script Conventions block as the top portion of this release notes page, so you can view it properly in the console.
```

View the script for more details.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
