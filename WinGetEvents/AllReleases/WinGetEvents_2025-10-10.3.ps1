<############### See NOTES in the help page regarding execution of PowerShell scripts.
## ▄▄▄▄▄▄▄▄▄▄▄▄▄ In Notepad++, this file needs to be saved with Encoding=UTF-16 LE BOM, & there are some UTF characters saved in this script.
## ▌           ▐ Similarly, it works with XML data using the header <?xml version="1.0" encoding="utf-16"?>
## ▌ IMPORTANT ▐ Not all Unicode characters will render in all text editors & consoles or by all fonts.
## ▌           ▐ Most of the Unicode characters in this script are widely compatible (except for certain optional quotes in function Do-Get-Quoted).
## ▀▀▀▀▀▀▀▀▀▀▀▀▀ I recommend the DejaVu Sans Mono font if any Unicode characters aren't rendering in your text editor or console.
################ It's your font, not your app or OS, unless your app doesn't let you choose the best font, then it's your app.
For the best viewing experience, expand your window to be at least 155 characters wide, until these lines are no longer wrapped...
        10        20        30        40        50        60        70        80        90       100       110       120       130       140       150  155
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345
################>


#####
# The following <#-HELP-#...#-HELP-#> block should be viewed with CLI parameter -h|-Help to see it properly formatted, displaying all
#  lines between (but not including) <#-HELP-# & #-HELP-#>, with several key references in it dynamically replaced & auto-wrapping long lines...
#  • Do not move, alter, or duplicate the <#-HELP-# & #-HELP-#> lines, which must be at the start of their own lines, as those are the coded references.
#####
<#-HELP-#

.SYNOPSIS
  Advanced Windows Event Log filter output script
.DESCRIPTION
  Filters Windows Event Logs based on severity level (-l|-MaxLevel), date/interval (-d|-Days or -r|-Range), by log names (-n) or System by default, excluding event IDs (-x|-ExcludeIDs), & outputs results formatted in either XML or Text with -t|-Text with a summary above. Log name inclusions (-n) are passed as a quoted comma-separated list. Event exclusions (-x|-ExcludeIDs) are passed as a quoted comma-separated list. Date range (-r|-Range) must include exactly 2 dates (from,to) in 'yyyy-mm-dd,yyyy-mm-dd' format. With -t|-Text, always quote field contents with -q|-Quote, -qo|-QuoteOpening, or -qc|-QuoteClosing. Output by default goes to the console or to an output file path with -o|-Out|-OutFile.
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
.INPUTS
  This script does not accept pipeline input, it requires certain CLI parameters (at least -l|-MaxLevel & one of -d|-Days or -r|-Range), & it can use other parameters to get the proper info & format it to the desired state. For all parameters that take a quoted argument (e.g. -r 'yyyy-mm-dd,yyyy-mm-dd'), the examples in this help page all show the use of single quotes, which takes all text within the quotes as literal plain text. That's fine if your content doesn't contain any single quotes & you don't use any variables (e.g. "${varName}"), but if so, you're better off using double quotes. If you use double quotes, keep in mind that certain references are no longer taken as literal text, & certain characters must be escaped using ` — if your content contains any double quotes, escape each " as `". If your content contains something that looks like code, such as a variable reference, like ${varName} or $varName, & you want it taken as literal text, not interpreted as code, also escape each $ as `$ (e.g. -o "${pathTo}\`$sToDonuts.txt").
.OUTPUTS
  Output is sent to the following...
   • All normal text: the Success stream, 1, using Write-Output, & this does not support color.
   • Everything else: [Console], using Write-Host (includes all Error, Warning, Verbose, & Debug messages), & this supports color.
     • Error, Warning, Verbose, & Debug go to [Console], because if they went to stream 1, output would be captured as return statuses from functions.
     • Streams 2-6 can't be used, because Write-Host (to support -BackgroundColor & -ForegroundColor) cannot be redirected to those streams.

.PARAMETER -d|-Days N
  Specify the number of days ago  as N, an Integer >=0, to include (mutually exclusive with -r|-Range). With this parameter, it will get all events from midnight of the date equal to N days ago up to the present date & time, where 0 is today, 1 is yesterday, etc. One of -d|-Days or -r|-Range is required.
.PARAMETER -dbg|-Debugging
  Enables Verbosity to its max+1 & it will not write any changes. Since this sets the Verbosity level automatically, parameter -v|-Verbosity is ignored.
.PARAMETER -h|-Help
  Output this help page & exit.
.PARAMETER -l|-MaxLevel N
  Specify the max log level as N (1=Critical, 2=Error, 3=Warning, 4=Information, 5=Verbose). The number you choose will retrieve that level & below (e.g. -l 2 will get all Critical & Error events). This parameter is required.
.PARAMETER -n|-Names 'Name1,Name2,...,NameN'
  Specify the event log names to be included as a quoted comma-separated list of log names (e.g. -n 'Application,Security,System'). Only 'System' is used by default if this parameter is not used. Each log name you specify must match exactly how it appears in the Event Viewer (e.g. -n 'Hardware Events'). See INPUTS above regarding proper quoting.
.PARAMETER -o|-Out|-OutFile 'C:\path\to\outfile.xml'
  Specify the output file path, including directory, file name, & extension desired. If this parameter is not used, it only outputs in the console. See INPUTS above regarding proper quoting.
.PARAMETER -q|-Quote
  Only relevant with parameter -t|-Text, always quote field contents using double quotes*. Unlike the next 2 parameters, this parameter does not take an argument, since you're using the default of double quotes.
  * Or customize the opening & closing quotes used with -qo|-QuoteOpening & -qc|-QuoteClosing.
.PARAMETER -qo|-QuoteOpening 'X'
  Only relevant with parameter -t|-Text, & most likely used in conjunction with -qc|-QuoteClosing, specify the opening quote as 'X' (e.g. -qo '«'). If you use parameter -q|-Quote instead of -qo|-QuoteOpening & -qc|-QuoteClosing, it uses double quotes around each field's contents. See INPUTS above regarding proper quoting.
.PARAMETER -qc|-QuoteClosing 'X'
  Only relevant with parameter -t|-Text, & most likely used in conjunction with -qo|-QuoteOpening, specify the closing quote as 'X' (e.g. -qc '»'). If you use parameter -q|-Quote instead of -qo|-QuoteOpening & -qc|-QuoteClosing, it uses double quotes around each field's contents. See INPUTS above regarding proper quoting.
.PARAMETER -r|-Range 'yyyy-mm-dd,yyyy-mm-dd'
  Specify a quoted comma-separated date range in from,to order (e.g. -r '2025-08-01,2025-08-31'). See INPUTS above regarding proper quoting.
.PARAMETER -Releases|-ReleaseNotes
  Output the release notes page & exit.
.PARAMETER -Silent
  Normally, any warning or error message also beeps in the console, but by using this parameter, the beep is silenced.
.PARAMETER -t|-Text
  By default, output is XML. Use this parameter to output events in plain text format instead.
.PARAMETER -v|-Verbosity N
  Set the verbosity level to N (0=none, 1=basic, 2=very) to indicate what it's doing. Verbose messages are not included in the output if you use parameter -o|-Out|-OutFile.
  Very verbose output may exceed the history size of your console, & if so, you can...
   1.  Redirect the Information stream (6) to a file by appending this to the end of script execution:
         ScriptName.ps1 6>'log.txt'
   2a. Newer systems — Increase the History Size of your console to something much larger (e.g. my default is 2000000, i.e. 2 million lines).
   2b. Older systems — Increase the Screen Buffer Size, Height, of your console to 9999 (the max it supports; if it isn't enough see 1).
.PARAMETER -x|-ExcludeIDs 'ID1,ID2,...,IDN'
  Specify a quoted comma-separated list of Event ID numbers to exclude (e.g. -x '7034,7039'). Without this parameter, all Event ID numbers are included.

.EXAMPLE
  ScriptName.ps1 -l 3 -d 1 -x '7034,7039' -o 'events.xml'
  ScriptName.ps1 -l 2 -r '2025-08-01,2025-08-31'
  ScriptName.ps1 -l 2 -d 1 -t

.AUTHOR  Jeremy Gagliardi
.VERSION 2025-10-21.3
.LINK    https://github.com/jjg8/Shell-Scripts/tree/main/WinGetEvents

.NOTES
 • PowerShell does not allow direct script execution by default. To enable, you need to...
   • Launch the PowerShell console using "Run as Administrator", & execute one of the following commands, depending on your needed scope...
     • Set-ExecutionPolicy Bypass -Scope CurrentUser
     • Set-ExecutionPolicy Bypass -Scope LocalMachine
   • Usually, when you download a script from the Internet, it'll be blocked by default, & you can unblock it with this command...
     • Unblock-File -Path 'C:\path\to\ScriptName.ps1'
 • Unicode characters & encoding...
   • This script has many UTF-8 characters in it above and beyond the Basic Latin block.
   • Sometimes, data sources from other services (e.g. Event Log data) may have UTF-8 characters in them you might not be aware of.
   • Many modern text & document editors use more than Basic Latin (what many old-timers might call ASCII), probably without many even realizing it...
     • E.g. Word, Confluence, and I'm sure others, automatically use En Dash, Em Dash, bullets, curved quotes, and other special characters, all of which aren't in Basic Latin, and much of which end up in email messages & documents.
   • If a UTF character doesn't render, it's your font, not your app or OS, unless your app doesn't let you choose the best font, then it's your app.
 • You can read the comments in the script for a lot more detail.

#-HELP-#> # CLI parameter -h|-Help will output everything above this line, formatted & auto-wrapped.


#####
# The following <#-NOTES-#...#-NOTES-#> block should be viewed with CLI parameter -Releases|-ReleaseNotes to see it properly formatted, displaying all
#  lines between (but not including) <#-NOTES-# & #-NOTES-#>, with several key references in it dynamically replaced & auto-wrapping long lines...
#  • Do not move, alter, or duplicate the <#-NOTES-# & #-NOTES-#> lines, which must be at the start of their own lines, as those are the coded references.
#####
<#-NOTES-#

Release Notes for ScriptName.ps1, below Script Conventions, most recent at the bottom:

 Script Conventions (best effort)...
 • I use the term "console", rather than terminal, because that's how PowerShell refers to it using the "[Console]::" directive.
 • For the best viewing experience, expand your window to be at least 155 characters wide, until these lines are no longer wrapped...
        10        20        30        40        50        60        70        80        90       100       110       120       130       140       150  155
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345
   • That means all code & comment lines in this script will not exceed 155 & will be manually wrapped to the next line(s) to avoid awkward auto-wrapping, except for the help & release notes blocks, which will be auto-wrapped by using the -h|-Help or -Releases|-ReleaseNotes CLI parameters.
 • All variable & function names are unique throughout the script for easy search & replace.
 • All function names use Word1-...-WordN syntax (e.g. Do-Output-Error or Do-Get-Var-Quoted).
 • All variables are written in the form ${...} (e.g. ${_}, ${exitCode}, etc.) for both readability & better functionality — By bracing all variable names, aside from distinguishing them better, it's also possible to embed them in text (e.g. abc${def}ghi) without the outer text being confused for part of the variable name, & global search & replace is much easier (e.g. {exitCode} & -exitCode are far less likely to be confused for other text).
 • Global variables use the ${Script:VarName} (upper-case V) syntax and all using the Script: Namespace, while function local variables all use the ${varName} (lower-case v) syntax, & key names are always KeyName (title-case) syntax.
   • ${Script:VarName} makes it globally accessible within the script but must always be referenced inside functions as ${Script:VarName} & not just ${VarName}, otherwise ${VarName} will be treated as if it's a local variable inside the function, & it won't work.
   • All variables named like ${varName} (lower-case v) within a function are local only to that function.
   • PowerShell's ${Global:VarName} definitions survive after script execution in the console session, & there are no such variables in this script.
   • PowerShell's ${Script:VarName} is global within the script, but it doesn't survive into the console session after the script exits.
 • All common Do-* functions are listed first in alphabetical order, followed by all other functions unique to this script in alphabetical order.
 • I made an effort to comment what a closing } belongs to if the opening { is more than a typical screenful away & for all for|foreach loops.
   • So, if you don't see "} # END of blahblahblah", the opening { is probably easily found nearby.
 • Notes on Unicode characters used & handled by this script...
   • Not all Unicode characters will render in all text editors & consoles or by all fonts.
   • I recommend the DejaVu Sans Mono font if any Unicode characters aren't rendering in your text editor or console.
   • If you see any of the following:  a diamond with a ? in it or a tall rectangle with ?, X, /, \, or empty, then those are the so-called "tofu" characters (depending on which font you're using), meaning a Unicode character isn't rendering with the font used.
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
   • Having just learned PowerShell (after a lifetime of Linux shell scripting), I didn't know that a Global: Namespace reference meant it survives past script execution in the console session & learned that a Script: Namespace reference is the same as a global scope but only within the script itself.

2025-09-09.2.0.2
 • Minor bug fix — Replaced logic for getting the script's own directory with code that actually worked.

2025-10-10.3
 • Common functions...
   • Replaced a lot of common functions with better-written versions.
   • When copying a lot of the common functions between scripts, I noticed ways to improve them & rename them all beginning with Do- to distinguish them from all other functions that are unique to each script.
   • I began ordering all Do-* functions first alphabetically, followed by all other functions unique to this script next alphabetically.
   • Added function Do-Auto-Plural to handle automatic word choice based on an Integer, singular if 1|-1 or plural otherwise.
 • Release Notes...
   • Added this Release Notes page.
   • Added a -releaseNotes switch to function Do-Output-Help-Page.
   • Added CLI parameter -Releases|-ReleaseNotes.
 • Rewrote the help page from the ground up.
 • Added CLI parameter -dbg|-Debugging.
 • Improved comments throughout the script.
 • Replaced all references to WinGetEvents in the help block with ScriptName, & re-wrote the function Do-Output-Help-Page logic to replace it dynamically with ${Script:RuntimeTable}.BareName, so the same function can be copied from script-to-script & work in each without any rewrites necessary.
 • Replaced all of the ${Script:*} variables with hash tables ${Script:EventLogTable}, ${Script:RegExTable}, & ${Script:RuntimeTable}.
 • Incorporated the Script Conventions block as the top portion of this release notes page, so you can view it properly in the console.

#-NOTES-#> # Parameter -Releases|-ReleaseNotes will output everything above this line, formatted & auto-wrapped.



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



#####
##### Declare All CLI Parameters...
#####
# • All are Mandatory=${False} here, so parameter checking can be done below in the Parameter Processing section.
#####

[CmdletBinding()]
param (
    [Parameter(Mandatory=${False})][Alias('d')                        ][String]${Days},
    [Parameter(Mandatory=${False})][Alias('dbg')                      ][Switch]${Debugging},
    [Parameter(Mandatory=${False})][Alias('h')                        ][Switch]${Help},
    [Parameter(Mandatory=${False})][Alias('l')][ValidateSet(1,2,3,4,5)][Int   ]${MaxLevel},
    [Parameter(Mandatory=${False})][Alias('n')                        ][String]${Names},
    [Parameter(Mandatory=${False})][Alias('o','Out')                  ][String]${OutFile},
    [Parameter(Mandatory=${False})][Alias('q')                        ][Switch]${Quote},
    [Parameter(Mandatory=${False})][Alias('qo')                       ][String]${QuoteOpening},
    [Parameter(Mandatory=${False})][Alias('qc')                       ][String]${QuoteClosing},
    [Parameter(Mandatory=${False})][Alias('r')                        ][String]${Range},
    [Parameter(Mandatory=${False})][Alias('Releases')                 ][Switch]${ReleaseNotes},
    [Parameter(Mandatory=${False})]                                    [Switch]${Silent},
    [Parameter(Mandatory=${False})][Alias('t')                        ][Switch]${Text},
    [Parameter(Mandatory=${False})][Alias('v')                        ][Int   ]${Verbosity},
    [Parameter(Mandatory=${False})][Alias('x')                        ][String]${ExcludeIDs}
)


#####
##### Console Encoding — Ensure all output is properly encoded to handle Unicode characters...
#####

[Console]::OutputEncoding = [System.Text.Encoding]::Unicode


#####
##### Declare All Global Variables...
#####
# • Any declaration in [] on its own line, needs to end with ` (and nothing after it, including comments), otherwise it announces the type to the console.
# • Script: means it's global within the script (don't use Global:, because that survives after script execution into the session).
#####


##### All data used for Event Log output and formatting...
[HashTable]${Script:EventLogTable} = @{
    DateFrom       = [DateTime                    ]( Get-Date )
    DateThru       = [DateTime                    ]( Get-Date )
    Description    = [String                      ]''
    DoText         = [Bool                        ]${False}
    EventList      = [System.Collections.ArrayList]@()
    ExcludedIDs    = [Int[]                       ]@()
    IncludedString = [String                      ]''
    IncludedNames  = [String[]                    ]@()
    LevelCount     = [Int                         ]0
    LevelLabel     = [String                      ]''
    LevelList      = [HashTable]@{
        1 = 'Critical'
        2 = 'Error'
        3 = 'Warning'
        4 = 'Information'
        5 = 'Verbose'
    }
    LevelTotal     = [Int]0
    Output         = [String[]                    ]@()
    Quote          = [HashTable]@{
        Opening  = '"'; Closing = '"'
        ##### Other ideas (customize to suit)...
        #Opening = '«'; Closing = '»' # E.g. «string»
        #Opening = '“'; Closing = '”' # E.g. “string”
        #Opening = '‹'; Closing = '›' # E.g. ‹string›
        #Opening = "‘"; Closing = "’" # E.g. ‘string’
    }
    Summary        = [String                      ]'' # Used only if ${Script:RuntimeTable}.Verbose.Level>0
    XmlFormatted   = [String                      ]''
    XmlString      = [String                      ]''
} # END of [HashTable]${Script:EventLogTable} = @{}


##### All necessary RegEx patterns for validating user-entered data...
[HashTable]${Script:RegExTable} = @{
    #####
    # Range-check for the ${Script:RuntimeTable}.ExitStatus table, allows an Integer value from 0 to 255...
    #####
    ExitStatus = '^([0-9]|[1-9][0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$'
} # END of [HashTable]${Script:RegExTable} = @{}


#####
# Info, obtained at runtime, about the script itself, the host it's running on, and how it was invoked...
#  • This table also contains some handy constants.
#  • The Beep table will be used to determine if the Do-Output-Error function beeps, based on the below stated criteria.
#  • The ExitStatus table will be used to determine which exit code (Integer 0-255) to use, based on the below stated criteria.
#####
[HashTable]${Script:RuntimeTable} = @{
    ##### The name of the script at invocation, derived from the Basename but without the extension...
    BareName       = [String][System.IO.Path]::GetFileNameWithoutExtension([String]$( Split-Path -Leaf ${MyInvocation}.MyCommand.Path ))
    ##### Just the basename (filename portion, including extension) of the script at invocation...
    Basename       = [String]$( Split-Path -Leaf ${MyInvocation}.MyCommand.Path )
    ##### Just the dirname (full directory-only portion of the path) of the script at invocation...
    Dir_name       = [String]$( Split-Path -Path ${MyInvocation}.MyCommand.Path -Parent ).Replace('Microsoft.PowerShell.Core\FileSystem::', '')
    #####
    # When calling the Do-Output-Error function, decide if it should beep after the message, based on these criteria; customize to suit...
    #  • Set each to ${True} or ${False} for its default.
    #  • These will all be set to ${False} at runtime with parameters -Silent or -niv|-ni|-NonInteractive.
    #  • See the criteria below in the ExitStatus block.
    #####
    ErrorBeepsOn   = @{
        E0Good = ${False} # This should always be False.
        E1Warn = ${True}
        E2User = ${True}
        E3Code = ${True}
       #E4NIMR is never used in this context, since parameter -niv|-ni|-NonInteractive always enables -Silent, which sets these all to False.
        EXMore = ${True}  # When any other exit code is passed in to the Do-Output-Error function that's not defined below in the ExitStatus block.
    }
    #####
    # Different exit status codes (Integer 0-255) to use, based on these criteria; customize to suit...
    #  • E0Good [Default=0] must always be 0, unless you want the script to fail under normal circumstances (i.e. don't).
    #  • E1Warn [Default=0] is recommended to be 0, unless you want the script to fail on any Warning message that it could otherwise recover from.
    #  • E2User [Default=1]...
    #  • E3Code [Default=2]...
    #  • E4NIMR [Default=3]...
    #    • These all must be different numbers where E1Warn<E2User<E3Code<E4NIMR<=255 and will be enforced at runtime in Parameter Processing.
    #####
    ExitStatus     = @{
        E0Good = 0 # When everything goes according to plan.
        E1Warn = 0 # When a warning message is written to the console, but the script should continue to execute (if you keep this as 0).
        E2User = 1 # When the user doesn't give the correct parameters at invocation (causes Do-Output-Error to prepend 'ERROR:' & append how to use help).
        E3Code = 2 # When the script encounters a problem it can't handle (causes Do-Output-Error to prepend 'CODING ERROR:' & includes a call stack trace).
                   #  This is due to a coding error (an error by the programmer), as opposed to a usage error (an error by the user).
        E4NIMR = 3 # In -NonInteractive mode if it encounters any Missing Requirements.
                   #  However, if it encounters any error above this first, it'll exit with that status instead.
       #EXMore is not itself an exit status code condition but rather a state in the ErrorBeepsOn block above to mean any other exit code passed in to the
       # Do-Output-Error function that's not defined here in the ExitStatus block.
    }
    ##### The Dir_name & BareName combined...
    FullName       = [String]'' # set below after declaration
    ##### The Dir_name & Basename combined...
    FullPath       = [String]'' # set below after declaration
    Host           = @{
        #####
        # The Local block pertains to how the host sees itself in the local intranet, which may or may not match its public Internet presence...
        #  • In many cases, local DNS info will be intranet-specific or in some cases even absent.
        #  • Local.Domain, if found, is just the DNS DomainName portion on the local intranet without the Local.Hostname portion.
        #    • It's crucial for assembling Local.FQDN.
        #    • If Local.Domain cannot be found in the "Assemble Host.Local.* Addresses" section, this will be set to an empty string ''.
        #  • Local.Hostname is just the hostname portion (without the DNS DomainName portion) of the host.
        #    • It's crucial for assembling Local.FQDN.
        #  • Local.FQDN will either be Local.Hostname & Local.Domain combined or only Local.Hostname if Local.Domain is unknown.
        #####
        Local      = @{
          Domain   = ''
          FQDN     = ''
          Hostname = ${Env:ComputerName}
        }
    }
    ##### Details for -NonInteractive mode...
    NonInteractive = @{
        ##### Indicates whether running in -NonInteractive mode and is set to True at runtime with parameters -niv or -ni|-NonInteractive...
        IsTrue     = ${False}
        Verbose    = @{
            #####
            # The index to ${Script:RuntimeTable}.Verbose.ColorBG|.ColorFG to use to get the proper colors for -NonInteractive mode verbose messages...
            #####
            Color  = 4
            #####
            # If parameter -niv is used, not -Debugging or -v|-Verbosity, it gives verbose messages ONLY for missing reqs in -NonInteractive mode...
            #####
            IsTrue = ${False}
            #####
            # The Verbosity Level with which to indicate any skipped actions while in -NonInteractive mode...
            #  • Refer to ${Script:RuntimeTable}.Verbose.Level below.
            #  • This will indicate whether or not to show skipped actions when -v|-Verbosity N or -dbg|-Debugging (3) >= this number.
            #####
            Level  = 1
            #####
            # Indicates which parameter was used (-niv or -ni|-NonInteractive)...
            #  • It's used both in a verbose message, as well as a usage error message, where applicable.
            #####
            Param  = ''
        } # END of Verbose = @{}
    } # END of NonInteractive = @{}
    ##### All CLI parameters defined (whether used or not) and their metadata at script invocation...
    Parameters     = [System.Management.Automation.ParameterMetadata[]]$( Get-Command ${PSCmdlet}.MyInvocation.InvocationName ).Parameters.Values
    ##### Symbols used in Error, Warning, Verbose, or Debug messages; customize to suit, but keep brief...
    Symbols        = @{
        Bullet = ' • '
        EmDash = ' — '
        Good   = 'OK:' # Also used for matching
        Warn   = '!!!' # Also used for not matching
    }
    ##### The entire invocation line, including (as specified by the user) directory, script filename, and all parameters used...
    UserArgs       = [String]${MyInvocation}.Line
    #####
    # Items used in Verbose/Debug mode; customize to suit...
    #  • Some of these items may also be used in Warning/Error messages.
    #####
    Verbose        = @{
        #####
        # The index numbers correspond to Verbose.Level below...
        #  • 4 only applies to -NonInteractive mode messages.
        #####
        ColorBG = @{
            0 = 'Black'
            1 = 'Black'
            2 = 'Black'
            3 = 'Black'
            4 = 'Black'
        }
        ColorFG = @{
            0 = 'Green'
            1 = 'Cyan'
            2 = 'Yellow'
            3 = 'Magenta'
            4 = 'Blue'
        }
        Divider     = '─' * 15 # A short sequence of horizontal lines.
        InDebugMode = ${False} # Signals from parameter -dbg|-Debugging if the script is in debugging mode; if so any action that writes will be skipped.
        Indent      = '  '     # The string to use to indent Verbose output, and multiplied by successive levels.
        Level       = 0 # Signals from parameters -v|-Verbosity [12] or -dbg|-Debugging (3) if & which Verbose messages are written to the console...
                        #  • It starts at Level=0 (not in a Verbose or Debug mode of any kind).
                        #  • If set with -v|-Verbosity 1, these are messages that just explain what action it's performing at the moment.
                        #  • If set with -v|-Verbosity 2, these are much more verbose messages, that include variable names & values, etc.
                        #  • If set to 3 with -dbg|-Debugging, these are write actions to be skipped in debugging mode.
        ##### This is the string it'll print in Verbose messages if a value = ${Null}, rather than showing empty space...
        NullString  = ' NULL '
    } # END of Verbose = @{}
} # END of [HashTable]${Script:RuntimeTable} = @{}
##### Now assemble from values above...
${Script:RuntimeTable}.FullName = (${Script:RuntimeTable}.Dir_name+'\'+${Script:RuntimeTable}.BareName)
${Script:RuntimeTable}.FullPath = (${Script:RuntimeTable}.Dir_name+'\'+${Script:RuntimeTable}.Basename)



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



#####
##### First, all common Do-* functions are defined in alphabetical order, followed by all other functions unique to this script in alphabetical order...
#####

function Do-Auto-Plural {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Given ${itemCount} (Integer), ${singleForm} (singular form of a word), ${pluralForm} (a plural suffix/word), and other optional parameters, as the
#     function name suggests, it automatically decides if it should be plural or not; based on the Abs(${itemCount}), it'll choose the singular (=1) or
#     plural (≠1) forms, and it returns a string consisting of "${itemCount} ${singleForm}${pluralForm}" as described below.
#  • In the following...
#    • → means 'results in' or 'to'.
#    • → is also defined in the ${complexSuffixes} array as the separator between each singular→plural pair (e.g. 'ex→ices'), meaning if it finds that
#       ${singleForm} ends with 'ex', ${pluralForm} is 'ices', & Abs(${itemCount})≠1 (i.e. it should be plural), it'll remove 'ex' & append 'ices', e.g...
#         Usage:  Do-Auto-Plural ${someInt} 'index' 'ices'
#         If Singular → "${someInt} index"
#         If Plural   → "${someInt} indices" # 'index'-'ex'+'ices' → 'indices'
#  • This function is only meant to be used to auto-pluralize a single word (e.g. 'toy') or a compound (hyphenated) set of word parts (e.g.
#     'mother-in-law'), not a phrase or a sentence, as for example...
#    • Use it like this:  ('A sentence with '+( Do-Auto-Plural ${someInt} 'word' )+'.')
#      • ${someInt}=1  → 'A sentence with 1 word.'
#      • ${someInt}=-1 → 'A sentence with -1 word.'
#      • ${someInt}=2  → 'A sentence with 2 words.' # or any value that's not 1 or -1
#    • Do NOT use it like this:  Do-Auto-Plural ${someInt} "A sentence with ${someInt} word." → "${someInt} A sentence with ${someInt} word.s"
#    • The case of ${singleForm} and ${pluralForm} are used as-is, as for example...
#      • 'latch' 'es' → 'latches' (lower-case)
#      • 'Latch' 'es' → 'Latches' (title-case)
#      • 'LATCH' 'ES' → 'LATCHES' (upper-case)
#      • 'RAID'  's'  → 'RAIDs'   (this is useful if RAID is an acronym and only the letters of the acronym should be upper-case)
#      • 'RAID'  'S'  → 'RAIDS'   (use this form if RAID is just an upper-case word whose plural should also be upper-case)
#    • That said, if you don't specify ${pluralForm}, it defaults to 'S' if the last letter of ${singleForm} is upper-case, or 's' otherwise, e.g...
#      • 'raid'       → 'raids'   (lower-case 'd' results in 's')
#      • 'Raid'       → 'Raids'   (lower-case 'd' results in 's')
#      • 'RAID'       → 'RAIDS'   (upper-case 'D' results in 'S')
#  • Normally, ${pluralForm} is just a simple suffix to be appended, usually 's' or 'es', but it can also be a complex suffix (see the comments below on
#     Complex Suffixes) where the singular suffix needs to be removed before the plural suffix is appended, the most common being 'y→ies', e.g...
#       'fly'-'y'+'ies' → 'flies'
#  • If you need to make a whole-word replacement (e.g. 'man' → 'men'), you can specify ${pluralForm} as the whole word & use the -wholeWord switch.
#
# Logic:
#  • If Abs(${itemCount})=1...
#    • If -padSingle was used, it returns ${singleForm}${pluralForm}, where ${pluralForm}=' '*${pluralLength}, e.g...
#      • 'brother'      'brethren' -padSingle -wholeWord → 'brother '
#      • 'latch'        'es'       -padSingle            → 'latch  '
#      • 'passer-by'               -padSingle            → 'passer-by '
#    • Else if -padSingle was NOT used, it sets ${pluralForm}='', so it just returns ${singleForm}, e.g...
#      • 'brother'      'brethren'            -wholeWord → 'brother'
#      • 'latch'        'es'                             → 'latch'
#      • 'passer-by'                                     → 'passer-by'
#  • Else if Abs(${itemCount})≠1...
#    • If -wholeWord was used, then it sets ${singleForm}='', so it just returns ${pluralForm} (e.g. 'brother' 'brethren' -wholeWord → 'brethren'.
#    • Else if the last letter(s) of ${singleForm} are in ${complexSuffixes} (left of the →) & ${pluralForm} is the corresponding entry (right of the →)
#       (e.g. ${singleForm}='index'; ${pluralForm}='ices'; ${suffixItem}[0]='ex'; ${suffixItem}[1]='ices'), then it first removes the singular suffix
#       from ${singleForm} (e.g. 'index'-'ex' → 'ind') before appending the plural suffix ${pluralForm} (e.g. 'ind'+'ices' → 'indices').
#    • Else if the plural form of ${singleForm} is any of the following...
#      • The same word whether singular or plural (e.g. 'deer'), then you don't need this function, or at least specify e.g. 'deer' 'deer' -wholeWord
#      • A completely different word depending on if it's singular or plural, specify e.g. 'brother' 'brethren' -wholeWord
#      • If ${singleForm} is a compound (hyphenated) set of word parts (e.g. 'passer-by', 'mother-in-law', or 'run-through-of-code')...
#        • If it matches this criteria:
#          • It has 3+ word parts with part 2 one of these ${prepositions} = @('at','by','for','in','of','on','with'), or
#          • It matches the ${leftmostExceptions} = @('hanger-on','looker-on','passer-by','runner-up'),
#          then using -pluralizePart N is optional if it doesn't match the default of pluralizing the leftmost part (i.e. -pluralizePart 1)...
#          • If it should be pluralized on the leftmost part, this is the default, specify e.g. 'mother-in-law' → 'mothers-in-law'.
#          • If it should be pluralized on the rightmost part, specify e.g. 'check-in-time' -pluralizePart 3 → 'check-in-times'.
#        • If it matches any other criteria of hyphenated word parts, you must use -pluralizePart N to force it to a particular part#...
#          • If it should be pluralized on the leftmost part, specify e.g. 'passer-by' -pluralizePart 1 → 'passers-by'.
#          • If it should be pluralized on the rightmost part, specify e.g. 'run-up' -pluralizePart 2 → 'run-ups'.
#          • If it should be pluralized on a middle part, specify e.g. 'run-through-of-code' -pluralizePart 2 → 'run-throughs-of-code'.
#
# Returns:
#  • Via Do-Output-Undefined-Error if...
#    • ${itemCount} (first typed as a String, then converted to Int if Do-Get-Integer doesn't return ${Null}) is undefined or not an Integer, or
#    • ${singleForm} is undefined.
#  • Via Do-Output-Error with -exitKey 'E3Code' if...
#    • -wholeWord was used & ${pluralForm} is in ${suffixes} (i.e. it's not a whole word; see code below).
#    • ${pluralizePart} (first typed as a String, then converted to Int if Do-Get-Integer doesn't return ${Null}) is undefined or not an Integer, or
#    • ${pluralizePart}<1, or
#    • ${pluralizePart}>${partArray}.Count.
#  • Otherwise, it returns [String]"${itemCount} ${singleForm}${pluralForm}" as described above and below.
#
# Usage:
#  • Parameter 1 — ${itemCount}:  String (REQUIRED)  — the number of items to determine if ${singleForm} should be singular (1|-1) or plural (otherwise).
#    • This is String type to start with, so it can detect if a number was defined with it or not, and if valid, converted to Int.
#  • Parameter 2 — ${singleForm}: String (REQUIRED)  — the singular form of the word.
#  • Parameter 3 — ${pluralForm}: String             — [Default=[Ss]] either a plural suffix to append to ${singleForm} or, if using -wholeWord, the
#     whole-word replacement of ${singleForm} if Abs(${itemCount})≠1.
#    • If ${pluralForm} is undefined, then if the last letter of ${singleForm} is an upper-case letter, this defaults to 'S', otherwise 's'.
#    • If you set -pluralForm 'ies' and ${singleForm} ends in '[aeiou]y' (e.g. 'toy'), it'll automatically correct it as if it were -pluralForm 's'.
#    • If you set ${pluralForm}, you must choose the appropriate case (e.g. 'RAID' 's' → 'RAIDs' or 'LATCH' 'ES' → 'LATCHES').
#  • Parameter -padSingle:        Switch             — if used & Abs(${itemCount})=1, it pads ${pluralForm}=' '*${pluralLength} after ${singleForm}.
#  • Parameter -wholeWord:        Switch             — if used, ${pluralForm} is a whole-word replacement when plural (e.g. men for man).
#    • The use of -wholeWord will result in an E3Code error if ${singleForm} matches the entries defined below in ${suffixes} (i.e. not a whole word).
#  • Parameter ${pluralizePart}:  String             — if used, force the plural to part number ${pluralizePart} in a compound (hyphenated) set of parts.
#    • This is String type to start with, so it can detect if a number was defined with it or not, and if valid, converted to Int (N).
#    • The part count, N, starts at 1 and goes up to the number of hyphenated word parts (e.g. mother-in-law has 3 words, so valid values are 1-3).
#    • Normally, if ${singleForm} is a hyphenated set of 3+ words with part 2 being a preposition (e.g. mother-in-law), or if it matches one of the
#       ${leftmostExceptions} defined below (e.g. 'passer-by'), it defaults to pluralizing the leftmost part (1) automatically, or to the last part
#       otherwise. When ${singleForm} doesn't match either pattern, you can force it to part# ${pluralizePart}, as for example...
#         'check-in-time'       -pluralizePart 3 → 'check-in-times'
#         'run-through-of-code' -pluralizePart 2 → 'run-throughs-of-code'
#    • If there is no Nth part (i.e. 1>N>part count), it results in an E3Code error.
#
# Dependencies...
#  • Functions...
#    • Do-Get-Integer
#    • Do-Output-Error
#    • Do-Output-Undefined-Error
#####
    param(
        [String]${itemCount},
        [String]${singleForm},
        [String]${pluralForm},
        [Switch]${padSingle},
        [Switch]${wholeWord},
        [String]${pluralizePart}
    )
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )


    #####
    ##### Local parameter processing...
    #####

    #####
    # Complex Suffixes...
    # • If it's NOT a complex suffix, then ${wordRoot} will stay as-is from ${singleForm}.
    # • Else, ${wordRoot} will be the truncated ${singleForm} as indicated in these examples...
    #     ${singleForm}-${suffixItem}[0] → ${wordRoot}+${suffixItem}[1] → new ${pluralForm} (typical of loanwords from this language)
    #     'alumna'     -'a'              → 'alumn'    +'ae'             → 'alumnae'         (Latin)
    #     'index'      -'ex'             → 'ind'      +'ices'           → 'indices'         (Latin)
    #     'criterion'  -'ion'            → 'criter'   +'ia'             → 'criteria'        (Greek)
    #     'analysis'   -'is'             → 'analys'   +'es'             → 'analyses'        (Greek)
    #     'appendix'   -'ix'             → 'append'   +'ices'           → 'appendices'      (Latin)
    #     'paparazzo'  -'o'              → 'paparazz' +'i'              → 'paparazzi'       (Italian)
    #     'phenomenon' -'on'             → 'phenomen' +'a'              → 'phenomena'       (Greek)
    #     'bacterium'  -'um'             → 'bacteri'  +'a'              → 'bacteria'        (Latin)
    #     'alumnus'    -'us'             → 'alumn'    +'i'              → 'alumni'          (Latin)
    #     'helix'      -'x'              → 'heli'     +'ces'            → 'helices'         (Greek)
    #     'fly'        -'y'              → 'fl'       +'ies'            → 'flies'           (English)
    # • The general rule for 'y'→'ies' is when 'y' is preceeded by a consonant, not a vowel.
    # • There are many singular words ending in '[aeiou]y' (e.g. 'toy') that just use the default suffix 's'.
    #####
    ${complexSuffixes} = @('a→ae','ex→ices','ion→ia','is→es','ix→ices','o→i','on→a','um→a','us→i','x→ces','y→ies')
    ##### Get only the plural suffixes (${suffixItem}[1]) from ${complexSuffixes} as an array ${suffixes}...
    ${suffixes} = @(); foreach (${suffixPair} in ${complexSuffixes}) { ${suffixItem} = ${suffixPair} -Split '→'; ${suffixes} += ${suffixItem}[1] }
    ##### Also add simple suffixes 'es' and 's'...
    ${suffixes} += 'es'; ${suffixes} += 's'
    ##### Prepositions for determining if the plural is to the leftmost or rightmost word in a compound (hyphenated) set of 3 words...
    ${prepositions} = @('at','by','for','in','of','on','with')
    ##### 2-word compounds in this list will set ${pluralizePart}=1, even if not satisfying the usual 3+ words where word 2 is in ${prepositions}...
    ${leftmostExceptions} = @('hanger-on','looker-on','passer-by','runner-up')
    ##### Default value...
    [Int]${pluralizePart} = 1

    #####
    # Local validity and range-checking...
    #####

    ##### If Do-Get-Integer returns ${Null}, then ${itemCount} is NOT a valid Integer, resulting in an UNDEFINED Int error...
    if (( Do-Get-Integer "${itemCount}" ) -eq ${Null}) {
        Do-Output-Undefined-Error "${funcName}" 'itemCount' 'Int'
    ##### Otherwise, ${itemCount} IS a valid Integer...
    } else {
        ##### Convert ${itemCount} from [String] to [Int] (e.g. '1'→1, '+1'→1, '-1'→-1, etc.)...
        ${itemCount} = [Int]${itemCount}
    }
    ##### If ${singleForm} is Null or Whitespace, it's an UNDEFINED String error...
    if ([String]::IsNullOrWhitespace(${singleForm})) {
        Do-Output-Undefined-Error "${funcName}" 'singleForm' 'String'
    }
    ##### If ${pluralForm} is Null or Whitespace...
    if ([String]::IsNullOrWhitespace(${pluralForm})) {
        ##### If the last letter of ${singleForm} is a case-sensitive match for '[A-Z]', default ${pluralForm} to 'S', otherwise 's'...
        if (${singleForm}[-1] -CMatch '[A-Z]') { ${pluralForm} = 'S' } else { ${pluralForm} = 's' }
    }
    ##### If -wholeWord was used, and ${pluralForm} is a known suffix, then it's NOT a valid whole-word replacement...
    if (${wholeWord} -and ${pluralForm}.ToLower() -In ${suffixes}) {
        Do-Output-Error `
            -errorMessage    'With switch -wholeWord, required parameter [String]${pluralForm} must be a whole-word replacement, not a suffix.' `
            -callingFuncName "${funcName}" -exitKey 'E3Code'
    }
    #####
    # First, split ${singleForm} by '-' into its invididual parts into ${partArray}...
    #  • E.g. 'mother-in-law' → @('mother','in','law')
    #####
    ${partArray} = ${singleForm} -Split '-'
    ##### If ${pluralizePart} is UNDEFINED...
    if ([String]::IsNullOrWhitespace(${pluralizePart})) {
        #####
        # Decide if ${pluralizePart} should be the leftmost part (1) or rightmost (${partArray}.Count)...
        #  • Choose 1 if...
        #    • Part count>=3 and the lower-case conversion of word 2 (index [1]) is in ${prepositions}, or
        #    • The lower-case conversion of ${singleForm} is in ${leftmostExceptions}.
        #  • Choose ${partArray}.Count otherwise.
        #####
        [Int]${pluralizePart} = if (
            (${partArray}.Count -ge 3 -and ${partArray}[1].ToLower() -In ${prepositions}) -or
             ${singleForm}.ToLower() -In ${leftmostExceptions}
        ) {
            1
        } else {
            ${partArray}.Count
        }
    ##### Else if ${pluralizePart} WAS defined...
    } else {
        ##### If Do-Get-Integer returns ${Null}, then ${pluralizePart} is NOT a valid Integer, resulting in an UNDEFINED Int error...
        if (( Do-Get-Integer "${pluralizePart}" ) -eq ${Null}) {
            Do-Output-Undefined-Error "${funcName}" 'pluralizePart' 'Int'
        ##### Otherwise, ${pluralizePart} IS a valid Integer...
        } else {
            ##### Convert ${pluralizePart} from [String] to [Int] (e.g. '1'→1, '+1'→1, etc.)...
            ${pluralizePart} = [Int]${pluralizePart}
        }
        ##### If ${pluralizePart}<1, it's INVALID...
        if (${pluralizePart} -lt 1) {
            Do-Output-Error `
                -errorMessage "Parameter `${pluralizePart}=${pluralizePart} cannot be less than 1." `
                -callingFuncName "${funcName}" -exitKey 'E3Code'
        ##### Else if ${pluralizePart} exceeds the part count, it's INVALID...
        } elseif (${pluralizePart} -gt ${partArray}.Count) {
            Do-Output-Error -errorMessage (
                'With compound word ${singleForm}='+( Do-Get-Quoted 'Auto' "${singleForm}" )+",`n"+
                " parameter `${pluralizePart}=${pluralizePart} is out of range (1-"+${partArray}.Count.ToString()+').'
            ) -callingFuncName "${funcName}" -exitKey 'E3Code'
        }
    } # END of if ([String]::IsNullOrWhitespace(${pluralizePart})) {} else {}


    ##### Now subtract 1 from ${pluralizePart}, so it can be used directly as an index to ${partArray} (e.g. 1→0, etc.)...
    ${pluralizePart} = ${pluralizePart}--


    #####
    # If...
    #  • ${singleForm} has more than 1 character, and
    #    • the lower-case conversion of the 2nd-to-last letter of ${singleForm} is a case-sensitive match for '[aeiou]', and
    #    • the lower-case conversion of the last letter of ${singleForm} equals 'y' (e.g. 'toy'), and
    #    • the lower-case conversion of ${pluralForm} equals 'ies'...
    #  Then correct ${pluralForm} from 'ies' to 's'...
    #####
    if (${singleForm}.Length -gt 1) {
        if (
            (${singleForm}[-2]).ToString().ToLower() -CMatch '[aeiou]' -and
            (${singleForm}[-1]).ToString().ToLower() -eq 'y' -and
             ${pluralForm}.ToLower() -eq 'ies'
        ) {
            ##### If the last letter of ${singleForm} is a case-sensitive match for '[A-Z]', correct ${pluralForm} to 'S', otherwise 's'...
            if (${singleForm}[-1] -CMatch '[A-Z]') { ${pluralForm} = 'S' } else { ${pluralForm} = 's' }
        }
    }


    #####
    ##### Decide if it's Singular or Plural, based on ${itemCount}, which must be a positive or negative Integer or 0...
    #####

    ##### When ${itemCount} is 1 or -1, it's the SINGULAR form...
    if ([Math]::Abs(${itemCount}) -eq 1) {

        ##### If -padSingle was used...
        if (${padSingle}) {
            #####
            # For this to work for all possible combinations, it has to calculate the proper length, depending on the following conditions...
            #  • If ${pluralForm} is a whole-word replacement, get the length of ${pluralForm}-${singleForm}.
            #  • If ${pluralForm} is a complex suffix (e.g. 'ex→ices'), get the length of ${pluralForm}-${suffixItem}[0].
            #  • If ${pluralForm} is a simple suffix (e.g. 's' or 'es'), just get that length.
            #####
            [Int]${pluralLength} = 0
            if (${wholeWord}) {
                ${pluralLength} = ${pluralForm}.Length - ${singleForm}.Length
            } else {
                foreach (${suffixPair} in ${complexSuffixes}) {
                    ${suffixItem} = ${suffixPair} -Split '→'
                    if (${singleForm}.ToLower().EndsWith(${suffixItem}[0]) -and ${pluralForm}.ToLower() -eq ${suffixItem}[1]) {
                        ${pluralLength} = ${pluralForm}.Length - ${suffixItem}[0].Length
                        break # out of the foreach loop, since it found a ${suffixItem}[0]→${suffixItem}[1] match.
                    } # END of if (${singleForm}.ToLower().EndsWith(${suffixItem}[0]) -and ${pluralForm}.ToLower() -eq ${suffixItem}[1]) {}
                } # END of foreach (${suffixPair} in ${complexSuffixes}) {}
                if (${pluralLength} -eq 0) { ${pluralLength} = ${pluralForm}.Length }
            } # END of if (${wholeWord}) {} else {}
            #####
            # If ${pluralLength}>0, replace ${pluralForm} with an equal number of spaces to append as a suffix to ${singleForm} below,
            #  otherwise, set ${pluralForm} to ''...
            #####
            if (${pluralLength} -gt 0) { ${pluralForm} = ' ' * ${pluralLength} } else { ${pluralForm} = '' }

        ##### Else if -padSingle was NOT used...
        } else {
            ##### Empty ${pluralForm}, so it returns only ${singleForm} (e.g. pie, latch, fly, man, cactus, mother-in-law, etc.) below...
            ${pluralForm} = ''
        } # END of if (${padSingle}) {} else {}

    ##### Else when ${itemCount} is any other Integer that's NOT 1 or -1, it's the PLURAL form...
    } else {
        ##### If -wholeWord was NOT used, then ${pluralForm} will be a suffix to be appended to ${singleForm}...
        if (-not ${wholeWord}) {

            ##### ${singleForm} was already split into ${partArray} above in Local parameter processing.

            ##### If there are 2+ parts in ${partArray}, e.g. @('mother','in','law') or @('run','through','of','code')...
            if (${partArray}.Count -gt 1) {
                ##### Set ${singleForm} to the Nth-index part, ${pluralizePart}, (e.g. [0]='mother' or [1]='through'), for processing below...
                ${singleForm} = ${partArray}[${pluralizePart}]
            }

            ##### Start with ${wordRoot} equal to ${singleForm} (e.g. 'mother', 'through', 'index', etc.)...
            ${wordRoot} = "${singleForm}"

            #####
            ##### Handle complex suffixes...
            #####
            # • If it's NOT a complex suffix, then ${wordRoot} will stay as-is from ${singleForm}.
            # • Else, ${wordRoot} will become the truncated ${singleForm} as indicated by the examples above where ${complexSuffixes} is declared.
            #####

            ##### Get each ${suffixPair} from ${complexSuffixes} defined above...
            foreach (${suffixPair} in ${complexSuffixes}) {
                #####
                # Split ${suffixPair} by '→' into the 2-element array ${suffixItem},
                #  where [0]=the singular suffix (e.g. 'ex')   to be removed from the end of ${singleForm} (e.g. 'index'-'ex' → 'ind'),
                #  and   [1]=the plural   suffix (e.g. 'ices') to be appended to it when plural (e.g. 'ind'+'ices' → 'indices').
                #####
                ${suffixItem} = ${suffixPair} -Split '→'
                #####
                # If...
                #  • the lower-case conversion of ${singleForm} (e.g. 'index') ends with ${suffixItem}[0] (e.g. 'ex'), and
                #  • the lower-case conversion of ${pluralForm} equals ${suffixItem}[1] (e.g. 'ices'),
                # Then it IS a complex suffix...
                #####
                if (${singleForm}.ToLower().EndsWith(${suffixItem}[0]) -and ${pluralForm}.ToLower() -eq ${suffixItem}[1]) {
                    #####
                    # Assign to ${wordRoot} ${singleForm} (e.g. 'index') with ${suffixItem}[0] (e.g. 'ex') removed (e.g. 'index'-'ex' → 'ind')...
                    #  • Since this uses Substring(), case doesn't matter.
                    #  • In this example, ${singleForm}='index' and ${suffixItem}[0]='ex'...
                    #    • ${singleForm}.Length-${suffixItem}[0].Length = 5-2 = 3
                    #    • Resulting in ${singleForm}.Substring(0, 3) → 'ind'
                    #####
                    ${wordRoot} = ${singleForm}.Substring(0, ${singleForm}.Length-${suffixItem}[0].Length)
                    ##### ${wordRoot} will now be the root (e.g. 'ind'), ready for appending ${pluralForm} to it (e.g. 'ind'+'ices' → 'indices').
                    break # out of the foreach loop, since it found a singular→plural suffix match.
                ##### Otherwise, just keep ${wordRoot} as-is from ${singleForm} (e.g. 'mother').
                } # END of if (${singleForm}.ToLower().EndsWith(${suffixItem}[0]) -and ${pluralForm}.ToLower() -eq ${suffixItem}[1]) {}
            } # END of foreach (${suffixPair} in ${complexSuffixes}) {}

            ##### If ${wordRoot} is still EQUAL to ${singleForm} (i.e. it's NOT a complex suffix)...
            if ("${wordRoot}" -eq "${singleForm}") {
                ##### Set ${pluralForm} to ${singleForm}+${pluralForm} (e.g. 'mother'+'s' → 'mothers')...
                ${pluralForm} = "${singleForm}${pluralForm}"

            ##### Else if ${wordRoot} is NOT equal to ${singleForm} (i.e. it IS a complex suffix with ${suffixItem}[0] removed)...
            } else {
                ##### Set ${pluralForm} to ${wordRoot}+${pluralForm} (e.g. 'ind'+'ices' → 'indices')...
                ${pluralForm} = "${wordRoot}${pluralForm}"
            }

       #Else if -wholeWord WAS used (e.g. 'man' 'men' -wholeWord), leave everything as-is, so it'll just use ${pluralForm} (e.g. 'men') below.
        } # END of if (-not ${wholeWord}) {}
        ##### At this point, ${pluralForm} is now the whole word to use (e.g. 'mothers', 'throughs', 'indices', 'men', etc.).

        ##### If there are 2+ parts in ${partArray}, e.g. @('mothers','in','law')...
        if (${partArray}.Count -gt 1) {
            ##### Set the Nth-index part, ${pluralizePart}, to ${pluralForm} (e.g. 'mothers')...
            ${partArray}[${pluralizePart}] = "${pluralForm}"
            ##### Reassemble ${partArray} into [String]${pluralForm}, e.g. @('mothers','in','law') → 'mothers-in-law'...
            [String]${pluralForm} = ${partArray} -Join '-'
        }

        ##### Empty ${singleForm} so it'll only use ${pluralForm} below...
        ${singleForm} = ''
    } # END of if ([Math]::Abs(${itemCount}) -eq 1) {} else {}


    #####
    ##### Return the String result...
    #####
    # In summary...
    #  • When ${itemCount} is 1 or -1...
    #    • ${singleForm} has remained as-is (e.g. 'mother-in-law', 'index', 'man', etc.).
    #    • If -padSingle WAS used, ${pluralForm} will have 1 or more spaces (e.g. 's' → ' ' → 'mother-in-law ').
    #    • If -padSingle was NOT used, ${pluralForm} is emptied, so it'll only use ${singleForm} (e.g. 'mother-in-law').
    #  • When ${itemCount} is NOT 1 or -1...
    #    • If -wholeWord was NOT used...
    #      • ${pluralForm} will be a plural suffix (e.g. 's').
    #      • If there are 2+ parts in ${partArray}, e.g. @('mother','in','law'), ${singleForm} will get ${partArray}[${pluralizePart}].
    #      • If ${singleForm} has a complex suffix...
    #        • ${wordRoot} will be the truncated form of ${singleForm} (e.g. 'ind').
    #        • ${pluralForm} gets ${wordRoot}+${pluralForm} (e.g. 'ind'+'ices' → 'indices').
    #      • If ${singleForm} does NOT have a complex suffix...
    #        • ${singleForm} has remained as-is (e.g. 'mother').
    #        • ${pluralForm} gets ${singleForm}+${pluralForm} (e.g. 'mother'+'s' → 'mothers').
    #    • If -wholeWord WAS used...
    #      • ${pluralForm} will be a whole-word replacement (e.g. 'men').
    #      • ${pluralForm} has remained as-is.
    #    • If there are 2+ word parts in ${partArray}...
    #      • ${partArray}[${pluralizePart}] gets ${pluralForm} (e.g. 'mothers').
    #      • ${pluralForm} gets the re-assembled ${partArray} joined by '-', e.g. @('mothers','in','law') → 'mothers-in-law'.
    #    • ${singleForm} is emptied, so it'll only use ${pluralForm}.
    #####

    return "${itemCount} ${singleForm}${pluralForm}"
} # END of function Do-Auto-Plural


function Do-Check-Path {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Check for a file path indicated in ${filePath} and briefly described in ${fileName}.
#  • If ${fileName} or ${filePath} aren't properly defined, it's always error immediately using -exitKey 'E3Code'.
#  • If -directory is used, ${filePath} is expected to be a directory, so if it finds a plain file instead, that's an error.
#  • Else, ${filePath} is expected to be a plain file, so if it find a directory instead, that's an error.
#  • If -mustExist is used, it's an error if ${filePath} doesn't already exist, otherwise it's only a warning.
#  • If there's an error...
#    • If -returnOnlyTrueFalse is used, return ${False} to indicate a problem.
#    • Else if full output is needed, use Do-Output-Error to explain the problem and exit using -exitCode ${errorCode}.
#  • If it encounters a warning condition...
#    • If -returnOnlyTrueFalse is used, return ${False} to indicate a problem.
#    • Else if -noWarn is NOT used, output a warning message.
#    • Return 'Warning' to indicate this condition.
#  • If it gets all the way to the bottom, return ${True} to indicate everything is OK and the script can continue.
#
# Returns:
#  • [Bool  ]${False}  — if -returnOnlyTrueFalse is used AND...
#    • ${filePath} is INVALID; or
#    • ${filePath} does NOT exist AND -mustExist IS used; or
#    • ${filePath} EXISTS but is the WRONG TYPE; or
#    • ${filePath} EXISTS but contains NO data AND -warnIfEmpty IS used.
#  • [String]'Warning' — if...
#    • ${filePath} does NOT exist AND -mustExist is NOT used; or
#    • ${filePath} EXISTS but contains NO data, -warnIfEmpty IS used, and -returnOnlyTrueFalse is NOT used.
#  • [Bool  ]${True}   — for all remaining conditions.
#  • Additional Notes...
#    • If you use -returnOnlyTrueFalse, then returned output will only be type [Bool].
#    • However, if you use -mustExist or -warnIfEmpty, it may also return [String]'Warning'.
#      • To account for this, you may need to change the type using:  if ([String]( Do-Check-Path ... ) -eq 'Warning') {}.
#
# Usage:
#  • Parameter 1 — ${fileName}:      String (REQUIRED) — the brief description of the file being checked (e.g. 'Config File').
#  • Parameter 2 — ${filePath}:      String (REQUIRED) — the full path to the file being checked (e.g. 'C:\Users\jdoe\Documents\filename.ext').
#  • Parameter -errorCode:           Integer           — [Default=${Script:RuntimeTable}.ExitStatus.E2User] the exit code to use on error.
#    • This ${errorCode} doesn't apply to warning conditions, which (if -noWarn is NOT used) will always use ${Script:RuntimeTable}.ExitStatus.E1Warn.
#  • Parameter -errorKey:            String            — [Default='E2User'] in lieu of an ${errorCode}, use ${Script:RuntimeTable}.ExitStatus.${errorKey}.
#  • Parameter -callingFuncName:     String            — if used, prepend "${callingFuncName}:" to ${funcName}.
#  • Parameter -directory:           Switch            — if used, the file is expected to be a directory, not a plain file.
#  • Parameter -mustExist:           Switch            — if used, the file must exist, otherwise it's an error.
#  • Parameter -returnOnlyTrueFalse: Switch            — if used, doesn't output any warning or error, & returns only ${True} (OK) or ${False} (problem).
#  • Parameter -noWarn:              Switch            — if used, never output a warning message (but it still returns 'Warning' if applicable).
#  • Parameter -warnIfEmpty:         Switch            — if used, it also checks if ${filePath} contains data, and if not outputs a warning.
#    • In the specific case where -returnOnlyTrueFalse and -warnIfEmpty are both used, it will return ${False} (problem) if empty.
#  • Parameter -warnSuffix:          String            — [Default=''] if used, append ${warnSuffix} to the end of the warning message, if applicable.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Do-Get-Quoted
#    • Do-Get-Var-Quoted
#    • Do-Output-Error
#    • Do-Output-Warning
#    • Do-Processing
#####
    param(
        [String]${fileName},
        [String]${filePath},
        [Int   ]${errorCode}=${Script:RuntimeTable}.ExitStatus.E2User,
        [String]${errorKey}='E2User',
        [String]${callingFuncName}='',
        [Switch]${directory},
        [Switch]${mustExist},
        [Switch]${returnOnlyTrueFalse},
        [Switch]${noWarn},
        [Switch]${warnIfEmpty},
        [String]${warnSuffix}=''
    )
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )
    if (${callingFuncName}) { ${funcName} = "${callingFuncName}:${funcName}" }

    ##### These are always E3Code errors if true...
    if ([String]::IsNullOrWhitespace(${fileName})) { Do-Output-Undefined-Error "${funcName}" 'fileName' 'String' }
    if ([String]::IsNullOrEmpty(${filePath})     ) { Do-Output-Undefined-Error "${funcName}" 'filePath' 'String' }
    if (${directory} -and ${warnIfEmpty}) {
        Do-Output-Error `
            -errorMessage    'Optional function parameters -directory & -warnIfEmpty cannot be used together.' `
            -callingFuncName "${funcName}" -exitKey 'E3Code'
    }

    ##### If ${errorKey} is defined, get ${errorCode} from ${Script:RuntimeTable}.ExitStatus.${errorKey}...
    if (-not [String]::IsNullOrWhitespace(${errorKey})) { ${errorCode} = ${Script:RuntimeTable}.ExitStatus.${errorKey} }
    ##### Setup for either a Directory or a Plain file...
    if (${directory}) {
        ${fileType} = 'Directory'
        ${pathType} = 'Container'
        ${bad_Type} = 'plain file'
    } else {
        ${fileType} = 'Plain file'
        ${pathType} = 'Leaf'
        ${bad_Type} = 'directory'
    }
    ##### ${fileSpec} is used in verbose, warning, and error messages...
    ${fileSpec} = ("${fileType}, "+( Do-Get-Quoted 'Auto' "${fileName}" )+', '+( Do-Get-Quoted 'Auto' "${filePath}" )+' ')


    Do-Processing 2 "${funcName}" (
        ${fileSpec}.Trim()+"...`n"+
        ( Do-Get-Var-Quoted 1 'fileName'            22 'Auto' "${fileName}"            -nl )+
        ( Do-Get-Var-Quoted 1 'filePath'            22 'Auto' "${filePath}"            -nl )+
        ( Do-Get-Var-Quoted 1 'errorCode'           22 'None' "${errorCode}"           -nl )+
        ( Do-Get-Var-Quoted 1 'directory'           22 'None' "${directory}"           -nl )+
        ( Do-Get-Var-Quoted 1 'mustExist'           22 'None' "${mustExist}"           -nl )+
        ( Do-Get-Var-Quoted 1 'returnOnlyTrueFalse' 22 'None' "${returnOnlyTrueFalse}" -nl )+
        ( Do-Get-Var-Quoted 1 'noWarn'              22 'None' "${noWarn}"              -nl )+
        ( Do-Get-Var-Quoted 1 'warnIfEmpty'         22 'None' "${warnIfEmpty}"         -nl )+
        ( Do-Get-Var-Quoted 1 'warnSuffix'          22 'Auto' "${warnSuffix}"              )
    )
    ##### If ${filePath} is not syntactically valid...
    if (-not (Test-Path -LiteralPath ${filePath} -IsValid)) {
        ##### If only a True/False answer is needed...
        if (${returnOnlyTrueFalse}) {
            ##### Return ${False} to indicate a problem...
            Do-Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+${Script:RuntimeTable}.Symbols.Warn+'Path is INVALID.') -noPrefix
            Do-Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+"return ${False}") -noPrefix
            return ${False}
        ##### Else if full error output is needed...
        } else {
            ##### Exit immediately with an error...
            Do-Output-Error `
                -errorMessage    "${fileSpec}is an invalid path." `
                -callingFuncName "${funcName}"                    `
                -exitCode         ${errorCode}
        }
    ##### Else if it doesn't exist...
    } elseif (-not (Test-Path -LiteralPath ${filePath})) {
        ##### If only a True/False answer is needed...
        if (${returnOnlyTrueFalse}) {
            if (${mustExist}) {
                ##### In this case, the file must exist, so return ${False} to indicate a problem...
                Do-Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+${Script:RuntimeTable}.Symbols.Warn+"Path DOESN'T EXIST.") -noPrefix
                Do-Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+"return ${False}") -noPrefix
                return ${False}
            }
        ##### Else if full output is needed...
        } else {
            ##### If -mustExist is used...
            if (${mustExist}) {
                ##### Exit immediately with an error...
                Do-Output-Error `
                    -errorMessage    "${fileSpec}doesn't exist." `
                    -callingFuncName "${funcName}"               `
                    -exitCode         ${errorCode}
            ##### Else -mustExist is NOT used...
            } else {
                Do-Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+"return 'Warning'") -noPrefix
                ##### If warning output is allowed...
                if (-not ${noWarn}) {
                    ##### Output a warning...
                    Do-Output-Warning "${fileSpec}is new${warnSuffix}." -preSpace
                }
                ##### Return 'Warning' to indicate this condition.
                return 'Warning'
            }
        }
    ##### Else if it exists but is not the expected ${pathType}...
    } elseif (-not (Test-Path -LiteralPath ${filePath} -PathType ${pathType})) {
        ##### If only a True/False answer is needed...
        if (${returnOnlyTrueFalse}) {
            ##### Return ${False} to indicate a problem...
            Do-Processing 2 "${funcName}" (
                ' '+${Script:RuntimeTable}.Symbols.Bullet+${Script:RuntimeTable}.Symbols.Warn+'Path is NOT THE PROPER TYPE.'
            ) -noPrefix
            Do-Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+"return ${False}") -noPrefix
            return ${False}
        ##### Else if full error output is needed...
        } else {
            ##### Exit immediately with an error...
            Do-Output-Error `
                -errorMessage    "${fileSpec}already exists as a ${bad_Type}." `
                -callingFuncName "${funcName}"                                 `
                -exitCode         ${errorCode}
        }
    ##### Else if it exists and is the expected ${pathType}...
    } else {
        ##### If -warnIfEmpty was used...
        if (${warnIfEmpty}) {
            ##### If the file contains no data...
            if ([String]::IsNullOrWhitespace((Get-Content ${Script:EmailTable}.ConfigFile.Path -Raw).Trim())) {
                Do-Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+"return 'Warning'") -noPrefix
                ##### If only a True/False answer is needed...
                if (${returnOnlyTrueFalse}) {
                    ##### Return ${False} to indicate a problem...
                    Do-Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+"return ${False}") -noPrefix
                    return ${False}
                ##### Else if warning output is allowed...
                } elseif (-not ${noWarn}) {
                    ##### Output a warning...
                    Do-Output-Warning "${fileSpec}exists but has no data${warnSuffix}." -preSpace
                }
                ##### Return 'Warning' to indicate this condition...
                return 'Warning'
            }
        }
    } # END of if {} elseif {} elseif {} else {}


    ##### If it gets this far, return ${True} to indicate everything is OK and the script can continue...
    Do-Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+${Script:RuntimeTable}.Symbols.Good+'Path is valid.') -noPrefix
    Do-Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+"return ${True}") -noPrefix
    return ${True} 
} # END of function Do-Check-Path


function Do-Draw-Box {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Draw a box around some text, for example...
#      ▄▄▄▄▄▄▄▄
#      ▌      ▐ # this line omitted if -tighten is used.
#      ▌ TEXT ▐
#      ▌      ▐ # this line omitted if -tighten is used.
#      ▀▀▀▀▀▀▀▀
#
# Returns:  [String]${textString} — as described above and below.
#
# Usage:
#  • Parameter -textString: String  — [default=''] the string of text to surround with a box.
#  • Parameter -textPrefix: String  — [default=''] a string of text to prefix each line of the box.
#  • Parameter -textSuffix: String  — [default=''] a string of text to suffix each line of the box.
#  • Parameter -textPadAll: Integer — [default=0 ] the number of spaces to pad before & after ${textString}.
#  • Parameter -textPadPre: Integer — [default=0 ] the number of spaces to pad only before    ${textString}.
#  • Parameter -textPadEnd: Integer — [default=0 ] the number of spaces to pad only after     ${textString}.
#  • Parameter -tighten:    Switch  — if used, don't print the extra line immediately above & below ${textString}.
#  • Parameter -nl:         Switch  — if used, appends a newline at the end.
#
# Dependencies:
#  • None
#####
    param(
        [String]${textString}='',
        [String]${textPrefix}='',
        [String]${textSuffix}='',
        [Int   ]${textPadAll}=0,
        [Int   ]${textPadPre}=0,
        [Int   ]${textPadEnd}=0,
        [Switch]${tighten},
        [Switch]${nl}
    )


    ${paddingPre} = ''
    ${paddingEnd} = ''
    if (${textPadAll} -gt 0) {
        ${paddingPre} = ' ' * ${textPadAll} 
        ${paddingEnd} = ' ' * ${textPadAll}
    } else {
        if (${textPadPre} -gt 0) { ${paddingPre} = ' ' * ${textPadPre} }
        if (${textPadEnd} -gt 0) { ${paddingEnd} = ' ' * ${textPadEnd} }
    }
    if (${nl}) { ${newline} = "`n" } else { ${newline} = '' }

    ${textString} = "${paddingPre}${textString}${paddingEnd}"
    ${textLength} = ${textString}.Length
    ${text_Line1} = '▄' * ${textLength}
    ${text_Line2} = ' ' * ${textLength}
    ${text_Line3} = '▀' * ${textLength}

    ${text_Line1} = "${textPrefix}▄${text_Line1}▄${textSuffix}`n"
    ${text_Line2} = "${textPrefix}▌${text_Line2}▐${textSuffix}`n"; if (${tighten}) { ${text_Line2} = '' }
    ${textString} = "${textPrefix}▌${textString}▐${textSuffix}`n"
    ${text_Line3} = "${textPrefix}▀${text_Line3}▀${textSuffix}${newline}"


    ${textString} = (
        "${text_Line1}"+
        "${text_Line2}"+
        "${textString}"+
        "${text_Line2}"+
        "${text_Line3}"
    )


    return "${textString}"
} # END of function Do-Draw-Box


function Do-Get-Integer ([String]${numberString}) {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • If ${numberString} is not an Integer value, return ${Null}.
#  • Otherwise, return the Integer value.
#
# Returns:
#  • ${Null}           — if ${numberString} is NOT an Integer value.
#  • [Int]${numberInt} — the Integer value from ${numberString}.
#
# Usage:
#  • Parameter 1 — ${numberString}: String — a number, inputted as a String, to be outputted as an Integer or as ${Null} if invalid.
#
# Dependencies...
#  • None
#####
    ##### Local variable, of type Integer, to hold the parsed value...
    [Int]${numberInt} = 0

    ##### Return either Null if not an Integer or the Integer value...
    if (-not [Int]::TryParse(${numberString}, [Ref]${numberInt})) {
        return ${Null}
    } else {
        return ${numberInt}
    }
} # END of function Do-Get-Integer


function Do-Get-Padded ([String]${textString}='', [Int]${textMaxWidth}=0, [String]${padString}=' ', [Switch]${padBefore}) {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Return ${textString} padded out with ${padString} to a max width of ${textMaxWidth}.
#  • If ${padBefore} is used, put the padding before ${textString}, otherwise put it after.
#  • If ${textString} is...
#    •  <${textMaxWidth}, return ${textString} padded.
#    • >=${textMaxWidth}, return ${textString} as is.
#
# Returns:  [String]${textString} as described above and below.
#
# Usage:
#  • Parameter 1 — ${textString}   String  — [Default=''] the text to return padded.
#  • Parameter 2 — ${textMaxWidth} Integer — [Default=${textString}.Length] the max width of the padded ${textString}.
#  • Parameter 3 — ${padString}    String  — [Default=' '] the string to use for padding.
#  • Parameter -padBefore          Switch  — if used, put the padding before ${textString}, otherwise put it after.
#
# Dependencies:
#  • None
#####
    if (${textMaxWidth} -eq 0) { ${textMaxWidth} = ${textString}.Length }


    if (${textString}.Length -lt ${textMaxWidth}) {
        ${widthDiff} = (${textMaxWidth} - ${textString}.Length)
        if (${padString}.Length -gt 1) {
                ${repeat}    = [Int](${widthDiff} / ${padString}.Length)
                ${textPad}   = "${padString}" * ${repeat}
                ${widthDiff} = (${widthDiff} - ${textPad}.Length)
            if (${widthDiff} -gt 0) {
                ${leftover} = ${padString}.Substring(1, ${widthDiff})
            } else {
                ${leftover} = ''
            }
                ${textPad}  = "${textPad}${leftover}"
        } else {
                ${textPad}  = "${padString}" * ${widthDiff}
        }

        if (${padBefore}) {
            ${textString} = "${textPad}${textString}"
        } else {
            ${textString} = "${textString}${textPad}"
        }
    }


    return "${textString}"
} # END of function Do-Get-Padded


function Do-Get-Quoted {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Returns ${textString} quoted using ${quoteTable}.${quoteKey}.Opening & .Closing (e.g. 'text' or "text").
#  • If ${quoteKey} is not provided or it's invalid, it defaults to 'Auto'.
#  • In Auto mode, it does the following...
#    • It initially prefers 'Single.Basic'.
#    • However, if ${textString} contains any single quotes...
#      • It switches to 'Double.Basic'
#      • Then, if ${textString} contains any unescaped double quotes, it replaces " with `" (except if it's already `").
#      • Next, if ${textString} contains any variable references with unescaped dollar signs, it replaces $ with `$ (except if it's already `$).
#  • Other modifiers can be used as detailed below.
#
# Returns:  [String]${textString} — as described above and below.
#
# Usage:
#  • Parameter 1 — ${quoteKey}:   String  — [Default='Auto'] the key to the ${quoteTable} defined below.
#    • It's the portion between ${quoteTable}. and the .Opening/.Closing portions (e.g. ${quoteTable}.${quoteKey}.(Opening|Closing)).
#  • Parameter 2 — ${textString}: String  — [Default=''] the string to return quoted.
#  • Parameter 3 — ${repeat}:     Integer — [Default=1] repeat each Opening & Closing quote ${repeat} times.
#    • ${repeat} must be a positive integer>0, and if <1, it defaults to 1.
#    • E.g. (Do-Get-Quoted 'Begin' "${textString}" 3) produces "///${textString}\\\"
#  • Parameter 4 — ${multiline}:  Integer — if used, it'll structure it as...
#      Quote-Opening
#        ${textString}
#      Quote-Closing
#    • In this case, it's assumed Quote-Opening & ${textString} are already indented (prior to calling this function), and this function only properly
#       indents with ${Script:RuntimeTable}.Verbose.Indent * ${multiline} for only the Quote-Closing portion.
#  • Parameter -customOpening     String  — if used, instead of using ${quoteTable}.${quoteKey}.Opening, use ${customOpening}.
#  • Parameter -customClosing     String  — if used, instead of using ${quoteTable}.${quoteKey}.Closing, use ${customClosing}.
#  • Parameter -nl:               Switch  — if used, append a newline at the end.
#
# Notes:
#  • There are several Unicode characters included in the ${quoteTable} defined below.
#  • See the "Notes on Unicode characters used by this script" at the top of this script.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Unicode support for certain characters in the ${quoteTable} below.
#####
    param(
        [String]${quoteKey}='Auto',
        [String]${textString}='',
        [Int   ]${repeat}=1,
        [Int   ]${multiline},
        [String]${customOpening}='',
        [String]${customClosing}='',
        [Switch]${nl}
    )

    #####
    ##### Scope-checking...
    #####

    ##### Aliases for ${quoteKey}...
    switch (${quoteKey}) {
        'Brackets.Parens'      { ${quoteKey}  = 'Brackets.Parentheses' }
        'Brackets.Parenthesis' { ${quoteKey}  = 'Brackets.Parentheses' }
        'Brackets.Angled'      { ${quoteKey} += '.Basic'               }
        'Double'               { ${quoteKey} += '.Basic'               }
        'Double.Oblique'       { ${quoteKey} += '.Basic'               }
        'Single'               { ${quoteKey} += '.Basic'               }
    }
    ##### If ${repeat} is invalid...
    if (${repeat} -lt 1) { ${repeat} = 1 }


    #####
    ##### Local Declarations...
    #####

    [HashTable]${quoteTable} = @{
        Array             = @{ Opening = '@('; Closing = ')' }
        Back = @{
            Basic         = @{ Opening = '`';  Closing = '`' }
            FullWidth     = @{ Opening = '｀';  Closing = '｀' }
        }
        Brackets = @{
            Angled = @{
                Basic     = @{ Opening = '<';  Closing = '>' }
                Double    = @{ Opening = '«';  Closing = '»' }
                Single    = @{ Opening = '‹';  Closing = '›' }
            }
            Curly         = @{ Opening = '{';  Closing = '}' }
            Parentheses   = @{ Opening = '(';  Closing = ')' }
            Square        = @{ Opening = '[';  Closing = ']' }
        }
        Divider = @{
            Upper         = @{ Opening = (${Script:RuntimeTable}.Verbose.Divider+'///'); Closing = ('\\\'+${Script:RuntimeTable}.Verbose.Divider) }
            Lower         = @{ Opening = (${Script:RuntimeTable}.Verbose.Divider+'\\\'); Closing = ('///'+${Script:RuntimeTable}.Verbose.Divider) }
        }
        Double = @{
            Basic         = @{ Opening = '"';  Closing = '"' }
            FullWidth     = @{ Opening = '＂'; Closing = '＂' }
            Oblique = @{
                Basic     = @{ Opening = '‶';  Closing = '″' }
                FullWidth = @{ Opening = '〝'; Closing = '〞' }
            }
            Thick         = @{ Opening = '❝';  Closing = '❞' }
            Thin          = @{ Opening = '“';  Closing = '”' }
        }
        HashTable         = @{ Opening = '@{'; Closing = '}' }
        None              = @{ Opening = '';   Closing = ''  }
        Single = @{
            Basic         = @{ Opening = "'";  Closing = "'" }
            FullWidth     = @{ Opening = '＇'; Closing = '＇' }
            Thick         = @{ Opening = '❛';  Closing = '❜' }
            Thin          = @{ Opening = "`‘"; Closing = "`’" }
        }
        Slashes = @{
            Upper         = @{ Opening = '/';  Closing = '\' }
            Lower         = @{ Opening = '\';  Closing = '/' }
        }
    } # END of [HashTable]${quoteTable} = @{}

    [HashTable]${regExTable} = @{
        Quote = @{
            Double = '(?<!`)"' # Matches " but not `"
            Single = "'"       # Matches '
        }
        VarName = (            # Matches $VarName, ${VarName}, $Namespace:VarName, ${Namespace:VarName} but not `$...
            '(?<!`)\$'+
            '(?:(?i)(alias|cmdlet|env|executioncontext|function|global|local|private|script|type|variable):)?'+
            '(?:\{[^}]+\}|[A-Za-z_][A-Za-z_0-9]*)'
        )
    }


    ##### If either ${customOpening} and/or ${customClosing} are empty...
    if (${customOpening} -eq '' -or ${customClosing} -eq '') {
        #####
        ##### Handle Auto...
        #####

        if (${quoteKey} -eq 'Auto') {
            ##### Initially, prefer single quotes...
            ${quoteKey} = 'Single.Basic'
            ##### However, if ${textString} contains any single quotes...
            if (([RegEx]::Matches(${textString}, ${regExTable}.Quote.Single)).Count -gt 0) {
                ##### Switch to double quotes...
                ${quoteKey} = 'Double.Basic'
                ##### Then, if ${textString} contains any unescaped double quotes...
                if (([RegEx]::Matches(${textString}, ${regExTable}.Quote.Double)).Count -gt 0) {
                    ##### Replace " with `" (except if it's already `")...
                    ${textString} = ${textString} -Replace ${regExTable}.Quote.Double, '`"'
                }
                ##### Next, if ${textString} contains any variable references with unescaped dollar signs...
                if (([RegEx]::Matches(${textString}, ${regExTable}.VarName)).Count -gt 0) {
                    ##### Replace $ with `$ (except if it's already `$)...
                    ${textString} = ${textString} -Replace ${regExTable}.VarName, { "`${$(${_}.Value.Substring(1))}" }
                }
            }
        }

        #####
        # Handle ${quoteKey} containing either a single KeyName or a chain of KeyName1.KeyName2...etc.,
        #  which must be properly split and reassembled into a valid ${keyReference}.
        #  • This also defaults to 'Single.Basic' if ${quoteKey} is invalid.
        #####

        ${keyParts}     = ${quoteKey} -Split '\.'
        ${keyReference} = ${quoteTable}
        foreach (${level2Key} in ${keyParts}) {
            if (${keyReference}.ContainsKey(${level2Key})) {
                ${keyReference} = ${keyReference}.${level2Key}
            } else {
                ${quoteKey} = 'Auto'
                break # from the foreach loop
            }
        } # END of foreach (${level2Key} in ${keyParts}) {}
    } # END of if (${customOpening} -eq '' -or ${customClosing} -eq '') {}


    ####
    #### Setup for either ${multiline} or inline...
    ####

    if (${multiline}) {
        ${newlineMid} = "`n"
        ${mlIndent}   = ${Script:RuntimeTable}.Verbose.Indent * ${multiline}
        ##### It's assumed ${textString} is already indented, so leave it as is.
    } else { # inline...
        ${newlineMid} = ''
        ${mlIndent}   = ''
    }


    #####
    ##### Handle -nl...
    #####

    if (${nl}) {
        ${newlineEnd} = "`n"
    } else {
        ${newlineEnd} = ''
    }


    #####
    ##### Return ${textString} properly quoted, and if ${multiline} is True, with newlines and with the final quote properly indented...
    #####

    ##### Choose the appropriate Opening quote...
    if (${customOpening} -eq '') {
        ${quoteOpening} = ${keyReference}.Opening
    } else {
        ${quoteOpening} = "${customOpening}"
    }
    ##### And repeat it ${repeat} times...
    ${quoteOpening} = ( "${quoteOpening}" * ${repeat} )

    ##### Choose the appropriate Closing quote...
    if (${customClosing} -eq '') {
        ${quoteClosing} = ${keyReference}.Closing
    } else {
        ${quoteClosing} = "${customClosing}"
    }
    ##### And repeat it ${repeat} times...
    ${quoteClosing} = ( "${quoteClosing}" * ${repeat} )

    ##### Assemble and return the final formatted series of strings...
    return "${quoteOpening}${newlineMid}${textString}${newlineMid}${mlIndent}${quoteClosing}${newlineEnd}"
} # END of function Do-Get-Quoted


function Do-Get-Var-Quoted {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Similar to Do-Get-Quoted, this returns a ${varName} = ${valueString} pair with ${valueString} quoted with several modifiers detailed below.
#  • If ${varName} is empty, it simply returns.
#
# Returns:
#  • Nothing                           — if ${varName} is empty.
#  • [String]${varName}=${valueString} — as described above and below.
#
# Usage:
#  • Parameter 1 — ${preIndent}:   Integer — the # of times to indent ${varName} using ${nameIndent}=${Script:RuntimeTable}.Verbose.Indent * ${preIndent}.
#  • Parameter 2 — ${varName}:     String  — the name of the variable to show before the =...
#    • If -noBrackets is used, ${varName} is left as is.
#    • Otherwise, it'll be set to "`${${varName}}".
#  • Parameter 3 — ${varMaxWidth}: Integer — the max width of ${varName}.
#    • If ${varMaxWidth}<${varName}.Length, it defaults to ${varName}.Length; a good way to ensure this always occurs is to pass in 0.
#    • If ${varName}.Length<${varMaxWidth}, it pads spaces after ${varName} until it equals ${varMaxWidth}.
#  • Parameter 4 — ${quoteKey}:    String  — the key to the ${quoteTable} in the Do-Get-Quoted function with which to quote ${valueString}.
#  • Parameter 5 — ${valueString}: String  — the value string to return quoted after the =.
#  • Parameter 6 — ${repeat}:      Integer — [Default=1] repeat each quote ${repeat} times.
#  • Parameter -prefix:            String  — if used, prepend ${varName} with ${prefix}.
#  • Parameter -varType:           String  — if used, prepend the quoted ${valueString} with "[${varType}] ".
#  • Parameter -noBrackets:        Switch  — if used, leave ${varName} as is (e.g. if it's something like '${Script:RuntimeTable}.Verbose.Indent').
#  • Parameter -tighten:           Switch  — if used, don't put spaces before & after the =.
#  • Parameter -preBullet:         Switch  — if used, appends ${Script:RuntimeTable}.Symbols.Bullet to ${nameIndent}.
#  • Parameter -noValue:           Switch  — if used, omit the entire ${valueString} portion.
#  • Parameter -scs                Switch  — if used, appends '; ' to ${suffix} at the end (before ${newline}).
#  • Parameter -suffix             String  — [Default=''] if used, appends ${suffix} before ${newline}.
#  • Parameter -nl                 Switch  — if used, appends an extra ${newline}="`n" at the end.
#  • Parameter -multiline          Boolean — if True, then it'll structure it multiline as...
#      ${varName} = Quote-Opening
#        ${valueString}
#      Quote-Closing
#    where Quote-Opening & Quote-Closing are chosen by Do-Get-Quoted using ${quoteKey}.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Do-Get-Padded
#    • Do-Get-Quoted
#####
    param(
        [Int   ]${preIndent},
        [String]${varName},
        [Int   ]${varMaxWidth},
        [String]${quoteKey},
        [String]${valueString}='',
        [Int   ]${repeat}=1,
        [String]${prefix}='',
        [String]${varType}='',
        [Switch]${noBrackets},
        [Switch]${tighten},
        [Switch]${preBullet},
        [Switch]${noValue},
        [Switch]${scs},
        [String]${suffix}='',
        [Switch]${nl},
        [Bool  ]${multiline}
    )


    ##### Scope all variables...
    if (${varName}.Length -eq 0) { return }
    if (${preIndent} -lt 0) { ${preIndent} = 0 }
    if (-not ${noBrackets}) { ${varName} = "`${${varName}}" }
    if (${varMaxWidth} -lt ${varName}.Length) { ${varMaxWidth} = ${varName}.Length }
    ${varName} = ( Do-Get-Padded "${varName}" ${varMaxWidth} )
    if (${preIndent}) { ${nameIndent} = ${Script:RuntimeTable}.Verbose.Indent * ${preIndent} } else { ${nameIndent} = '' }
    if (${preBullet}) { ${nameIndent} += ${Script:RuntimeTable}.Symbols.Bullet }
    if (${multiline}) { ${multiIndent} = ${preIndent} } else { ${multiIndent} = 0 }
    if (${varType} -ne '') { ${varType} = "[${varType}] " }
    if (${tighten}) { ${equalSign} = '=' } else { ${equalSign} = ' = ' }
    if (${scs}) { ${suffix} += '; ' }
    if (${nl}) { ${newline} = "`n" } else { ${newline} = '' }


    ##### Assemble the portions...
        ${namePortion}  = "${nameIndent}${prefix}${varName}"
    if (${noValue}) {
        ${valuePortion} = ''
    } else {
        ${valuePortion} = ("${equalSign}${varType}"+( Do-Get-Quoted "${quoteKey}" "${valueString}" ${repeat} -multiline ${multiIndent} ))
    }
        ${tailPortion}  = "${suffix}${newline}"


    ##### Return the formatted results...
    return "${namePortion}${valuePortion}${tailPortion}"
} # END of function Do-Get-Var-Quoted


function Do-Get-Vars (${getVarsObject}, [String[]]${getVarsExclusions}=@(''), [Bool]${getVarsAliases}, [Int]${getVarsLevel}=1) {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Part of the Verbose set of functions.
#  • For each variable name in the ${getVarsObject}, append its name and value in the form (1 per line)...
#    • If it's a String:    Name = 'Value'
#    • Or if it's complex:  Name = "Value"
#    • Otherwise:           Name = Value
#  • Return the entire list as a String.
#  • All local variables in this function begin with getVars so it doesn't get confused with variable names passed in from elsewhere.
#
# Returns:
#  • [String]                              — an error if the type of ${getVarsObject} is not the proper variable type in ${getVarsTable}.ValidTypes.
#  • [String]${getVarsTable}.VarsAndValues — when ${getVarsObject} is correctly parsed.
#
# Usage:
#  • Parameter 1 — ${getVarsObject}:     [untyped] (REQUIRED) — a multi-variable names & values object (type-checked internally).
#    • Valid types for this object are...
#      • ParameterMetadata[]
#      • ValueCollection
#  • Parameter 2 — ${getVarsExclusions}: String Array         — [Default=@('')] if specified, a list of variable names to exclude.
#  • Parameter 3 — ${getVarsAliases}:    Boolean              — if specified & True, it also includes variable aliases.
#  • Parameter 4 — ${getVarsLevel}:      Integer              — [Default=1] an optional # of levels of indentation for each name/value pair.
#    • If <1, it defaults to 1.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Do-Get-Padded
#    • Do-Get-Quoted
#####
    if (${getVarsLevel} -lt 1) { ${getVarsLevel} = 1 }
    ${getVarsTable} = @{
        ListOfAliases = ''
        ListOfVars    = ${Null}
        NamePadWidth  = 1
        ObjectType    = ${getVarsObject}.GetType().Name
        TypePadWidth  = 1
        ValidTypes    = @('ParameterMetadata[]','ValueCollection')
        VarAlias      = ${Null}
        VarName       = ${Null}
        VarsAndValues = ''
        VarType       = ${Null}
        VarValue      = ${Null}
    }
    ${getVarsID1} = ${Null}
    ${getVarsID2} = ${Null}

    ##### If ${getVarsObject} is the proper type...
    if (${getVarsTable}.ObjectType -In ${getVarsTable}.ValidTypes) {
        ##### Build the list of variable names into the form Name1,Name2,...,NameN...
        ${getVarsTable}.ListOfVars   = ${Null}
        ${getVarsTable}.NamePadWidth = 1
        foreach (${getVarsID1} in ${getVarsObject}) {
            ${getVarsTable}.VarName = ${getVarsID1}.Name
            ##### Skip excluded names (case-insensitive)...
            if (${getVarsExclusions} -Contains ${getVarsTable}.VarName) { continue } #foreach loop
            try {
                #### If this succeeds, it's a script-defined parameter...
                Get-Variable -Name ${getVarsTable}.VarName -ErrorAction Stop | Out-Null
            } catch {
                ##### Else ignore PowerShell-defined Common Parameters...
                continue # foreach loop
            }
            ##### If ${getVarsAliases} is True and ${getVarsID1} has aliases, append them after ${getVarsTable}.VarName...
            ${getVarsTable}.ListOfAliases = `
                if (${getVarsAliases} -and ${getVarsID1}.Aliases) {
                    ','+(${getVarsID1}.Aliases -Join ',')
                } else {
                    '' 
                }
            ##### Get the max width of all var names & alias names...
            if (${getVarsTable}.VarName.Length -gt ${getVarsTable}.NamePadWidth) { ${getVarsTable}.NamePadWidth = ${getVarsTable}.VarName.Length }
            foreach (${getVarsID2} in ${getVarsTable}.ListOfAliases) {
                if (${getVarsID2}.Length -gt ${getVarsTable}.NamePadWidth) { ${getVarsTable}.NamePadWidth = ${getVarsID2}.Length }
            } # END of foreach (${getVarsID2} in ${getVarsTable}.ListOfAliases) {}
            if (${getVarsTable}.ListOfVars) { ${getVarsTable}.ListOfVars += ',' }
            ${getVarsTable}.ListOfVars += (${getVarsTable}.VarName+${getVarsTable}.ListOfAliases)
        } # END of foreach (${getVarsID1} in ${getVarsObject}) {}
    ##### If ${getVarsObject} is NOT the proper type...
    } else {
        ##### Reject it...
        return (
            'Input object type '+
                ( Do-Get-Quoted 'Auto' ${getVarsTable}.ObjectType )+
                ' is not a valid type ('+
                $( ${getVarsTable}.ValidTypes -Join ',' )+
                ').'
        )
    } # END of if (${getVarsTable}.ObjectType -In ${getVarsTable}.ValidTypes) {} else {}

    ##### Get the max width of all var types...
    ${getVarsTable}.TypePadWidth = 1
    foreach (${getVarsID1} in ${getVarsTable}.ListOfVars -Split ',\s*') {
        ${getVarsTable}.VarValue = $( Get-Variable -Name ${getVarsID1} -ValueOnly -ErrorAction SilentlyContinue )
        if (${getVarsTable}.VarValue -eq ${Null}) {
            ${getVarsTable}.VarType = ${Script:RuntimeTable}.Verbose.NullString
        } else {
            ${getVarsTable}.VarType = ${getVarsTable}.VarValue.GetType().Name.Replace('SwitchParameter', 'Switch')
        }
        if (${getVarsTable}.VarType.Length -gt ${getVarsTable}.TypePadWidth) { ${getVarsTable}.TypePadWidth = ${getVarsTable}.VarType.Length }
    } # END of foreach (${getVarsID1} in ${getVarsTable}.ListOfVars -Split ',\s*') {}

    ##### Iterate through the list of variable names...
    ${getVarsTable}.VarsAndValues = ''
    foreach (${getVarsID1} in ${getVarsTable}.ListOfVars -Split ',\s*') {
        ##### Append each pair in the form Name='Value' or Name=Value...
        if (${getVarsTable}.VarsAndValues) { ${getVarsTable}.VarsAndValues += "`n" }
        ${getVarsTable}.VarValue = $( Get-Variable -Name ${getVarsID1} -ValueOnly -ErrorAction SilentlyContinue )
        if (${getVarsTable}.VarValue -eq ${Null}) {
            ${getVarsTable}.VarValue = ${Script:RuntimeTable}.Verbose.NullString
            ${getVarsTable}.VarType  = ${Null}
        } else {
            ${getVarsTable}.VarType  = ${getVarsTable}.VarValue.GetType().Name.Replace('SwitchParameter', 'Switch')
        }
        if (${getVarsTable}.VarType -eq 'String') { ${getVarsTable}.VarValue = ( Do-Get-Quoted 'Auto' ${getVarsTable}.VarValue ) }
        if (${getVarsTable}.VarType -eq ${Null}) {
            ${getVarsTable}.VarType = ''
        } else {
            ${getVarsTable}.VarType = ( Do-Get-Quoted 'Brackets.Square' ( Do-Get-Padded ${getVarsTable}.VarType ${getVarsTable}.TypePadWidth ) )
        }
        ${getVarsTable}.VarsAndValues += (
            (${Script:RuntimeTable}.Verbose.Indent * ${getVarsLevel})+
            ( Do-Get-Padded "${getVarsID1}" ${getVarsTable}.NamePadWidth )+
            ' = '+
            ${getVarsTable}.VarType+
            ' '+
            ${getVarsTable}.VarValue
        )
    } # END of foreach (${getVarsID1} in ${getVarsTable}.ListOfVars -Split ',\s*') {}

    ##### Return the list in the form Name1='Value1', Name2='Value2', ..., NameN='ValueN'...
    return ${getVarsTable}.VarsAndValues
} # END of function Do-Get-Vars


function Do-Is-Valid-Color ([String]${intendedColor}, [String]${fallbackColor}, [Switch]${returnOnlyTrueFalse}) {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Determines if a color word, passed into a function, is valid in PowerShell or not.
#
# Returns:
#  • If -returnOnlyTrueFalse IS used...
#    • [Bool  ]${True}          — when...
#      • ${intendedColor} IS valid; or
#      • ${intendedColor} is NOT valid AND ${fallbackColor} IS valid.
#    • [Bool  ]${False}         — for any other condition.
#  • Otherwise...
#    • [String]${intendedColor} — when it IS valid.
#    • [String]${fallbackColor} — when ${intendedColor} is NOT valid AND ${fallbackColor} IS valid.
#    • via Do-Output-Error         — when both are NOT valid.
#
# Usage:
#  • Parameter 1 — ${intendedColor}: String — the color word to check.
#  • Parameter 2 — ${fallbackColor}: String — the fallback color word to use if ${intendedColor} is invalid.
#  • Parameter 3 — ${callingFunc}:   String — the name of the calling function for use in the ${errorMessage}.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Do-Output-Error
#    • Do-Processing
#####
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    ${validColors} = @(
        'darkblue','darkgray','darkgreen','darkcyan','darkred','darkmagenta','darkyellow',
        'black','gray','blue','green','cyan','red','magenta','yellow','white'
    )

    ##### If ${intendedColor} is valid...
    if (${validColors} -Contains ${intendedColor}.ToLower()) {
        ##### Return ${intendedColor}...
        if (-not ${returnOnlyTrueFalse}) {
            Do-Processing 2 "${funcName}" (
                ${Script:RuntimeTable}.Symbols.Good+"`${intendedColor}='${intendedColor}' is valid; returning `${intendedColor}."
            )
            return "${intendedColor}"
        } else {
            return ${True}
        }

    ##### Else if ${intendedColor} is INVALID but ${fallbackColor} is valid...
    } elseif (${validColors} -Contains ${fallbackColor}.ToLower()) {
        ##### Return ${fallbackColor}...
        if (-not ${returnOnlyTrueFalse}) {
            Do-Processing 2 "${funcName}" (
                ${Script:RuntimeTable}.Symbols.Warn+"`${intendedColor}='${intendedColor}' is INVALID; returning `${fallbackColor}='${fallbackColor}'."
            )
            return "${fallbackColor}"
        } else {
            return ${True}
        }

    ##### Else if ${intendedColor} and ${fallbackColor} are both INVALID...
    } else {
        if (${returnOnlyTrueFalse}) {
            return ${False}
        } else {
            ##### Exit immediately with an error...
            Do-Output-Error `
                -errorMessage    "Both the `${intendedColor}='${intendedColor}' & `${fallbackColor}='${fallbackColor}' are INVALID." `
                -callingFuncName "${funcName}" -exitKey 'E3Code'
        }
    } # END of if (${validColors} -Contains ${intendedColor}.ToLower()) {} elseif {} else {}
} # END of function Do-Is-Valid-Color


function Do-Is-Valid-Entry {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Determines if a config file entry or input value entered by the user is valid or not.
#
# Returns:
#  • [Bool]${True}  — when ${inputValue} IS valid.
#  • [Bool]${False} — when ${inputValue} is NOT valid.
#
# Usage:
#  • Parameter 1 — ${level2Key}:   String (REQUIRED)  — (used if Verobse=2) to output the key name being validated.
#  • Parameter 2 — ${inputValue}:  [untyped]          — the value being validated (type checked using the next parameter).
#  • Parameter 3 — ${varType}:     String (REQUIRED)  — validate that the input value conforms to this variable type.
#  • Parameter 4 — ${varRegExKey}: String             — [Default=Boolean] the key name to ${Script:RegExTable} for which pattern to use for validation.
#  • Parameter 5 — ${mayBeEmpty}:  Boolean            — if used, and the input value is empty, it returns valid.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RegExTable}
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Do-Get-Quoted
#    • Do-Get-Vars
#    • Do-Output-Error
#    • Do-Process-Debug
#    • Do-Processing
#####
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=${True} )][String]${level2Key},
        [Parameter(Mandatory=${False})]        ${inputValue},
        [Parameter(Mandatory=${True} )][String]${varType},
        [Parameter(Mandatory=${False})][String]${varRegExKey},
        [Parameter(Mandatory=${False})][Bool  ]${mayBeEmpty}
    )
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    if ([String]::IsNullOrWhitespace(${varRegExKey})) {
        if (${varType} -eq 'Boolean') {
            ${varRegExKey} = 'Boolean'
        } else {
            Do-Output-Undefined-Error "${funcName}" 'varRegExKey' 'String'
        }
    }
    ${validation} = ${Script:RegExTable}.${varRegExKey}
    Do-Process-Debug `
        -doIt            (${Script:RuntimeTable}.Verbose.Level -gt 1) `
        -callingFuncName "${funcName}"                                `
        -debugIndex      0                                            `
        -processValue    ( Do-Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values )

    ##### Get the type of ${inputValue}...
    if (${inputValue} -eq ${Null}) {
        ${inputType}    = ${Null}
        ${verboseValue} = ${Script:RuntimeTable}.Verbose.NullString
    } else {
        ${inputType} = ${inputValue}.GetType().Name
        if (${inputType} -eq 'String') {
            ##### Structure of ${inputValue} is quoted...
            ${verboseValue} = ( Do-Get-Quoted 'Auto' "${inputValue}" )
        } else {
            ##### Structure of ${inputValue} is unquoted...
            ${verboseValue} = ${inputValue}
        }
    }
    ${excludedVars} = @('keyName','varType','varRegExKey','mayBeEmpty')
    Do-Process-Debug `
        -doIt            (${Script:RuntimeTable}.Verbose.Level -gt 1) `
        -callingFuncName "${funcName}"                                `
        -debugIndex      1                                            `
        -processValue    ( Do-Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values ${excludedVars} )

    ${isValid} = ${False}
    if (${mayBeEmpty} -and ${inputValue} -eq '') {
        ${isValid} = ${True}
    } else {
        if (${inputType} -eq ${varType}) {
            Do-Processing 2 "${funcName}" (
                ' '+
                ${Script:RuntimeTable}.Symbols.Bullet+
                ${Script:RuntimeTable}.Symbols.Good+
                'Variable Type matches '+
                ( Do-Get-Quoted 'Brackets.Square' "${varType}" )+
                '.'
            ) -noPrefix
            ${isValid} = [Bool]([RegEx]::IsMatch(${inputValue}.ToString().Replace('\','\\'), ${validation}))
            if (${isValid}) {
                Do-Processing 2 "${funcName}" (
                    ' '+${Script:RuntimeTable}.Symbols.Bullet+${Script:RuntimeTable}.Symbols.Good+'Contents match validation.'
                ) -noPrefix
            } else {
                Do-Processing 2 "${funcName}" (
                    ' '+${Script:RuntimeTable}.Symbols.Bullet+${Script:RuntimeTable}.Symbols.Warn+'Contents do not match validation.'
                ) -noPrefix
            }
        } else {
            Do-Processing 2 "${funcName}" (
                ' '+
                ${Script:RuntimeTable}.Symbols.Bullet+
                ${Script:RuntimeTable}.Symbols.Warn+
                'Variable Type '+
                ( Do-Get-Quoted 'Brackets.Square' "${inputType}" )+
                "doesn't match "+
                ( Do-Get-Quoted 'Brackets.Square' "${varType}"   )+
                '.'
            ) -noPrefix
            ${isValid} = ${False}
        }
    } # END of if (${mayBeEmpty} -and ${inputValue} -eq '') {} else {}

    Do-Processing 2 "${funcName}" "  return ${isValid}" -noPrefix
    return ${isValid}
} # END of function Do-Is-Valid-Entry


function Do-Output-Error {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Write either a formatted ${errorMessage} or an unformatted ${customMessage} to the console, using...
#    • -BackgroundColor ${backgroundColor}
#    • -ForegroundColor ${foregroundColor}
#    • If either color is invalid, use the default defined below.
#  • Beep in the console.
#  • If ${exitCode}>0, exit with a status of ${exitCode}.
#----
#  • If ${customMessage} is defined, set ${errorMessage} to ${customMessage} without any of the below formatting.
#  • Else if ${customMessage} is NOT defined, format it as follows...
#    • ${errorPrefix} is set to 'ERROR:  ' by default.
#      • If ${exitCode}=${Script:RuntimeTable}.ExitStatus.E3Code...
#        • ${errorPrefix} is set to 'CODING ERROR:  '.
#        • Stack trace info is also set in ${errorCallStack}.
#          • ${errorCallStack} is also set if both ${customMessage} and ${errorMessage} are NOT defined.
#    • If ${errorMessage} is undefined, set it to a default of 'No specific error message was included.'.
#  • If ${failed} is True, append ' FAILED!' to ${errorMessage}.
#  • Else if ${exception} is not empty, append a multiline string as detailed below to ${errorMessage}.
#  • If ${customMessage} is NOT defined...
#    • ${errorSuffix} is set to '' by default.
#      • If ${exitCode}=${Script:RuntimeTable}.ExitStatus.E2User, it's set to "`nIf you need help, use parameter -h|-Help."
#    • If ${callingFuncName} is defined, it appends the following to ${errorMessage}...
#      • If ${callingSection} is defined, it sets it to " in the ${callingSection} section".
#      • If 'MAIN', "`nThis was called from the MAIN BODY of the script${callingSection}."
#      • Otherwise, "`nThe calling function was ${callingFuncName}${callingSection}."
#    • ${errorMessage} is then set to "`n${errorPrefix}${errorMessage}${errorCallStack}${errorSuffix}`n"
#  • Then do the following...
#    • If ${errorMessage} contains ${Script:RuntimeTable}.Symbols.Warn, it will automatically set, unless overriden by parameter(s)...
#      • ${backgroundColor} = 'Dark Yellow'
#      • ${foregroundColor} = 'Black'
#    • Otherwise...
#      • ${backgroundColor} = 'Black'
#      • ${foregroundColor} = 'Red'
#  • If only 1 String parameter is passed in, and no other parameters, it will default to a Red-on-Black error & exit using ExitStatus.E2User.
#
# Returns:
#  • via Do-Output-Write — in all cases; then
#  • [Console]::Beep() — if ${Script:RuntimeTable}.ExitStatus.${exitKey} (where ${exitKey} is E0Good, E1Warn, E2User, E3Code, or EXMore) is True; then
#  • via Do-Process-Exit  — when ${exitCode}>0.
#
# Usage:
#  • Parameter -errorMessage:    String  — the message to be formatted as above to output as an error.
#  • Parameter -exitCode:        Integer — [Default=${Script:RuntimeTable}.ExitStatus.E2User] if >0, exit with this exit code number at the end.
#  • Parameter -exitKey:         String  — [Default='E2User'] in lieu of an ${exitCode}, use ${Script:RuntimeTable}.ExitStatus.${exitKey}.
#  • Parameter -customMessage:   String  — if used, overrides ${errorMessage} without any formatting.
#  • Parameter -undefinedParam:  String  — if used, overrides ${errorMessage} & ${customMessage} with an undefined parameter error message.
#  • Parameter -undefinedType:   String  — if used, and ${undefinedParam} is defined, prepend the parameter name with "[${undefinedType}]".
#  • Parameter -backgroundColor: String  — [Default=see above] the background color to use.
#  • Parameter -foregroundColor: String  — [Default=see above] the foreground color to use.
#  • Parameter -failed:          Switch  — if used, appends ' FAILED!' to ${errorMessage}.
#  • Parameter -exception:       String  — if used, if ${failed} is False, appends to ${errorMessage}, (
#        " failed with:`n"+
#        ${Script:RuntimeTable}.Verbose.Divider+"`n"+
#        "${exception}`n"+
#        ${Script:RuntimeTable}.Verbose.Divider
#    )
#  • Parameter -failSuffix:      String  — only if ${exception} is True, appends ${failSuffix} after ${exception}.
#  • Parameter -callingFuncName: String  — [Default=''       ] if included, will output an extra line after ${errorMessage} (see above).
#  • Parameter -callingSection:  String  — [Default=''       ] if included, also explain which section it's called from.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Do-Get-Var-Quoted
#    • Do-Is-Valid-Color
#    • Do-Output-Write
#    • Do-Process-Exit
#    • Do-Processing
#####
    param(
        [String]${errorMessage},
        [Int]   ${exitCode}=${Script:RuntimeTable}.ExitStatus.E2User,
        [String]${exitKey}='E2User',
        [String]${customMessage},
        [String]${undefinedParam},
        [String]${undefinedType},
        [String]${backgroundColor},
        [String]${foregroundColor},
        [Switch]${failed},
        [String]${exception}='',
        [String]${failSuffix}='',
        [String]${callingFuncName}='',
        [String]${callingSection}=''
    )
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )


    ##### If ${exitKey} is defined, get ${exitCode} from ${Script:RuntimeTable}.ExitStatus.${exitKey}...
    if (-not [String]::IsNullOrWhitespace(${exitKey})) { ${exitCode} = ${Script:RuntimeTable}.ExitStatus.${exitKey} }
    #####
    # Range-check ${exitCode}...
    #####
    if (${exitCode} -lt 0) {
        Do-Processing 2 "${funcName}" (${Script:RuntimeTable}.Symbols.Warn+"ExitCode=${exitCode} is less than 0, defaulting to 0.")
        ${exitCode} = 0
    } elseif (${exitCode} -gt 255) {
        Do-Processing 2 "${funcName}" (${Script:RuntimeTable}.Symbols.Warn+"ExitCode=${exitCode} is more than 255, defaulting to 255.")
        ${exitCode} = 255
    } else {
        Do-Processing 2 "${funcName}" (${Script:RuntimeTable}.Symbols.Good+"ExitCode=${exitCode} is valid.")
    }


    ##### If ${undefinedParam} is defined...
    if (-not [String]::IsNullOrWhitespace(${undefinedParam})) {
        ##### Set ${errorMessage} to "Required function parameter ${undefinedType}`${${undefinedParam}} is undefined."...
        if ([String]::IsNullOrWhitespace(${exitKey})) { ${exitCode} = ${Script:RuntimeTable}.ExitStatus.E3Code }
        Do-Processing 2 "${funcName}" (
            ( Do-Get-Var-Quoted 1 'undefinedParam'  18 'Auto' "${undefinedParam}"  -nl )+
            ( Do-Get-Var-Quoted 1 'undefinedType'   18 'Auto' "${undefinedType}"   -nl )+
            ( Do-Get-Var-Quoted 1 'exitCode'        18 'None' "${exitCode}"        -nl )+
            ( Do-Get-Var-Quoted 1 'backgroundColor' 18 'Auto' "${backgroundColor}" -nl )+
            ( Do-Get-Var-Quoted 1 'foregroundColor' 18 'Auto' "${foregroundColor}"     )
        ) -nl
        if ([String]::IsNullOrWhitespace(${undefinedType})) { ${undefinedType} = '' } else { ${undefinedType} = "[${undefinedType}]" }
        ${errorMessage} = "Required function parameter ${undefinedType}`${${undefinedParam}} is undefined."

    ##### Else if ${customMessage} is defined...
    } elseif (-not [String]::IsNullOrEmpty(${customMessage})) {
        ##### Set ${errorMessage} to ${customMessage} without any formatting...
        Do-Processing 2 "${funcName}" (
            ( Do-Get-Var-Quoted 1 'customMessage'    0                    -noValue -nl )+
            ( Do-Get-Var-Quoted 1 'exitCode'        18 'None' "${exitCode}"        -nl )+
            ( Do-Get-Var-Quoted 1 'backgroundColor' 18 'Auto' "${backgroundColor}" -nl )+
            ( Do-Get-Var-Quoted 1 'foregroundColor' 18 'Auto' "${foregroundColor}"     )
        ) -nl
        ${errorMessage} = ${customMessage}

    ##### Else if ${customMessage} is NOT defined, format ${errorMessage} as follows...
    } else {
        Do-Processing 2 "${funcName}" (
            ( Do-Get-Var-Quoted 1 'errorMessage'     0                    -noValue -nl )+
            ( Do-Get-Var-Quoted 1 'exitCode'        18 'None' "${exitCode}"        -nl )+
            ( Do-Get-Var-Quoted 1 'backgroundColor' 18 'Auto' "${backgroundColor}" -nl )+
            ( Do-Get-Var-Quoted 1 'foregroundColor' 18 'Auto' "${foregroundColor}"     )
        ) -nl
        #####
        # Set the default ${errorPrefix} to 'ERROR:  '.
        # Set the default ${errorCallStack} to ''.
        #  • If ${exitCode}=${Script:RuntimeTable}.ExitStatus.E3Code...
        #    • This means it's an unrecoverable coding error, so also prepend 'CODING ' to ${errorPrefix}.
        #    • Also set ${errorCallStack} prepended with a newline.
        #      • Also set ${errorCallStack} if ${errorMessage} is NOT defined.
        #####
            ${errorPrefix}    = 'ERROR:  '
            ${errorCallStack} = ''
        if (${exitCode} -eq ${Script:RuntimeTable}.ExitStatus.E3Code) {
            ${errorPrefix}    = "CODING ${errorPrefix}"
        }
        if (${exitCode} -eq ${Script:RuntimeTable}.ExitStatus.E3Code -or [String]::IsNullOrWhitespace(${errorMessage})) {
            ${errorCallStack} = Get-PSCallStack | ForEach-Object { "$(${_}.FunctionName) called from $(${_}.Location)`n" }
            ${errorCallStack} = (
                "`n"+
                "This is an unrecoverable coding error.`n"+
                "Here's some call stack trace info...`n"+
                ${Script:RuntimeTable}.Verbose.Divider+"`n"+
                "${errorCallStack}"+
                ${Script:RuntimeTable}.Verbose.Divider
            )
        }

        #####
        # If ${errorMessage} is NOT defined...
        #####
        if ([String]::IsNullOrWhitespace(${errorMessage})) {
            ##### Set a default error message...
            ${errorMessage} = 'No specific error message was included.'
        }
    } # END of if (-not [String]::IsNullOrWhitespace(${undefinedParam})) {} elseif (-not [String]::IsNullOrEmpty(${customMessage})) {} else {}


    #####
    # If ${failed} is True, append ' FAILED!' to ${errorMessage}...
    #####
    if (${failed}) {
        ${errorMessage} += ' FAILED!'
    #####
    # Else if ${exception} is defined, append to ${errorMessage}, (
    #     " failed with:`n"+
    #     ${Script:RuntimeTable}.Verbose.Divider+"`n"+
    #     "${exception}`n"+
    #     ${Script:RuntimeTable}.Verbose.Divider+"${failSuffix}"
    # )
    #####
    } elseif (${exception} -ne '') {
        ${errorMessage} += (
            " failed with:`n"+
            ${Script:RuntimeTable}.Verbose.Divider+"`n"+
            "${exception}`n"+
            ${Script:RuntimeTable}.Verbose.Divider+"${failSuffix}"
        )
    }


    ##### If ${customMessage} is NOT defined...
    if ([String]::IsNullOrEmpty(${customMessage})) {
        #####
        # Set the default ${errorSuffix} to ''.
        #  • If ${exitCode}=${Script:RuntimeTable}.ExitStatus.E2User...
        #    • This means it's a usage error, so include a blurb about using the help parameter.
        #    • Set ${errorSuffix} to "`nIf you need help, use option -h|-Help.".
        #####
        ${errorSuffix} = ''
        if (${exitCode} -eq ${Script:RuntimeTable}.ExitStatus.E2User) { ${errorSuffix} = "`nIf you need help, use parameter -h|-Help." }

        #####
        # If ${callingFuncName} is defined...
        #####
        if (-not [String]::IsNullOrWhitespace(${callingFuncName})) {
            ##### If ${callingSection} is defined...
            if (-not [String]::IsNullOrWhitespace(${callingSection})) {
                ##### Format it as an extension to ${callingFuncName}...
                ${callingSection} = " in the ${callingSection} section"
            }
            ##### Append that info after a newline to ${errorMessage}...
            if (${callingFuncName}.ToUpper() -eq 'MAIN') {
                ${errorMessage} += "`nThis was called from the MAIN BODY of the script${callingSection}."
            } else {
                ${errorMessage} += "`nThe calling function was ${callingFuncName}${callingSection}."
            }
        }

        #####
        # If ${exitCode}>0, append that to ${errorMessage}...
        #####
        if (${exitCode} -gt 0) {
            ${errorMessage} += "`nThe exit status code is ${exitCode}"
            ##### For these, also include an explanation in parenthesis...
            switch (${exitCode}) {
                1 { ${errorMessage} += ' (Usage Error)'  }
                2 { ${errorMessage} += ' (Coding Error)' }
            }
            ${errorMessage} += '.'
        }

        #####
        # Assemble the formatted ${errorMessage} with a newline before and after...
        #####
        ${errorMessage} = "`n${errorPrefix}${errorMessage}${errorCallStack}${errorSuffix}`n"
    } # END of if ([String]::IsNullOrEmpty(${customMessage})) {}


    #####
    # If ${errorMessage} contains ${Script:RuntimeTable}.Symbols.Warn...
    #####
    if ([Bool]([RegEx]::IsMatch(${errorMessage}.Replace('\','\\'), ${Script:RuntimeTable}.Symbols.Warn))) {
        ##### Set the ${exitKey} to ${RuntimeTable}.ErrorBeepsOn to...
        ${exitKey} = 'E1Warn'
        ##### Use colors Black on DarkYellow, unless each is overriden by parameter(s)...
        ${backgroundColor} = ( Do-Is-Valid-Color -intendedColor "${backgroundColor}" -fallbackColor 'DarkYellow' )
        ${foregroundColor} = ( Do-Is-Valid-Color -intendedColor "${foregroundColor}" -fallbackColor 'Black'      )

    #####
    # Else if ${errorMessage} DOESN'T contain ${Script:RuntimeTable}.Symbols.Warn...
    #####
    } else {
        ##### Determine the key to ${RuntimeTable}.ErrorBeepsOn by ${exitCode}...
        switch (${exitCode}) {
            ${Script:RuntimeTable}.ExitStatus.E0Good { ${exitKey} = 'E0Good' }
            ${Script:RuntimeTable}.ExitStatus.E2User { ${exitKey} = 'E2User' }
            ${Script:RuntimeTable}.ExitStatus.E3Code { ${exitKey} = 'E3Code' }
            default                                  { ${exitKey} = 'EXMore' }
        }
        ##### Use colors Red on Black, unless each is overriden by parameter(s)...
        ${backgroundColor} = ( Do-Is-Valid-Color -intendedColor "${backgroundColor}" -fallbackColor 'Black'      )
        ${foregroundColor} = ( Do-Is-Valid-Color -intendedColor "${foregroundColor}" -fallbackColor 'Red'        )
    }


    #####
    # Write the ${errorMessage}...
    #  • This uses -niExitKey 'E0Good' to the Do-Process-Non-Interactive function, because it should honor the ${exitCode} of this function.
    #####
    Do-Output-Write `
        -textOutput        "${errorMessage}"      `
        -streamWord        'Error'                `
        -backgroundColor   "${backgroundColor}"   `
        -foregroundColor   "${foregroundColor}"   `
        -niCallingFunction "${funcName}"          `
        -niCallingVarNames "`"`${errorMessage}`"" `
        -niExitKey         'E0Good'


    #####
    # Also Beep, if applicable...
    #  • With parameters -Silent or -niv|-ni|-NonInteractive, all of these will be False.
    #####
    Do-Processing 2 "${funcName}" (
        "For ExitStatus.${exitKey}, `${Script:RuntimeTable}.ErrorBeepsOn.${exitKey}="+${Script:RuntimeTable}.ErrorBeepsOn.${exitKey}
    )
    if (${Script:RuntimeTable}.ErrorBeepsOn.${exitKey}) { [Console]::Beep() }


    #####
    # If ${exitCode}>0, then exit with that code...
    #####
    if (${exitCode} -gt 0) { Do-Process-Exit ${exitCode} "${funcName}" }
} # END of function Do-Output-Error


function Do-Output-Feedback ([String]${feedbackMessage}, [Switch]${success}) {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Outputs "${prefix}${feedbackMessage}" as feedback as defined in the Do-Processing function when ${processPrefix}='Feedback'.
#
# Returns:  via Do-Processing in all cases.
#
# Usage:
#  • Parameter 1 — ${feedbackMessage}: String — the message to output as feedback.
#  • Parameter -success:               Switch — if used, sets ${prefix}=${Script:RuntimeTable}.Symbols.Good.
#
# Dependencies:
#  • Functions...
#    • Do-Processing
#####
    if (${success}) { ${prefix} = ${Script:RuntimeTable}.Symbols.Good } else { ${prefix} = '' }

    Do-Processing 0 'Feedback' "${prefix}${feedbackMessage}"
} # END of function Do-Output-Feedback


function Do-Output-Help-Page {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Output the help block from the top of this script, between the <#-HELP-# & #-HELP-#> lines.
#  • If parameter -releaseNotes is used, it outputs the release notes block , between the <#-NOTES-# & #-NOTES-#> lines.
#  • If it doesn't find the block, it prints an error.
#
# Returns:
#  • via Wrap-text      — if ${helpTagBegin} AND ${helpTagClose} are both FOUND in this script; or
#  • via Do-Output-Warning — if either ${helpTagBegin} AND/OR ${helpTagClose} are NOT found in this script; then
#  • via Do-Process-Exit   — in all cases.
#
# Usage:
#  • Parameter -releaseNotes: Switch — if used, instead of outputting the help block, it outputs the release notes block.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Do-Get-Padded
#    • Do-Get-Quoted
#    • Do-Get-Var-Quoted
#    • Do-Output-Warning
#    • Do-Process-Exit
#    • Do-Processing
#    • Do-Output-Wrapped
#  • Other...
#    • There must be a commented help section somewhere in the script bounded by ${helpTagBegin} and ${helpTagClose}.
#####
    param(
        [Switch]${releaseNotes}
    )
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    ${scriptPath} = ${Script:RuntimeTable}.FullPath

    ${scriptLines}   = Get-Content -Path ${scriptPath}
    ${termWidth}     = ${Host}.UI.RawUI.WindowSize.Width
    ${helpBlock}     = ''

    if (${releaseNotes}) {
        ${helpTagBegin} = '<#-NOTES-#'; ${helpTagClose} = '#-NOTES-#>'; ${helpType} = 'release notes'
    } else {
        ${helpTagBegin} = '<#-HELP-#';  ${helpTagClose} = '#-HELP-#>';  ${helpType} = 'help'
    }
    ${helpLineClose} = -1
    ${helpLineStart} = -1
    Do-Processing 2 "${funcName}" (
        ( Do-Get-Var-Quoted 1 'scriptPath'           20 'Auto' "${scriptPath}"                   -nl )+
        ( Do-Get-Var-Quoted 1 '${scriptLines}.Count' 20 'None'  ${scriptLines}.Count -noBrackets -nl )+
        ( Do-Get-Var-Quoted 1 'termWidth'            20 'None' "${termWidth}"                    -nl )+
        ( Do-Get-Var-Quoted 1 'helpTagBegin'         20 'Auto' "${helpTagBegin}"                 -nl )+
        ( Do-Get-Var-Quoted 1 'helpTagClose'         20 'Auto' "${helpTagClose}"                     )
    ) -nl

    for (${lineNum} = 0; ${lineNum} -lt ${scriptLines}.Count; ${lineNum}++) {
            if (${helpLineStart} -eq -1 -and ${scriptLines}[${lineNum}] -Like "${helpTagBegin}*") {
                ${helpLineStart} = ${lineNum}+1
                ${verboseWidth}  = ([String](${helpLineStart}-1)).Length
        }
        elseif (${helpLineClose} -eq -1 -and ${scriptLines}[${lineNum}] -Like "${helpTagClose}*") {
                ${helpLineClose} = ${lineNum}-1
                if (([String](${helpLineClose}+1)).Length -gt ${verboseWidth}) { ${verboseWidth} = ([String](${helpLineClose}+1)).Length }
        }
        if (${helpLineStart} -ge 0 -and ${helpLineClose} -gt ${helpLineStart}) {
            ${helpLineCount} = (${helpLineClose}-${helpLineStart})
            ${verboseVName1} = ('${scriptLines}'+( Do-Get-Quoted 'Brackets.Square' ( Do-Get-Padded (${helpLineStart}-1) ${verboseWidth} -padBefore ) ))
            ${verboseVNameN} = ('${scriptLines}'+( Do-Get-Quoted 'Brackets.Square' ( Do-Get-Padded (${helpLineClose}+1) ${verboseWidth} -padBefore ) ))
            ${verboseValue1} = ${scriptLines}[(${helpLineStart}-1)..(${helpLineStart}-1)]
            ${verboseValueN} = ${scriptLines}[(${helpLineClose}+1)..(${helpLineClose}+1)]
            Do-Processing 2 "${funcName}" (
                ( Do-Get-Var-Quoted 1 'helpLineCount'    20 'None'  ${helpLineCount}              -nl )+
                ( Do-Get-Var-Quoted 1 'helpLineStart'    20 'None'  ${helpLineStart}              -nl )+
                ( Do-Get-Var-Quoted 1 'helpLineClose'    20 'None'  ${helpLineClose}              -nl )+
                ( Do-Get-Var-Quoted 1 "${verboseVName1}" 20 'Auto' "${verboseValue1}" -noBrackets -nl )+
                ( Do-Get-Var-Quoted 1 "${verboseVNameN}" 20 'Auto' "${verboseValueN}" -noBrackets     )
            ) -noPrefix

            ${helpBlock} = (${scriptLines}[(${helpLineStart})..(${helpLineClose})] -Join "`n") -Split '\r?\n'

            foreach (${lineString} in ${helpBlock}) {
                if ([String]::IsNullOrWhiteSpace(${lineString})) {
                    ''
                } else {
                    ${lineString} = ${lineString} `
                        -Replace '^\.PARAMETER ',    ''                                                           `
                        -Replace '^\.',              ''                                                           `
                        -Replace 'ScriptName',       ${Script:RuntimeTable}.BareName                              `
                        -Replace 'exit with code 1', ('exit with code '+${Script:RuntimeTable}.ExitStatus.E2User) `
                        -Replace 'exit with code 2', ('exit with code '+${Script:RuntimeTable}.ExitStatus.E3Code) `
                        -Replace 'exit with code 3', ('exit with code '+${Script:RuntimeTable}.ExitStatus.E4NIMR)
                    Do-Output-Wrapped "${lineString}"
                } # END of if ([String]::IsNullOrWhiteSpace(${lineString})) {} else {}
            } # END of foreach (${lineString} in ${helpBlock}) {}
            break # from the for loop
        } # END of if (${helpLineStart} -ge 0 -and ${helpLineClose} -gt ${helpLineStart}) {}
    } # END of for (${lineNum} = 0; ${lineNum} -lt ${scriptLines}.Count; ${lineNum}++) {}

    if (${helpLineStart} -ge 0 -and ${helpLineClose} -gt ${helpLineStart}) {
        ##### Do nothing here.
    } else {
        Do-Output-Warning (
            "No ${helpType} block found in "+( Do-Get-Quoted 'Auto' "${scriptPath}" )+".`n"+
            "The ${helpType} block must begin with ${helpTagBegin} & end with ${helpTagClose} each at the beginning of the line.`n"
        )
    }

    Do-Process-Exit ${Script:RuntimeTable}.ExitStatus.E0Good "${funcName}"
} # END of function Do-Output-Help-Page


function Do-Output-Undefined-Error {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Wrapper for Do-Output-Error using...
#      -undefinedParam  "${undefinedParam}" `
#      -undefinedType   "${undefinedType}"  `
#      -callingFuncName "${callingFuncName}"
#  • This function is used to output an error...
#    • from another function with name ${undefinedFunc},
#    • that one of its required parameter variables named ${undefinedParam} was left undefined, and
#    • if used, what variable type, ${undefinedType}, that ${undefinedParam} was expected to be.
#  • If either ${callingFuncName} &/or ${undefinedParam} are themselves undefined, it'll output a "that's ironic" E3Code error (see code below).
#
# Returns:  via Do-Output-Error in all cases as described above and below.
#
# Usage:
#  • Parameter 1 — ${callingFuncName}: String (REQUIRED) — the name of the calling function.
#    • This will be obtained dynamically from within the calling function the same as ${funcName} is defined in the code below.
#  • Parameter 2 — ${undefinedParam}:  String (REQUIRED) — the name of the calling function's required parameter variable that was left undefined.
#    • This should only be the varName portion of the ${varName} reference from the calling function.
#  • Parameter 3 — ${undefinedType}:   String            — [Default=''] if used, what variable type ${undefinedParam} was expected to be.
#    • This should only be the Type portion of the [Type] reference prior to the calling function's parameter definition (e.g. Bool, Int, etc.)
#
# Dependencies:
#  • Functions...
#    • Do-Output-Error
#####
    param(
        [String]${callingFuncName},
        [String]${undefinedParam},
        [String]${undefinedType}=''
    )
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )


    #####
    ##### Let's get some E3Code errors out of the way first...
    #####

    ##### Set the ${ironicPrefix} and ${ironicSuffix}, which are both used twice just below...
    ${ironicPrefix} = "Well, that's ironic, required function parameter [String]`${"
    ${ironicSuffix} = '} is itself undefined.'
    ##### Do ${callingFuncName} first, because the next error message uses it, while this one only uses ${funcName} (because that's all that's known)...
    if ([String]::IsNullOrWhitespace(${callingFuncName})) {
        Do-Output-Error `
            -errorMessage "${ironicPrefix}callingFuncName${ironicSuffix}" `
            -callingFunction "${funcName}" -exitKey 'E3Code'
    }
    ##### If it gets past the above error, then it uses both ${callingFuncName}:${funcName} together here...
    if ([String]::IsNullOrWhitespace(${undefinedParam})) {
        Do-Output-Error `
            -errorMessage "${ironicPrefix}undefinedParam${ironicSuffix}" `
            -callingFunction "${callingFuncName}:${funcName}" -exitKey 'E3Code'
    }


    #####
    ##### If it gets this far, then this is the actual undefined parameter error that's intended to be sent with this function...
    #####

    Do-Output-Error `
        -undefinedParam  "${undefinedParam}"  `
        -undefinedType   "${undefinedType}"   `
        -callingFuncName "${callingFuncName}" `
        -exitKey         'E3Code'
} # END of function Do-Output-Undefined-Error


function Do-Output-Warning {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Wrapper function for Do-Output-Error using...
#      -customMessage   "${prefix}${warningMessage}"
#      -exception       "${exception}"
#      -backgroundColor "${backgroundColor}"
#      -foregroundColor "${foregroundColor}"
#      -exitKey         'E1Warn'
#
# Returns:  via Do-Output-Error as described above and below.
#
# Usage:
#  • Parameter 1 — ${warningMessage}: String — the message to write to the console, prepended with ${prefix}=${Script:RuntimeTable}.Symbols.Warn.
#  • Parameter -prefix:               String — [Default=''] if used, additional text to prepend before ${Script:RuntimeTable}.Symbols.Warn.
#  • Parameter -preSpace:             Switch — if used, prepends an extra space to ${prefix}.
#  • Parameter -noPrefix:             Switch — if used (takes priority over -prefix & -preSpace), omits ${prefix} entirely.
#  • Parameter -backgroundColor:      String — [Default=''] if used, override the default ${backgroundColor} in Do-Output-Error.
#  • Parameter -foregroundColor:      String — [Default=''] if used, override the default ${foregroundColor} in Do-Output-Error.
#  • Parameter -exception:            String — [Default=''] if used, also pass in -exception "${exception}" to Do-Output-Error.
#
# Dependencies:
#  • Functions...
#    • Do-Output-Error
#####
    param(
        [String]${warningMessage},
        [String]${prefix}='',
        [Switch]${preSpace},
        [Switch]${noPrefix},
        [String]${backgroundColor}='',
        [String]${foregroundColor}='',
        [String]${exception}=''
    )


    if (${noPrefix}) {
        ${prefix} = ''
    } else {
        if (${preSpace}) { ${prefix} = " ${prefix}" }
        ${prefix} += ${Script:RuntimeTable}.Symbols.Warn
    }


    Do-Output-Error `
        -customMessage   "${prefix}${warningMessage}" `
        -exception       "${exception}"               `
        -backgroundColor "${backgroundColor}"         `
        -foregroundColor "${foregroundColor}"         `
        -exitKey         'E1Warn'
} # END of function Do-Output-Warning


function Do-Output-Wrapped {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • For each line of text in the ${textToWrap} string array, input received from a pipeline, wrap lines longer than ${termWidth} at word breaks.
#
# Returns:  via Do-Output-Write — in all cases.
#
# Usage:
#  • Parameter 1 — ${textToWrap}: String Array (REQUIRED) — an array of text lines to be wrapped according to ${termWidth}.
#  • Parameter 2 — ${termWidth}:  Integer                 — [Default=${Host}.UI.RawUI.WindowSize.Width] the desired width or width of the console.
#    • Although you can specify your own ${termWidth} with this parameter, it will be forced to a basic functional minimum of 40.
#
# Dependencies:
#  • Functions...
#    • Do-Output-Write
#####
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=${True}, ValueFromPipeline=${True})][String[]]${textToWrap},
        [Parameter(Mandatory=${False}                          )][Int     ]${termWidth}=${Host}.UI.RawUI.WindowSize.Width
    )
    if (${termWidth} -lt 40) { ${termWidth} = 40 }

    foreach (${originalLine} in ${textToWrap}) {
        ##### Capture *all* leading whitespace exactly as-is...
        ${lineIndent} = [RegEx]::Match(${originalLine}, '^[ \t]*').Value
        ${availableWidth} = ${termWidth} - ${lineIndent}.Length

        ##### Remove only the indent for wrapping logic...
        ${lineContent} = ${originalLine}.Substring(${lineIndent}.Length)

        ${lineWords} = ${lineContent} -Split ' '
        ${currentLine} = ''
        foreach (${currentWord} in ${lineWords}) {
            if ((${currentLine}.Length + ${currentWord}.Length + 1) -gt ${availableWidth}) {
                Do-Output-Write (${lineIndent} + ${currentLine}.TrimEnd())
                ${currentLine}  = "${currentWord} "
            } else {
                ${currentLine} += "${currentWord} "
            }
        } # END of foreach (${currentWord} in ${lineWords}) {}
        if (${currentLine}) {
            Do-Output-Write (${lineIndent} + ${currentLine}.TrimEnd())
        }
    } # END of foreach (${originalLine} in ${textToWrap}) {}
} # END of function Do-Output-Wrapped


function Do-Output-Write {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • This is designed so if the only parameter is a single string, it'll default to...
#    • ${backgroundColor} = 'Black'
#    • ${foregroundColor} = 'Gray'
#    • ${extraNewline}    = ${False}
#    • ${noNewline}       = ${False}
#  • Scope-checking...
#    • If either ${backgroundColor} or ${foregroundColor} are invalid, it'll replace both with 'Black' & 'Gray', respectively.
#    • So, to use any color other than Gray on Black, BOTH colors need to be specified and valid.
#  • Before continuing, it sets ${niActive} to True or False, based on...
#    • If -thisIsAnNiMessage was used, it chooses False.
#    • Otherwise, it gets the value of ${Script:RuntimeTable}.NonInteractive.IsTrue.
#  • If ${niActive} is True, it calls Do-Process-Non-Interactive to re-frame the message.
#  • Otherwise, it outputs ${textOutput}, honoring -extraNewline & -noNewline, and using...
#    • If ${outFile} is defined and valid, it writes to it using Out-File.
#    • If ${streamNum} is 1, it uses Write-Output, otherwise if 6, it uses Write-Host.
#      • If using Write-Host, it can also use...
#        • -BackgroundColor ${backgroundColor}
#        • -ForegroundColor ${foregroundColor}
#
# Returns:
#  • via Do-Process-Non-Interactive  — if -thisIsAnNiMessage is NOT used AND ${Script:RuntimeTable}.NonInteractive.IsTrue is True.
#  • via Out-File/Do-Output-Feedback — if ${outFile} is defined AND valid.
#  • via Write-Host               — for all other conditions.
#
# Usage:
#  • Parameter -textOutput:          String  — [Default=''] the text to output.
#  • Parameter -outFile              String  — if used, use Out-File to write ${textOutput} to ${outFile}.
#  • These are only relevant if ${outFile} is undefined and ignored otherwise...
#    • Parameter -streamNum          Integer — [Default=1 ] if used (only 1 & 6 are valid at present), redirect output to ${streamNum}.
#    • Parameter -streamWord         String  — if used, determine ${streamNum} from ${streamWord} and if not recognized, default to 1.
#    • These are only relevant if ${streamNum}=6, where it can use Write-Host, instead of Write-Output...
#      • Parameter -backgroundColor: String  — the background color to use.
#      • Parameter -foregroundColor: String  — the foreground color to use.
#  • Parameter -extraNewline:        Boolean — whether or not to output an extra newline after ${textOutput} (without using colors).
#  • Parameter -noNewline:           Switch  — if used, add -NoNewline to Write-Host or Out-File, whichever applies.
#  • Parameter -niCallingFunction:   String  — in -NonInteractive mode, the function name to show in the Do-Process-Non-Interactive function.
#  • Parameter -niCallingVarNames:   String  — in -NonInteractive mode, the var name(s) to show instead of '${textOutput}' in Do-Process-Non-Interactive.
#  • Parameter -niExitCode:          Integer — [Default=${Script:RuntimeTable}.ExitStatus.E4NIMR] for -NonInteractive mode,
#     the exit code to pass into the Do-Process-Non-Interactive function.
#  • Parameter -niExitKey:           String  — [Default=''] in lieu of an ${niExitCode}, use ${Script:RuntimeTable}.ExitStatus.${niExitKey}.
#  • Parameter -thisIsAnNiMessage:   Boolean — indicates whether or not the call to this function was from Do-Process-Non-Interactive, and if True, prevents
#     calling it again.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Do-Check-Path
#    • Do-Get-Quoted
#    • Do-Is-Valid-Color
#    • Do-Output-Error
#    • Do-Output-Feedback
#    • Do-Process-Non-Interactive
#    • Do-Processing
#####
    param(
        [String]${textOutput}='',
        [String]${outFile},
        [Int   ]${streamNum}=1,
        [String]${streamWord},
        [String]${backgroundColor},
        [String]${foregroundColor},
        [Bool  ]${extraNewline},
        [Switch]${noNewline},
        [String]${niCallingFunction},
        [String]${niCallingVarNames}='',
        [Int   ]${niExitCode}=${Script:RuntimeTable}.ExitStatus.E4NIMR,
        [String]${niExitKey}='',
        [Bool  ]${thisIsAnNiMessage}
    )
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )


    #####
    ##### Scope-check all necessary variables...
    #####

    ##### If ${niExitKey} is defined, get ${niExitCode} from ${Script:RuntimeTable}.ExitStatus.${niExitKey}...
    if (-not [String]::IsNullOrWhitespace(${niExitKey})) { ${niExitCode} = ${Script:RuntimeTable}.ExitStatus.${niExitKey} }
    ##### If ${outFile} is defined...
    if (${outFile}) {
        ##### Use Do-Check-Path only to check for errors and don't output any warning messages...
        ${Null} = ( Do-Check-Path 'Output File' "${outFile}" -noWarn -callingFuncName "${funcName}" )

        #####
        # The following are all irrelevant & silently ignored...
        #  • ${streamWord}
        #  • ${streamNum}
        #  • ${backgroundColor}
        #  • ${foregroundColor}
        #####

        if (${extraNewline}) { ${textOutput} += "`n" }
    ##### Else if using Write-Host....
    } else {
        ##### If ${streamWord} is defined, use that to determine ${streamNum}...
        if (${streamWord}) {
            switch (${streamWord}.ToLower()) {
                #####
                # Only stream numbers 1 & 6 are supported at present.
                #  • If 1, the Success stream, it's use Write-Output.
                #  • If 6, it'll use Write-Host, which sends output to the console.
                #  • The following streams CANNOT be redirected...
                #    • 2, the Error   stream (uses 6 instead)
                #    • 3, the Warning stream (uses 6 instead)
                #    • 4, the Verbose stream (uses 6 instead)
                #    • 5, the Debug   stream (uses 6 instead)
                #  • The default is 6 if unspecified.
                #####
                'debug'       { ${streamNum} = 6 }
                'error'       { ${streamNum} = 6 }
                'info'        { ${streamNum} = 6 }
                'information' { ${streamNum} = 6 }
                'output'      { ${streamNum} = 1 }
                'success'     { ${streamNum} = 1 }
                'verbose'     { ${streamNum} = 6 }
                'warning'     { ${streamNum} = 6 }
                default       { ${streamNum} = 1 }
            }
        }
        ##### If ${streamNum} is not 1 or 6, default to 1...
        if (${streamNum} -NotIn @(1,6)) { ${streamNum} = 1 }
        ##### If either ${backgroundColor} or ${foregroundColor} or both are invalid...
        if (
            -not ( Do-Is-Valid-Color -intendedColor "${backgroundColor}" -fallbackColor '' -returnOnlyTrueFalse ) -or
            -not ( Do-Is-Valid-Color -intendedColor "${foregroundColor}" -fallbackColor '' -returnOnlyTrueFalse )
        ) {
            ##### Set both to Gray on Black by default...
            ${backgroundColor} = 'Black'
            ${foregroundColor} = 'Gray'
        }
    } # END of if (${outFile}) {} else {}
    if (${niCallingVarNames} -eq '') { ${niCallingVarNames} = "`"`${textOutput}`"" }
    if (${noNewline}) {
        ${verboseNoNewline} = '-NoNewline'
        if (${outFile}) {
            ${verboseNoNewline} = " ${verboseNoNewline}"
        } else {
            ${verboseNoNewline} = ("`n"+${Script:RuntimeTable}.Verbose.Indent+"${verboseNoNewline}")
        }
    } else {
        ${verboseNoNewline} = '' 
    }


    #####
    # If ${thisIsAnNiMessage} is True, then the call to this function is ultimately from Do-Process-Non-Interactive, so set ${niActive} to False so it
    #  won't call Do-Process-Non-Interactive again to prevent an infinite loop.
    #####
    if (${thisIsAnNiMessage}) {
        ${niActive} = ${False}
    #####
    # Else if ${thisIsAnNiMessage} is False, then the call to this function is NOT from Do-Process-Non-Interactive, so set ${niActive} to
    #  ${Script:RuntimeTable}.NonInteractive.IsTrue to determine if Do-Process-Non-Interactive is called or not.
    #####
    } else {
        ${niActive} = ${Script:RuntimeTable}.NonInteractive.IsTrue
    }
<#
Write-Host "
  `${outFile}           = '${outFile}'
  `${streamWord}        = '${streamWord}'
  `${streamNum}         = ${streamNum}
  `${backgroundColor}   = '${backgroundColor}'
  `${foregrouncColor}   = '${foregroundColor}'
  `${extraNewline}      = ${extraNewline}
  `${noNewline}         = ${noNewline}
  `${niCallingFunction} = '${niCallingFunction}'
  `${niCallingVarNames} = '${niCallingVarNames}'
  `${niExitCode}        = ${niExitCode}
  `${thisIsAnNiMessage} = ${thisIsAnNiMessage}
  `${niActive}          = ${niActive}
  `${textOutput}...
${textOutput}
..."
#>

    ##### If ${niActive} is True...
    if (${niActive}) {
        #####
        # Redirect all output to the Do-Process-Non-Interactive function...
        #  • ${verboseNoNewline} is set above this section.
        #####
        if (${outFile}) {
            ${verboseWriter} = "${niCallingVarNames} | Out-File -FilePath '${outFile}' -Encoding Unicode${verboseNoNewline}"
        } else {
            ${verboseExtraNewline} = ''
            switch (${streamNum}) {
                1 {
                    ${verboseWriter} = 'Write-Output'
                    ${verboseColors} = ''
                    if (${extraNewline}) { ${verboseExtraNewLine} = "`n${verboseWriter} ''" }
                }
                6 {
                    ${verboseWriter} = 'Write-Host'
                    ${verboseColors} = (
                        "`n"+
                        ${Script:RuntimeTable}.Verbose.Indent+"-BackgroundColor ${backgroundColor}`n"+
                        ${Script:RuntimeTable}.Verbose.Indent+"-ForegroundColor ${foregroundColor}"
                    )
                    if (${extraNewline}) { ${verboseExtraNewLine} = "`n${verboseWriter} ''" }
                }
            }
            ${verboseWriter} += (
                "`n"+
                ${Script:RuntimeTable}.Verbose.Indent+"${niCallingVarNames}"+
                "${verboseColors}"+
                "${verboseNoNewline}"+
                "${verboseExtraNewLine}"
            )
        }
        Do-Process-Non-Interactive `
            "${niCallingFunction}" `
            "${verboseWriter}" `
            (
                "Where ${niCallingVarNames} is...`n"+
                ( Do-Get-Quoted 'Divider.Upper' 'CONTENT BEGIN' -nl )+
                "${textOutput}`n"+
                ( Do-Get-Quoted 'Divider.Lower' 'CONTENT CLOSE'     )
            ) `
            -exitCode ${niExitCode}

    ##### Else if ${niActive} is False, proceed with normal output...
    } else {
        ##### If ${outFile} is defined, write ${textOutput} to it...
        if (${outFile}) {
            ${verboseOutFile} = ( Do-Get-Quoted 'Auto' "${outFile}" )
            Do-Processing `
                $(if (${Script:RuntimeTable}.Verbose.InDebugMode) { 3 } else { 1 }) `
                "${funcName}" `
                "ACTION ${niCallingVarNames} | Out-File -FilePath ${verboseOutFile} -Encoding Unicode${verboseNoNewline}..."

            if (-not ${Script:RuntimeTable}.Verbose.InDebugMode) {
                try {
                    if (${noNewline}) {
                        "${textOutput}" | Out-File -FilePath ${outFile} -Encoding Unicode -NoNewline
                    } else {
                        "${textOutput}" | Out-File -FilePath ${outFile} -Encoding Unicode
                    }
                    Do-Output-Feedback "Output written to:${verboseOutFile}" -success
                } catch {
                    if (${niCallingFunction}) { ${errorCallFunc} = "${niCallingFunction}" } else { ${errorCallFunc} = "${funcName}" }
                    Do-Output-Error `
                        -errorMessage    "Output to file:${verboseOutFile}" `
                        -exception       "$(${_}.Exception.Message)"        `
                        -callingFuncName "${errorCallFunc}"
                }
            }

        ##### Else if ${outFile} is undefined, use Write-Host to send ${textOutput} to the console...
        } else {
            switch (${streamNum}) {
                ##### If ${streamNum} is 1, use Write-Output...
                1 {
                    if (${noNewline}) {
                        Write-Output "${textOutput}" -NoNewline
                    } else {
                        Write-Output "${textOutput}"
                    }
                    if (${extraNewline}) {
                        Write-Output ''
                    }
                } # END of 1 {}
                ##### If${streamNum} is 6, use Write-Host...
                6 {
                    if (${noNewline}) {
                        Write-Host `
                            "${textOutput}"                     `
                            -BackgroundColor ${backgroundColor} `
                            -ForegroundColor ${foregroundColor} `
                            -NoNewline
                    } else {
                        Write-Host `
                            "${textOutput}"                     `
                            -BackgroundColor ${backgroundColor} `
                            -ForegroundColor ${foregroundColor}
                    }
                    ##### This is done separately from above, so it doesn't inherit the colors.
                    if (${extraNewline}) {
                        Write-Host ''
                    }
                ##### Else, no other streams are supported, so only 1 or 6 are valid above.
                } # END of 6 {}
            } # END of switch (${streamNum}) {}
        } # END of if (${outFile}) {} else {}
    } # END of if (${niActive}) {} else {}
} # END of function Do-Output-Write


function Do-Process-Array ([Int]${processLevel}, [String]${processPrefix}, [String]${arrayTitle}, ${arrayList}, [Int]${arrayLevel}) {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Part of the Verbose set of functions.
#  • If ${Script:RuntimeTable}.Verbose.Level is less than the processing level integer, simply do nothing by returning.
#  • Otherwise...
#    • Convert the arrayList to text.
#    • Call the Do-Processing function with the data.
#
# Returns:
#  • Nothing                — if ${Script:RuntimeTable}.Verbose.Level<${processLevel}.
#  • [String]${arrayAsText} — when ${arrayLevel}>0.
#  • via Do-Processing         — when ${arrayLevel}=0.
#
# Usage:
#  • Parameter 1 — ${processLevel}:  Integer      — the number where ${Script:RuntimeTable}.Verbose.Level is at or above to activate this function.
#  • Parameter 2 — ${processPrefix}: String       — the prefix title preceeding ${processTitle}.
#  • Parameter 3 — ${arrayTitle}:    String       — the title of the array being processed.
#  • Parameter 4 — ${arrayList}:     String Array — the array being processed.
#  • Parameter -arrayLevel:          Integer      — if used, return the raw result, indented (${arrayLevel}+1) times, instead of through Do-Processing.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Do-Get-Padded
#    • Do-Get-Quoted
#    • Do-Get-Var-Quoted
#    • Do-Processing
#####
    if (${Script:RuntimeTable}.Verbose.Level -lt ${processLevel}) { return }
    if (${arrayLevel} -lt 0) { ${arrayLevel} = 0 }

    ${arrayProcessed} = @()
    ${indexPadWidth}  = (${arrayList}.Length - 1).ToString().Length
    ${typePadWidth}   = 1
    ${arrayIndex}     = -1

    ##### First iterate to find ${typePadWidth}...
    foreach (${arrayValue} in ${arrayList}) {
        if (${arrayValue} -eq ${Null}) {
            ${valueType} = ${Script:RuntimeTable}.Verbose.NullString
        } else {
            ${valueType} = ${arrayValue}.GetType().Name
        }
        if (${valueType}.Length -gt ${typePadWidth}) { ${typePadWidth} = ${valueType}.Length }
    } # END of foreach (${arrayValue} in ${arrayList}) {}

    ##### Next iterate to build ${arrayProcessed}...
    foreach (${arrayValue} in ${arrayList}) {
        ${arrayIndex}++
        if (${arrayValue} -eq ${Null}) {
            ${arrayValue} = ''
            ${valueType}  = ${Script:RuntimeTable}.Verbose.NullString
        } else {
            ${valueType}  = ${arrayValue}.GetType().Name
        }
        if (${valueType} -eq 'String') { ${quoteKey} = 'Auto' } else { ${quoteKey} = 'None' }
        ${arrayProcessed} += (
            Do-Get-Var-Quoted `
                (${arrayLevel}+1) `
                ( Do-Get-Quoted 'Brackets.Square' ( Do-Get-Padded "${arrayIndex}" ${indexPadWidth} ) ) `
                0 `
                "${quoteKey}" `
                "${arrayValue}" `
                -noBrackets `
                -varType ( Do-Get-Padded "${valueType}" ${typePadWidth} )
        )
    } # END of foreach (${arrayValue} in ${arrayList}) {}

    if (${arrayProcessed}.Length -gt 0) {
        ${arrayAsText} = ${arrayProcessed} -Join "`n"
    } else {
        ${arrayAsText} = ''
    }

    if (${arrayLevel}) {
        return ${arrayAsText}
    } else {
        Do-Processing `
            -processLevel   ${processLevel}   `
            -processPrefix "${processPrefix}" `
            -processTitle  "${arrayTitle}"    `
            -processValue  "${arrayAsText}"
    }
} # END of function Do-Process-Array


function Do-Process-Debug {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Part of the Verbose set of functions.
#  • If ${doIt} is False, simply do nothing by returning.
#  • Otherwise...
#    • Where ${indexTable}...
#      • .ColorBg = 0
#      • .ColorFg = 1
#      • .PrTitle = 2
#    • If ${debugArray}.Length is 0 (i.e. undefined), use a default 2-element array.
#    • If ${debugIndex} exceeds the max index of ${debugArray}...
#      • Set ${processTitle} to "debugIndex=${debugIndex}".
#      • Then set ${debugIndex} to...
#        • If there are at least 2 elements, alternate between odds (0) & evens (1).
#        • If only 1 element, always use 0.
#    • Otherwise, set ${processTitle} to ${debugArray}[${indexTable}.PrTitle][${debugIndex}].
#    • Set ${backgroundColor} to         ${debugArray}[${indexTable}.ColorBg][${debugIndex}].
#    • Set ${foregroundColor} to         ${debugArray}[${indexTable}.ColorFg][${debugIndex}].
#    • If ${processValue} is an empty string, set it to ${Script:RuntimeTable}.Verbose.NullString.
#    • Call the Do-Processing function with...
#      -processLevel    0
#      -processPrefix   "${callingFuncName}"
#      -processTitle    "${processTitle}"
#      -processValue    "${processValue}"
#      -backgroundColor "${backgroundColor}"
#      -foregroundColor "${foregroundColor}"
#      -extraNewline    ${extraNewline}
#
# Returns:
#  • Nothing        — if ${doIt} is False.
#  • via Do-Processing — if ${doIt} is True.
#
# Usage:
#  • Parameter 1 -doIt            Boolean (REQUIRED) — a boolean passed in from the calling function indicating whether or not to activate.
#  • Parameter 2 -callingFuncName String  (REQUIRED) — the name of the calling function.
#  • Parameter 4 -debugIndex      Integer (REQUIRED) — the 2nd dimension index number to use for ${debugArray}.
#  • Parameter 3 -debugArray      2D String Array    — an array of the form (2nd dimension # of elements dependent on the calling function)...
#    • Array [0] = ColorBg0, ..., ColorBgN
#    • Array [1] = ColorFg0, ..., ColorFgN
#    • Array [2] = PrTitle0, ..., PrTitleN
#  • Parameter 5 -processValue    String             — the detailed list of value(s) to output.
#  • Parameter 6 -extraNewline    Switch             — whether or not to write an additional newline at the end.
#
# Dependencies:
#  • Functions...
#    • Do-Processing
#####
    param (
        [Parameter(Mandatory=${True} )][Bool        ]${doIt},
        [Parameter(Mandatory=${True} )][String      ]${callingFuncName},
        [Parameter(Mandatory=${True} )][Int         ]${debugIndex},
        [Parameter(Mandatory=${False})][String[][][]]${debugArray},
        [Parameter(Mandatory=${False})][String      ]${processValue}='',
        [Parameter(Mandatory=${False})][Switch      ]${extraNewline}
    )
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    if (-not ${doIt}) { return }

    ${indexTable} = @{
        ColorBg = 0
        ColorFg = 1
        PrTitle = 2
    }
    ##### If ${debugArray} is undefined, setup a basic Null array, so the next if condition is possible...
    if (${debugArray} -eq ${Null}) {
        Do-Processing 2 "${funcName}" '${debugArray} is undefined, using a default.'
        ${debugArray} = @( @(), @(), @() )
        ${arrayReset} = ${True}
    } else {
        ${arrayReset} = ${False}
    }
    ##### If ${debugArray} has no elements for ${debugIndex}, define a 2-element default...
    if (
        ${debugArray}[${indexTable}.ColorBg][${debugIndex}] -eq ${Null} -or
        ${debugArray}[${indexTable}.ColorFg][${debugIndex}] -eq ${Null} -or
        ${debugArray}[${indexTable}.PrTitle][${debugIndex}] -eq ${Null}
    ) {
        if (-not ${arrayReset}) {
            Do-Processing 2 "${funcName}" "`${debugArray} has no elements for `${debugIndex}=${debugIndex}, using a default."
        }
        ##### [0]       , [1]
        ${debugArray} = @(
            @('DarkCyan', 'Cyan'  ),
            @('Black'   , 'Black' ),
            @('BEFORE'  , 'SCOPED')
        )
    }
    ${processTitle}  = ${Null}
    ${debugMaxIndex} = ( ${debugArray}.Length - 1 )
    ##### If ${debugIndex} is larger than ${debugMaxIndex}...
    if (${debugIndex} -gt ${debugMaxIndex}) {
        Do-Processing 2 "${funcName}" "`${debugIndex}=${debugIndex} exceeds `${debugArray} size=${debugMaxIndex}."
        ${processTitle} = "debugIndex=${debugIndex}"
        ##### If there are at least 2 elements in the array...
        if (${debugMaxIndex} -gt 0) {
            ##### Alternate odds & evens...
            if ((${debugIndex} % 2) -eq 0) {
                Do-Processing 2 "${funcName}" '${debugIndex} is even, so defaulting to 0.'
                ${debugIndex} = 0
            } else {
                Do-Processing 2 ":${funcName}" '${debugIndex} is odd, so defaulting to 1.'
                ${debugIndex} = 1
            }
        ##### If there's only 1 element in the array, just use that one...
        } else {
            Do-Processing 2 "${funcName}" '${debugIndex} defaulting to 0.'
            ${debugIndex} = 0
        }
    }
    if (${processTitle} -eq ${Null}) {
        ${processTitle}    = ${debugArray}[${indexTable}.PrTitle][${debugIndex}]
    }
        ${backgroundColor} = ${debugArray}[${indexTable}.ColorBg][${debugIndex}]
        ${foregroundColor} = ${debugArray}[${indexTable}.ColorFg][${debugIndex}]
    if (${processValue} -eq '') {
        ${processValue}    = ${Script:RuntimeTable}.Verbose.NullString
    }


    #####
    # Since the ${doIt} condition determines whether or not this function activates, use -processLevel 0 here...
    #####
    Do-Processing `
        -processLevel    0                    `
        -processPrefix   "${callingFuncName}" `
        -processTitle    "${processTitle}"    `
        -processValue    "${processValue}"    `
        -backgroundColor "${backgroundColor}" `
        -foregroundColor "${foregroundColor}" `
        -extraNewline    ${extraNewline}
} # END of function Do-Process-Debug


function Do-Process-Exit ([Int]${exitCode}=0, [String]${processPrefix}='', [String]${exitKey}='E0Good') {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Part of the Verbose set of functions and necessary to exit with ${exitCode} from the script.
#  • Calls the Do-Processing function at level 1 for Verbose output and then exits.
#
# Returns:
#  • via Do-Processing   — in all cases; then
#  • exit ${exitCode} — in all cases.
#
# Usage:
#  • Parameter 1 — ${exitCode}:      Integer — [Default=0 ] the exit code to use when exiting from the script, and this is range checked...
#    • As a failsafe...
#      • If ${exitCode}<0,   it defaults to 0.
#      • If ${exitCode}>255, it defaults to 255.
#  • Parameter 2 — ${processPrefix}: String  — [Default=''] the prefix title to pass to the Do-Processing function.
#  • Parameter -exitKey:             String  — [Default='E0Good'] in lieu of an ${exitCode}, use ${Script:RuntimeTable}.ExitStatus.${exitKey}.
#
# Dependencies:
#  • Functions...
#    • Do-Processing
#####
    ##### If ${exitKey} is defined, get ${exitCode} from ${Script:RuntimeTable}.ExitStatus.${exitKey}...
    if (-not [String]::IsNullOrWhitespace(${exitKey})) { ${exitCode} = ${Script:RuntimeTable}.ExitStatus.${exitKey} }
    ##### Range-check ${exitCode}...
    if (${exitCode} -lt 0) { ${exitCode} = 0 } elseif (${exitCode} -gt 255) { ${exitCode} = 255 }
    ##### Give the final Do-Processing message...
    Do-Processing `
        -processLevel   1                 `
        -processPrefix "${processPrefix}" `
        -processTitle  "exit ${exitCode}" `
        -isLast
    ##### Exit with ${exitCode}...
    exit ${exitCode}
} # END of function Do-Process-Exit


function Do-Process-Non-Interactive {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Part of the Verbose set of functions.
#  • Calls the Do-Processing function at level ${Script:RuntimeTable}.NonInteractive.Verbose.Level for Verbose output.
#  • If ${exitCode}>0, it then exits with that code.
#
# Returns:
#  • via Do-Processing   — if...
#    • ${Script:RuntimeTable}.NonInteractive.Verbose.IsTrue is True AND/OR
#    • ${Script:RuntimeTable}.Verbose.Level>${Script:RuntimeTable}.NonInteractive.Verbose.Level; then
#  • via Do-Process-Exit — if ${exitCode}>0.
#
# Usage:
#  • Parameter 1 — ${processPrefix}: String  — the name of the calling function to pass to the Do-Processing function for Verbose output.
#  • Parameter 2 — ${processTitle}:  String  — the title message to pass to the Do-Processing function for Verbose output.
#    • This will always be prepended with "-NonInteractive SKIPPING:".
#  • Parameter 3 — ${processValue}:  String  — [Default=''] the value it would have processed outside of -NonInteractive mode.
#  • Parameter 4 — ${exitCode}:      Integer — [Default=${Script:RuntimeTable}.ExitStatus.E4NIMR] exit with this code if >0.
#  • Parameter -exitKey:             String  — [Default=''] in lieu of an ${exitCode}, use ${Script:RuntimeTable}.ExitStatus.${exitKey}.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Do-Process-Exit
#    • Do-Processing
#####
    param (
        [String]${processPrefix},
        [String]${processTitle},
        [String]${processValue}='',
        [Int   ]${exitCode}=${Script:RuntimeTable}.ExitStatus.E4NIMR,
        [String]${exitKey}='E4NIMR'
    )

    ##### If ${exitKey} is defined, get ${exitCode} from ${Script:RuntimeTable}.ExitStatus.${exitKey}...
    if (-not [String]::IsNullOrWhitespace(${exitKey})) { ${exitCode} = ${Script:RuntimeTable}.ExitStatus.${exitKey} }

    ##### If one of these conditions is True...
    if (
        ${Script:RuntimeTable}.NonInteractive.Verbose.IsTrue -or
        ${Script:RuntimeTable}.Verbose.Level -ge ${Script:RuntimeTable}.NonInteractive.Verbose.Level
    ) {
        #####
        # Write a verbose message to the console...
        #  • Use -processLevel 0 here, so it always fires.
        #####
        Do-Processing `
            -processLevel  0                                        `
            -processPrefix "${processPrefix}"                       `
            -processTitle  "In -NonInteractive mode CANNOT PROCESS" `
            -processValue  "${processTitle}${processValue}"         `
            -thisIsAnNiMessage
    }

    ##### If ${exitCode}>0, then exit with that code...
    if (${exitCode}) { Do-Process-Exit ${exitCode} "${processPrefix}" }
} # END of function Do-Process-Non-Interactive


function Do-Process-Params ([Int]${processLevel}, [String]${processPrefix}, [String]${processScope}) {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Part of the Verbose set of functions.
#  • If ${Script:RuntimeTable}.Verbose.Level is less than the processing level integer, simply do nothing by returning.
#  • Otherwise...
#    • Get the parameter list of names & values from ${Script:RuntimeTable}.Parameters.
#    • Call the Do-Processing function with the data.
#
# Returns:
#  • Nothing        — if ${Script:RuntimeTable}.Verbose.Level<${processLevel}.
#  • via Do-Processing — otherwise.
#
# Usage:
#  • Parameter 1 — ${processLevel}:  Integer — the processing level integer.
#  • Parameter 2 — ${processPrefix}: String  — the prefix title preceeding ${processTitle}.
#  • Parameter 3 — ${processScope}:  String  — the processing scope word or phrase.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Do-Get-Vars
#    • Do-Processing
#####
    if (${Script:RuntimeTable}.Verbose.Level -lt ${processLevel}) { return }

    Do-Processing `
        -processLevel   ${processLevel}             `
        -processPrefix "${processPrefix}"           `
        -processTitle  "Parameters ${processScope}" `
        -processValue  ( Do-Get-Vars ${Script:RuntimeTable}.Parameters )
} # END of function Do-Process-Params


function Do-Process-Table {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Part of the Verbose set of functions.
#  • If ${Script:RuntimeTable}.Verbose.Level is less than the processing level integer, simply do nothing by returning.
#  • Otherwise...
#    • Convert the table to text.
#    • Call the Do-Processing function with the data.
#
# Returns:
#  • Nothing                — if ${Script:RuntimeTable}.Verbose.Level<${processLevel}.
#  • via Do-Processing         — if ${tableLevel}=1.
#  • [String]${arrayAsText} — if ${tableLevel}>1.
#
# Usage:
#  • Parameter 1 — ${processLevel}:  Integer (REQUIRED) — the number where ${Script:RuntimeTable}.Verbose.Level is at or above to activate this function.
#  • Parameter 2 — ${processPrefix}: String  (REQUIRED) — the prefix title preceeding ${processTitle}.
#  • Parameter 3 — ${tableTitle}:    String  (REQUIRED) — the title of the table being processed.
#  • Parameter 4 — ${tableVar}:      Object  (REQUIRED) — the table being processed.
#    • This parameter is of type Object, because it could be one of these types, which all work the same...
#      • HashTable
#      • Ordered
#      • PSCustomObject
#  • Parameter 5 — ${onlyThisKey}:   [untyped]          — if used, only return this key and its value.
#  • Parameter 6 -tableLevel         Integer            — [Default=1] if used, the indent level to use.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Do-Get-Var-Quoted
#    • Do-Get-Vars
#    • Do-Output-Warning
#    • Do-Process-Array
#    • Do-Process-Table
#    • Do-Processing
#####
    param(
        [Int   ]${processLevel},
        [String]${processPrefix},
        [String]${tableTitle},
        [Object]${tableVar},
                ${onlyThisKey},
        [Int   ]${tableLevel}=1
    )
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    if (${Script:RuntimeTable}.Verbose.Level -lt ${processLevel}) { return }

    if ([String]::IsNullOrWhitespace(${processPrefix})) { Do-Output-Undefined-Error "${funcName}" 'processPrefix' 'String' }
    if ([String]::IsNullOrWhitespace(${tableTitle})   ) { Do-Output-Undefined-Error "${funcName}" 'tableTitle'    'String' }
    if ([String]::IsNullOrWhitespace(${tableVar})     ) { Do-Output-Undefined-Error "${funcName}" 'tableVar'      'Object' }

    if (${tableLevel} -lt 1) { ${tableLevel} = 1 }


    #####─────Begin:(Local Helper Functions)─────
    function Get-Keys ([Object]${tableVar}, [String]${funcName}) {
        ${tableTypes} = @('hashtable','ordered','pscustomobject')
        if (${tableVar} -eq ${Null}) {
            ${inputType} = ''
        } else {
            ${inputType} = ${tableVar}.GetType().Name
        }
        ${tableKeys} = @()
        if (${inputType}.ToLower() -In ${tableTypes}) {
            if (${inputType}.ToLower() -eq 'pscustomobject') {
                ${tableKeys} = ${tableVar}.PSObject.Properties.Name
            } else {
                ${tableKeys} = ${tableVar}.Keys
            }
        } else {
            Do-Output-Warning (
                "${funcName}:"+
                ( Do-Get-Var-Quoted 0 'tableVar' 0 'Auto' "${tableVar}" )+
                ' of type '+
                ( Do-Get-Quoted 'Auto' "${inputType}" )+
                ' is not the required type of HashTable, Ordered, or PSCustomObject.'
            )
        }
        return ${tableKeys}
    } # END of function Get-Keys

    function Get-Type-Width ([Object]${tableVar}, [String[]]${keyList}) {
        ${maxPadWidth} = 1
        foreach (${level1Key} in ${keyList}) {
            ${tableValue} = ${tableVar}.${level1Key}
            if (${tableValue} -eq ${Null}) {
                ${valueType} = ${Script:RuntimeTable}.Verbose.NullString
            } else {
                ${valueType} = ${tableValue}.GetType().Name
            }
            if (${valueType}.Length -gt ${maxPadWidth}) { ${maxPadWidth} = ${valueType}.Length }
        } # END of foreach (${level1Key} in ${keyList}) {}
        return ${maxPadWidth}
    } # END of function Get-Type-Width
    #####─────EndOf:(Local Helper Functions)─────


    ${doSingle}        = (-not [String]::IsNullOrWhitespace(${onlyThisKey}))
    ${keyList}         = Get-Keys ${tableVar} "${funcName}" | Sort-Object
    ${keyIndentBefore} = ${Script:RuntimeTable}.Verbose.Indent * ${tableLevel}
    ${tableTypes}      = @('hashtable','ordered','pscustomobject')

    ${arrayAsText} = ''
    if (${keyList}) {
        ${keysPadWidth} = (${keyList} | ForEach-Object { ${_}.Length } | Measure-Object -Maximum).Maximum
        ${typePadWidth} = ( Get-Type-Width ${tableVar} ${keyList} )

        ${arrayProcessed} = foreach (${level1Key} in ${keyList}) {
            if (${doSingle}) {
                if (${level1Key} -ne ${onlyThisKey}) { continue } # to the next item in this foreach loop
            }
            ${tableValue} = ${tableVar}.${level1Key}
            if (${tableValue} -eq ${Null}) {
                ${tableValue} = ''
                ${valueType}  = ${Script:RuntimeTable}.Verbose.NullString
            } else {
                ${valueType}  = ${tableValue}.GetType().Name
            }


            ##### If this value is type Object[] (Array)...
            if (${valueType}.ToLower() -eq 'object[]') {
                ${valueType} = 'Array'
                ${subResult} = Do-Process-Array `
                     ${processLevel}          `
                    "${processPrefix}"        `
                    ''                        `
                     ${tableVar}.${level1Key} `
                     ${tableLevel}

                if (${subResult} -eq '') { ${multiline} = ${False} } else { ${multiline} = ${True} }
                ${level1Key} = ( Do-Get-Padded "${level1Key}" ${keysPadWidth} )
                ${valueType} = ( Do-Get-Padded "${valueType}" ${typePadWidth} )

                ( Do-Get-Var-Quoted `
                     ${tableLevel}          `
                    "${level1Key}"          `
                     0                      `
                    'Array'                 `
                    "${subResult}"          `
                    -noBrackets             `
                    -multiline ${multiline} `
                    -varType  "${valueType}"
                )

            ##### Else if this value is type ParameterMetadata[]...
            } elseif (${valueType}.ToLower() -eq 'parametermetadata[]') {
                ${subResult} = Do-Get-Vars `
                    -getVarsObject ${tableVar}.${level1Key} `
                    -getVarsLevel (${tableLevel}+1)

                if (${subResult} -eq '') { ${multiline} = ${False} } else { ${multiline} = ${True} }
                ${level1Key} = ( Do-Get-Padded "${level1Key}" ${keysPadWidth} )
                ${valueType} = ( Do-Get-Padded "${valueType}" ${typePadWidth} )

                ( Do-Get-Var-Quoted `
                     ${tableLevel}          `
                    "${level1Key}"          `
                    0                       `
                    'HashTable'             `
                    "${subResult}"          `
                    -noBrackets             `
                    -multiline ${multiline} `
                    -varType  "${valueType}"
                )

            ##### Else if this value is a type in ${tableTypes}...
            } elseif (${valueType}.ToLower() -In ${tableTypes}) {
                ##### Recurse to the next level...
                ${subResult} = Do-Process-Table `
                     ${processLevel}          `
                    "${processPrefix}"        `
                    "${tableTitle}"           `
                     ${tableVar}.${level1Key} `
                     ${onlyThisKey}           `
                    (${tableLevel}+1)

                if (${subResult} -eq '') { ${multiline} = ${False} } else { ${multiline} = ${True} }
                ${level1Key} = ( Do-Get-Padded "${level1Key}" ${keysPadWidth} )
                ${valueType} = ( Do-Get-Padded "${valueType}" ${typePadWidth} )

                ( Do-Get-Var-Quoted `
                     ${tableLevel}          `
                    "${level1Key}"          `
                     0                      `
                    'HashTable'             `
                    "${subResult}"          `
                    -noBrackets             `
                    -multiline ${multiline} `
                    -varType  "${valueType}"
                )

            ##### Else if this value is any other type...
            } else {
                ##### This is an individual item...
                if (${valueType} -eq 'String') { ${quoteKey} = 'Auto' } else { ${quoteKey} = 'None' }
                ${level1Key} = ( Do-Get-Padded "${level1Key}" ${keysPadWidth} )
                ${valueType} = ( Do-Get-Padded "${valueType}" ${typePadWidth} )

                ( Do-Get-Var-Quoted `
                     0                      `
                    "${level1Key}"          `
                     0                      `
                    "${quoteKey}"           `
                    "${tableValue}"         `
                    -noBrackets             `
                    -varType "${valueType}" `
                    -prefix  "${keyIndentBefore}"
                )
            } # END of if {} elseif {} elseif {} else {}
        } # END of ${arrayProcessed} = foreach (${level1Key} in ${keyList}) {}
        ${arrayAsText} = ${arrayProcessed} -Join "`n"
    } else {
        ${tableTitle} += ' — TABLE IS EMPTY.'
    } # END of if (${keyList}) {} else {}

    if (${tableLevel} -eq 1) {
        if (${doSingle}) {
            Do-Processing `
                -processLevel   ${processLevel}              `
                -processPrefix "${processPrefix}"            `
                -processTitle  "${tableTitle}${arrayAsText}"
        } else {
            if (-not ${keyList}) { ${arrayAsText} = (${Script:RuntimeTable}.Verbose.Indent+${Script:RuntimeTable}.Verbose.NullString) }
            ${arrayAsText} = "{`n${arrayAsText}`n}"
            Do-Processing `
                -processLevel   ${processLevel}   `
                -processPrefix "${processPrefix}" `
                -processTitle  "${tableTitle}"    `
                -processValue  "${arrayAsText}"
        }
    } else {
        return ${arrayAsText}
    }
} # END of function Do-Process-Table


function Do-Processing {
#####
# Preamble:
#  • This is one of the Do-* set of functions, so named because they are core functions for multiple scripts to use.
#
# Purpose:
#  • Part of the Verbose set of functions, and it's responsible for formatting all verbose, debug, or feedback messages, as follows.
#  • If ${Script:RuntimeTable}.Verbose.Level is less than ${processLevel}, simply do nothing by returning.
#  • Otherwise...
#    • If ${processPrefix}, ${processTitle}, and ${processValue} are all Null or Empty, it simply writes an empty string.
#    • Otherwise...
#      • If ${processPrefix} is 'Feedback', it sets ${processFeedback}=${True}; ${processPrefix}=''; ${streamWord}='Output'.
#      • Otherwise...
#        • It sets ${streamWord}='Verbose'.
#        • If ${processPrefix} is not empty, it appends ':' to it.
#        • It then prepends 'Processing:' to it.
#        • If ${processLevel}>2, it appends 'DEBUG-SKIPPING:' to it.
#        • If -Continuation and ${processPrefix} is not empty, it replaces the prefix with an equal number of spaces.
#    • It then sets ${processMessage} to "${processPrefix}${processTitle}".
#    • If ${processValue} is defined, it sets ${processMessage} in the form...
#      (
#          "${processMessage}"+( Do-Get-Quoted 'Divider.Upper' 'CONTENT BEGIN' )
#          "${processValue}`n"+
#          "${processMessage}"+( Do-Get-Quoted 'Divider.Lower' 'CONTENT CLOSE' )
#      )
#    • It then uses...
#        Do-Output-Write
#            -textOutput        "${processMessage}"
#            -streamWord        "${streamWord}"
#            -backgroundColor   ${Script:RuntimeTable}.Verbose.ColorBG.${processLevel}
#            -foregroundColor   ${Script:RuntimeTable}.Verbose.ColorFG.${processLevel}
#            -extraNewline      ${extraNewline}
#            -niCallingFunction "${funcName}"
#            -niCallingVarNames "`"`${processMessage}`""
#            -niExitKey         'E0Good'
#
# Returns:
#  • via Do-Output-Error  — if ${processLevel}<0 or >3.
#  • Nothing           — if ${Script:RuntimeTable}.Verbose.Level<${processLevel}.
#  • via Do-Output-Write — otherwise.
#
# Usage:
#  • Parameter 1 — ${processLevel}:  Integer — [Default=3 ] the number at or above which ${Script:RuntimeTable}.Verbose.Level must be to activate this.
#    • Only 3 levels of verbosity are currently defined (1-3), with 3 indicating it's a DEBUG-SKIPPING statement.
#    • Additionally, if 0, it will always activate this function.
#      • If used for feedback, you must also use -processPrefix 'Feedback' to avoid the usual Verbose mode prefix.
#    • If <0 or >3, it triggers an E3Code error.
#  • Parameter 2 — ${processPrefix}: String  — [Default=''] see above for how this is used.
#  • Parameter 3 — ${processTitle}:  String  — [Default=''] see above for how this is used.
#  • Parameter 4 — ${processValue}:  String  — [Default=''] see above for how this is used.
#  • Parameter 5 — ${extraNewline}:  Boolean — value passed directly into the Do-Output-Write function.
#  • Parameter -Continuation:        Switch  — if used, omits the entire prefix and indents an equal number of spaces instead.
#  • Parameter -noPrefix:            Switch  — if used, omits the entire prefix and does not indent.
#  • Parameter -isFirst:             Switch  — this should only be used once on the very first call to this function...
#    • Parameters -isFirst and -isLast are mutually exclusive, and if they're used together results in an E3Code error.
#    • If used, prepends the following, relative to ${processMessage}...
#      • an extra newline before to set it apart from the CLI prompt,
#      • an introduction message in a box to make it very visible where Verbose output started, and
#      • an extra newline after to set it apart from the Verbose output.
#  • Parameter -isLast:              Switch  — this should only be used once on the very last call in function Do-Process-Exit...
#    • Parameters -isFirst and -isLast are mutually exclusive, and if they're used together results in an E3Code error.
#    • If used, appends the following, relative to ${processMessage}...
#      • an extra newline before to set it apart from the Verbose output,
#      • a conclusion message in a box to make it very visible where Verbose output ended, and
#      • an extra newline after to set it apart from the CLI prompt.
#  • Parameter -thisIsAnNiMessage:   Switch  — if used, indicates that this is coming from the Do-Process-Non-Interactive function.
#  • Parameter -backgroundColor:     String  — override the default BackgroundColor, which is normally
#     ${Script:RuntimeTable}.Verbose.ColorBG.${processLevel}.
#  • Parameter -foregroundColor:     String  — override the default ForegroundColor, which is normally
#     ${Script:RuntimeTable}.Verbose.ColorFG.${processLevel}.
#  • Parameter -nl:                  Switch  — if used, start ${processTitle} on a new line.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Do-Draw-Box
#    • Do-Get-Quoted
#    • Do-Output-Error
#    • Do-Output-Write
#####
    param(
        [Int]   ${processLevel}=3,
        [String]${processPrefix}='',
        [String]${processTitle}='',
        [String]${processValue}='',
        [Bool  ]${extraNewline},
        [Switch]${Continuation},
        [Switch]${noPrefix},
        [Switch]${isFirst},
        [Switch]${isLast},
        [Switch]${thisIsAnNiMessage},
        [String]${backgroundColor},
        [String]${foregroundColor},
        [Switch]${nl}
    )
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    if (${processLevel} -lt 0 -or ${processLevel} -gt 3) {
        Do-Output-Error `
            -errorMessage    "Required parameter [Int]`${processLevel}=${processLevel} is out of range 0-3." `
            -callingFuncName "${funcName}" -exitKey 'E3Code'
    }
    if (${isFirst} -and ${isLast}) {
        Do-Output-Error `
            -errorMessage    'Switch parameters -isFirst and -isLast are mutually exclusive and cannot be used together.' `
            -callingFuncName "${funcName}" -exitKey 'E3Code'
    }

    if (${Script:RuntimeTable}.Verbose.Level -lt ${processLevel}) { return }

    ${streamWord} = 'Verbose'
    if (${processPrefix} -eq '' -and ${processTitle} -eq '' -and ${processValue} -eq '') {
        ${processMessage} = ''
    } else {
        ##### Determine the proper ${processPrefix}...
        if (${noPrefix}) {
                ${processPrefix} = ''
        } else {
            if (${processPrefix} -eq 'Feedback') {
                ${processFeedback} = ${True}
                ${processPrefix}   = ''
                ${streamWord}      = 'Output'
            } else {
                if (${processPrefix} -ne '') { ${processPrefix} += ':' }
                ${processPrefix} = "Processing:${processPrefix}"
                if (${processLevel} -gt 2)   { ${processPrefix} += 'DEBUG-SKIPPING:' }
            }
            if (${Continuation} -and ${processPrefix}.Length -gt 0) { ${processPrefix} = ' ' * (${processPrefix}.Length) }
        }

        ##### Assemble ${processMessage}...
        if (${nl}) { ${processTitle} = "`n${processTitle}" }
        ${processMessage} = "${processPrefix}${processTitle}"

        ##### If ${processValue} is defined...
        if (-not [String]::IsNullOrWhitespace(${processValue})) {
            ${processMessage} = (
                "${processMessage}"+( Do-Get-Quoted 'Divider.Upper' 'CONTENT BEGIN' -nl )+
                "${processValue}`n"+
                "${processMessage}"+( Do-Get-Quoted 'Divider.Lower' 'CONTENT CLOSE'     )
            )
        }
    } # END of if (${processPrefix} -eq '' -and ${processTitle} -eq '' -and ${processValue} -eq '') {} else {}


    #####
    # If -isFirst, prepend...
    #  • an extra newline before to set it apart from the CLI prompt,
    #  • an introduction message in a box to make it very visible where Verbose output started, and
    #  • an extra newline after to set it apart from the Verbose output.
    #####
    if (${isFirst}) {
        ${textString} = Do-Draw-Box `
            -textString ('RUNNING '+${Script:RuntimeTable}.Basename) `
            -textPrefix ${Script:RuntimeTable}.Verbose.Indent        `
            -textPadAll 1 -nl
        ${processMessage} = "`n${textString}`n${processMessage}"
    }
    #####
    # If -isLast, append...
    #  • an extra newline before to set it apart from the Verbose output,
    #  • a conclusion message in a box to make it very visible where Verbose output ended, and
    #  • an extra newline after to set it apart from the CLI prompt.
    #####
    if (${isLast}) {
        ${textString} = Do-Draw-Box `
            -textString 'The End'                             `
            -textPrefix ${Script:RuntimeTable}.Verbose.Indent `
            -textPadAll 1 -nl
        ${processMessage} = "${processMessage}`n${textString}`n"
    }


    #####
    # Write ${processMessage} using...
    #  • ${Script:RuntimeTable}.Verbose.ColorBG.${processLevel}
    #  • ${Script:RuntimeTable}.Verbose.ColorFG.${processLevel}
    #####
    # • Since this isn't an error, always use -niExitKey 'E0Good'.
    #####

    if (${thisIsAnNiMessage}) { ${processLevel} = ${Script:RuntimeTable}.NonInteractive.Verbose.Color }
    if (-not ${backgroundColor}) { ${backgroundColor} = ${Script:RuntimeTable}.Verbose.ColorBG.${processLevel} }
    if (-not ${foregroundColor}) { ${foregroundColor} = ${Script:RuntimeTable}.Verbose.ColorFG.${processLevel} }
    Do-Output-Write `
        -textOutput        "${processMessage}"      `
        -streamWord        "${streamWord}"          `
        -backgroundColor   "${backgroundColor}"     `
        -foregroundColor   "${foregroundColor}"     `
        -extraNewline      ${extraNewline}          `
        -niCallingFunction "${funcName}"            `
        -niCallingVarNames "`"`${processMessage}`"" `
        -niExitKey         'E0Good'                 `
        -thisIsAnNiMessage ${thisIsAnNiMessage}
} # END of function Do-Processing


#####
##### END of all Do-* functions.
#####


#####
##### The rest of these functions are unique to this script...
#####

function Format-View-Text {
#####
# Purpose:
#  • Reformat ${Script:EventLogTable}.XmlFormatted to be plain text.
#  • Return it as a String.
#
# Usage:
#  • No parameters (uses ${Script:EventLogTable}.XmlFormatted as input).
#####
    [CmdletBinding()]
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    ${XmlInput} = ${Script:EventLogTable}.XmlFormatted
    ${XmlInput} = ${XmlInput}.TrimStart([Char]0xFEFF).Trim()

    ${xmlDoc} = New-Object System.Xml.XmlDocument
    ${xmlDoc}.PreserveWhitespace = ${False}
    ${xmlDoc}.LoadXml(${XmlInput})

    ${eventElement} = ${xmlDoc}.SelectSingleNode("//*[local-name()='Event']")
    if (-not ${eventElement}) { throw 'No <Event> element found in XML' }
    ${nsUri} = ${eventElement}.NamespaceURI

    ${nsMgr} = New-Object System.Xml.XmlNamespaceManager(${xmlDoc}.NameTable)
    ${nsMgr}.AddNamespace('ev', ${nsUri})

    ${stringBuffer} = New-Object System.Text.StringBuilder
    ${eventList} = ${xmlDoc}.SelectNodes('//ev:Event', ${nsMgr})


    #####─────Begin:(Local Helper Function)─────
    function Add-Node {
    #####
    # Purpose:
    #  • Use built-in XML functionality to add the block as an XML node.
    #  • Append it to ${stringBuffer}.
    #
    # Usage:
    #  • Parameter 1 - ${node}:     XmlNode - an XML block, as type String, reformatted to be an XmlNode.
    #  • Parameter 2 - ${indent}:   Integer - the number of spaces to indent
    #####
        param(
            [System.Xml.XmlNode]${node},
            [Int]${indent} = 0
        )
        if (${node}.NodeType -ne [System.Xml.XmlNodeType]::Element) { return }

        ##### Get the label from the Name attribute or element LocalName...
        if (${node}.Attributes['Name']) {
            ${label} = ${node}.Attributes['Name'].Value
        } else {
            ${label} = ${node}.LocalName
        }

        ##### Collect other attributes...
        ${attrText} = @()
        foreach (${attribute} in ${node}.Attributes) {
            if (${attribute}.Name -ne 'Name') {
                ${attrText} += ('{0}={1}' -f ${attribute}.Name, ${attribute}.Value)
            }
        } # END of foreach (${attribute} in ${node}.Attributes) {}
        ${attrSuffix} = if (${attrText}.Count -gt 0) { ' [' + (${attrText} -join ', ') + ']' } else { '' }

        ##### If element has child elements, recurse...
        if ((${node}.ChildNodes | Where-Object { ${_}.NodeType -eq 'Element' }).Count -gt 0) {
            [Void]${stringBuffer}.AppendLine(('{0}{1}{2}:' -f ('  ' * ${indent}), ${label}, ${attrSuffix}))
            foreach (${child} in ${node}.ChildNodes) {
                Add-Node -node ${child} -indent (${indent} + 1)
            } # END of foreach (${child} in ${node}.ChildNodes) {}
        } else {
            ${value} = ${node}.InnerText
            [Void]${stringBuffer}.AppendLine(('{0}{1}{2}: {3}' -f ('  ' * ${indent}), ${label}, ${attrSuffix}, ${value}))
        }
    } # END of local function Add-Node
    #####─────EndOf:(Local Helper Function)─────


    #####─────(Main Function Body)─────
    foreach (${eventTag} in ${eventList}) {
        ##### Walk every child of <Event>...
        foreach (${eventSubBlock} in ${eventTag}.ChildNodes) {
            Add-Node -node ${eventSubBlock} -indent 0
        } # END of foreach (${eventSubBlock} in ${eventTag}.ChildNodes) {}
        [Void]${stringBuffer}.AppendLine( ${Script:RuntimeTable}.Verbose.Divider )
    } # END of foreach (${eventTag} in ${eventList}) {}


    return ${stringBuffer}.ToString()
} # END of function Format-View-Text


function Format-View-XML {
#####
# Purpose:
#  • Reformat the list of events to be a formatted XML block.
#  • Return it as a string.
#
# Usage:
#  • No parameters (uses ${Script:EventLogTable}.EventList as input).
#####
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    #####─────Begin:(Local Helper Function)─────
    function Add-EventDetails {
    #####
    # Purpose:
    #  • Create the <EventDetails> XML container.
    #  • For each field ID in the field list...
    #    • Create a new node in the container with its value.
    #  • Append the container to the parent <Event> node.
    #
    # Usage:
    #  • Parameter 1 - ${XmlDoc}:    Xml          - an XML document created from each <Event> block.
    #  • Parameter 2 - ${RootNode}:  XmlElement   - the root of the <Event> node.
    #  • Parameter 3 - ${EventObj}:  EventRecord  - the <Event> block object.
    #  • Parameter 4 - ${FieldList}: String Array - the list of fields for which to populate field names & values.
    #####
        param(
            [Xml]${XmlDoc},
            [System.Xml.XmlElement]${RootNode},
            [System.Diagnostics.Eventing.Reader.EventRecord]${EventObj},
            [String[]]${FieldList}
        )

        ${nsURI} = ${RootNode}.NamespaceURI

        ##### Create the <EventDetails> container...
        ${detailsNode} = ${XmlDoc}.CreateElement('EventDetails', ${nsURI})

        foreach (${fieldID} in ${FieldList}) {
            ##### Prefer the live EventRecord property...
            if (${EventObj}.PSObject.Properties.Name -contains ${fieldID}) {
                ${value} = ${EventObj}.${fieldID}
            } else {
                ${xmlNode} = ${RootNode}.SelectSingleNode(".//*[local-name()='${fieldID}']")
                ${value}   = if (${xmlNode}) { ${xmlNode}.InnerText } else { ${Null} }
            }

            ##### Only append if there's a non-empty ${value}...
            if (${value} -ne ${Null} -and ${value} -ne '') {
                ${newNode} = ${XmlDoc}.CreateElement(${fieldID}, ${nsURI})
                ${newNode}.InnerText = ${value}
                ${detailsNode}.AppendChild(${newNode}) | Out-Null
            }
        } # END of foreach (${fieldID} in ${FieldList}) {}

        ##### Append the <EventDetails> block to the <Event>...
        ${RootNode}.AppendChild(${detailsNode}) | Out-Null
    } # END of local function Add-EventDetails
    #####─────EndOf:(Local Helper Function)─────


    #####─────(Main Function Body)─────
    ${eventFragments} = foreach (${eventBlock} in ${Script:EventLogTable}.EventList) {
        ##### Parse this event's raw XML...
        ${xmlDoc} = [Xml]${eventBlock}.ToXml()

        ##### Namespace manager for XPath queries...
        ${nsMgr} = New-Object System.Xml.XmlNamespaceManager(${xmlDoc}.NameTable)
        ${nsMgr}.AddNamespace('e', ${xmlDoc}.DocumentElement.NamespaceURI)

        ##### Root <Event> node...
        ${eventRoot} = ${xmlDoc}.DocumentElement

        ##### Enrich with extra fields...
        Add-EventDetails `
            -XmlDoc ${xmlDoc} `
            -RootNode ${eventRoot} `
            -EventObj ${eventBlock} `
            -FieldList @(
                'Id',
                'Message',
                'LevelDisplayName',
                'TimeCreated',
                'TaskDisplayName',
                'OpcodeDisplayName',
                'KeywordsDisplayNames'
            )

        ##### Return just the enriched <Event> node...
        ${eventRoot}.OuterXml
    } # END of ${eventFragments} = foreach (${eventBlock} in ${Script:EventLogTable}.EventList) {}

    ##### Join all ${eventFragments} by newlines and wrap in the master <Events> block tags...
    ${rawXml} = "<Events>`n$(${eventFragments} -join "`n")`n</Events>"

    ##### Parse into an XML document...
    [Xml]${xmlDoc} = ${rawXml}

    ##### Configure pretty-print settings...
    ${xmlWriterSettings} = New-Object System.Xml.XmlWriterSettings
    ${xmlWriterSettings}.Indent = ${True}
    ${xmlWriterSettings}.IndentChars = '  '
    ${xmlWriterSettings}.NewLineChars = "`r`n"
    ${xmlWriterSettings}.NewLineHandling = 'Replace'
    ${xmlWriterSettings}.OmitXmlDeclaration = ${False}

    ##### Write formatted XML to a string...
    ${stringBuilder} = New-Object System.Text.StringBuilder
    ${xmlWriterObj} = [System.Xml.XmlWriter]::Create(${stringBuilder}, ${xmlWriterSettings})
    ${xmlDoc}.Save(${xmlWriterObj})
    ${xmlWriterObj}.Close()

    ##### Remove the XML declaration at the top (because we already have one above the Summary)...
    ${xmlString} = ${stringBuilder}.ToString() -replace '^\s*<\?xml.*?\?>\s*', ''

    ##### Extra indent for entire <Events> block and all children...
    ${xmlString} = [RegEx]::Replace(
        ${xmlString},
        '(<Events\b[\s\S]*?</Events>)',
        { param(${m})
            # Split into lines, indent each, join back
            (${m}.Value -split '\r?\n' | ForEach-Object { '  ' + ${_} }) -join "`r`n"
        },
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    return ${xmlString}
} # END of function Format-View-XML


function Summary-Line {
#####
# Purpose:
#  • Form XML or plain text lines as part of the <Summary> block.
#  • Depending on ${tagType}, it outputs...
#    • Begin:  ${tagBegin}
#    • Whole:  ${tagBegin}${tag_Text}${tagClose}
#    • Close:  ${tagClose}
#  • These are formed by...
#    • If ${DoText} is TRUE...
#      • If ${tagType} is not Whole, simply do nothing by returning.
#      • Otherwise...
#        • ${tagSpacing} is decremented by 2.
#        • If ${tagName} is Description...
#          • ${tagName} gets an empty string.
#          • ${tagSpacing} gets 0.
#        • If ${tagName} is LevelCount...
#          • ${tagName} gets "Level ${tagValue}=${tagLabel}"
#        • Then...
#          • ${tagIndent} gets a space multiplied by ${tagSpacing}.
#          • ${tagBegin}  gets "${tagIndent}${tagName}".
#          • ${fillerStr} gets ${fillerChr} multiplied by ${tagMax} minus the length of ${tagBegin}.
#          • ${tag_Text}  gets "${tagBegin}${fillerStr}${tag_Text}"
#          • ${tagBegin} and ${tagClose} get an empty string.
#    • If ${DoText} is FALSE...
#      • If ${tagValue} is defined, it gets " Value=`"${tagValue}`"".
#      • If ${tagLabel} is defined, it gets " Label=`"${tagLabel}`"".
#      • ${value_label_part} gets "${tagValue}${tagLabel}".
#      • ${fillerSpace}      gets a space multiplied by ${value_label_max} minus the length of ${value_label_part}.
#      • ${value_label_part} gets "${value_label_part}${fillerSpace}".
#      • ${tagIndent}        gets a space multiplied by ${tagSpacing}.
#      • ${tagBegin}         gets "${tagIndent}<${tagName}${value_label_part}>".
#      • If ${tagType} is Close...
#        • ${tagClose}       gets "${tagIndent}</${tagName}>"
#      • If ${tagType} is not Close...
#        • ${tagClose}       gets "</${tagName}>"
#  • Appends its output to ${Script:EventLogTable}.Output.
#
# Usage:
#  • Parameter 1 - ${tagName}         String  (REQUIRED) - the name of the XML tag to write to the <Summary> block.
#  • Parameter 2 - ${tagSpacing}      Integer (REQUIRED) - number of spaces to indent before ${tagName}, if ${tagType} is Begin or Whole.
#  • Parameter 3 - ${tagType}         String  (REQUIRED) - one of:  Begin, Whole, or Close.
#  • Parameter 4 - ${tag_Text}        String             - the text inside of the XML tag, which may be blank.
#  • Parameter 5 - ${tagValue}        String             - when ${tagType} is LevelCount, the level Value number (e.g. 1).
#  • Parameter 6 - ${tagLabel}        String             - when ${tagType} is LevelCount, the level Label string (e.g. Warning).
#  • Parameter 7 - ${value_label_max} Integer            - when ${tagType} is LevelCount, the max width of the string "Level ${tagValue}=${tagLabel}".
#####
    param (
        [Parameter(Mandatory=${True} )][String]${tagName},
        [Parameter(Mandatory=${True} )][Int   ]${tagSpacing},
        [Parameter(Mandatory=${True} )][String]${tagType},
        [Parameter(Mandatory=${False})][String]${tag_Text},
        [Parameter(Mandatory=${False})][String]${tagValue},
        [Parameter(Mandatory=${False})][String]${tagLabel},
        [Parameter(Mandatory=${False})][Int   ]${value_label_max}
    )
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    ${doDebug} = ${False}
    #${doDebug} = ${True}
    ##### [0]        [1]        [2]      [3]      [4]      [5]
    ${debugArray} = @(
        @('DarkCyan','DarkCyan','Cyan',  'Red',   'Black', 'DarkGreen'),
        @('Black',   'Black',   'Black', 'Black', 'Green', 'Black'),
        @('BEFORE',  'MIDDLE',  'SCOPED','RETURN','FORMAT','OUTPUT')
    )
    ${excludeVars} = @('value_label_max')
    Do-Process-Debug `
        -doIt             ${doDebug}    `
        -callingFuncName "${funcName}"  `
        -debugIndex       0             `
        -debugArray       ${debugArray} `
        -processValue     $( Do-Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values ${excludeVars} )

    ##### Initial Declarations...
    ${fillerChr} = '•' # Or customize to suit
    ${tagIndent} = ''
    ${tagMax}    = 22
    ##### Initialize these all to an empty string to start out...
    ${fillerStr} = ''
    ${tagBegin}  = ''
    ${tagClose}  = ''
    ${tagString} = ''

    ##### Scope Checking & Verbose Summary...
    if (${tagName} -eq 'LevelCount') {
        ##### Use ${tagString} temporarily...
        ${tagString} = "${tagIndent}Level ${tagValue}=${tagLabel}"

        ##### Debug MIDDLE...
        Do-Process-Debug `
            -doIt             ${doDebug}    `
            -callingFuncName "${funcName}"  `
            -debugIndex       1             `
            -debugArray       ${debugArray} `
            -processValue     $( Do-Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values ${excludeVars} )

        if (${tagString}.Length -gt 0 -and ${tagMax} -ge ${tagString}.Length) { ${fillerStr} = "${fillerChr}" * (${tagMax} - ${tagString}.Length) }
        ${Script:EventLogTable}.Summary += "${tagString}${fillerStr}${tag_Text}`n"
        ##### Re-initialize ${tagString} back to empty...
        ${tagString} = ''
    } elseif (${tagName} -eq 'WorkingDirectory') {
        if (-not ${tag_Text}.EndsWith('\')) { ${tag_Text} += '\' }
    }
    if ([String]::IsNullOrWhiteSpace(${tagType})) { ${tagType} = 'Whole' }
    if (${tagSpacing} -lt 0) { ${tagSpacing} = 0 }
    if (-not [String]::IsNullOrWhiteSpace(${tagValue})) {
        if (-not ${Script:EventLogTable}.DoText) { ${tagValue} = " Value=`"${tagValue}`"" }
    } else {
        ${tagValue} = ''
    }
    if (-not [String]::IsNullOrWhiteSpace(${tagLabel})) {
        if (-not ${Script:EventLogTable}.DoText) { ${tagLabel} = " Label=`"${tagLabel}`"" }
    } else {
        ${tagLabel} = ''
    }
    ##### Debug SCOPED...
        Do-Process-Debug `
            -doIt             ${doDebug}    `
            -callingFuncName "${funcName}"  `
            -debugIndex       2             `
            -debugArray       ${debugArray} `
            -processValue     $( Do-Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values ${excludeVars} )

    ##### If Text format...
    if (${Script:EventLogTable}.DoText) {
        if (${tagType} -ne 'Whole') {
            ##### Debug RETURN...
            Do-Process-Debug `
                -doIt             ${doDebug}    `
                -callingFuncName "${funcName}"  `
                -debugIndex       3             `
                -debugArray       ${debugArray} `
                -processValue     "`n"
            return
        }
        ${tagSpacing}-=2
        if (${tagName} -eq 'Description') {
            ${tagName} = ''
            ${tagSpacing} = 0
        } elseif (${tagName} -eq 'LevelCount' ) {
            ${tagName} = "Level ${tagValue}=${tagLabel}"
        }
        ${tagIndent} = ' ' * (${tagSpacing})
        ${tagBegin}  = "${tagIndent}${tagName}"
        if (${tagBegin}.Length -gt 0 -and ${tagMax} -ge ${tagBegin}.Length) { ${fillerStr} = "${fillerChr}" * (${tagMax} - ${tagBegin}.Length) }
        ${tag_Text}  = "${tagBegin}${fillerStr}${tag_Text}"
        ${tagBegin}  = ''
        ${tagClose}  = ''

    ##### If XML format...
    } else {
        ${value_label_part} = "${tagValue}${tagLabel}"
        if (${value_label_part}.Length -gt 0 -and ${value_label_max} -ge ${value_label_part}.Length) {
            ${fillerSpace} = ' ' * (${value_label_max} - ${value_label_part}.Length)
            ${value_label_part} = "${value_label_part}${fillerSpace}"
        }
        ${tagIndent} = ' ' * (${tagSpacing})
        ${tagBegin}  = "${tagIndent}<${tagName}${value_label_part}>"
        ${tagClose}  = "</${tagName}>"
        if (${tagType} -eq 'Close') { ${tagClose} = "${tagIndent}${tagClose}" }
    } # END of if (${Script:EventLogTable}.DoText) {} else {}
    ##### Debug FORMAT...
    Do-Process-Debug `
        -doIt             ${doDebug}    `
        -callingFuncName "${funcName}"  `
        -debugIndex       4             `
        -debugArray       ${debugArray} `
        -processValue     $( Do-Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values ${excludeVars} )

    ##### Assemble based on ${tagType}...
        if (${tagType} -eq 'Begin') {
        ${tagString} = "${tagBegin}"
    } elseif (${tagType} -eq 'Whole') {
        ${tagString} = "${tagBegin}${tag_Text}${tagClose}"
    } elseif (${tagType} -eq 'Close') {
        ${tagString} = "${tagClose}"
    }

    ##### Debug OUTPUT...
    Do-Process-Debug `
        -doIt             ${doDebug}    `
        -callingFuncName "${funcName}"  `
        -debugIndex       5             `
        -debugArray       ${debugArray} `
        -extraNewline                   `
        -processValue     $( Do-Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values ${excludeVars} )

    ##### Assign it...
    ${Script:EventLogTable}.Output += "${tagString}"
} # END of function Summary-Line



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



##########
########## Parameter Processing...
##########
# Parameters are processed in the following order of precedence...
#   1. -dbg|-Debugging takes precedence over -v|-Verbosity.
#   2. -Silent (also triggered by -niv|-ni|-NonInteractive).
#   3. -niv takes precedence over -ni|-NonInteractive, ignores -h|-Help.
#   4. -h|-Help takes precedence over -Releases|-ReleaseNotes, and if either is used, it's processed immediately and exits.
#   5. From this point, all other parameters are processed in alphabetical order.
#      5a. -d|-Days takes precedence over -r|-Range.
#      5b. -qo|-QuoteOpening & -qc|-QuoteClosing both take precedence over -q|-Quote.
##########

#####
##### General parameters...
#####


#####
# -dbg
# -Debugging
# -v
# -Verbosity
#####
# • Precedence level 1.
# • -dbg|-Debugging takes precedence over -v|-Verbosity.
#####
if (${Debugging}) {
    #####
    # -Debugging
    #####
    ${Script:RuntimeTable}.Verbose.InDebugMode = ${True}
    ${Script:RuntimeTable}.Verbose.Level       = 3
} else {
    #####
    # -v
    # -Verbosity
    #####
    if (${Verbosity}) { ${Script:RuntimeTable}.Verbose.Level = ${Verbosity} }
}
    Do-Processing 1 'MAIN' 'BEGIN:Parameter Processing' -isFirst
if (${Debugging}) {
    Do-Processing 1 'MAIN' ('PARAMETER '+( Do-Get-Var-Quoted 0 'Debugging' 0 'None' ${Debugging} ))
}
if (${Verbosity}) {
    Do-Processing 1 'MAIN' ('PARAMETER '+( Do-Get-Var-Quoted 0 'Verbosity' 0 'None' ${Verbosity} ))
}
Do-Process-Table  2 'MAIN' '${Script:RuntimeTable} BEFORE' ${Script:RuntimeTable}


#####
# (Internal only, not mentioned in help) Range-check the ExitStatus table...
#####
# • Precedence level 1b.
# • It also ensures E1Warn<E2User<E3Code<E4NIMR<=255.
#####

##### E0Good Validity...
if (-not ( Do-Is-Valid-Entry 'ExitStatus.E0Good'    ${Script:RuntimeTable}.ExitStatus.E0Good 'Int32' 'ExitStatus' )) {
     Do-Processing 2 'MAIN'  'ExitStatus.E0Good =   0'
         ${Script:RuntimeTable}.ExitStatus.E0Good =   0
}
##### There is no other range-check associated with E0Good.

##### E1Warn Validity...
if (-not ( Do-Is-Valid-Entry 'ExitStatus.E1Warn'    ${Script:RuntimeTable}.ExitStatus.E1Warn 'Int32' 'ExitStatus' )) {
     Do-Processing 2 'MAIN'  'ExitStatus.E1Warn =   0'
         ${Script:RuntimeTable}.ExitStatus.E1Warn =   0
}
##### E1Warn Range-check (since every code after this must be greater than this, the max this can be is 252)...
if (      ${Script:RuntimeTable}.ExitStatus.E1Warn -gt 252                                       ) {
     Do-Processing 2 'MAIN'   'ExitStatus.E1Warn =   252'
          ${Script:RuntimeTable}.ExitStatus.E1Warn =   252
}

##### E2User Validity...
if (-not ( Do-Is-Valid-Entry 'ExitStatus.E2User'    ${Script:RuntimeTable}.ExitStatus.E2User 'Int32' 'ExitStatus' )) {
     Do-Processing 2 'MAIN'  'ExitStatus.E2User =   1'
         ${Script:RuntimeTable}.ExitStatus.E2User =   1
}
##### E2User Range-check...
if (      ${Script:RuntimeTable}.ExitStatus.E2User -le ${Script:RuntimeTable}.ExitStatus.E1Warn  ) {
     Do-Processing 2 'MAIN'  ('ExitStatus.E2User =  (${Script:RuntimeTable}.ExitStatus.E1Warn+1) = '+(${Script:RuntimeTable}.ExitStatus.E1Warn+1))
          ${Script:RuntimeTable}.ExitStatus.E2User =  (${Script:RuntimeTable}.ExitStatus.E1Warn+1)
}

##### E3Code Validity...
if (-not ( Do-Is-Valid-Entry 'ExitStatus.E3Code'    ${Script:RuntimeTable}.ExitStatus.E3Code 'Int32' 'ExitStatus' )) {
     Do-Processing 2 'MAIN'  'ExitStatus.E3Code =   2'
         ${Script:RuntimeTable}.ExitStatus.E3Code =   2
}
##### E3Code Range-check...
if (     ${Script:RuntimeTable}.ExitStatus.E3Code -le ${Script:RuntimeTable}.ExitStatus.E2User  ) {
     Do-Processing 2 'MAIN' ('ExitStatus.E3Code =  (${Script:RuntimeTable}.ExitStatus.E2User+1) = '+(${Script:RuntimeTable}.ExitStatus.E2User+1))
         ${Script:RuntimeTable}.ExitStatus.E3Code =  (${Script:RuntimeTable}.ExitStatus.E2User+1)
}

##### E4NIMR Validity...
if (-not ( Do-Is-Valid-Entry 'ExitStatus.E4NIMR'    ${Script:RuntimeTable}.ExitStatus.E4NIMR 'Int32' 'ExitStatus' )) {
     Do-Processing 2 'MAIN'  'ExitStatus.E4NIMR =   3'
         ${Script:RuntimeTable}.ExitStatus.E4NIMR =   3
}
##### E4NIMR Range-check...
if (     ${Script:RuntimeTable}.ExitStatus.E4NIMR -le ${Script:RuntimeTable}.ExitStatus.E3Code  ) {
     Do-Processing 2 'MAIN' ('ExitStatus.E4NIMR =  (${Script:RuntimeTable}.ExitStatus.E3Code+1) = '+(${Script:RuntimeTable}.ExitStatus.E3Code+1))
         ${Script:RuntimeTable}.ExitStatus.E4NIMR =  (${Script:RuntimeTable}.ExitStatus.E3Code+1)
}


#####
# -Silent
#####
# • Precedence level 2.
# • -niv|-ni|-NonInteractive automatically triggers -Silent, which must occur prior to processing -niv|-ni|-NonInteractive.
#####
${Silent} = (${Silent} -or ${niv} -or ${NonInteractive})
if (${Silent}) {
    Do-Processing 1 'MAIN' ('PARAMETER '+( Do-Get-Var-Quoted 0 'Silent' 0 'None' ${Silent} ))
   #There is no corresponding value for E0Good, since that mode is never used in Do-Output-Error.
    ${Script:RuntimeTable}.ErrorBeepsOn.E1Warn = ${False}
    ${Script:RuntimeTable}.ErrorBeepsOn.E2User = ${False}
    ${Script:RuntimeTable}.ErrorBeepsOn.E3Code = ${False}
   #There is no corresponding value for E4NIMR, since that mode automatically silences all of these.
    ${Script:RuntimeTable}.ErrorBeepsOn.EXMore = ${False}
}


#####
# -niv
# -ni
# -NonInteractive
#####
# • Precedence level 3.
# • This must be processed before parameters -h|-Help.
# • -niv takes precedence over -ni|-NonInteractive.
#####

##### If ${niv} and/or ${NonInteractive} are True...
if (${niv} -or ${NonInteractive}) {
    ##### If ${niv} is True, this takes precedence...
    if (${niv}) {
        Do-Processing 1 'MAIN' ('PARAMETER '+( Do-Get-Var-Quoted 0 'niv' 0 'None' ${niv} ))
        ${Script:RuntimeTable}.NonInteractive.Verbose.Param = '-niv'
        ${Script:RuntimeTable}.NonInteractive.Verbose.IsTrue = ${True}
    ##### Else if ${NonInteractive} is True...
    } else {
        Do-Processing 1 'MAIN' ('PARAMETER '+( Do-Get-Var-Quoted 0 'NonInteractive' 0 'None' ${NonInteractive} ))
        ${Script:RuntimeTable}.NonInteractive.Verbose.Param = '-ni|-NonInteractive'
    }
        ${Script:RuntimeTable}.NonInteractive.IsTrue         = ${True}

    ##### Override parameter -h|-Help if specified...
    if (${Help}) {
        Do-Processing 1 'MAIN' ('OVERRIDING PARAMETER -h|-Help with parameter '+${Script:RuntimeTable}.NonInteractive.Verbose.Param+'.')
        ${Help} = ${False}
    }
    ##### However, if parameter -rs|-RunSetup|-RerunSetup was specified, it's an error in combination with -niv|-ni|-NonInteractive...
    if (${RerunSetup}) {
        Do-Output-Error `
            -errorMessage    ('Parameter -rs|-RunSetup|-RerunSetup is invalid with parameter '+${Script:RuntimeTable}.NonInteractive.Verbose.Param+'.') `
            -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
    }
}


#####
# -h
# -Help
# -Releases|-ReleaseNotes
#####
# • Precedence level 4.
# • -h|-Help takes precedence over -Releases|-ReleaseNotes, and if either is used, it's processed immediately and exits.
#####
if (${Help}) {
    Do-Processing 1 'MAIN' 'PARAMETER Help = True'
    Do-Processing 1 'MAIN' 'ACTION IMMEDIATE Do-Output-Help-Page'
    Do-Output-Help-Page
}
if (${ReleaseNotes}) {
    Do-Processing 1 'MAIN' 'PARAMETER ReleaseNotes = True'
    Do-Processing 1 'MAIN' 'ACTION IMMEDIATE Do-Output-Help-Page -releaseNotes'
    Do-Output-Help-Page -releaseNotes
}


#####
##### Event Log-specifc parameters...
#####


#####
# -d
# -Days
# -r
# -Range
#####
# • Precedence level 5a.
# • -d|-Days takes precedence over -r|-Range.
# • -d|-Days & -r|-Range are mutually exclusive and one is required.
#####
${Days} = $( Do-Get-Integer "${Days}" )
if (-not ${Days} -and -not ${Range} ) {
    Do-Output-Error `
        -errorMessage    'You must specify either -d|-Days (days ago) or -r|-Range (date range), but not both.' `
        -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
}

##### If -d, calculate start date from ${Days}...
if ( [Bool]${Days} -or (${Days} -eq 0) ) {
    ##### Validate the number of days parameter, which must be an integer >=0...
    if (${Days} -lt 0) { Do-Output-Error 'You must specify the parameter to -d|-Days (days ago) as an Integer >=0.' }
    ##### Midnight of target number (${Days}) days ago, where 0=today at midnight...
    ${Script:EventLogTable}.DateFrom = (Get-Date).Date.AddDays(-${Days})
    ##### Today's date & current time...
    ${Script:EventLogTable}.DateThru =  Get-Date

##### Else if -r|-Range, parse date range from ${Range} as 'from,to'...
} elseif (${Range}) {
    ##### Validate the date range is (from,to) in 'yyyy-mm-dd,yyyy-mm-dd' format and that to>=from...
    ${Script:EventLogTable}.DateFrom, ${Script:EventLogTable}.DateThru = ${Range} -Split ',' | ForEach-Object {
        try {
            [DateTime]::Parse(${_}.Trim())
        } catch {
            Do-Output-Error `
                -errorMessage (
                    "Invalid date format '${_}'.`n"+
                    "With -r|-Range, you must include exactly 2 dates (from,to) in 'yyyy-mm-dd,yyyy-mm-dd' format where to>=from."
                ) `
                -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
        }
    }
    if (${Script:EventLogTable}.DateThru -lt ${Script:EventLogTable}.DateFrom) {
        Do-Output-Error `
            -errorMessage (
                "Invalid date format '${Range}'.`n"+
                "With -r|-Range, you must include exactly 2 dates (from,to) in 'yyyy-mm-dd,yyyy-mm-dd' format where to>=from."
            ) `
            -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
    }
    ##### Extend end date to include the full day...
    ${Script:EventLogTable}.DateThru = ${Script:EventLogTable}.DateThru.AddDays(1).AddSeconds(-1)
} # END of if ( [Bool]${Days} -or (${Days} -eq 0) ) {} elseif (${Range}) {}


#####
# -l
# -MaxLevel
#####
# • This parameter is required.
#####
if (-not ${MaxLevel}) {
    Do-Output-Error `
        -errorMessage    'You must specify the max log level with -l|-MaxLevel [1-5].' `
        -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
}


#####
# -n
# -Names
#####
##### If not -n|-Names, default to System...
if ([String]::IsNullOrWhitespace(${Names})) { ${Names} = 'System' }
##### Parse the log name inclusion list...
${Script:EventLogTable}.IncludedString = ${Names}
${Script:EventLogTable}.IncludedNames  = ${Names} -Split ',' | ForEach-Object { ${_}.Trim() }


#####
# -o
# -Out
# -OutFile
#####
if ([String]::IsNullOrEmpty(${OutFile})) { ${OutFile} = '' }


#####
# -q
# -Quote
# -qo
# -QuoteOpening
# -qc
# -QuoteClosing
#####
# • Precedence level 5b.
# • -qo|-QuoteOpening & -qc|-QuoteClosing both take precedence over -q|-Quote.
# • -q|-Quote, -qo|-QuoteOpening, & -qc|-QuoteClosing can only be used with -t|-Text.
#####
if (-not ${Text} -and (${Quote} -or ${QuoteOpening} -or ${QuoteClosing})) {
    Do-Output-Error `
        -errorMessage    'You can only use parameters -q|Quote, -qo|-QuoteOpening, & -qc|-QuoteClosing with -t|-Text.' `
        -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
}
##### -qo & -qc must be non-empty...
if (${QuoteOpening} -and [String]::IsNullOrEmpty(${QuoteOpening})) {
    Do-Output-Error `
        -errorMessage    "Invalid use of -qo|-QuoteOpening.`nYou must include a character(s) (escaped or quoted as needed) for the opening quote." `
        -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
}
if (${QuoteClosing} -and [String]::IsNullOrEmpty(${QuoteClosing})) {
    Do-Output-Error `
        -errorMessage    "Invalid use of -qc|-QuoteClosing.`nYou must include a character(s) (escaped or quoted as needed) for the closing quote." `
        -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
}
##### If not -q|-Quote, unset the globals...
if (-not ${Quote}) { ${Script:EventLogTable}.Quote.Opening = '';  ${Script:EventLogTable}.Quote.Closing = '' }
##### If -qo|-QuoteOpening is used, always assign it to ${Script:EventLogTable}.Quote.Opening, even if -q|-Quote was used earlier...
if (${QuoteOpening}) { ${Script:EventLogTable}.Quote.Opening = "${QuoteOpening}" }
##### If -qc|-QuoteClosing is used, always assign it to ${Script:EventLogTable}.Quote.Closing, even if -q|-Quote was used earlier...
if (${QuoteClosing}) { ${Script:EventLogTable}.Quote.Closing = "${QuoteClosing}" }
##### At this point, if any of -q|-Quote, -qo|-QuoteOpening, &/or -qc|-QuoteClosing were used, both globals should be populated.
##### If -qo|-QuoteOpening is used but not -qc|-QuoteClosing, set ${Script:EventLogTable}.Quote.Closing to ${QuoteOpening}...
if (${QuoteOpening} -and -not ${QuoteClosing}) { ${Script:EventLogTable}.Quote.Closing = "${QuoteOpening}" }
##### If -qc|-QuoteClosing is used but not -qo|-QuoteOpening, set ${Script:EventLogTable}.Quote.Opening to ${QuoteClosing}...
if (${QuoteClosing} -and -not ${QuoteOpening}) { ${Script:EventLogTable}.Quote.Opening = "${QuoteClosing}" }


#####
# -t
# -Text
#####
${Script:EventLogTable}.DoText = [Bool]${Text}


#####
# -x
# -ExcludeIDs
#####
# • If -x|-ExcludeIDs, parse the exclusion list...
#####
if (${ExcludeIDs}) {
    ${Script:EventLogTable}.ExcludedIDs = ${ExcludeIDs} -Split ',' | ForEach-Object { ${_}.Trim() } | Where-Object { ${_} -Match '^\d+$' }
}

Do-Process-Table 2 'MAIN' '${Script:RuntimeTable} SCOPED' ${Script:RuntimeTable}
Do-Processing 1 'MAIN' 'CLOSE:Parameter Processing.'



#####
##### Assemble Host.Local.* Addresses...
#####
# • Assemble ${Script:RuntimeTable}.Host.Local.FQDN from ${Script:RuntimeTable}.Host.Local.Hostname & ${Script:RuntimeTable}.Host.Local.Domain if set.
#####

##### Try to get the DNS domain name, or ${Null} if none...
try {
    ##### Try to get the AD DNS DomainName...
    ${Script:RuntimeTable}.Host.Local.Domain = ([System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()).Name
} catch {
    ##### Not domain-Joined or AD query failed — fall back to the NIC's DNS suffix...
    ${Script:RuntimeTable}.Host.Local.Domain = Get-WmiObject Win32_NetworkAdapterConfiguration `
        | Where-Object { ${_}.IPEnabled -eq ${True} -and ${_}.DNSDomain -and ${_}.DNSDomain -ne '' } `
        | Select-Object -isFirst 1 -ExpandProperty DNSDomain
}
##### If it's not a real domain (e.g., not set or the same as Hostname), treat it as empty...
if (
    ${Script:RuntimeTable}.Host.Local.Domain -eq ${Script:RuntimeTable}.Host.Local.Hostname -or
    [String]::IsNullOrWhiteSpace(${Script:RuntimeTable}.Host.Local.Domain)
) {
    ${Script:RuntimeTable}.Host.Local.Domain = ''
    ${Script:RuntimeTable}.Host.Local.FQDN   = ${Script:RuntimeTable}.Host.Local.Hostname
##### Else if it is a real domain, append it to the Hostname...
} else {
    ${Script:RuntimeTable}.Host.Local.FQDN   = (${Script:RuntimeTable}.Host.Local.Hostname+'.'+${Script:RuntimeTable}.Host.Local.Domain)
}


#####
##### Retrieve & filter all events within the range of ${Script:EventLogTable}.DateFrom & ${Script:EventLogTable}.DateThru where MaxLevel<=${MaxLevel}...
#####

Do-Processing 1 'MAIN' (
    "`n"+
    ${Script:RuntimeTable}.Verbose.Indent+
        "Get-WinEvent excluding '"+
        ${Script:EventLogTable}.ExcludedIDs+
        "' where MaxLevel<=${MaxLevel} StartTime='"+
        ${Script:EventLogTable}.DateFrom+
        "' EndTime='"+
        ${Script:EventLogTable}.DateThru+
        "'..."
)
Do-Processing 1 'MAIN' (${Script:RuntimeTable}.Verbose.Indent+"foreach LogName in '"+${Script:EventLogTable}.IncludedString+"'...") -noPrefix
foreach (${Script:LogName} in ${Script:EventLogTable}.IncludedNames) {
    Do-Processing 1 'MAIN' ((${Script:RuntimeTable}.Verbose.Indent*2)+"where LogName='${Script:LogName}'") -noPrefix
    ${Script:EventLogTable}.EventList += Get-WinEvent -FilterHashtable @{
        LogName   = "${Script:LogName}"
        StartTime =  ${Script:EventLogTable}.DateFrom
        EndTime   =  ${Script:EventLogTable}.DateThru
    } -ErrorAction SilentlyContinue | Where-Object {
        ${_}.Level -le ${MaxLevel} -and
        (${Script:EventLogTable}.ExcludedIDs -NotContains ${_}.Id)
    }
} # END of foreach (${Script:LogName} in ${Script:EventLogTable}.IncludedNames) {}
Do-Processing 1 'MAIN' ('Raw event count = '+${Script:EventLogTable}.EventList.Count)
if (${Script:EventLogTable}.EventList.Count -gt 0) {
    Do-Process-Array `
         2     `
        'MAIN' `
        'Brief ${Script:EventLogTable}.EventList' `
        @(     ${Script:EventLogTable}.EventList | ForEach-Object { '{0} | {1} | {2}' -f ${_}.Id, ${_}.LevelDisplayName, ${_}.TimeCreated } )
}


#####
##### Summarize by ${Script:LevelValue} in 1..${MaxLevel} from ${Script:EventLogTable}.LevelList...
#####

Do-Processing 1 'MAIN' 'Assembling Summary'
${Script:EventLogTable}.Description = "Event report for Level ${MaxLevel} "+$(if (${MaxLevel} -gt 1) { 'or lower' } else { 'only' })+', where...'
if (${Script:EventLogTable}.DoText) {
    ${Script:EventLogTable}.Description = ('Summary — '+${Script:EventLogTable}.Description)
    ${Script:EventLogTable}.Output += ${Script:RuntimeTable}.Verbose.Divider
    ${Script:EventLogTable}.Output += ${Script:RuntimeTable}.Verbose.Divider
} else {
    ${Script:EventLogTable}.Output += '<?xml version="1.0" encoding="utf-16"?>'
}
    Summary-Line 'Report'           0 'Begin'
    Summary-Line 'Summary'          2 'Begin'
    Summary-Line 'Description'      4 'Whole'  ${Script:EventLogTable}.Description
    Summary-Line 'ReportingHost'    4 'Whole'  ${Script:RuntimeTable}.Host.Local.FQDN
    Summary-Line 'RangeFrom'        4 'Whole'  ${Script:EventLogTable}.DateFrom
    Summary-Line 'RangeThru'        4 'Whole'  ${Script:EventLogTable}.DateThru
foreach (${Script:LevelValue} in 1..${MaxLevel}) {
    ${Script:EventLogTable}.LevelLabel = ${Script:EventLogTable}.LevelList[${Script:LevelValue}]
    ${Script:EventLogTable}.LevelCount = (
        ${Script:EventLogTable}.EventList |
        Where-Object { ${_}.LevelDisplayName -eq ${Script:EventLogTable}.LevelLabel }
    ).Count
    Summary-Line 'LevelCount'       4 'Whole' (( Do-Auto-Plural ${Script:EventLogTable}.LevelCount 'event' -padSingle )+' found') `
        ${Script:LevelValue}               `
        ${Script:EventLogTable}.LevelLabel `
        29
    ${Script:EventLogTable}.LevelTotal += ${Script:EventLogTable}.LevelCount
}
    Summary-Line 'LevelCount'       4 'Whole'  (( Do-Auto-Plural ${Script:EventLogTable}.LevelTotal 'event' -padSingle )+' TOTAL') '*' 'TOTAL' 29
    Summary-Line 'WorkingDirectory' 4 'Whole'  ${Script:RuntimeTable}.Dir_name
    Summary-Line 'CLIandParameters' 4 'Whole'  ${Script:RuntimeTable}.UserArgs
    Summary-Line 'Summary'          2 'Close'
if (${Script:EventLogTable}.DoText) {
    ${Script:EventLogTable}.Output += ${Script:RuntimeTable}.Verbose.Divider
    ${Script:EventLogTable}.Output += ${Script:RuntimeTable}.Verbose.Divider
}
Do-Process-Array `
     2     `
    'MAIN' `
      '${Script:EventLogTable}.Output'`
    @( ${Script:EventLogTable}.Output )


#####
##### Add XML or plain text event entries to ${Script:EventLogTable}.Output...
#####

Do-Processing 1 'MAIN' 'Assembling Output'
##### Assemble all event records into ${Script:EventLogTable}.XmlString...
${Script:EventLogTable}.XmlString = (
    "<Events>`n"+
    ( ( ${Script:EventLogTable}.EventList | ForEach-Object { ${_}.ToXml() } ) -Join "`n" )+"`n"+
    '</Events>'
)
Do-Process-Array `
    2 `
    'MAIN' `
      '${Script:EventLogTable}.XmlString' `
    @( ${Script:EventLogTable}.XmlString )

##### Format into XML UTF-16...
${Script:EventLogTable}.XmlFormatted = Format-View-XML
Do-Process-Array `
     2     `
    'MAIN' `
       '${Script:EventLogTable}.XmlFormatted' `
     @( ${Script:EventLogTable}.XmlFormatted )
##### Append to ${Script:EventLogTable}.Output according to ${Script:EventLogTable}.DoText...
if (${Script:EventLogTable}.DoText) {
    ##### If there are no events...
    if (${Script:EventLogTable}.XmlFormatted -eq '  <Events></Events>') {
        ${Script:EventLogTable}.Output += 'No events were found for the given criteria.'
        ##### Add bottom dividers...
        ${Script:EventLogTable}.Output += ${Script:RuntimeTable}.Verbose.Divider
        ${Script:EventLogTable}.Output += ${Script:RuntimeTable}.Verbose.Divider

    ##### Else if there ARE events...
    } else {
        ##### Convert them to plain text...
        ${Script:EventLogTable}.Output += Format-View-Text
    }
} else {
    ##### Keep it as XML UTF-16...
    ${Script:EventLogTable}.Output += ${Script:EventLogTable}.XmlFormatted
    ##### Append the final closing </Report> tag...
    ${Script:EventLogTable}.Output += '</Report>'
}
Do-Process-Array `
    2 `
    'MAIN' `
    '${Script:EventLogTable}.Output' `
     ${Script:EventLogTable}.Output


#####
##### Write the final ${Script:EventLogTable}.Output either to ${OutFile} if not '' or to the console if it is...
#####

Do-Output-Write `
    -textOutput        ( ${Script:EventLogTable}.Output -Join "`n" ) `
    -outFile           "${OutFile}"                                  `
    -niCallingFunction 'MAIN' -niCallingVarNames '( ${Script:EventLogTable}.Output -Join "`n" )'
Do-Processing 1 'MAIN' ("Final summary...`n"+${Script:EventLogTable}.Summary)


#####
##### The end.
#####

Do-Process-Exit ${Script:RuntimeTable}.ExitStatus.E0Good 'MAIN'


