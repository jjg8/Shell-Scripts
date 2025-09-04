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
##### Because these are all Global scope, they need to be correctly typed...
#####
# Otherwise, an incorrect type will survive after script execution.
# Any declaration in [] on its own line, needs to have ` after it, otherwise it announces the type info to the console.
#####

[DateTime] ${Global:DateFrom}       = Get-Date
[DateTime] ${Global:DateThru}       = Get-Date
[String]   ${Global:Description}    = ''
[String]   ${Global:Divider}        = '────────────────' # Just some horizontal lines (or customize to suit)
[String]   ${Global:DomainName}     = ''     # Set below
[Bool]     ${Global:DoText}         = ${False}
[System.Collections.ArrayList]`
           ${Global:EventList}      = @()    # Empty system events array
[Int[]]    ${Global:ExcludedIDs}    = @()    # Empty integer array
[String]   ${Global:FQDN}           = ''     # Set below
[String]   ${Global:Hostname}       = ${Env:ComputerName}
[String]   ${Global:IncludedString} = ''
[String]   ${Global:IncludedNames}  = ''
[Int]      ${Global:LevelCount}     = 0
[String]   ${Global:LevelLabel}     = ''
[HashTable]${Global:LevelList}      = @{
    1 = 'Critical'
    2 = 'Error'
    3 = 'Warning'
    4 = 'Information'
    5 = 'Verbose'
}
[Int]      ${Global:LevelValue}     = 0
[String[]] ${Global:Output}         = @() # Empty string array
[String]   ${Global:QC}             = ''  # Set below
[String]   ${Global:QO}             = ''  # Set below
[String]   ${Global:Script_Dir}     = ${PWD}.Path
[String]   ${Global:ScriptBase}     = Split-Path -Leaf ${MyInvocation}.MyCommand.Path
[String]   ${Global:ScriptCall}     = ${MyInvocation}.Line
[System.Management.Automation.ParameterMetadata[]]`
           ${Global:ScriptArgs}     = $( Get-Command ${PSCmdlet}.MyInvocation.InvocationName ).Parameters.Values
[String]   ${Global:Summary}        = ''  # Used only if ${Global:Verbose}>0
[Int]      ${Global:Verbose}        = 0
[String]   ${Global:XmlFormatted}   = ''
[String]   ${Global:XmlString}      = ''


#####
##### Set defaults quotes...
#####
# QO = opening quote
# QC = closing quote
#####
${Global:QO} = '"';  ${Global:QC} = '"' # E.g. "string"
##### Other ideas (customize to suit)...
#${Global:QO} = '«'; ${Global:QC} = '»' # E.g. «string»
#${Global:QO} = '“'; ${Global:QC} = '”' # E.g. “string”
#${Global:QO} = '‹'; ${Global:QC} = '›' # E.g. ‹string›
#${Global:QO} = "‘"; ${Global:QC} = "’" # E.g. ‘string’


#####
##### Assemble ${Global:FQDN} from ${Global:Hostname} and ${Global:DomainName} if set...
#####

##### Try to get the DNS domain name, or ${Null} if none...
try {
    ##### Try to get the AD DNS domain name...
    ${Global:DomainName} = ([System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()).Name
} catch {
    ##### Not domain-joined or AD query failed — fall back to NIC DNS suffix...
    ${Global:DomainName} = Get-WmiObject Win32_NetworkAdapterConfiguration `
        | Where-Object { ${_}.IPEnabled -eq ${True} -and ${_}.DNSDomain -and ${_}.DNSDomain -ne '' } `
        | Select-Object -First 1 -ExpandProperty DNSDomain
}
##### If it's not a real domain (e.g., same as hostname), treat it as empty...
if (${Global:DomainName} -eq ${Global:Hostname} -or [String]::IsNullOrWhiteSpace(${Global:DomainName})) {
    ${Global:FQDN} = "${Global:Hostname}"
} else {
    ${Global:FQDN} = "${Global:Hostname}.${Global:DomainName}"
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



function Error-Output ([String]${errorMessage}) {
#####
# Purpose:
#  • Write ${errorMessage} to the console.
#  • Beep in the console.
#  • Exit with a status of 1.
#
# Usage:
#  • Parameter 1 - ${errorMessage}: String - the message to output as an error.
#####
    ${errorMessage} = "`nERROR:  ${errorMessage}`nIf you need help, use option -h.`n"
    Write-Host "${errorMessage}" -ForegroundColor Red
    [Console]::Beep()
    exit 1
} # END of function Error-Output

function Format-ViewText {
#####
# Purpose:
#  • Reformat ${Global:XmlFormatted} to be plain text.
#  • Return it as a String.
#
# Usage:
#  • No parameters (uses ${Global:XmlFormatted} as input).
#####
    [CmdletBinding()]
    param ()

    ${XmlInput} = ${Global:XmlFormatted}
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
        [Void]${stringBuffer}.AppendLine( ${Global:Divider} )
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
#  • No parameters (uses ${Global:EventList} as input).
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
    ${eventFragments} = foreach (${eventBlock} in ${Global:EventList}) {
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
#  • Parameter 1 - ${varsObj}:       [unspecified type] - a multi-variable names & values object (type-checked internally).
#  • Parameter 2 - ${varExclusions}: String             - a list of variable name exclusions, as type String Array.
#####
    ##### If ${varsObj} is of type ValueCollection...
    if (${varsObj}.GetType().Name -eq 'ValueCollection') {
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

function Process-Params ([Int]${procLevel}, [String]${processScope}) {
#####
# Purpose:
#  • Part of the Verbose set of functions.
#  • If ${Global:Verbose} is less than the processing level integer, simply do nothing by returning.
#  • Otherwise...
#    • Get the parameter list of names & values from ${Global:ScriptArgs}.
#    • Call the Processing function with the data.
#
# Usage:
#  • Parameter 1 - ${procLevel}:    Integer - the processing level integer.
#  • Parameter 2 - ${processScope}: String  - the processing scope word or phrase.
#####
    if (${Global:Verbose} -lt ${procLevel}) { return }
    ${parameterList} = Get-Vars ${Global:ScriptArgs}
    Processing ${procLevel} "Parameters ${processScope}" "${parameterList}"
} # END of function Process-Params

function Process-Array ([Int]${procLevel}, [String]${arrayTitle}, [String[]]${arrayList}) {
#####
# Purpose:
#  • Part of the Verbose set of functions.
#  • If ${Global:Verbose} is less than the processing level integer, simply do nothing by returning.
#  • Otherwise...
#    • Convert the arrayList to text.
#    • Call the Processing function with the data.
#
# Usage:
#  • Parameter 1 - ${procLevel}:  Integer      - the number where ${Global:Verbose} is at or above to activate this function.
#  • Parameter 2 - ${arrayTitle}: String       - the title of the array being processed.
#  • Parameter 3 - ${arrayList}:  String Array - the array being processed.
#####
    if (${Global:Verbose} -lt ${procLevel}) { return }
    ${arrayAsText} = ${arrayList} -join "`n"
    Processing ${procLevel} "${arrayTitle}" "${arrayAsText}"
} # END of function Process-Array

function Processing ([Int]${procLevel}, [String]${processWhat}, [String]${processContent}) {
#####
# Purpose:
#  • Part of the Verbose set of functions.
#  • If ${Global:Verbose} is less than the processing level integer, simply do nothing by returning.
#  • Otherwise...
#    • If ${processWhat} is Null or WhiteSpace, it simply writes an empty string.
#    • Otherwise...
#      • If ${processWhat} is Null or Empty, it sets ${processMessage} in the form...
#Processing:${processWhat}
#      • Otherwise, it sets ${processMessage} in the form...
#Processing:${processWhat} /BEGIN\${processDivide}
#${processContent}
#Processing:${processWhat} \CLOSE/${processDivide}
#        • Where ${processDivide} is ${Global:Divider}●●●●●${Global:Divider}.
#      • It uses Write-Host to output ${processMessage}...
#        • Using BackgroundColor Black.
#        • Using ForegroundColor based on ${procLevel}...
#          • 1: Cyan
#          • 2: Yellow
#
# Usage:
#  • Parameter 1 - ${procLevel}:      Integer - the number at or above which ${Global:Verbose} must be to activate this function.
#    • Only 2 levels of verbosity are currently defined, 1 or 2.
#  • Parameter 2 - ${processWhat}:    String  - the title of what it's processing at the moment.
#  • Parameter 3 - ${processContent}: String  - the content of what it's processing at the moment.
#####
    if (${Global:Verbose} -lt ${procLevel}) { return }
    ${BgColor} = 'Black'
    ${FgColor} = @{
        1 = 'Cyan'
        2 = 'Yellow'
    }

    if ([String]::IsNullOrWhiteSpace(${processWhat})) {
        ${processMessage} = ''
    } else {
        ${processMessage} = "Processing:${processWhat}"
        if (-not [String]::IsNullOrEmpty(${processContent})) {
            ${processDivide}  = "${Global:Divider}●●●●●${Global:Divider}"
            ${processPrefix1} = "${processMessage} /BEGIN\${processDivide}"
            ${processPrefix2} = "${processMessage} \CLOSE/${processDivide}"
            ${processMessage} = "${processPrefix1}`n${processContent}`n${processPrefix2}"
        }
    }

    Write-Host `
        "${processMessage}" `
        -BackgroundColor ${BgColor} `
        -ForegroundColor ${FgColor}[${procLevel}]
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
#  • Parameter 1 -DotIt         Boolean         (REQUIRED) - a boolean passed in from the calling function indicating whether or not to active.
#  • Parameter 2 -funcName      String          (REQUIRED) - the name of the calling function.
#  • Parameter 3 -debugArray    2D String Array (REQUIRED) - an array of the form (2nd dimension # of elements dependent on the calling function)...
#    • Array [0] = BgColor0, ..., BgColorN
#    • Array [1] = FgColor0, ..., FgColorN
#    • Array [2] = Prefix0,  ..., PrefixN
#  • Parameter 4 -debugIndex    Integer         (REQUIRED) - the 2nd dimension index number to use from -debugArray.
#  • Parameter 5 -debugMessage  String                     - the debug message to output.
#  • Parameter 6 -extraNewline  Boolean                    - whether or not to write an additional newline at the end.
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
#  • No parameters (it uses ${Global:Script_Dir}\${Global:ScriptBase} as input between the lines beginning with <#-HELP-# and #-HELP-#>
#####
    ${script} = "${Global:Script_Dir}\${Global:ScriptBase}"

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
#  • Appends its output to ${Global:Output}.
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
        ${Global:Summary} += "${tagString}${fillerStr}${tag_Text}`n"
        ##### Re-initialize ${tagString} back to empty...
        ${tagString} = ''
    } elseif (${tagName} -eq 'WorkingDirectory') {
        if (-not ${tag_Text}.EndsWith('\')) { ${tag_Text} += '\' }
    }
    if ([String]::IsNullOrWhiteSpace(${tagType})) { ${tagType} = 'Whole' }
    if (${tagSpacing} -lt 0) { ${tagSpacing} = 0 }
    if (-not [String]::IsNullOrWhiteSpace(${tagValue})) { if (-not ${Global:DoText}) { ${tagValue} = " Value=`"${tagValue}`"" } } else { ${tagValue} = '' }
    if (-not [String]::IsNullOrWhiteSpace(${tagLabel})) { if (-not ${Global:DoText}) { ${tagLabel} = " Label=`"${tagLabel}`"" } } else { ${tagLabel} = '' }
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
    ${Global:Output} += "${tagString}"
} # END of function Summary-Line

function Wrap-Text {
#####
# Purpose:
#  • For each line of text in the ${textToWrap} string array, wrap lines longer than ${termWidth} at word breaks.
#
# Usage:
#  • Parameter 1 - ${textToWrap}: String Array (REQUIRED) - an array of text lines to be wrapped according to -termWidth.
#  • Parameter 2 - ${termWidth}:  Integer                 - the width of the terminal (defaults to the ${Host}.UI.RawUI.WindowSize.Width).
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
if (${Verbosity}) { ${Global:Verbose} = ${Verbosity} }
Processing 1 ''
Processing 1 'Parameters'
Process-Params 2 'BEFORE'

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
    ${Global:DateFrom} = (Get-Date).Date.AddDays(-${Days})
    ##### Today's date & current time...
    ${Global:DateThru} =  Get-Date
##### If -r, parse date range from ${Range} as "from,to"...
} else {
    ##### Validate the date range is (from,to) in "yyyy-mm-dd,yyyy-mm-dd" format and that to>=from...
    ${Global:DateFrom}, ${Global:DateThru} = ${Range} -split ',' | ForEach-Object {
        try { [DateTime]::Parse(${_}.Trim()) } catch {
            Error-Output "Invalid date format '${_}'.`nWith -r, you must include exactly 2 dates (from,to) in `"yyyy-mm-dd,yyyy-mm-dd`" format."
        }
    }
    if (${Global:DateThru} -lt ${Global:DateFrom}) { Error-Output 'With -r, end date must be on or after start date.' }
    ##### Extend end date to include full day
    ${Global:DateThru} = ${Global:DateThru}.AddDays(1).AddSeconds(-1)
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
${Global:IncludedString} = ${Names}
${Global:IncludedNames}  = ${Names} -split ',' | ForEach-Object { ${_}.Trim() }


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
if (-not ${Quote}) { ${Global:QO} = '';  ${Global:QC} = '' }
##### If -qo is used, always assign it to ${Global:QO}, even if -q was used earlier (-qo overrides -q)...
if (${QuoteOpening}) { ${Global:QO} = "${QuoteOpening}" }
##### If -qc is used, always assign it to ${Global:QC}, even if -q was used earlier (-qc overrides -q)...
if (${QuoteClosing}) { ${Global:QC} = "${QuoteClosing}" }
#####
# At this point, if any of -q, -qo, &/or -qc were used, both globals should be populated.
#####
##### If -qo is used but not -qc, set ${Global:QC} to ${QuoteOpening} (-qo overrides -q)...
if (${QuoteOpening} -and -not ${QuoteClosing}) { ${Global:QC} = "${QuoteOpening}" }
##### If -qc is used but not -qo, set ${Global:QO} to ${QuoteClosing} (-qc overrides -q)...
if (${QuoteClosing} -and -not ${QuoteOpening}) { ${Global:QO} = "${QuoteClosing}" }

#####
# -t
# -Text
#####
${Global:DoText} = $(if (${Text}) { ${True} } else { ${False} })

#####
# -x
# -ExcludeIDs
#####
##### If -x, parse the exclusion list...
if (${ExcludeIDs}) { ${Global:ExcludedIDs} = ${ExcludeIDs} -split ',' | ForEach-Object { ${_}.Trim() } | Where-Object { ${_} -match '^\d+$' } }

Process-Params 2 'SCOPED'



#####
##### Retrieve and filter all events within the range of ${Global:DateFrom} and ${Global:DateThru} where Level<=${MaxLevel}...
#####

Processing 1 "Get-WinEvent excluding '${Global:ExcludedIDs}' where Level<=${MaxLevel} StartTime='${Global:DateFrom}' 'EndTime=${Global:DateThru}'..."
Processing 1 "  foreach LogName in '${Global:IncludedString}'..."
foreach (${Global:LogName} in ${Global:IncludedNames}) {
    Processing 1 "    where LogName='${Global:LogName}'"
    ${Global:EventList} += Get-WinEvent -FilterHashtable @{
        LogName   = "${Global:LogName}"
        StartTime =  ${Global:DateFrom}
        EndTime   =  ${Global:DateThru}
    } -ErrorAction SilentlyContinue | Where-Object {
        ${_}.Level -le ${MaxLevel} -and
        (${Global:ExcludedIDs} -notcontains ${_}.Id)
    }
}
Processing 1 "Raw event count: $(${Global:EventList}.Count)"
Process-Array 2 `
    'Brief ${Global:EventList}' `
    @( ${Global:EventList} | ForEach-Object { '{0} | {1} | {2}' -f ${_}.Id, ${_}.LevelDisplayName, ${_}.TimeCreated } )


#####
##### Summarize by ${Global:LevelValue} (${MaxLevel}) in ${Global:LevelList}...
#####

Processing 1 'Assembling Summary'
${Global:Description} = "Event report for Level ${MaxLevel} "+$(if (${MaxLevel} -gt 1) { 'or lower' } else { 'only' })+', where...'
if (${Global:DoText}) {
    ${Global:Description} = "Summary — ${Global:Description}"
    ${Global:Output} += "${Global:Divider}"
    ${Global:Output} += "${Global:Divider}"
} else {
    ${Global:Output} += '<?xml version="1.0" encoding="utf-16"?>'
}
    Summary-Line 'Report'           0 'Begin'
    Summary-Line 'Summary'          2 'Begin'
    Summary-Line 'Description'      4 'Whole' "${Global:Description}"
    Summary-Line 'ReportingHost'    4 'Whole' "${Global:FQDN}"
    Summary-Line 'RangeFrom'        4 'Whole' "${Global:DateFrom}"
    Summary-Line 'RangeThru'        4 'Whole' "${Global:DateThru}"
foreach (${Global:LevelValue} in 1..${MaxLevel}) {
    ${Global:LevelLabel} =  ${Global:LevelList}[${Global:LevelValue}]
    ${Global:LevelCount} = (${Global:EventList} | Where-Object { ${_}.LevelDisplayName -eq ${Global:LevelLabel} }).Count
    Summary-Line 'LevelCount'       4 'Whole' "${Global:LevelCount} events found" "${Global:LevelValue}" "${Global:LevelLabel}" 29
}
    Summary-Line 'WorkingDirectory' 4 'Whole' "${Global:Script_Dir}"
    Summary-Line 'Execution'        4 'Whole' "${Global:ScriptCall}"
    Summary-Line 'Summary'          2 'Close'
if (${Global:DoText}) {
    ${Global:Output} += "${Global:Divider}"
    ${Global:Output} += "${Global:Divider}"
}
Process-Array 2 `
    '${Global:Output}'`
    @( ${Global:Output} )


#####
##### Add XML or plain text event entries to ${Global:Output}...
#####

Processing 1 'Assembling Output'
##### Assemble all event records into ${Global:XmlString}...
${Global:XmlString} = `
    "<Events>`n" +`
    $(
        (
            ${Global:EventList} | ForEach-Object { ${_}.ToXml() }
        ) -join "`n"
    ) +`
    "`n</Events>"
##### Show the contents of ${Global:XmlString} when ${Global:Verbose}>=2...
Process-Array 2 `
    '${Global:XmlString}' `
    @( ${Global:XmlString} )

##### Format into XML UTF-16...
${Global:XmlFormatted} = Format-View-XML
##### Show the contents of ${Global:XmlFormatted} when ${Global:Verbose}>=2...
Process-Array 2 `
     '${Global:XmlFormatted}' `
     @( ${Global:XmlFormatted} )
##### Append to ${Global:Output} according to ${Global:DoText}...
if (${Global:DoText}) {
    ##### Convert to plain text...
    ${Global:Output} += Format-ViewText
} else {
    ##### Keep it as XML UTF-16...
	${Global:Output} += ${Global:XmlFormatted}
}

##### If XML, append the final closing </Report> tag...
if (-not ${Global:DoText}) { ${Global:Output} += '</Report>' }
##### Show the conents of ${Global:Output} when ${Global:Verbose}>=2...
Process-Array 2 `
    '${Global:Output}' `
    @( ${Global:Output} )


#####
##### Write the final ${Global:Output} either to a file or the console...
#####

if (${OutFile}) {
    ##### To file in ${OutFile}...
    Processing 1 "Output through Out-File -FilePath '${OutFile}' -Encoding Unicode..."
    ${Global:Output} | Out-File -FilePath ${OutFile} -Encoding Unicode
    Write-Host "🆗, output written to:'${OutFile}'"
} else {
    ##### To console...
    Processing 1 'Output using Write-Host...'
    ${Global:Output} | ForEach-Object { ${_}.ToString() } | Write-Host

    ##### Final debug output, if uncommented...
    #${Global:Output} | ForEach-Object {
    #    Write-Host ("TYPE={0} LEN={1} VAL=>>{2}<<" -f ${_}.GetType().Name, ${_}.ToString().Length, ${_}) -ForegroundColor Cyan
    #}
}
Processing 1 "Final summary...`n${Global:Summary}The end.`n"



#####
##### The end.
#####
