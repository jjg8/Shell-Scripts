<#
.SYNOPSIS
    Advanced Windows Event Log Filter Script
.DESCRIPTION
    Filters Windows event logs based on severity (-l), date/interval (-d, -r), excluded event IDs (-x), and outputs
    results in XML format with a summary. Event exclusions (-x) are passed as a quoted comma-separated list. Date
    range (-r) must include exactly two dates (from,to) in "yyyy-mm-dd,yyyy-mm-dd" format.
.PARAMETER l
    Max log level (1=Critical, 2=Error, 3=Warning, 4=Information, 5=Verbose)
.PARAMETER d
    Number of days ago to include (mutually exclusive with -r)
.PARAMETER r
    Comma-separated date range: start,end (e.g. "2025-08-01,2025-08-31")
.PARAMETER x
    Comma-separated list of Event IDs to exclude (e.g. "7034,7039")
.PARAMETER o
    Output file path (writes to stdout if omitted)
.EXAMPLE
    .\WinGetEvents.ps1 -l 3 -d 1 -x "7034,7039" -o "out.xml"
.EXAMPLE
    .\WinGetEvents.ps1 -l 2 -r "2025-08-01,2025-08-31"
.AUTHOR
    Jeremy Gagliardi
.VERSION
    2025-08-24.1
.LINK
    https://github.com/jjg8/Shell-Scripts/tree/main/WinGetEvents
#>

param (
    [Parameter(Mandatory=$true)]
    [ValidateSet(1,2,3,4,5)]
    [int]$l,  # Log level filter: 1=Critical, ..., 5=Verbose

    [Parameter(Mandatory=$false)]
    [int]$d,  # Number of days to look back

    [Parameter(Mandatory=$false)]
    [string]$r,  # Comma-separated date range: start,end (e.g. "2025-08-01,2025-08-31")

    [string]$x,  # Comma-separated list of Event IDs to exclude (e.g. "7034,7039")

    [string]$o   # Optional output file path
)

# Validate date parameters
if (-not $d -and -not $r) {
    Write-Error "You must specify either -d (days ago) or -r (date range), but not both."
    exit 1
}
if ($d -and $r) {
    Write-Error "Parameters -d and -r cannot be used together."
    exit 1
}

# Parse exclusion list
$excludedIDs = @()
if ($x) {
    $excludedIDs = $x -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' }
}

# Parse date range
if ($r) {
    $startDate, $endDate = $r -split ',' | ForEach-Object {
        try { [datetime]::Parse($_.Trim()) } catch {
            Write-Error "Invalid date format in -r: '$_'"
            exit 1
        }
    }
    if ($endDate -lt $startDate) {
        Write-Error "End date must be after start date."
        exit 1
    }
    # Extend end date to include full day
    $endDate = $endDate.AddDays(1).AddSeconds(-1)
}

# Calculate start date from -d
if ($d) {
    $startDate = (Get-Date).AddDays(-$d)
    $endDate = Get-Date
}

# Retrieve and filter events
$events = Get-WinEvent -FilterHashtable @{LogName='System'; Level=$l} -ErrorAction SilentlyContinue | Where-Object {
    $_.TimeCreated -ge $startDate -and $_.TimeCreated -le $endDate -and
    ($excludedIDs -notcontains $_.Id)
}

# Summarize by level
$levels = @{
    1 = 'Critical'
    2 = 'Error'
    3 = 'Warning'
    4 = 'Information'
    5 = 'Verbose'
}

#foreach ($level in 1..5) {
#    $label = $levels[$level] + "..."
#    $count = ($events | Where-Object { $_.LevelDisplayName -eq $levels[$level] }).Count
#
#    # Calculate how many dots to pad to reach 25 characters total
#    $dots = "." * (14 - $label.Length)
#    Write-Host "$label$dots$count"
#}
#Write-Host ""

# Output XML
$xml = "<Events>`n"
foreach ($event in $events) {
    $xml += "  <Event>`n"
    $xml += "    <Id>$($event.Id)</Id>`n"
    $xml += "    <TimeCreated>$($event.TimeCreated)</TimeCreated>`n"
    $xml += "    <Message>$($event.Message)</Message>`n"
    $xml += "  </Event>`n"
}
$xml += "</Events>"

# Initialize output array
$output = @()

# Build summary block
foreach ($level in 1..5) {
    $label = $levels[$level]
    $count = ($events | Where-Object { $_.LevelDisplayName -eq $label }).Count
    $dots = "." * (14 - $label.Length)
    $output += "$label$dots$count"
}

# Add XML header
$output += ""
$output += "<Events>"

# Build XML entries
foreach ($event in $events) {
    $output += "  <Event>"
    $output += "    <Id>$($event.Id)</Id>"
    $output += "    <TimeCreated>$($event.TimeCreated.ToString('MM/dd/yyyy HH:mm:ss'))</TimeCreated>"
    $output += "    <Message>$($event.Message)</Message>"
    $output += "  </Event>"
}

$output += "</Events>"

# Write to file or console
if ($o) {
    $output | Out-File -FilePath $o -Encoding UTF8
    Write-Host "OK, output written to: $o"
} else {
    $output | ForEach-Object { Write-Host $_ }
}

# END of script.