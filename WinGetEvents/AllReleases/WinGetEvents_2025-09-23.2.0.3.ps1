##########
##########
## ▄▄▄▄▄▄▄▄▄▄▄▄▄ This file needs to be saved with Encoding=UTF-16 LE BOM.
## ▌ IMPORTANT ▐ There are some UTF characters saved in this script.
## ▀▀▀▀▀▀▀▀▀▀▀▀▀ Similarly, it works with XML data using the header
##########       <?xml version="1.0" encoding="utf-16"?>
##########
<#-HELP-# Option -h or -Help will print everything below this line...

.SYNOPSIS
  Advanced Windows Event Log Filter Script
.DESCRIPTION
  Filters Windows event logs based on severity level (-l), date/interval (-d or -r), by log names (-n) or System by default, excluding event IDs (-x), and outputs results formatted in either XML or Text with -t with a summary above. Log name inclusions (-n) are passed as a quoted comma-separated list. Event exclusions (-x) are passed as a quoted comma-separated list. Date range (-r) must include exactly 2 dates (from,to) in "yyyy-mm-dd,yyyy-mm-dd" format. With -t, always quote field contents with -q, -qo, or -qc. Output by default goes to the console or to an output file path (-o).
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
  WinGetEvents.ps1 -l 2 -r "2025-08-01,2025-08-31"
  WinGetEvents.ps1 -l 2 -d 1 -t
.AUTHOR
  Jeremy Gagliardi
.VERSION
  2025-09-23.2.0.3
.LINK
  https://github.com/jjg8/Shell-Scripts/tree/main/WinGetEvents

#-HELP-#> # Option -h or -Help will print everything above this line.
#####
# • The layout of this script is optimized for a terminal width of at least 155.
# • All variable & function names are unique throughout the script for easy search/replace.
# • All variables are written in the form ${...} (e.g. ${_}, ${Output}, ${Verbose}, etc) for both readability and better functionality.
# • Banners were made using https://www.bagill.com/ascii-sig.php
#   • Add a space before and after the Text.
#   • Font:  Banner3-D
#   • I added an extra row of colons before and after each word.
#   • I also added the same text after each one, so it's searchable
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



#####
##### Declare and get all parameters...
#####
# All are Mandatory=${False}, so parameter checking can be done below in the MAIN BODY.
#####

[CmdletBinding()]
param (
  [Parameter(Mandatory=${False})][Alias('d')][String]${Days},
  [Parameter(Mandatory=${False})][Alias('h')][Switch]${Help},
  [Parameter(Mandatory=${False})][Alias('l')][ValidateSet(1,2,3,4,5)][Int]${MaxLevel},
  [Parameter(Mandatory=${False})][Alias('n')][String]${Names},
  [Parameter(Mandatory=${False})][Alias('o','Out')][String]${OutFile},
  [Parameter(Mandatory=${False})][Alias('q')][Switch]${Quote},
  [Parameter(Mandatory=${False})][Alias('qo')][String]${QuoteOpening},
  [Parameter(Mandatory=${False})][Alias('qc')][String]${QuoteClosing},
  [Parameter(Mandatory=${False})][Alias('r')][String]${Range},
  [Parameter(Mandatory=${False})][Alias('t')][Switch]${Text},
  [Parameter(Mandatory=${False})][Alias('v')][Int]${Verbosity},
  [Parameter(Mandatory=${False})][Alias('x')][String]${ExcludeIDs}
)


[Console]::OutputEncoding = [System.Text.Encoding]::Unicode


#####
##### Declare all global variables...
#####
# • Any declaration in [] on its own line, needs to have ` after it, otherwise it announces the type info to the console.
# • Script: means it's global within the script (don't use Global:, because that survives after script execution into the session.
#####

[DateTime] ${Script:DateFrom}       = Get-Date
[DateTime] ${Script:DateThru}       = Get-Date
[String]   ${Script:Description}    = ''
[String]   ${Script:Divider}        = '────────────────' # Just some horizontal lines (or customize to suit)
[String]   ${Script:DomainName}     = ''     # Set below
[Bool]     ${Script:DoText}         = ${False}
[System.Collections.ArrayList]`
           ${Script:EventList}      = @()    # Empty system events array
[Int[]]    ${Script:ExcludedIDs}    = @()    # Empty integer array
[String]   ${Script:FQDN}           = ''     # Set below
[String]   ${Script:Hostname}       = ${Env:ComputerName}
[String]   ${Script:IncludedString} = ''
[String[]] ${Script:IncludedNames}  = ''
[Int]      ${Script:LevelCount}     = 0
[String]   ${Script:LevelLabel}     = ''
[HashTable]${Script:LevelList}      = @{
    1 = 'Critical'
    2 = 'Error'
    3 = 'Warning'
    4 = 'Information'
    5 = 'Verbose'
}
[Int]      ${Script:LevelValue}     = 0
[String[]] ${Script:Output}         = @() # Empty string array
[String]   ${Script:QC}             = ''  # Set below
[String]   ${Script:QO}             = ''  # Set below
[System.Management.Automation.ParameterMetadata[]]`
           ${Script:ScriptArgs}     = $( Get-Command ${PSCmdlet}.MyInvocation.InvocationName ).Parameters.Values
[String]   ${Script:ScriptBase}     = Split-Path -Leaf ${MyInvocation}.MyCommand.Path
[String]   ${Script:ScriptCall}     = ${MyInvocation}.Line
[String]   ${Script:Script_Dir}     = [String](
        Split-Path -Path ${MyInvocation}.MyCommand.Path -Parent
    ).Replace('Microsoft.PowerShell.Core\FileSystem::', '')
[String]   ${Script:Summary}        = ''  # Used only if ${Script:Verbose}>0
[Int]      ${Script:Verbose}        = 0
[String]   ${Script:XmlFormatted}   = ''
[String]   ${Script:XmlString}      = ''
Write-Host "${Script:Script_Dir}"; exit

#####
##### Set defaults quotes...
#####
# QO = opening quote
# QC = closing quote
#####
${Script:QO} = '"';  ${Script:QC} = '"' # E.g. "string"
##### Other ideas (customize to suit)...
#${Script:QO} = '«'; ${Script:QC} = '»' # E.g. «string»
#${Script:QO} = '“'; ${Script:QC} = '”' # E.g. “string”
#${Script:QO} = '‹'; ${Script:QC} = '›' # E.g. ‹string›
#${Script:QO} = "‘"; ${Script:QC} = "’" # E.g. ‘string’


#####
##### Assemble ${Script:FQDN} from ${Script:Hostname} and ${Script:DomainName} if set...
#####

##### Try to get the DNS domain name, or ${Null} if none...
try {
    ##### Try to get the AD DNS domain name...
    ${Script:DomainName} = ([System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()).Name
} catch {
    ##### Not domain-joined or AD query failed — fall back to NIC DNS suffix...
    ${Script:DomainName} = Get-WmiObject Win32_NetworkAdapterConfiguration `
        | Where-Object { ${_}.IPEnabled -eq ${True} -and ${_}.DNSDomain -and ${_}.DNSDomain -ne '' } `
        | Select-Object -First 1 -ExpandProperty DNSDomain
}
##### If it's not a real domain (e.g., same as hostname), treat it as empty...
if (${Script:DomainName} -eq ${Script:Hostname} -or [String]::IsNullOrWhiteSpace(${Script:DomainName})) {
    ${Script:FQDN} = "${Script:Hostname}"
} else {
    ${Script:FQDN} = "${Script:Hostname}.${Script:DomainName}"
}



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



function Error-Output {
#####
# Purpose:
#  • Write either a formatted ${errorMessage} or unformatted ${customMessage} to the console, using...
#    • -BackgroundColor ${backgroundColor}
#    • -ForegroundColor ${foregroundColor}
#  • Beep in the console.
#  • If ${ExitCode}>0, exit with a status of ${ExitCode}.
#  • If ${errorMessage} contains ${Script:Symbol}.Warn, it will automatically set, unless overriden...
#    • ${backgroundColor} = 'Dark Yellow'
#    • ${foregroundColor} = 'Black'
#  • This is designed so that if only 1 String parameter is passed in, and none of the others, it will default to a Red on Black error & exit with code 1.
#
# Usage:
#  • Parameter -customMessage:   String  — the message to remain unformatted to output as an error; or
#  • Parameter -ExitCode:        Integer — [default=1] if >0, exit with this exit code number.
#  • Parameter -errorMessage:    String  — the message to be formatted to output as an error.
#  • Parameter -backgroundColor: String  — [default='Black'] the background color to use.
#  • Parameter -foregroundColor: String  — [default='Red'] the foreground color to use.
#####
    param(
        [String]${errorMessage},
        [Int]   ${ExitCode}=1,
        [String]${customMessage},
        [String]${backgroundColor},
        [String]${foregroundColor}
    )

    if (-not [String]::IsNullOrEmpty(${customMessage})) {
        ${errorMessage} = ${customMessage}
    } else {
        ${errorMessage} = "`nERROR:  ${errorMessage}`nIf you need help, use option -h.`n"
    }
    if ([Bool]([RegEx]::IsMatch(${errorMessage}, ${Script:Symbol}.Warn))) {
        ${backgroundColor} = $( Is-Valid-Color "${backgroundColor}" 'DarkYellow' )
        ${foregroundColor} = $( Is-Valid-Color "${foregroundColor}" 'Black'      )
    } else {
        ${backgroundColor} = $( Is-Valid-Color "${backgroundColor}" 'Black' )
        ${foregroundColor} = $( Is-Valid-Color "${foregroundColor}" 'Red'   )
    }

    Write-Host `
        "${errorMessage}" `
        -BackgroundColor ${backgroundColor} `
        -ForegroundColor ${foregroundColor}

    [Console]::Beep()

    if (${ExitCode} -lt 0) { ${ExitCode} = 0  }
    if (${ExitCode} -gt 0) { exit ${ExitCode} }
} # END of function Error-Output

function Format-ViewText {
#####
# Purpose:
#  • Reformat ${Script:XmlFormatted} to be plain text.
#  • Return it as a String.
#
# Usage:
#  • No parameters (uses ${Script:XmlFormatted} as input).
#####
    [CmdletBinding()]
    param ()

    ${XmlInput} = ${Script:XmlFormatted}
    ${XmlInput} = ${XmlInput}.TrimStart([char]0xFEFF).Trim()

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
        }
        ${attrSuffix} = if (${attrText}.Count -gt 0) { ' [' + (${attrText} -join ', ') + ']' } else { '' }

        ##### If element has child elements, recurse...
        if ((${node}.ChildNodes | Where-Object { ${_}.NodeType -eq 'Element' }).Count -gt 0) {
            [Void]${stringBuffer}.AppendLine(('{0}{1}{2}:' -f ('  ' * ${indent}), ${label}, ${attrSuffix}))
            foreach (${child} in ${node}.ChildNodes) {
                Add-Node -node ${child} -indent (${indent} + 1)
            }
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
        }
        [Void]${stringBuffer}.AppendLine( ${Script:Divider} )
    }


    return ${stringBuffer}.ToString()
} # END of function Format-ViewText

function Format-View-XML {
#####
# Purpose:
#  • Reformat the list of events to be a formatted XML block.
#  • Return it as a string.
#
# Usage:
#  • No parameters (uses ${Script:EventList} as input).
#####

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
        }

        ##### Append the <EventDetails> block to the <Event>...
        ${RootNode}.AppendChild(${detailsNode}) | Out-Null
    } # END of local function Add-EventDetails
    #####─────EndOf:(Local Helper Function)─────


    #####─────(Main Function Body)─────
    ${eventFragments} = foreach (${eventBlock} in ${Script:EventList}) {
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
    }

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

function Get-Integer ([String]${numberString}) {
#####
# Purpose:
#  • If the number string is not an Integer value, return Null.
#  • Otherwise, return the Integer value.
#
# Usage:
#  • Parameter 1 - ${numberString}: String - a number, inputted as a String, to be outputted as an Integer.
#####
    ##### Local variable, of type Integer, to hold the parsed value...
    [Int]${numberInt} = 0

    ##### Return either Null if not an Integer or the Integer value...
    if (-not [Int]::TryParse(${numberString}, [Ref]${numberInt})) {
        return ${Null}
    } else {
        return ${numberInt}
    }
} # END of function Get-Integer

function Get-Vars (${varsObj}, [String[]]${varExclusions}) {
#####
# Purpose:
#  • Part of the Verbose set of functions.
#  • For each variable name in the variables object, append its name and value, in the form Name='Value'.
#  • Return the entire list, as a String, in the form Name1='Value1', Name2='Value2', ..., NameN='ValueN'.
#
# Usage:
#  • Parameter 1 — ${varsObj}:       [unspecified type] — a multi-variable names & values object (type-checked internally).
#  • Parameter 2 — ${varExclusions}: String             — a list of variable name exclusions, as type String Array.
#####
    ##### If ${varsObj} is of type ValueCollection...
    ${objectType} = ${varsObj}.GetType().Name
    if (${objectType} -eq 'ValueCollection' -or ${objectType} -eq 'ParameterMetadata[]') {
        ##### Build the list of variable names into the form Name1,Name2,...,NameN...
        ${varNamesList} = ${Null}
        foreach (${varID} in ${varsObj}) {
            ${var_Name} = ${varID}.Name
            ##### Skip excluded names (case-insensitive)...
            if (${varExclusions} -contains ${var_Name}) { continue } #foreach loop
            try {
                #### If this succeeds, it's a script-defined parameter...
                Get-Variable -Name ${var_Name} -ErrorAction Stop | Out-Null
            } catch {
                ##### Else, ignore PowerShell-defined Common Parameters...
                continue # foreach loop
            }
            ##### If ${varID} has aliases, append them after ${var_Name}...
            ${varAliases} = if (${varID}.Aliases) { ','+(${varID}.Aliases -join ',') } else { '' }
            if (${varNamesList}) { ${varNamesList} += ',' }
            ${varNamesList} += "${var_Name}${varAliases}"
        }
    ##### If ${varsObj} is NOT of type ValueCollection...
    } else {
        ##### Reject it...
        return 'Input was not a valid ValueCollection type.'
    }

    ##### Iterate through the list of variable names...
    ${varNamesWithValues} = ${Null}
    foreach (${varID} in ${varNamesList} -split ',\s*') {
        ##### Append each pair in the form Name='Value'...
        if (${varNamesWithValues}) { ${varNamesWithValues} += ', ' }
        ${varNamesWithValues} += `
            "${varID}='" + `
            $( Get-Variable -Name ${varID} -ValueOnly -ErrorAction SilentlyContinue ) + `
            "'"
    }

    ##### Return the list in the form Name1='Value1', Name2='Value2', ..., NameN='ValueN'...
    return "${varNamesWithValues}"
} # END of function Get-Vars

function Is-Valid-Color ([String]${intendedColor}, [String]${fallbackColor}) {
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    ${validColors} = @(
        'darkblue','darkgray','darkgreen','darkcyan','darkred','darkmagenta','darkyellow',
        'black','gray','blue','green','cyan','red','magenta','yellow','white'
    )

    if (${validColors} -Contains ${intendedColor}.ToLower()) {
        Processing 2 "${funcName}" "intendedColor='${intendedColor}' is valid."
        return "${intendedColor}"
    } else {
        Processing 2 "${funcName}" "intendedColor='${intendedColor}' is invalid, returning fallbackColor='${fallbackColor}'."
        return "${fallbackColor}"
    }
} # END of function Is-Valid-Color

function Process-Array ([Int]${processLevel}, [String]${processPrefix}, [String]${arrayTitle}, [String[]]${arrayList}) {
#####
# Purpose:
#  • Part of the Verbose set of functions.
#  • If ${Script:Verbose} is less than the processing level integer, simply do nothing by returning.
#  • Otherwise...
#    • Convert the arrayList to text.
#    • Call the Processing function with the data.
#
# Usage:
#  • Parameter 1 — ${processLevel}:     Integer      — the number where ${Script:Verbose} is at or above to activate this function.
#  • Parameter 2 — ${processPrefix}: String       — the prefix title preceeding ${processTitle}.
#  • Parameter 3 — ${arrayTitle}:    String       — the title of the array being processed.
#  • Parameter 4 — ${arrayList}:     String Array — the array being processed.
#####
    if (${Script:Verbose} -lt ${processLevel}) { return }
    ${arrayProcessed} = @()
    ${arrayIndex} = 0
    foreach (${arrayValue} in ${arrayList}) {
        ${valueType} = ${Null}
        if (${arrayValue} -eq ${Null}) {
            ${arrayValue} = "${Script:NullString}"
        } else {
            ${valueType} = ${arrayValue}.GetType().Name
        }
        ${qo} = ''; ${qc} = ''
        if (${valueType} -eq 'string') { ${qo} = "'"; ${qc} = "'" }

        ${arrayProcessed} += "[${arrayIndex}]=${qo}${arrayValue}${qc}"
        ${arrayIndex}++
    }
    ${arrayAsText} = ${arrayProcessed} -join "`n"

    Processing `
        ${processLevel} `
        "${processPrefix}" `
        "${arrayTitle}" `
        "${arrayAsText}"
} # END of function Process-Array

function Process-Params ([Int]${processLevel}, [String]${processPrefix}, [String]${processScope}) {
#####
# Purpose:
#  • Part of the Verbose set of functions.
#  • If ${Script:Verbose} is less than the processing level integer, simply do nothing by returning.
#  • Otherwise...
#    • Get the parameter list of names & values from ${Script:ScriptArgs}.
#    • Call the Processing function with the data.
#
# Usage:
#  • Parameter 1 — ${processLevel}:  Integer — the processing level integer.
#  • Parameter 2 — ${processPrefix}: String  — the prefix title preceeding ${processTitle}.
#  • Parameter 3 — ${processScope}:  String  — the processing scope word or phrase.
#####
    if (${Script:Verbose} -lt ${processLevel}) { return }
    ${parameterList} = Get-Vars ${Script:ScriptArgs}

    Processing `
        ${processLevel} `
        "${processPrefix}" `
        "Parameters ${processScope}" `
        "${parameterList}"
} # END of function Process-Params

function Processing {
#####
# Purpose:
#  • Part of the Verbose set of functions.
#  • If ${Script:Verbose} is less than the processing level integer, simply do nothing by returning.
#  • Otherwise...
#    • If ${processTitle} is Null or WhiteSpace, it simply writes an empty string.
#    • Otherwise...
#      • If ${processTitle} is Null or Empty, it sets ${processMessage} to an empty string.
#      • Else if ${processValue} is Null or Empty, it sets ${processMessage} in the form...
#Processing:${processPrefix}:${processTitle}
#      • Else, it sets ${processMessage} in the form...
#Processing:${processPrefix}:${processTitle} /BEGIN\${process_Divide}
#${processValue}
#Processing:${processPrefix}:${processTitle} \CLOSE/${process_Divide}
#        • Where ${process_Divide} is ${Script:Divider1}${Script:Divider2}${Script:Divider1}.
#      • It uses Write-Host to output ${processMessage}...
#        • Using BackgroundColor Black.
#        • Using ForegroundColor based on ${processLevel}...
#          • 1: Cyan
#          • 2: Yellow
#
# Usage:
#  • Parameter 1 — ${processLevel}:     Integer — the number at or above which ${Script:Verbose} must be to activate this function.
#    • Only 3 levels of verbosity are currently defined, 1-3, with 3 indicating it's a DEBUG-SKIPPING statement.
#  • Parameter 2 — ${processPrefix}: String  — what to prefix ${processTitle}.
#  • Parameter 3 — ${processTitle}:  String  — the title of what it's processing at the moment.
#  • Parameter 4 — ${processValue}:  String  — the value(s) of what it's processing at the moment.
#  • Parameter -Order:               Integer — if used, writes an extra newline, relative to ${processMessage},...
#    • if =1, before
#    • if =2, after
#  • Parameter -Continuation:        Switch  — if used, omits the entire ${processPrefix} and pads an equal number of spaces instead.
#####
    param(
        [Int]   ${processLevel},
        [String]${processPrefix},
        [String]${processTitle},
        [String]${processValue},
        [Int]   ${Order},
        [Switch]${Continuation}
    )

    if (${Script:Verbose} -lt ${processLevel}) { return }
    ${BgColor} = 'Black'
    ${FgColor} = @{
        1 = 'Cyan'
        2 = 'Yellow'
        3 = 'Magenta'
    }

    if ([String]::IsNullOrWhiteSpace(${processPrefix})) {
        ${processMessage} = ''
    } else {
        ##### Determine the proper ${processPrefix}...
        ${processPrefix}  = "Processing:${processPrefix}"
        if (${processLevel} -gt 2) { ${processPrefix} += ':DEBUG-SKIPPING' }
        ${processPrefix} += ':'
        if (${Continuation}) { ${processPrefix} = ' ' * (${processPrefix}.Length) }

        ##### Assemble ${processMessage}...
        ${processMessage} = "${processPrefix}${processTitle}"
        ##### If ${processValue} is defined...
        if (-not [String]::IsNullOrEmpty(${processValue})) {
            ##### Create a before & after divider line...
            ${process_Divide}  = "${Script:Divider1}${Script:Divider2}${Script:Divider1}"
            ${processMessage} += '—Content'
            ${processPrefix1}  = "${processMessage}/BEGIN\${process_Divide}"
            ${processPrefix2}  = "${processMessage}\CLOSE/${process_Divide}"
            ##### Place the before & after divider lines around ${processValue}...
            ${processMessage}  = "${processPrefix1}`n${processValue}`n${processPrefix2}"
        }
    }

    if (${Order} -eq 1) { Write-Host '' } elseif (${Order} -eq 2) { ${processMessage} += "The end.`n" }
    Write-Host `
        "${processMessage}" `
        -BackgroundColor ${BgColor} `
        -ForegroundColor ${FgColor}[${processLevel}]
} # END of function Processing

function Show-Debug {
#####
# Purpose:
#  • Part of the Verbose set of functions.
#  • If ${DoIt} is FALSE, simply do nothing by returning.
#  • Otherwise...
#    • Where...
#      • ${indexBgColor} = 0
#      • ${indexFgColor} = 1
#      • ${indexPrefix}  = 2
#    • Set the ${prefixString} to be ${debugArray}[${indexPrefix}][${debugIndex}].
#    • If ${debugMessage} is not an empty string, append a space to ${prefixString}.
#    • It uses Write-Host to output ${funcName}:${prefixString}${debugMessage}...
#      • Using BackgroundColor ${debugArray}[${indexBgColor}][${debugIndex}].
#      • Using ForegroundColor ${debugArray}[${indexFgColor}][${debugIndex}].
#    • If ${extraNewline} is TRUE, write an extra newline.
#
# Usage:
#  • Parameter 1 -DotIt         Boolean         (REQUIRED) — a boolean passed in from the calling function indicating whether or not to active.
#  • Parameter 2 -funcName      String          (REQUIRED) — the name of the calling function.
#  • Parameter 3 -debugArray    2D String Array (REQUIRED) — an array of the form (2nd dimension # of elements dependent on the calling function)...
#    • Array [0] = BgColor0, ..., BgColorN
#    • Array [1] = FgColor0, ..., FgColorN
#    • Array [2] = Prefix0,  ..., PrefixN
#  • Parameter 4 -debugIndex    Integer         (REQUIRED) — the 2nd dimension index number to use from -debugArray.
#  • Parameter 5 -debugMessage  String                     — the debug message to output.
#  • Parameter 6 -extraNewline  Boolean                    — whether or not to write an additional newline at the end.
#####
    param (
        [Parameter(Mandatory=${True})][Bool]${DoIt},
        [Parameter(Mandatory=${True})][String]${funcName},
        [Parameter(Mandatory=${True})][String[][][]]${debugArray},
        [Parameter(Mandatory=${True})][Int]${debugIndex},
        [Parameter(Mandatory=${False})][String]${debugMessage},
        [Parameter(Mandatory=${False})][Bool]${extraNewline}
    )

    if (-not ${DoIt}) { return }
    [Int]   ${indexBgColor} = 0
    [Int]   ${indexFgColor} = 1
    [Int]   ${indexPrefix}  = 2
    [String]${prefixString} = ${debugArray}[${indexPrefix}][${debugIndex}]

    if (${debugMessage} -eq ${Null}) { ${debugMessage}  = ''  }
    if (${debugMessage} -ne ''     ) { ${prefixString} += ' ' }

    Write-Host `
        "${funcName}:${prefixString}${debugMessage}" `
        -BackgroundColor ${debugArray}[${indexBgColor}][${debugIndex}] `
        -ForegroundColor ${debugArray}[${indexFgColor}][${debugIndex}]
    if (${extraNewline}) { Write-Host '' }
} # END of function Show-Debug

function Show-help {
#####
# Purpose:
#  • Output the help block from the top of this script, between the <#-HELP-# and #-HELP-#> lines.
#  • If it doesn't find the block, it prints an error.
#
# Usage:
#  • No parameters (it uses ${Script:Script_Dir}\${Script:ScriptBase} as input between the lines beginning with <#-HELP-# and #-HELP-#>
#####
    ${script} = "${Script:Script_Dir}\${Script:ScriptBase}"

    ${helpBlock}    = ''
    ${helpTagBegin} = '<#-HELP-#'
    ${helpTagClose} = '#-HELP-#>'
    ${helpLines}    = Get-Content -Path ${script}
    ${helpLineClose}= -1
    ${helpLineStart}= -1
    ${termWidth}    = ${Host}.UI.RawUI.WindowSize.Width

    for (${i} = 0; ${i} -lt ${helpLines}.Count; ${i}++) {
        if (${helpLineStart} -eq -1 -and ${helpLines}[${i}] -like "${helpTagBegin}*") {
            ${helpLineStart} = ${i}
        }
        elseif (${helpLineClose} -eq -1 -and ${helpLines}[${i}] -like "${helpTagClose}*") {
            ${helpLineClose} = ${i}
        }
        if (${helpLineStart} -ne -1 -and ${helpLineClose} -ne -1) { break } # for loop
    }

    if (${helpLineStart} -ge 0 -and ${helpLineClose} -gt ${helpLineStart}) {
        ${helpBlock} = ${helpLines}[(${helpLineStart}+1)..(${helpLineClose}-1)] -join "`n"
        ${lineIndent} = [RegEx]::Match(${originalLine}, '^\s*').Value
        ${helpBlock} = ${helpBlock} -split '\r?\n'
        foreach (${l} in ${helpBlock}) {
            if ([String]::IsNullOrWhiteSpace(${l})) {
                ''
            } else {
                Wrap-Text ${l}
            }
        }
    } else {
        Write-Host ''
        Write-Warning "No help block found in ${script}.`
The help block must begin with ${helpTagBegin} & end with ${helpTagClose}"
        Write-Host ''
    }
    exit 0
} # END of function Show-help

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
#  • Appends its output to ${Script:Output}.
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
        [Parameter(Mandatory=${True})][String]${tagName},
        [Parameter(Mandatory=${True})][Int]${tagSpacing},
        [Parameter(Mandatory=${True})][String]${tagType},
        [Parameter(Mandatory=${False})][String]${tag_Text},
        [Parameter(Mandatory=${False})][String]${tagValue},
        [Parameter(Mandatory=${False})][String]${tagLabel},
        [Parameter(Mandatory=${False})][Int]${value_label_max}
    )

    ${doDebug} = ${False}
    #${doDebug} = ${True}
    ##### Debug BEFORE...
    ${funcName}   = $( ${MyInvocation}.MyCommand.Name )
    ##### [0]        [1]        [2]      [3]      [4]      [5]
    ${debugArray} = @(
        @('DarkCyan','DarkCyan','Cyan',  'Red',   'Black', 'DarkGreen'),
        @('Black',   'Black',   'Black', 'Black', 'Green', 'Black'),
        @('BEFORE',  'MIDDLE',  'SCOPED','RETURN','FORMAT','OUTPUT')
    )
    ${excludeVars} = @('value_label_max')
    Show-Debug `
        -DoIt         ${doDebug} `
        -funcName     "${funcName}" `
        -debugArray   ${debugArray} `
        -debugIndex   0 `
        -debugMessage $( Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values ${excludeVars} )

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
        Show-Debug `
            -DoIt         ${doDebug} `
            -funcName     "${funcName}" `
            -debugArray   ${debugArray} `
            -debugIndex   1 `
            -debugMessage $( Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values ${excludeVars} )

        if (${tagString}.Length -gt 0 -and ${tagMax} -ge ${tagString}.Length) { ${fillerStr} = "${fillerChr}" * (${tagMax} - ${tagString}.Length) }
        ${Script:Summary} += "${tagString}${fillerStr}${tag_Text}`n"
        ##### Re-initialize ${tagString} back to empty...
        ${tagString} = ''
    } elseif (${tagName} -eq 'WorkingDirectory') {
        if (-not ${tag_Text}.EndsWith('\')) { ${tag_Text} += '\' }
    }
    if ([String]::IsNullOrWhiteSpace(${tagType})) { ${tagType} = 'Whole' }
    if (${tagSpacing} -lt 0) { ${tagSpacing} = 0 }
    if (-not [String]::IsNullOrWhiteSpace(${tagValue})) { if (-not ${Script:DoText}) { ${tagValue} = " Value=`"${tagValue}`"" } } else { ${tagValue} = '' }
    if (-not [String]::IsNullOrWhiteSpace(${tagLabel})) { if (-not ${Script:DoText}) { ${tagLabel} = " Label=`"${tagLabel}`"" } } else { ${tagLabel} = '' }
    ##### Debug SCOPED...
    Show-Debug `
        -DoIt         ${doDebug} `
        -funcName     "${funcName}" `
        -debugArray   ${debugArray} `
        -debugIndex   2 `
        -debugMessage $( Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values ${excludeVars} )

    ##### If Text format...
    if (${DoText}) {
        if (${tagType} -ne 'Whole') {
            ##### Debug RETURN...
            Show-Debug `
                -DoIt         ${doDebug} `
                -funcName     "${funcName}" `
                -debugArray   ${debugArray} `
                -debugIndex   3 `
                -debugMessage "`n"
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
    }
    ##### Debug FORMAT...
    Show-Debug `
        -DoIt         ${doDebug} `
        -funcName     "${funcName}" `
        -debugArray   ${debugArray} `
        -debugIndex   4 `
        -debugMessage $( Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values ${excludeVars} )

    ##### Assemble based on ${tagType}...
        if (${tagType} -eq 'Begin') {
        ${tagString} = "${tagBegin}"
    } elseif (${tagType} -eq 'Whole') {
        ${tagString} = "${tagBegin}${tag_Text}${tagClose}"
    } elseif (${tagType} -eq 'Close') {
        ${tagString} = "${tagClose}"
    }

    ##### Debug OUTPUT...
    Show-Debug `
        -DoIt         ${doDebug} `
        -funcName     "${funcName}" `
        -debugArray   ${debugArray} `
        -debugIndex   5 `
        -debugMessage $( Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values ${excludeVars} )`
        -extraNewline ${True}

    ##### Assign it...
    ${Script:Output} += "${tagString}"
} # END of function Summary-Line

function Wrap-Text {
#####
# Purpose:
#  • For each line of text in the ${textToWrap} string array, wrap lines longer than ${termWidth} at word breaks.
#
# Usage:
#  • Parameter 1 — ${textToWrap}: String Array (REQUIRED) — an array of text lines to be wrapped according to -termWidth.
#  • Parameter 2 — ${termWidth}:  Integer                 — the width of the terminal (defaults to the ${Host}.UI.RawUI.WindowSize.Width).
#####
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=${True}, ValueFromPipeline=${True})][String[]]${textToWrap},
        [Int]${termWidth} = ${Host}.UI.RawUI.WindowSize.Width
    )

    foreach (${originalLine} in ${textToWrap}) {
        ##### Capture *all* leading whitespace exactly as-is...
        ${lineIndent} = [RegEx]::Match(${originalLine}, '^[ \t]*').Value
        ${availableWidth} = ${termWidth} - ${lineIndent}.Length

        ##### Remove only the indent for wrapping logic...
        ${lineContent} = ${originalLine}.Substring(${lineIndent}.Length)

        ${lineWords} = ${lineContent} -split ' '
        ${currentLine} = ''
        foreach (${currentWord} in ${lineWords}) {
            if ((${currentLine}.Length + ${currentWord}.Length + 1) -gt ${availableWidth}) {
                Write-Output (${lineIndent} + ${currentLine}.TrimEnd())
                ${currentLine} = "${currentWord} "
            } else {
                ${currentLine} += "${currentWord} "
            }
        }
        if (${currentLine}) {
            Write-Output (${lineIndent} + ${currentLine}.TrimEnd())
        }
    }
} # END of function Wrap-Text



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
##### Process & validate all parameters...
#####

#####
# -v
# -Verbosity
# Always do this one first.
#####
if (${Verbosity}) { ${Script:Verbose} = ${Verbosity} }
Processing 1 'MAIN ' 'Parameters' -Order 1
Process-Params 2 'MAIN' 'BEFORE'

#####
# -h
# -Help
#####
if (${Help}) { Show-help }

#####
# -d
# -Days
# -r
# -Range
#####
##### -d & -r are mutually exclusive and one is required...
${Days} = $( Get-Integer "${Days}" )
if (-not ${Days} -and -not ${Range} ) { Error-Output 'You must specify either -d (days ago) or -r (date range), but not both.' }
##### If -d, calculate start date from ${Days}...
if ( [Bool]${Days} -or (${Days} -eq 0) ) {
    ##### Validate the number of days parameter, which must be an integer >=0...
    if (${Days} -lt 0) { Error-Output 'You must specify the parameter to -d (days ago) as an integer >=0.' }
    ##### Mightnight of target number (${Days}) days ago, where 0=today at midnight...
    ${Script:DateFrom} = (Get-Date).Date.AddDays(-${Days})
    ##### Today's date & current time...
    ${Script:DateThru} =  Get-Date
##### If -r, parse date range from ${Range} as "from,to"...
} else {
    ##### Validate the date range is (from,to) in "yyyy-mm-dd,yyyy-mm-dd" format and that to>=from...
    ${Script:DateFrom}, ${Script:DateThru} = ${Range} -split ',' | ForEach-Object {
        try { [DateTime]::Parse(${_}.Trim()) } catch {
            Error-Output "Invalid date format '${_}'.`nWith -r, you must include exactly 2 dates (from,to) in `"yyyy-mm-dd,yyyy-mm-dd`" format."
        }
    }
    if (${Script:DateThru} -lt ${Script:DateFrom}) { Error-Output 'With -r, end date must be on or after start date.' }
    ##### Extend end date to include full day
    ${Script:DateThru} = ${Script:DateThru}.AddDays(1).AddSeconds(-1)
}

#####
# -l
# -Level
#####
if (-not ${MaxLevel}) { Error-Output 'You must specify the max log level with -l [1-5].' }

#####
# -n
# -Names
#####
##### If not -n, default to System...
if ([String]::IsNullOrWhitespace(${Names})) { ${Names} = 'System' }
##### Parse the log name inclusion list...
${Script:IncludedString} = ${Names}
${Script:IncludedNames}  = ${Names} -split ',' | ForEach-Object { ${_}.Trim() }


#####
# -q
# -Quote
# -qo
# -QuoteOpening
# -qc
# -QuoteClosing
#####
##### -q, -qo, & -qc can only be used with -t...
if (-not ${Text} -and (${Quote} -or ${QuoteOpening} -or ${QuoteClosing})) {
    Error-Output 'You can only use options -q, -qo, and -qc with -t.'
}
##### -qo & -qc must be non-empty...
if (${QuoteOpening} -and [String]::IsNullOrEmpty(${QuoteOpening})) {
    Error-Output "Invalid use of -qo.`nYou must include a character(s) (escaped or quoted as needed) for the opening quote."
}
if (${QuoteClosing} -and [String]::IsNullOrEmpty(${QuoteClosing})) {
    Error-Output "Invalid use of -qc.`nYou must include a character(s) (escaped or quoted as needed) for the closing quote."
}
##### If not -q, unset the globals...
if (-not ${Quote}) { ${Script:QO} = '';  ${Script:QC} = '' }
##### If -qo is used, always assign it to ${Script:QO}, even if -q was used earlier (-qo overrides -q)...
if (${QuoteOpening}) { ${Script:QO} = "${QuoteOpening}" }
##### If -qc is used, always assign it to ${Script:QC}, even if -q was used earlier (-qc overrides -q)...
if (${QuoteClosing}) { ${Script:QC} = "${QuoteClosing}" }
#####
# At this point, if any of -q, -qo, &/or -qc were used, both globals should be populated.
#####
##### If -qo is used but not -qc, set ${Script:QC} to ${QuoteOpening} (-qo overrides -q)...
if (${QuoteOpening} -and -not ${QuoteClosing}) { ${Script:QC} = "${QuoteOpening}" }
##### If -qc is used but not -qo, set ${Script:QO} to ${QuoteClosing} (-qc overrides -q)...
if (${QuoteClosing} -and -not ${QuoteOpening}) { ${Script:QO} = "${QuoteClosing}" }

#####
# -t
# -Text
#####
${Script:DoText} = $(if (${Text}) { ${True} } else { ${False} })

#####
# -x
# -ExcludeIDs
#####
##### If -x, parse the exclusion list...
if (${ExcludeIDs}) { ${Script:ExcludedIDs} = ${ExcludeIDs} -split ',' | ForEach-Object { ${_}.Trim() } | Where-Object { ${_} -match '^\d+$' } }

Process-Params 2 'MAIN' 'SCOPED'



#####
##### Retrieve and filter all events within the range of ${Script:DateFrom} and ${Script:DateThru} where Level<=${MaxLevel}...
#####

Processing 1 'MAIN' `
    "Get-WinEvent excluding '${Script:ExcludedIDs}' where Level<=${MaxLevel} StartTime='${Script:DateFrom}' 'EndTime=${Script:DateThru}'..."
Processing 1 'MAIN' "  foreach LogName in '${Script:IncludedString}'..." -Continuation
foreach (${Script:LogName} in ${Script:IncludedNames}) {
    Processing 1 'MAIN' "    where LogName='${Script:LogName}'" -Continuation
    ${Script:EventList} += Get-WinEvent -FilterHashtable @{
        LogName   = "${Script:LogName}"
        StartTime =  ${Script:DateFrom}
        EndTime   =  ${Script:DateThru}
    } -ErrorAction SilentlyContinue | Where-Object {
        ${_}.Level -le ${MaxLevel} -and
        (${Script:ExcludedIDs} -notcontains ${_}.Id)
    }
}
Processing 1 'MAIN' "Raw event count: $(${Script:EventList}.Count)"
Process-Array `
    2 `
    'MAIN' `
    'Brief ${Script:EventList}' `
    @( ${Script:EventList} | ForEach-Object { '{0} | {1} | {2}' -f ${_}.Id, ${_}.LevelDisplayName, ${_}.TimeCreated } )


#####
##### Summarize by ${Script:LevelValue} (${MaxLevel}) in ${Script:LevelList}...
#####

Processing 1 'MAIN' 'Assembling Summary'
${Script:Description} = "Event report for Level ${MaxLevel} "+$(if (${MaxLevel} -gt 1) { 'or lower' } else { 'only' })+', where...'
if (${Script:DoText}) {
    ${Script:Description} = "Summary — ${Script:Description}"
    ${Script:Output} += "${Script:Divider}"
    ${Script:Output} += "${Script:Divider}"
} else {
    ${Script:Output} += '<?xml version="1.0" encoding="utf-16"?>'
}
    Summary-Line 'Report'           0 'Begin'
    Summary-Line 'Summary'          2 'Begin'
    Summary-Line 'Description'      4 'Whole' "${Script:Description}"
    Summary-Line 'ReportingHost'    4 'Whole' "${Script:FQDN}"
    Summary-Line 'RangeFrom'        4 'Whole' "${Script:DateFrom}"
    Summary-Line 'RangeThru'        4 'Whole' "${Script:DateThru}"
foreach (${Script:LevelValue} in 1..${MaxLevel}) {
    ${Script:LevelLabel} =  ${Script:LevelList}[${Script:LevelValue}]
    ${Script:LevelCount} = (${Script:EventList} | Where-Object { ${_}.LevelDisplayName -eq ${Script:LevelLabel} }).Count
    Summary-Line 'LevelCount'       4 'Whole' "${Script:LevelCount} events found" "${Script:LevelValue}" "${Script:LevelLabel}" 29
}
    Summary-Line 'WorkingDirectory' 4 'Whole' "${Script:Script_Dir}"
    Summary-Line 'Execution'        4 'Whole' "${Script:ScriptCall}"
    Summary-Line 'Summary'          2 'Close'
if (${Script:DoText}) {
    ${Script:Output} += "${Script:Divider}"
    ${Script:Output} += "${Script:Divider}"
}
Process-Array `
    2 `
    'MAIN' `
      '${Script:Output}'`
    @( ${Script:Output} )


#####
##### Add XML or plain text event entries to ${Script:Output}...
#####

Processing 1 'MAIN' 'Assembling Output'
##### Assemble all event records into ${Script:XmlString}...
${Script:XmlString} = `
    "<Events>`n" +`
    $(
        (
            ${Script:EventList} | ForEach-Object { ${_}.ToXml() }
        ) -join "`n"
    ) +`
    "`n</Events>"
##### Show the contents of ${Script:XmlString} when ${Script:Verbose}>=2...
Process-Array `
    2 `
    'MAIN' `
      '${Script:XmlString}' `
    @( ${Script:XmlString} )

##### Format into XML UTF-16...
${Script:XmlFormatted} = Format-View-XML
##### Show the contents of ${Script:XmlFormatted} when ${Script:Verbose}>=2...
Process-Array `
    2 `
    'MAIN' `
     '${Script:XmlFormatted}' `
     @( ${Script:XmlFormatted} )
##### Append to ${Script:Output} according to ${Script:DoText}...
if (${Script:DoText}) {
    ##### Convert to plain text...
    ${Script:Output} += Format-ViewText
} else {
    ##### Keep it as XML UTF-16...
	${Script:Output} += ${Script:XmlFormatted}
}

##### If XML, append the final closing </Report> tag...
if (-not ${Script:DoText}) { ${Script:Output} += '</Report>' }
##### Show the conents of ${Script:Output} when ${Script:Verbose}>=2...
Process-Array `
    2 `
    'MAIN' `
      '${Script:Output}' `
    @( ${Script:Output} )


#####
##### Write the final ${Script:Output} either to a file or the console...
#####

if (${OutFile}) {
    ##### To file in ${OutFile}...
    Processing 1 'MAIN' "Output through Out-File -FilePath '${OutFile}' -Encoding Unicode..."
    ${Script:Output} | Out-File -FilePath ${OutFile} -Encoding Unicode
    Write-Host "🆗, output written to:'${OutFile}'"
} else {
    ##### To console...
    Processing 1 'MAIN' 'Output using Write-Host...'
    ${Script:Output} | ForEach-Object { ${_}.ToString() } | Write-Host

    ##### Final debug output, if uncommented...
    #${Script:Output} | ForEach-Object {
    #    Write-Host ("TYPE={0} LEN={1} VAL=>>{2}<<" -f ${_}.GetType().Name, ${_}.ToString().Length, ${_}) -ForegroundColor Cyan
    #}
}
Processing 1 'MAIN' "Final summary...`n${Script:Summary}" -Order 2



#####
##### The end.
#####
