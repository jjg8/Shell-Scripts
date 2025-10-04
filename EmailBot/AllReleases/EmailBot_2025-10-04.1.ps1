##########
##########       This file needs to be saved with Encoding=UTF-16 LE BOM, and there are some UTF characters saved in this script.
## ▄▄▄▄▄▄▄▄▄▄▄▄▄ Similarly, all email is sent with Encoding=UTF8 for widest compatibility.
## ▌ IMPORTANT ▐ Not all Unicode characters will render in all text editors and terminals.
## ▀▀▀▀▀▀▀▀▀▀▀▀▀ Most of the Unicode characters in this script are widely compatible (with the exception of certain quotes in function Get-Quoted).
##########       I recommend the DejaVu Sans Mono font if any Unicode characters aren't rendering in your text editor or terminal.
##########  The <#-HELP-#...#-HELP-#> block below is provided as a convenience, but you should use parameter -h|-Help to view it with proper formatting.
<#-HELP-# # Parameter -h|-Help will output everything below this line, formatted, and auto-wrap long lines...

.SYNOPSIS
  Notify by email from the command line or automated using Task Scheduler.
.DESCRIPTION
  Prompts for all required email info. Set up multiple email address profiles (-p N). Sends a test email (or 2 emails if setting up an Internal & External SMTP services). You can use a custom config file (-c "C:\path\to\config.json") or (without -c) simply default to EmailBot.json in the same directory as this script. Send an email: specify the text of the email body (-bt "text" or -bf "C:\path\to\body.txt"). Add an attachment(s) (-a "C:\path\to\attachment.ext"). If your SMTP service(s) require user authentication, it'll store the password you enter (securely) in the Windows Credential Manager and not in the config file. When you no longer need a stored credential, you can remove it (-rm "OldUserName") from the Windows Credential Manager. More customization parameters are available below.
  If the script encounters an error it can't handle (whichever it encounters first)...
   • Usage error, it will exit with code 1.
   • Coding error, it will exit with code 2.
   • Missing requirements in -NonInteractive mode, it will exit with code 3.
  IMPORTANT:If you do not specify the email parameters (at least -s and one of -bf or -bt), it will only send a test email message(s).
  Parameters are processed in the following order of precedence...
    1. -d|-Debugging takes precedence over -v|-Verbosity.
    2. -Silent (also triggered by -niv|-ni|-NonInteractive).
    3. -niv takes precedence over -ni|-NonInteractive, ignores -h|-Help, but errors on -rs|-RunSetup|-RerunSetup.
    4. -h|-Help is processed immediately and exits.
    5. -rm|-Remove takes precedence over and ignores the rest of parameters and is processed immediately after parameter processing and exits.
    6. From this point, all other parameters are processed in alphabetical order.
       6a. -bt|-BodyText takes precedence over -bf|-BodyFile.
       6b. After all parameters are processed, if any of -a|-Attachment, -bt|-BodyText, -bf|-BodyFile, and/or -s|-Subject were used, it makes sure one of -bt|-BodyText or -bf|-BodyFile, and -s|-Subject were specified together, otherwise it's an error.
.INPUTS
  This script does not accept pipeline input, it prompts in the console for required data during setup, it uses a config file to save data, and it uses CLI parameters to send email messages.
.OUTPUTS
  Output is sent to the following...
   • All normal text: the Success stream, 1, using Write-Output, and this does not support color.
   • Everything else: [Console], using Write-Host (includes all Error, Warning, Verbose, and Debug messages), and this supports color.
     • Error, Warning, Verbose, & Debug go to [Console], because if they went to stream 1, output would be captured as return statuses from functions.
     • Streams 2-6 can't be used, because Write-Host (to support -BackgroundColor & -ForegroundColor) cannot be redirected to those streams.
.PARAMETER -a|-Attachment "C:\path\to\attachment.ext"
  Specify a quoted comma-separated path(s) to an attachment(s) to the email with -a or -Attachment "C:\path\to\attachment.ext".
.PARAMETER -bf|-BodyFile "C:\path\to\body.txt"
  Specify the text to insert into the email body with -bf or -BodyFile "C:\path\to\body.txt". -bf and -bt are mutually exclusive. The text in the file may contain UTF8 characters. -bt|-BodyText takes precedence over -bf|-BodyFile.
.PARAMETER -bt|-BodyText "multi-line text"
  Specify the text to insert into the email body with -bt or -BodyText "multi-line text". -bt and -bf are mutually exclusive. The text may contain UTF8 characters. -bt|-BodyText takes precedence over -bf|-BodyFile.
.PARAMETER -c|-cf|-ConfigFile "C:\path\to\configfile.json"
  Specify a custom configuration file with -c|-cf|-ConfigFile "C:\path\to\configfile.json". If this parameter is not used, the config file defaults to EmailBot.json in the same directory as this script. To setup all new info, simply specify this parameter with a new file, rename/remove/empty the default EmailBot.json file, or use parameter -rs|-RunSetup|-RerunSetup, and the script will prompt for all necessary info. If you manually edit the config file, please keep it mind it must be properly JSON-formatted, or it might reject some or all of it; tag names and strings are quoted, while numbers and booleans are unquoted, and each item within the {} as well as the trailing } must end with a comma, except for the last item and the last } must not have a comma after it. If you do manually edit it, I recommend using parameter -d|-Debug to see how it's parsing the data. If anything required is missing from the config file, it will prompt for it.
.PARAMETER -d|-Debugging
  Enables Verbosity to its max+1 and will not write any changes or send any email. Parameter -v|-Verbosity is ignored.
.PARAMETER -h|-Help
  Output this help screen and exit.
.PARAMETER -i|-IgnoreDNS
  If the local DNS of the host is fictitious (i.e. only relevant within an intranet, as opposed to public DNS on the Internet), you can ignore the DNS DomainName of the host. Normally, the local DNS DomainName is offered as an option in the multiple choice prompt to set the From address, as well as being used in the test email message that's sent after all email parameters have been properly entered. If you use -i|-IgnoreDNS, then that option will not be offered in the multiple choice prompt for the From address, and the test email will only use the Hostname. This parameter will be saved in the config file once used.
.PARAMETER -ni|-NonInteractive
  Simply carry out the required operation and exit without any input or output, other than the exit code. Automatically enables -Silent. By using this parameter, if any required information is missing, it will exit with code 3. The only exceptions to this parameter are -d|-Debug, -v|-Verbosity, or -niv. Parameter -rs|-RunSetup|-RerunSetup will cause a Usage error. IMPORTANT:Ensure you complete all setup and test it prior to using this parameter.
.PARAMETER -niv
  The same as parameter -ni|-NonInteractive, it also enables Non-interactive mode, except -niv will also output verbose messages for any missing requirements but none of the other verbose or debug messages. -niv takes precedence over -ni|-NonInteractive.
.PARAMETER -p|-Profile N
  This sets the profile number to use for all email addresses (To, From, CC, BCC) to N, which must be a positive Integer. By default N=0. Profile numbers don't need to be sequential.
.PARAMETER -rm|-Remove "OldUserName"
  When you no longer need the stored credential for a particular SMTP UserName, you can remove it from the Windows Credential Manager with -rm|-Remove "OldUserName". If this parameter is specified, all other email parameters will be ignored, and it will remove the credential and exit.
.PARAMETER -rs|-RunSetup|-RerunSetup
  Normally, this script prompts only when there is missing required data. By using this parameter, you force it to rerun setup again for every prompt, even ones that already have answers. For each prompt, if it already has an answer that passes validity-checking, it will show it as a default answer, or you can enter a new answer to replace it.
.PARAMETER -Silent
  Normally, any warning or error message also beeps the console, but by using this parameter, the beep is silenced.
.PARAMETER -s|-Subject "single line of text"
  Specify the text to insert into the email subject with -s|-Subject "single line of text". The text may contain UTF8 characters.
.PARAMETER -UseHTML
  Indicates that the body text is in HTML format.
.PARAMETER -v|-Verbosity N
  Set the verbosity level to N (0=none, 1=basic, 2=very) to indicate what it's doing. Verbose messages are not included in an email message.
  Very verbose output may exceed the history size of your terminal, and if so, you can...
   1.  Redirect the Information stream (6) to a file by appending this to the end of script execution:
         EmailBot.ps1 6>"log.txt"
   2a. Newer systems — Increase the History Size of your terminal to something much larger (e.g. my default is 2000000, i.e. 2 million lines).
   2b. Older systems — Increase the Screen Buffer Size, Height, of your terminal to 9999 (the max it supports; if it isn't enough see 1).
.EXAMPLES
 • Use the default config file & profile number (it will prompt initially for all the required info)...
     EmailBot.ps1
 • Use a custom config file & profile number...
     EmailBot.ps1 -c "C:\path\to\config.json" -p 1
 • Send an email specifying the body text, a subject, and an attachment...
     EmailBot.ps1 -bt "multi-line text" -s "single line of text" -a "C:\path\to\attachment.ext"
 • Send an email specifying the body from a file, the body is in HTML format, and a subject...
     EmailBot.ps1 -bf "C:\path\to\body.txt" -UseHTML -s "single line of text"
 • Remove a credential
     EmailBot.ps1 -rm "OldUserName"

.AUTHOR  Jeremy Gagliardi
.VERSION 2025-10-04.1
.LINK    https://github.com/jjg8/Shell-Scripts/tree/main/EmailBot

.NOTES
 • This script was tested with the following configurations, which are typical...
   • Internal — Port 25, STARTTLS, no user authentication, only accepts requests from trusted IPs/Domains, only accepts a From address matching its Domain.
   • External — Port 587, STARTTLS, user auth required, accepts requests from anywhere on the Internet, only accepts a From address matching the account holder's full email address.
     • This is why, when you configure both services (see below) using this script, you need to provide 2 different From addresses for every profile. It's very likely that most modern SMTP services won't let you send an email with it using a From address that doesn't match its strict criteria. It prevents spoofing, spam, and other such abuse.
 • During setup, you will be walked through 3 sets of data...
   • Set1_Internal — This may be the only SMTP service you set up or 1 of 2, and if so, it's probably a service that uses IP/Domain-matching.
   • Set2_External — This may be set up if needed, and is probably a personal or other private SMTP service, usable from anywhere on the Internet where strict IP/Domain-matching isn't possible or practical.
   • Set3_Profiles — At least one profile needs to be set up (by default 0), and will set the To, From, CC, and BCC addresses it'll use to send an email.
     • This script doesn't currently support specifying any of these addresses on the fly, so they need to be configured and a test email sent beforehand.
 • All email sent by this script uses Encoding = UTF8.
   • For widespread compatibility, most SMTP services can handle up to UTF8 (as opposed to full Unicode, UTF-16 LE BOM, which some choke on).
   • Even if you don't have any advanced UTF8 characters in your message, it's still good practice to encode for UTF8.
   • Sometimes, data sources from other services (e.g. Event Log data) may have UTF8 characters in them you might not be aware of.
   • This script has many UTF8 characters in it above and beyond the Basic Latin block.
   • Many modern text & document editors use more than Basic Latin (what many old-timers might call ASCII), probably without many even realizing it...
     • E.g. Word, Confluence, and I'm sure others, automatically use En Dash, Em Dash, bullets, curved quotes, and other special characters, all of which aren't in Basic Latin, and much of which end up in email messages.
   • If a UTF8 character doesn't render, it's your font, not your app or OS.
 • You can read the comments in the script for a lot more detail.

#-HELP-#> # Parameter -h|-Help will output everything above this line, formatted, and auto-wrap long lines.
<##########
 Script Conventions (best effort)...
 • The layout of this script is optimized for a terminal width of at least 155 characters using a good monospace (fixed-width) font.
   • 155 characters is this many...
        10        20        30        40        50        60        70        80        90       100       110       120       130       140       150  155
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345
   • That means all code & comment lines in this script will not exceed 155 and may be manually wrapped to the next line(s).
 • All variable & function names are unique throughout the script for easy search & replace.
 • All variables are written in the form ${...} (e.g. ${_}, ${exitCode}, etc) for both readability and better functionality.
   • By bracing all variable names, aside from distinguishing them better, it also makes it possible to...
     • embed a variable within text (e.g. abc${def}ghi) without the outer text being confused for part of the variable name.
     • global search & replace is much easier (e.g. {exitCode} and -exitCode are far less likely to be confused for other text).
 • Global variables all use the ${Script:VarName} syntax, while function local variables all use the ${varName} syntax, and keys are always KeyName.
   • ${Script:VarName} makes it globally accessible within the script but must always be referenced inside functions as ${Script:VarName} and not as
      ${VarName}, otherwise ${VarName} will be treated as if it's a local variable inside the function.
   • All ${varName} variables within a function are local to that function.
   • For those familiar with UNIX/Linux shell scripting...
     • ${Global:VarName} is similar to export ${VarName}, which survives after script execution, and there are no such variables in this script.
     • ${Script:VarName} is global within the script, but it doesn't survive into the terminal after the script exits.
 • I made an effort to comment what a closing } belongs to if the opening { is more than a typical screenful away and for all for|foreach loops.
   • So, if you don't see } # END of blahblahblah, the opening { is probably nearby.
 • Notes on Unicode characters used by this script...
   • Not all Unicode characters will render in all text editors & terminals.
   • I recommend the DejaVu Sans Mono font if any Unicode characters aren't rendering in your text editor or terminal.
   • If you see any of the following...
     • a blank rectangle
     • a diamond with a ? in it
     • a rectangle with ?, x, /, or \ in it
     Those are the so-called "tofu" characters (depending on which font you're using), meaning a Unicode character isn't rendering with your chosen font.
   • Also, any FullWidth characters may appear slightly wider than standard-width characters, which means, even when using a monospace (fixed-width)
      font, they may not line up with the standard-width characters.
 • Banners were made using https://www.bagill.com/ascii-sig.php
   • Add a space before and after the text.
   • Font:  Banner3-D
   • I added an extra row of colons before and after each word.
   • I also added the same text after each one, so it's searchable.
##########>



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
##### Declare and get all CLI parameters...
#####
# • All are Mandatory=${False} here, so parameter checking can be done below in the Parameter Processing section.
#####

param(
    [Parameter(Mandatory=${False})][Alias('a')            ][String]${Attachment},
    [Parameter(Mandatory=${False})][Alias('bf')           ][String]${BodyFile},
    [Parameter(Mandatory=${False})][Alias('bt')           ][String]${BodyText},
    [Parameter(Mandatory=${False})][Alias('c','cf')       ][String]${ConfigFile},
    [Parameter(Mandatory=${False})][Alias('d')            ][Switch]${Debugging},
    [Parameter(Mandatory=${False})][Alias('h')            ][Switch]${Help},
    [Parameter(Mandatory=${False})][Alias('i')            ][Switch]${IgnoreDNS},
    [Parameter(Mandatory=${False})][Alias('ni')           ][Switch]${NonInteractive},
    [Parameter(Mandatory=${False})]                        [Switch]${niv},
    [Parameter(Mandatory=${False})][Alias('p')            ][Int   ]${Profile},
    [Parameter(Mandatory=${False})][Alias('rm')           ][String]${Remove},
    [Parameter(Mandatory=${False})][Alias('rs','RunSetup')][Switch]${RerunSetup},
    [Parameter(Mandatory=${False})]                        [Switch]${Silent},
    [Parameter(Mandatory=${False})][Alias('s')            ][String]${Subject},
    [Parameter(Mandatory=${False})]                        [Switch]${UseHTML},
    [Parameter(Mandatory=${False})][Alias('v')            ][Int   ]${Verbosity}
)


#####
##### Ensure all output is properly encoded to handle Unicode characters...
#####

[Console]::OutputEncoding = [System.Text.Encoding]::Unicode


#####
##### Declare all global variables...
#####
# • Any declaration in [] on its own line, needs to end with ` (and nothing after it, including comments), otherwise it announces the type to the console.
# • Script: means it's global within the script (don't use Global:, because that survives after script execution into the session).
#####


##### All data for composing the email message...
[HashTable]${Script:EmailTable} = @{

    #####
    # These 3 blocks are only used internally by the script and are never saved to the config file.
    #####
    # • Part1_Encoding is the only field that remains constant here. See NOTES in the help page.
    # • For all other items here, they are completed at runtime, either by automatic determinations or by parameters and other input from the user.
    # • These are just the initial empty declarations, but in some cases the default, which can be changed either by a parameter or some logical condition.
    #####
    Condition = @{
        ##### Which profile number to use in Set3_Profiles, which defaults to 0, unless changed by parameter -p|-Profile...
        ProfileIndex   = '0'
        ##### Which set(s) to setup & use (which will be Set1_Internal, Set2_External, or both, based on Group0_ItemA_UseExternal.Value & other factors)...
        SetsToUse      = 'Set1_Internal'
        ##### Whether to send a test email(s), becoming False if parameters -s|-Subject & either -bt|-BodyText or -bf|-BodyFile are specified...
        TestEmail      = ${True}
        #####
        # Conditions for transitions between each of the sets as named below...
        #  • These transitions occur even if nothing from the prior set(s) was prompted, and the named set has prompted, only upon its first such prompt.
        #  • These transitions serve as a noticeable visual cue to the user that there are different sets, when they occur, & it's not repeating prompts.
        #####
        Transition     = @{
            ##### Initially True, then set to False if & when the first Set1 prompt occurs to indicate that it's beginning with Set1...
            Set1_Internal = ${True}
            ##### Initially True, then set to False if & when the first Set2 prompt occurs to indicate when to output that Set1 is done & it's now Set2...
            Set2_External = ${True}
            ##### Initially True, then set to False if & when the first Set3 prompt occurs to indicate that Set1 & Set2 are done & it's now Set3...
            Set3_Profiles = ${True}
        }
        ##### Whether the config file needs to be updated, triggered in function Check-All-Entries if any data changes...
        UpdateConfig   = ${False}
    }
    ##### Everything about the config file...
    ConfigFile = @{
        ##### Data from the Set* blocks of this HashTable converted as JSON to a String ready for output to the config file at ConfigFile.Path...
        Data = [String]''
        #####
        # JSON-formatted data (PSCustomObject) after being read in from the config file using...
#########
# try {
#   ${Script:EmailTable}.ConfigFile.JSON = Get-Content ${Script:EmailTable}.ConfigFile.Path -Raw -Encoding Unicode | ConvertFrom-JSON -ErrorAction Stop
# } catch {
#   ${Script:EmailTable}.ConfigFile.JSON = @{}
# }
#########
        #####
        JSON = [PSCustomObject]@{}
        ##### The full path to the config file, determined by parameter -c|-cf|-ConfigFile or by default (${Script:RuntimeTable}.FullName+'.json')...
        Path = [String]''
    }
    #####
    # Fields used to assemble an email message in function Send-Email...
    #  • These fields are required for all email messages...
    #    • Part1_Encoding
    #    • Part2_Subject
    #    • Part3_Body
    #      • Part3_IsHTML is used to determine whether it uses BodyAsHTML or just Body.
    #  • This is optional...
    #    • Part4_Attach, however it's always used in a test email.
    #####
    Field = @{
        ##### This remains constant — See NOTES in the help page....
        Part1_Encoding = [System.Text.Encoding]::UTF8
        ##### Set by parameter -s|-Subject, or if doing a test email(s) by a default in the "Send a test email(s)" section...
        Part2_Subject  = ${Null}
        ##### Set by parameter -bt|-BodyText or -bf|-BodyFile, or if doing a test email(s) by a default in the "Send a test email(s)" section...
        Part3_Body     = ${Null}
        ##### Initially False but set to True only if parameter -UseHTML is used.
        Part3_IsHTML   = ${False}
        ##### Set by parameter -a|-Attachment, or if doing a test email(s) by a default in the "Send a test email(s)" section...
        Part4_Attach   = ${Null}
    }

    Set1_Internal = @{
    #####
    # This set will either be...
    #  • The only set used for SMTP settings, or if setup as such...
    #  • The primary connection when a mobile workstation is Internal to a particular IP/Domain needed to use the SMTP server, in which case it will use
    #     Set2_External when it detects that the host is External to the required IP/Domain as stored in Group0_ItemB_PublicAddresses.ValueSet.
    #####
    # • If you're using this for personal email, this will be your personal email service's SMTP service.
    # • But, if you're using a business SMTP service, there are a few more caveats...
    #   • Many business SMTP servers only accept outgoing email if the workstation sending it is within the same or a whitelisted DNS domain.
    #   • That's fine if your workstation remains fixed in place at that location.
    #   • But, if you're using a mobile workstation, then it won't always be on the same network.
    #   • When you connect your workstation remotely, such as on your home ISP, a mobile hotspot, or a public WiFi service, your workstation is no longer
    #      on the same network as your business SMTP server.
    #   • Even if you're using a VPN service to connect, many businesses use what's called a Split Tunnel, which routes essential business traffic as if
    #      it were on the same network as the servers but other traffic is routed directly from whatever your workstation is connected to (e.g. home).
    #   • That presents a problem when attempting to use a locked-down business SMTP server, which will reject any outgoing email connections originating
    #      from an external network.
    #   • If that's the case, you may need to use an External SMTP service (probably your personal email service) — see below in Set2_External.
    # • Only Set1_Internal contains Group0, which contains the criteria for whether to use Set1_Internal or Set2_External, if applicable...
    #   • Group0_ItemA_UseExternal stores the answer if it's a mobile workstation & should also use Set2_External when external to the business network.
    #   • Group0_ItemB_PublicAddresses, if Group0_ItemA_UseExternal is True, stores the comma-separated list of valid public DNS domain(s) that indicate
    #      when the workstation is considered to be Internal to the business network.
    #     • If your current public DNS domain doesn't match, then it will use Set2_External.
    # • VarType will be one of 'Boolean', 'Int32', or 'String'.
    #   • Boolean...
    #     • Stored in JSON as true or false (no quotes and all lowercase).
    #     • Stored in PowerShell as True or False (no quotes and initial caps).
    #   • Int32...
    #     • Stored in both JSON and PowerShell as -?[0-9]+ (no quotes).
    #   • String...
    #     • Stored in both JSON and PowerShell as "Value".
    # • Not all items have all Properties (metadata), and the Properties are only used internally within the script...
    #   • All items have...
    #     • Meta1_VarType      — this item's required variable type.
    #   • If the item is Group1_AddressA_IgnoreDNS...
    #     • Meta2_Prompt1 is unnecessary, since it's derived from using the -i|-IgnoreDNS parameter, rather than prompting for an answer.
    #   • All other items have...
    #     • Meta2_Prompt1      — desribing how to prompt for this item.
    #   • If the item is Group0_ItemA_UseExternal, it also has...
    #     • Meta2_Prompt2      — if Prompt1 is True, then it uses this followup prompt as well.
    #   • Notes about all prompts...
    #     • Where you see a prompt with :CUSTOM:, that signals to the Prompt-For-From or Prompt-For-Value functions to show a prompt as-is (with the
    #        :CUSTOM: removed, and not to format it with canned prefix & suffix phrases.
    #     • Where you see a prompt with :INSERT_ANSWER_HERE: that will be replaced with a valid answer at runtime.
    #     • All multiline prompts end with the closing ' on its own line intentionally, so Read-Host will place the : prompt on a new line.
    #     • All multiline prompts are wrapped intentionally so they don't exceed 80 characters per line, typical of a default terminal size.
    #   • If Meta1_VarType is Boolean, then it'll also have...
    #     • Meta3_RegExKey is unnecessary here, since it'll always be 'Boolean'.
    #     • Meta5_Default      — the default value to show or ${Null} for none.
    #   • If Meta1_VarType is Int32 or String, then it'll also have...
    #     • Meta3_RegExKey     — the key name to ${Script:RegExTable} containing the RegEx pattern to use for validation of that item's entered value.
    #     • Meta4_MayBeEmpty   — whether or not that item's value may be left as an empty value ''.
    #####
        Group0_ItemA_UseExternal = @{
            Properties = @{
                Meta1_VarType    = 'Boolean'
                Meta2_Prompt1    = `
':CUSTOM:Is this a mobile workstation that uses multiple ISPs to connect?
(If you use the same SMTP configuration for all, answer NO to this question)
'
                Meta2_Prompt2    = `
':CUSTOM:Do you need to setup 2 sets of parameters?
 • 1 using your business SMTP configuration when Internal, and
 • 1 using a different SMTP configuration when External
'
                Meta5_Default    = ${Null}
            }
            Value = ${Null}
        }
        Group0_ItemB_PublicAddresses = @{
            Properties = @{
                Meta1_VarType    = 'String'
                Meta2_Prompt1    = `
':CUSTOM:Enter a list of public IP address(es) &/or DNS domain(s) that
determines if your workstation is on the business network (if multiple separate
with commas). Your current public IP address & DNS domain is...
:INSERT_ANSWER_HERE:
'
                Meta3_RegExKey   = 'PublicList'
                Meta4_MayBeEmpty = ${False}
                Meta5_Default    = ${Null}
            }
            Value = ${Null}
            ValueSet = @()
        }

        Group1_SMTP1_Server_FQDN = @{
            Properties = @{
                Meta1_VarType    = 'String'
                Meta2_Prompt1    = 'outgoing email server FQDN address'
                Meta3_RegExKey   = 'FQDN'
                Meta4_MayBeEmpty = ${False}
            }
            Value = ${Null}
        }
        Group1_SMTP2_Port = @{
            Properties = @{
                Meta1_VarType    = 'Int32'
                Meta2_Prompt1    = `
':CUSTOM:Enter the outgoing email server port number to use.
Typical SMTP port numbers are 25, 465, 587, or something custom.
 • 25 is the default and could be used out of convenience if the server uses
   authentication or accepts requests based on IP/DNS of the sending host.
 • 465 is more of a legacy configuration.
 • 587 is much more common on the Internet.
 • Some organizations may opt for a custom port number (ask a SysAdmin).
'
                Meta3_RegExKey   = 'Port'
                Meta4_MayBeEmpty = ${False}
            }
            Value = ${Null}
        }
        Group1_SMTP3_UseSSL = @{
            Properties = @{
                Meta1_VarType    = 'Boolean'
                Meta2_Prompt1    = 'SSL (STARTTLS)'
                Meta5_Default    = ${True}
            }
            Value = ${Null}
        }
        Group1_SMTP4_Authenticate = @{
            Properties = @{
                Meta1_VarType    = 'Boolean'
                Meta2_Prompt1    = 'SMTP user authentication'
                Meta5_Default    = ${Null}
            }
            Value = ${Null}
        }
        Group1_SMTP4_UserName = @{
            Properties = @{
                Meta1_VarType    = 'String'
                Meta2_Prompt1    = 'outgoing email server user name'
                Meta3_RegExKey   = 'UserName'
                Meta4_MayBeEmpty = ${False}
            }
            Value = ${Null}
        }
    } # END of Set1_Internal = @{}

    Set2_External = @{
    #####
    # This set may be used for a mobile workstation when it's connected Externally on a public or private ISP service and the Internal SMTP service won't
    #  accept your connections.
    #####
    # • Each item's Properties will be inherited from Set1_Internal above at runtime.
    # • If your Internal SMTP service rejects any connection attempts from External sources, you can use this set for an External SMTP service.
    # • This will probably be your personal or a private email service.
    # • Since this is the External SMTP service, it's supposed to be useable from any network you happen to be on.
    # • Therefore, this set doesn't use the Group0_ItemA_UseExternal & Group0_ItemB_PublicAddresses items, like Set1_Internal needs.
    #####
        Group1_SMTP1_Server_FQDN = @{
            Properties = @{}
            Value = ${Null}
        }
        Group1_SMTP2_Port = @{
            Properties = @{}
            Value = ${Null}
        }
        Group1_SMTP3_UseSSL = @{
            Properties = @{}
            Value = ${Null}
        }
        Group1_SMTP4_Authenticate = @{
            Properties = @{}
            Value = ${Null}
        }
        Group1_SMTP4_UserName = @{
            Properties = @{}
            Value = ${Null}
        }
    } # END of Set2_External = @{}

    Set3_Profiles = @{
    #####
    # This set of profiles and their addresses is universal to both Set1_Internal & Set2_External.
    #####
    # • Although the From address is split into Set1 & Set2, because they're usually very closely tied to the SMTP service, they still belong in Set3,
    #    because they could be different for each Profile.
    # • This can have from 0 to many Profiles, defaulting to 0 or specified with parameter -p|-Profile.
    # • Profiles>0 don't need to be sequential.
    # • Only Profile0 is fixed as the default.
    # • However, if the user decides never to set up Profile0, that too could be skipped.
    # • All profiles>0 inherit the Properties from Profile0 defined here.
    #####
        ##### This needs to be before Profile*_ItemC_From_Set?, because the prompt uses ${Script:RuntimeTable}.Host.Local.Domain in its multiple choice...
        Profile0_ItemA_IgnoreDNS = @{
            Properties = @{
                Meta1_VarType    = 'Boolean'
               #Meta2_Prompt1 is unnecessary here, since this item is determined by parameter -i|-IgnoreDNS and not prompted for an answer.
                Meta5_Default    = ${Null}
            }
            Value = ${Null}
        }
        ##### This needs to be before Profile*_ItemC_From_Set?, because the prompt uses Profile*_ItemB_To in its multiple choice...
        Profile0_ItemB_To = @{
            Properties = @{
                Meta1_VarType    = 'String'
                Meta2_Prompt1    = 'To email address'
                Meta3_RegExKey   = 'EmailList'
                Meta4_MayBeEmpty = ${False}
            }
            Value = ${Null}
        }
        #####
        # Profile0_ItemC_From_Set[12] addresses, although unique to each Set1 & Set2, need to be tracked within each ProfileN instance, because they could
        #  be different for each Profile, so they don't belong with Set1 & Set2, respectively, which remain static no matter how many Profiles there are.
        #####
        Profile0_ItemC_From_Set1 = @{
            Properties = @{
                Meta1_VarType    = 'String'
                Meta2_Prompt1    = `
':CUSTOM:Enter the From email address to use, and please note...
 • Many business SMTP services will only accept a connection if the domain
   portion of the From address matches the business domain.
   E.g. if the business domain is Example.com, the From must be *@Example.com
 • Many 3rd-party SMTP services are even more restrictive, only accepting a
   connection if the From address exactly matches the entire email address
   of the account holder. E.g. SpecificUser@Example.com
 • It is very rare for an SMTP service to accept a From address foreign to it.
'
                Meta3_RegExKey   = 'EmailFrom'
                Meta4_MayBeEmpty = ${False}
            }
            Value = ${Null}
        }
        Profile0_ItemC_From_Set2 = @{
            Properties = @{} # This will copy over the Properties above at runtime.
            Value = ${Null}
        }
        Profile0_ItemD_CC = @{
            Properties = @{
                Meta1_VarType    = 'String'
                Meta2_Prompt1    = 'optional CC email address'
                Meta3_RegExKey   = 'EmailList'
                Meta4_MayBeEmpty = ${True}
            }
            Value = ${Null}
        }
        Profile0_ItemE_BCC = @{
            Properties = @{
                Meta1_VarType    = 'String'
                Meta2_Prompt1    = 'optional BCC email address'
                Meta3_RegExKey   = 'EmailList'
                Meta4_MayBeEmpty = ${True}
            }
            Value = ${Null}
        }
    } # END of Set3_Profiles = @{}
} # END of [HashTable]${Script:EmailTable} = @{}


##### All necessary RegEx patterns for validating user-entered data...
[HashTable]${Script:RegExTable} = @{
    #####
    # A Boolean will always be of PowerShell type [Bool] and either True or False, as opposed to String values '', 'True', or 'False'...
    #####
    Boolean    = "^(${True}|${False})$"
    #####
    # A From address will be a [String] consisting of a single email address (as opposed to a comma-separated list as described below)...
    #####
    EmailFrom  = '[^@]+@[^@]+\.[^@]+'
    #####
    # A To, CC, or BCC line will be a [String] consisting of either a single email address (as above) or a comma-separated list of email addresses with
    #  optional whitespace (\s*) around the comma(s)...
    #####
    EmailList  = '[^@]+@[^@]+\.[^@]+(\s*,\s*[^@]+@[^@]+\.[^@]+)*'
    #####
    # Range-check for the ${Script:RuntimeTable}.ExitStatus table, allows an Integer value from 0 to 255...
    #####
    ExitStatus = '^([0-9]|[1-9][0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$'
    #####
    # A Fully-Qualified DomainName (FQDN) will be a [String] in the form Label.TLD, Label.Label.TLD, etc...
    #  • Where...
    #    • [SET1] may contain the characters:  A-Z or a-z
    #    • [SET2] may contain the characters:  [SET1] or 0-9
    #    • [SET3] may contain the characters:  [SET2] or -
    #  • The pattern will be...
    #    • Each Label will be 1 of [SET2], followed by 0 or 1 of combined (0-61 of [SET3] and 1 of [SET2]), and end with a literal '.'.
    #      • I.e. the word portion must begin with 1 of [SET2], if length>1 it may be followed by 0-61 of [SET3] and end with 1 of [SET2], and then the
    #         word portion must end with a literal '.'.
    #      • Each Label can be from 1-63 characters.
    #      • Valid:    a., ab., a-b., a.b., a.b.c., etc.
    #      • Invalid:  -a., a-., ReallyReallyReallyReallyLongLabelNameExceeding63CharactersInLength
    #    • The TLD (Top-Level Domain, e.g. com, net, localdomain, etc.) will be 2-63 of [SET1]
    #    • All total...
    #      • The entire FQDN will be 4-253 characters (which includes a minimum of a 1-character Label, a literal '.', and a 2-character TLD).
    #      • Each Label can be from 1-63 characters.
    #      • Multiple Labels and the TLD are each separated with a literal '.'.
    #      • The TLD can be from 2-63 characters.
    #  • Examples...
    #    • Example.com
    #    • SMTP.YourCompany.com
    #    • Mail.YourHomeISP.net
    #    • Outgoing.YourSchool.edu
    #    Etc.
    #  • The ^ and $ are added just after declaration and assembly of PublicList below.
    #####
    FQDN       = '(?=.{4,253}$)(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}'
    #####
    # A Port will be an integer [Int32] value from 0 to 65535...
    #####
    Port       = '^([0-9]|[1-9][0-9]{1,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$'
    #####
    # A PublicIPv4 will be a [String] consisting of a dot-separated series of 4 octets, where each octet may be from 0-255, excluding Private IPs...
    #  • The ^ and $ are added just after declaration and assembly of PublicList below.
    #####
    PublicIPv4 = `
'(?:(?!10\.|127\.|169\.254\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.)((25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d))'
    #####
    # A PublicIPv6 will be a [String] consisting of a colon-separated series of 8 hex quads, where each quad is from 0-FFFF, excluding Private IPs...
    #  • The ^ and $ are added just after declaration and assembly of PublicList below.
    #####
    PublicIPv6 = `
'(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|(([0-9a-fA-F]{1,4}:){1,7}:)|(([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4})|(([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2})|(([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3})|(([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4})|(([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5})|([0-9a-fA-F]{1,4}:)((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1\d|[1-9]?)\d)\.){3}(25[0-5]|(2[0-4]|1\d|[1-9]?)\d)|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1\d|[1-9]?)\d)\.){3}(25[0-5]|(2[0-4]|1\d|[1-9]?)\d))'
    #####
    # A Group0_ItemB_PublicAddresses line will be a [String] consisting of either a single item or a comma-separated list of items with optional whitespace
    #  (\s*) around the comma(s), and the item(s) may be FQDN, PublicIPv4, or PublicIPv6 as above.
    #####
    PublicList = '' # Assembled from FQDN, PublicIPv4, and PublicIPv6 from above just after declaration below.
    #####
    # A UserName will be a String containing...
    #  • Where...
    #    • [SET1] may contain the characters:  A-Z, a-z, 0-9, ., _, %, +, or -
    #    • [FQDN] matches the RegEx above for a FQDN.
    #  • 1 or more of [SET1], followed by 0 or 1 of combined (literal '@', followed by [FQDN])
    #####
    UserName   = '' # Assembled from FQDN from above just after declaration below.
} # END of [HashTable]${Script:RegExTable} = @{}
##### Now assemble from values above...
${Script:RegExTable}.PublicList = (
    '^('+        ${Script:RegExTable}.FQDN+'|'+${Script:RegExTable}.PublicIPv4+'|'+${Script:RegExTable}.PublicIPv6+')'+
     '(\s*,\s*('+${Script:RegExTable}.FQDN+'|'+${Script:RegExTable}.PublicIPv4+'|'+${Script:RegExTable}.PublicIPv6+'))*$'
)
${Script:RegExTable}.UserName   = ('^[A-Za-z0-9._%+-]+(@'+${Script:RegExTable}.FQDN+')?$')
##### Add the final ^ and $ to these, after using them to assemble the above...
${Script:RegExTable}.FQDN       = ('^'+${Script:RegExTable}.FQDN+      '$')
${Script:RegExTable}.PublicIPv4 = ('^'+${Script:RegExTable}.PublicIPv4+'$')
${Script:RegExTable}.PublicIPv6 = ('^'+${Script:RegExTable}.PublicIPv6+'$')


#####
# Info, obtained at runtime, about the script itself, the host it's running on, and how it was invoked...
#  • This table also contains some handy constants.
#  • The Beep table will be used to determine if the Output-Error function beeps, based on the below stated criteria.
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
    # When calling the Output-Error function, decide if it should beep after the message, based on these criteria; customize to suit...
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
        EXMore = ${True}  # When any other exit code is passed in to the Output-Error function that's not defined below in the ExitStatus block.
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
        E2User = 1 # When the user doesn't give the correct parameters at invocation (causes Output-Error to prepend 'ERROR:' & append how to use help).
        E3Code = 2 # When the script encounters a problem it can't handle (causes Output-Error to prepend 'CODING ERROR:' & includes a call stack trace).
                   #  This is due to a coding error (an error by the programmer), as opposed to a usage error (an error by the user).
        E4NIMR = 3 # In -NonInteractive mode if it encounters any Missing Requirements.
                   #  However, if it encounters any error above this first, it'll exit with that status instead.
       #EXMore is not itself an exit status code condition but rather a state in the ErrorBeepsOn block above to mean any other exit code passed in to the
       # Output-Error function that's not defined here in the ExitStatus block.
    }
    ##### The Dir_name & BareName combined...
    FullName       = [String]'' # set below after declaration
    ##### The Dir_name & Basename combined...
    FullPath       = [String]'' # set below after declaration
    ##### Info about the host, determined at runtime, but also altered with parameter -i|-IgnoreDNS...
    Host           = @{
        #####
        # The Local block pertains to how the host sees itself in the local intranet, which may or may not match its public Internet presence...
        #  • In many cases, local DNS info will be intranet-specific or in some cases even absent.
        #  • Local.Domain, if found, is just the DNS DomainName portion on the local intranet without the Local.Hostname portion.
        #    • It's used in function Prompt-For-From and is crucial for assembling Local.FQDN.
        #    • If either Local.Domain cannot be found in the "Assemble Host.Local.* Addresses" section or if either parameter -i|-IgnoreDNS was used or
        #       if Profile0_ItemA_IgnoreDNS is True, this will be set to an empty string ''.
        #  • Local.Hostname is just the hostname portion (without the DNS DomainName portion) of the host.
        #    • It's used in a test email subject, in function Prompt-For-From, and is crucial for assembling Local.FQDN.
        #  • Local.FQDN will either be Local.Hostname & Local.Domain combined or only Local.Hostname if Local.Domain is unknown or IgnoreDNS is True.
        #    • It's used in a test email body.
        #####
        Local      = @{
          Domain   = ''
          FQDN     = ''
          Hostname = ${Env:ComputerName}
        }
        #####
        # The Public block pertains to how the host sees itself on the public Internet, which in many cases will be a NAT of some kind...
        #  • Public.IP will be discovered in function Get-Public-IP, and will be the NATed or fixed IP address of the host as seen from the Internet.
        #    • This is set first, and is required by the time Get-Public-DNS-Domain runs.
        #    • It then replaces :INSERT_ANSWER_HERE: in Set1_Internal.Group0_ItemB_PublicAddresses.Properties.Meta2_Prompt1.
        #    • It's then used in the "Determine which set(s) to use" section if Group0_ItemA_UseExternal is True and other factors.
        #  • Public.FQDN will be discovered in function Get-Public-DNS-Domain, and will be the NATed DNS FQDN of the host as seen from the Internet.
        #    • This is set after Public.IP and can only be found if Public.IP is not False.
        #    • It's then used in the "Determine which set(s) to use" section if Group0_ItemA_UseExternal is True and other factors.
        #  • Both Public.IP & Public.FQDN can be saved in Group0_ItemB_PublicAddresses.Value & .ValueSet for these comparisons to take place.
        #####
        Public     = @{
          FQDN     = ''
          IP       = ''
        }
    } # END of Host = @{}
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
            # If parameter -niv is used, not -d|-Debug or -v|-Verbosity, it gives verbose messages ONLY for missing requirements in -NonInteractive mode...
            #####
            IsTrue = ${False}
            #####
            # The Verbosity Level with which to indicate any skipped actions while in -NonInteractive mode...
            #  • Refer to ${Script:RuntimeTable}.Verbose.Level below.
            #  • This will indicate whether or not to show skipped actions when -v|-Verbosity N or -d|-Debug (3) >= this number.
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
        InDebugMode = ${False} # Signals from parameter -d|-Debug if the script is in debugging mode; if so any action that writes will be skipped.
        Indent      = '  '     # The string to use to indent Verbose output, and multiplied by successive levels.
        Level       = 0        # Signals from parameters -v|-Verbosity [12] or -d|-Debug (3) if Verbose messages & which ones are written to the console...
                               #  • It starts at Level=0 (not in a Verbose or Debug mode of any kind).
                               #  • If set with -v|-Verbosity 1, these are messages that just explain what action it's performing at the moment.
                               #  • If set with -v|-Verbosity 2, these are much more verbose messages, that include variable names & values, etc.
                               #  • If set to 3 with -d|-Debug, these are write actions to be skipped in debugging mode.
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



function Check-All-Entries ([Bool]${rerunSetup}, [Bool]${ignoreDNS}) {
#####
# Purpose:
#  • Check all entries from the config file, and if necessary, prompt for valid input.
#
# Returns:  ${Script:EmailTable}.Set* fully populated.
#
# Usage:
#  • Parameter 1 — ${rerunSetup}: Boolean (REQUIRED) — the value of CLI parameter ${RerunSetup}.
#  • Parameter 2 — ${ignoreDNS}:  Boolean (REQUIRED) — the value of CLI parameter ${IgnoreDNS}.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:EmailTable}
#  • Functions...
#    • Get-Var-Quoted
#    • Is-Valid-Entry
#    • Process-Table
#    • Processing
#    • Prompt-For-From
#    • Prompt-For-Value
#####
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    Processing 1 'MAIN' "SCOPE-CHECKING `${Script:EmailTable}.${level1Key}"

    ##### Get the keys at level 1 from ${Script:EmailTable}, including all Sets, and sort the list...
    ${keysLevel1}   = ${Script:EmailTable}.Keys |
        Where-Object { ${_} -Match '^Set' } |
        Sort-Object
    ${profileIndex} = ${Script:EmailTable}.Condition.ProfileIndex
    Processing 2 "${funcName}" (
        ( Get-Var-Quoted 1 'keysLevel1'   12 'Array' "${keysLevel1}"  -nl )+
        ( Get-Var-Quoted 1 'profileIndex' 12 'None'  "${profileIndex}"    )
    ) -nl

    foreach (${level1Key} in ${keysLevel1}) {
        if (${level1Key} -eq 'Set2_External') {
            Processing 2 "${funcName}" (
                ( Get-Var-Quoted `
                    1 `
                    '${Script:EmailTable}.Set1_Internal.Group0_ItemA_UseExternal.Value' `
                    0 `
                    'None' `
                    ${Script:EmailTable}.Set1_Internal.Group0_ItemA_UseExternal.Value `
                    -noBrackets
                )
            ) -nl
            if (-not ${Script:EmailTable}.Set1_Internal.Group0_ItemA_UseExternal.Value) {
                break # from the foreach loop
            }
        }
        ${keysLevel2} = ${Script:EmailTable}.${level1Key}.Keys | Sort-Object
        if (${level1Key} -eq 'Set3_Profiles' -and ${profileIndex} -ne '0') {
            ${newKeysList} = @()
            foreach (${level2Key} in ${keysLevel2}) {
                ${newKeyName}   = ${level2Key}.Replace('Profile0_', "Profile${profileIndex}_")
                ${newKeysList} += ${newKeyName}
                if (-not ${Script:EmailTable}.${level1Key}.${newKeyName}) {
                    ${Script:EmailTable}.${level1Key}.${newKeyName} = @{}
                    ${Script:EmailTable}.${level1Key}.${newKeyName}.Properties = ${Script:EmailTable}.${level1Key}.${level2Key}.Properties
                    ${Script:EmailTable}.${level1Key}.${newKeyName}.Value      = ${Null}
                }
            } # END of foreach (${level2Key} in ${keysLevel2}) {}
            ${keysLevel2} = ${newKeysList}
            Process-Table 2 "${funcName}" "`${Script:EmailTable}.${level1Key}" ${Script:EmailTable}.${level1Key}
        }
        Processing 2 "${funcName}" ("`n"+( Get-Var-Quoted 1 'keysLevel2' 0 'Array' "${keysLevel2}" ))

        foreach (${level2Key} in ${keysLevel2}) {
            ##### For the Set2_External block, set each item's Properties dynamically from the Set1_Internal block...
            if (${level1Key} -eq 'Set2_External') {
                ${Script:EmailTable}.${level1Key}.${level2Key}.Properties = ${Script:EmailTable}.Set1_Internal.${level2Key}.Properties
            }


            #####
            ##### Handle exceptions...
            #####

            ##### For Profile[0-9]+_ItemA_IgnoreDNS, it's only processed if it doesn't match ${ignoreDNS}...
            if (${level2Key} -Match 'Profile[0-9]+_ItemA_IgnoreDNS$') {
                if (-not ( Is-Valid-Entry ${level2Key} ${Script:EmailTable}.${level1Key}.${level2Key}.Value 'Boolean' )) {
                    ${Script:EmailTable}.Condition.UpdateConfig          = ${True}
                    ${Script:EmailTable}.${level1Key}.${level2Key}.Value = ${ignoreDNS}
                }
                continue # to the next item in the foreach loop
            }
            ##### For Profile[0-9]+_ItemC_From_Set2, it's only processed if ${Script:EmailTable}.Set1_Internal.Group0_ItemA_UseExternal is true...
            if (${level2Key} -Match 'Profile[0-9]+_ItemC_From_Set2$') {
                if (-not ${Script:EmailTable}.Set1_Internal.Group0_ItemA_UseExternal) {
                    if (-not [String]::IsNullOrEmpty(${Script:EmailTable}.${level1Key}.${level2Key}.Value)) {
                        ${Script:EmailTable}.Condition.UpdateConfig          = ${True}
                        ${Script:EmailTable}.${level1Key}.${level2Key}.Value = ''
                    }
                    continue # to the next item in the foreach loop
                }
            }
            ##### For Group0_ItemB_PublicAddresses, it's only processed if ${level1Key}.Group0_ItemA_UseExternal.Value is true...
            if (${level2Key} -eq 'Group0_ItemB_PublicAddresses') {
                if (-not ${Script:EmailTable}.${level1Key}.Group0_ItemA_UseExternal.Value) {
                    if (-not [String]::IsNullOrWhitespace(${Script:EmailTable}.${level1Key}.${level2Key}.Value)) {
                        ${Script:EmailTable}.Condition.UpdateConfig          = ${True}
                        ${Script:EmailTable}.${level1Key}.${level2Key}.Value = ''
                    }
                    continue # to the next item in the foreach loop
                }
            }
            ##### For Group1_SMTP4_UserName, it's only processed if Group1_SMTP4_Authenticate.Value is true...
            if (${level2Key} -eq 'Group1_SMTP4_UserName') {
                if (-not ${Script:EmailTable}.${level1Key}.Group1_SMTP4_Authenticate.Value) {
                    if (-not [String]::IsNullOrWhitespace(${Script:EmailTable}.${level1Key}.${level2Key}.Value)) {
                        ${Script:EmailTable}.Condition.UpdateConfig          = ${True}
                        ${Script:EmailTable}.${level1Key}.${level2Key}.Value = ''
                    }
                    continue # to the next item in the foreach loop
                }
            }

            #####
            ##### If not skipped above...
            #####

            ##### Get all values from ${Script:EmailTable}...
                ${varType}     = ${Script:EmailTable}.${level1Key}.${level2Key}.Properties.Meta1_VarType
                ${varPrompt1}  = ${Script:EmailTable}.${level1Key}.${level2Key}.Properties.Meta2_Prompt1
                ${varPrompt2}  = ${Script:EmailTable}.${level1Key}.${level2Key}.Properties.Meta2_Prompt2
            if (${varType} -eq 'Boolean') {
                ${varRegExKey} = 'Boolean'
                ##### These are never true for Booleans...
                ${mayBeEmpty}  = ${False}
                ${mayBeCSV}    = ${False}
            } else {
                ${varRegExKey} = ${Script:EmailTable}.${level1Key}.${level2Key}.Properties.Meta3_RegExKey
                ##### This is true only if set to true in ${Script:EmailTable}...
                ${mayBeEmpty}  = ${Script:EmailTable}.${level1Key}.${level2Key}.Properties.Meta4_MayBeEmpty
                ##### This is true only if ${varRegExKey} is EmailList...
                ${mayBeCSV}    = [Bool]${varRegExKey}.EndsWith('List')
            }
                ${varValue}    = ${Script:EmailTable}.${level1Key}.${level2Key}.Value

            ##### If ${rerunSetup} is True or ${varValue} is not a valid entry...
            if (${rerunSetup} -or -not ( Is-Valid-Entry ${level2Key} ${varValue} ${varType} ${varRegExKey} ${mayBeEmpty} )) {

                ##### Handle Transitions...
                switch (${level1Key}) {
                    'Set1_Internal'  {
                        ##### For Set1_Internal and Condition.Transition.Set1_Internal is still True...
                        if (${Script:EmailTable}.Condition.Transition.Set1_Internal) {
                            #####
                            # Show a transition box above Set1_Internal to make it obvious to the user that it's not yet Set2 or Set3...
                            #  • This will occur if this is the first Set1 prompt.
                            #####
                            Output-Writer ("`n"+( Draw-Box -textString 'Set1_Internal' -textPadAll 1 ))
                            ##### Set Condition.Transition.Set1_Internal to False, so it doesn't appear again...
                            ${Script:EmailTable}.Condition.Transition.Set1_Internal = ${False}
                        }
                    }
                    'Set2_External'  {
                        ##### For Set2_External and Condition.Transition.Set2_External is still True...
                        if (${Script:EmailTable}.Condition.Transition.Set2_External) {
                            #####
                            # Show a transition box above Set2_External to make it obvious to the user that it's not repeating Set1 again & not yet Set3...
                            #  • This will occur if this is the first Set2 prompt, whether or not there were any Set1 prompts prior to this.
                            #  • Even if there were no Set1 prompts, this makes for a nice title to make it obvious that it's beginning Set2.
                            #####
                            Output-Writer ("`n"+( Draw-Box -textString 'Set1_Internal is done, now for Set2_External' -textPadAll 1 ))
                            ##### Set Condition.Transition.Set2_External to False, so it doesn't appear again...
                            ${Script:EmailTable}.Condition.Transition.Set2_External = ${False}
                        }
                    }
                    'Set3_Profiles' {
                        ##### For Set3_Profiles and Condition.Transition.Set3_Profiles is still True...
                        if (${Script:EmailTable}.Condition.Transition.Set3_Profiles) {
                            #####
                            # Show a transition box above Set3_Profiles to make it obvious to the user that it's not Set1 & Set2...
                            #  • This will occur if this is the first Set3 prompt, whether or not there were any Set1|Set2 prompts prior to this.
                            #  • Even if there were no Set1 or Set2 prompts, this makes for a nice title to make it obvious that it's beginning Set3.
                            #####
                            Output-Writer ("`n"+( Draw-Box -textString 'Set1_Internal & Set2_External are done, now for Set3_Profiles' -textPadAll 1 ))
                            ##### Set Condition.Transition.Set3_Profiles to False, so it doesn't appear again...
                            ${Script:EmailTable}.Condition.Transition.Set3_Profiles = ${False}
                        }
                    }
                } # END of switch (${level1Key}) {}

                ##### If ${rerunSetup} is True...
                if (${rerunSetup}) {
                    #####
                    # Store the original value in ${originalValue} for comparison at the end of this loop, so if
                    #  different, it triggers an update...
                    #####
                    ${originalValue} = ${varValue}
                    ##### Set the default answer to the preexisting value...
                    ${varDefault}    = ${varValue}
                ##### Else if ${rerunSetup} is False...
                } else {
                    ##### Store ${Null} in ${originalValue} to always trigger an update at the end of this loop...
                    ${originalValue} = ${Null}
                    ##### Set the default answer to the value in ${Script:EmailTable}...
                    ${varDefault}    = ${Script:EmailTable}.${level1Key}.${level2Key}.Properties.Meta5_Default
                }
                ${defaultEmpty} = [Bool](${mayBeEmpty} -and ${varDefault} -eq '')

                ##### Prompt for a new value...
                if (${level2Key} -Match '^Profile[0-9]+_ItemC_From') {
                    ${Script:EmailTable}.${level1Key}.${level2Key}.Value = Prompt-For-From `
                        -level1Key     ${level1Key} `
                        -level2Key     ${level2Key} `
                        -defaultAnswer ${varDefault}
                } else {
                    ${Script:EmailTable}.${level1Key}.${level2Key}.Value = Prompt-For-Value `
                        -level1Key     ${level1Key}   `
                        -level2Key     ${level2Key}   `
                        -varType       ${varType}     `
                        -promptText    ${varPrompt1}  `
                        -varRegExKey   ${varRegExKey} `
                        -defaultAnswer ${varDefault}  `
                        -mayBeEmpty    ${mayBeEmpty}  `
                        -mayBeCSV      ${mayBeCSV}    `
                        -defaultEmpty  ${defaultEmpty}
                    if (${varPrompt2}) {
                        if (${Script:EmailTable}.${level1Key}.${level2Key}.Value -eq ${True}) {
                            ${Script:EmailTable}.${level1Key}.${level2Key}.Value = Prompt-For-Value `
                                -level1Key     ${level1Key}   `
                                -level2Key     ${level2Key}   `
                                -varType       ${varType}     `
                                -promptText    ${varPrompt2}  `
                                -varRegExKey   ${varRegExKey} `
                                -defaultAnswer ${varDefault}  `
                                -mayBeEmpty    ${mayBeEmpty}  `
                                -mayBeCSV      ${mayBeCSV}    `
                                -defaultEmpty  ${defaultEmpty}
                        }
                    }
                }
                ##### If a change is detected, trigger an update...
                if (${Script:EmailTable}.${level1Key}.${level2Key}.Value -ne ${originalValue}) {
                    ${Script:EmailTable}.Condition.UpdateConfig = ${True}
                }
            } # END of if (${rerunSetup} -or -not ( Is-Valid-Entry ${level2Key} ${varValue} ${varType} ${varRegExKey} ${mayBeEmpty} )) {}
        } # END of foreach (${level2Key} in ${keysLevel2}) {}
        Process-Table 2 'MAIN' "`${Script:EmailTable}.${level1Key} SCOPED" ${Script:EmailTable}.${level1Key}
    } # END of foreach (${level1Key} in ${keysLevel1}) {}
} # END of function Check-All-Entries


function Check-Path {
#####
# Purpose:
#  • Check for a file path indicated in ${filePath} and briefly described in ${fileName}.
#  • If ${fileName} or ${filePath} aren't properly defined, it's always error immediately using -exitKey 'E3Code'.
#  • If -directory is used, ${filePath} is expected to be a directory, so if it finds a plain file instead, that's an error.
#  • Else, ${filePath} is expected to be a plain file, so if it find a directory instead, that's an error.
#  • If -mustExist is used, it's an error if ${filePath} doesn't already exist, otherwise it's only a warning.
#  • If there's an error...
#    • If -returnOnlyTrueFalse is used, return ${False} to indicate a problem.
#    • Else if full output is needed, use Output-Error to explain the problem and exit using -exitCode ${errorCode}.
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
#      • To account for this, you may need to change the type using:  if ([String]( Check-Path ... ) -eq 'Warning') {}.
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
#    • Get-Quoted
#    • Get-Var-Quoted
#    • Output-Error
#    • Output-Warning
#    • Processing
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
    if ([String]::IsNullOrWhitespace(${fileName})) { Output-Undefined-Error "${funcName}" 'fileName' 'String' }
    if ([String]::IsNullOrEmpty(${filePath})     ) { Output-Undefined-Error "${funcName}" 'filePath' 'String' }
    if (${directory} -and ${warnIfEmpty}) {
        Output-Error `
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
    ${fileSpec} = ("${fileType}, "+( Get-Quoted 'Auto' "${fileName}" )+', '+( Get-Quoted 'Auto' "${filePath}" )+' ')


    Processing 2 "${funcName}" (
        ${fileSpec}.Trim()+"...`n"+
        ( Get-Var-Quoted 1 'fileName'            22 'Auto' "${fileName}"            -nl )+
        ( Get-Var-Quoted 1 'filePath'            22 'Auto' "${filePath}"            -nl )+
        ( Get-Var-Quoted 1 'errorCode'           22 'None' "${errorCode}"           -nl )+
        ( Get-Var-Quoted 1 'directory'           22 'None' "${directory}"           -nl )+
        ( Get-Var-Quoted 1 'mustExist'           22 'None' "${mustExist}"           -nl )+
        ( Get-Var-Quoted 1 'returnOnlyTrueFalse' 22 'None' "${returnOnlyTrueFalse}" -nl )+
        ( Get-Var-Quoted 1 'noWarn'              22 'None' "${noWarn}"              -nl )+
        ( Get-Var-Quoted 1 'warnIfEmpty'         22 'None' "${warnIfEmpty}"         -nl )+
        ( Get-Var-Quoted 1 'warnSuffix'          22 'Auto' "${warnSuffix}"              )
    )
    ##### If ${filePath} is not syntactically valid...
    if (-not (Test-Path -LiteralPath ${filePath} -IsValid)) {
        ##### If only a True/False answer is needed...
        if (${returnOnlyTrueFalse}) {
            ##### Return ${False} to indicate a problem...
            Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+${Script:RuntimeTable}.Symbols.Warn+'Path is INVALID.') -noPrefix
            Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+"return ${False}") -noPrefix
            return ${False}
        ##### Else if full error output is needed...
        } else {
            ##### Exit immediately with an error...
            Output-Error `
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
                Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+${Script:RuntimeTable}.Symbols.Warn+"Path DOESN'T EXIST.") -noPrefix
                Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+"return ${False}") -noPrefix
                return ${False}
            }
        ##### Else if full output is needed...
        } else {
            ##### If -mustExist is used...
            if (${mustExist}) {
                ##### Exit immediately with an error...
                Output-Error `
                    -errorMessage    "${fileSpec}doesn't exist." `
                    -callingFuncName "${funcName}"               `
                    -exitCode         ${errorCode}
            ##### Else -mustExist is NOT used...
            } else {
                Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+"return 'Warning'") -noPrefix
                ##### If warning output is allowed...
                if (-not ${noWarn}) {
                    ##### Output a warning...
                    Output-Warning "${fileSpec}is new${warnSuffix}." -preSpace
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
            Processing 2 "${funcName}" (
                ' '+${Script:RuntimeTable}.Symbols.Bullet+${Script:RuntimeTable}.Symbols.Warn+'Path is NOT THE PROPER TYPE.'
            ) -noPrefix
            Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+"return ${False}") -noPrefix
            return ${False}
        ##### Else if full error output is needed...
        } else {
            ##### Exit immediately with an error...
            Output-Error `
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
                Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+"return 'Warning'") -noPrefix
                ##### If only a True/False answer is needed...
                if (${returnOnlyTrueFalse}) {
                    ##### Return ${False} to indicate a problem...
                    Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+"return ${False}") -noPrefix
                    return ${False}
                ##### Else if warning output is allowed...
                } elseif (-not ${noWarn}) {
                    ##### Output a warning...
                    Output-Warning "${fileSpec}exists but has no data${warnSuffix}." -preSpace
                }
                ##### Return 'Warning' to indicate this condition...
                return 'Warning'
            }
        }
    } # END of if {} elseif {} elseif {} else {}


    ##### If it gets this far, return ${True} to indicate everything is OK and the script can continue...
    Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+${Script:RuntimeTable}.Symbols.Good+'Path is valid.') -noPrefix
    Processing 2 "${funcName}" (' '+${Script:RuntimeTable}.Symbols.Bullet+"return ${True}") -noPrefix
    return ${True} 
} # END of function Check-Path


function Credential-Get {
#####
# Purpose:
#  • Get a saved credential stored in the Windows Credential Manager as
#      ${Env:LocalAppData}\(${Script:RuntimeTable}.BareName+"_${userName}.cred")
#
# Returns:
#  • ${Null}                     — if...
#    • a credential is not saved for ${userName}; or
#    • a credential cannot be imported; or
#    • the imported credential is ${Null} OR is NOT of type [PSCredential].
#  • [PSCredential]${credential} — if a valid credential is retrieved.
#
# Usage:
#  • Parameter 1 — ${userName}: String (REQUIRED) — the user name used to authenticate to the SMTP service.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#####
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=${True})][String]${userName}
    )
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    ##### Sanitize filename (no colons)..
    ${safeFileName} = (${Script:RuntimeTable}.BareName+"_${userName}.cred" -Replace "[:]", "_")

    ##### Build full path safely...
    ${cred_Dir} = Join-Path -Path ${Env:LocalAppData} -ChildPath 'CredStore'
    ${credPath} = Join-Path -Path ${cred_Dir} -ChildPath ${safeFileName}

    if (-not (Test-Path -Path ${credPath} -PathType Leaf)) {
        return ${Null}
    }

    try {
        ${credential} = Import-Clixml -Path ${credPath}
    } catch {
        return ${Null}
    }

    if (${credential} -eq ${Null} -or -not (${credential} -is [PSCredential])) {
        return ${Null}
    }

    return ${credential}
} # END of function Credential-Get


function Credential-Remove {
#####
# Purpose:
#  • Remove credential ${userName} from the Windows Credential Manager stored in
#      ${Env:LocalAppData}\(${Script:RuntimeTable}.BareName+"_${userName}.cred")
#
# Returns:
#  • via Output-Error      — if...
#    • ${userName} is NOT defined; or
#    • if Remove-Item FAILS.
#  • via Output-Credential — if...
#    • a credential for ${userName} is NOT found; or
#    • if Remove-Item SUCCEEDS.
#
# Usage:
#  • Parameter 1 — ${userName}: String (REQUIRED) — the user name to remove.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Output-Credential
#    • Output-Error
#####
    param([String]${userName})
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    if ([String]::IsNullOrWhitespace(${userName})) { Output-Undefined-Error "${funcName}" 'userName' 'String' }

    ${userName} = ${userName}.ToLower()

    ##### Sanitize filename (no colons)..
    ${safeFileName} = (${Script:RuntimeTable}.BareName+"_${userName}.cred" -Replace "[:]", "_")

    ##### Build full path safely...
    ${cred_Dir} = Join-Path -Path ${Env:LocalAppData} -ChildPath 'CredStore'
    ${credPath} = Join-Path -Path ${cred_Dir} -ChildPath ${safeFileName}

    if (-not (Test-Path -Path ${credPath} -PathType Leaf)) {
        Output-Credential "${userName}" 'not found in' "${credPath}"
        return
    }

    ##### Remove...
    try {
        Remove-Item "${credPath}" -ErrorAction SilentlyContinue
    } catch {
        Output-Error `
            -errorMessage    "${funcName}"               `
            -exception       "$(${_}.Exception.Message)" `
            -callingFuncName "${funcName}"               `
            -exitKey         'E3Code'
    }

    ##### Announce what was done...
    Output-Credential "${userName}" 'removed from' "${credPath}"
} # END of function Credential-Remove


function Credential-Save {
#####
# Purpose:
#  • Save a credential for ${userName} in the Windows Credential Manager as
#      ${Env:LocalAppData}\(${Script:RuntimeTable}.BareName+"_${userName}.cred")
#
# Returns:
#  • via Output-Error      — if...
#    • ${userName} is NOT defined; or
#    • Export-CliXML FAILS
#  • via Output-Credential — for all other conditions.
#
# Usage:
#  • Parameter 1 — ${userName}: String (REQUIRED) — the user name used to authenticate to the SMTP host.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Credential-Get
#    • Get-Quoted
#    • Output-Credential
#    • Output-Error
#    • Processing
#####
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = ${True})][String]${userName}
    )
    ${funcName} = ${MyInvocation}.MyCommand.Name

    if ([String]::IsNullOrWhiteSpace(${userName})) { Output-Undefined-Error "${funcName}" 'userName' 'String' }

    ${userName} = ${userName}.ToLower()

    ##### Sanitize filename (no colons)..
    ${safeFileName} = (${Script:RuntimeTable}.BareName+"_${userName}.cred" -Replace "[:]", "_")

    ##### Build full path safely...
    ${cred_Dir} = Join-Path -Path ${Env:LocalAppData} -ChildPath 'CredStore'
    ${credPath} = Join-Path -Path ${cred_Dir} -ChildPath ${safeFileName}

    ##### Ensure directory exists...
    if (-not (Test-Path -Path ${cred_Dir} -PathType Container)) {
        New-Item -Path ${cred_Dir} -ItemType Directory -Force | Out-Null
    }

    ##### Prompt once to enter and once to confirm...
    do {
        ${securePass1} = Read-Host ('<Enter> password for '+( Get-Quoted 'Auto' "${userName}" )) -AsSecureString
        ${securePass2} = Read-Host ('CONFIRM password for '+( Get-Quoted 'Auto' "${userName}" )) -AsSecureString

        ##### Compare the plain text values...
        ${pass1Plain} = [Runtime.InteropServices.Marshal]::PtrToStringUni(
            [Runtime.InteropServices.Marshal]::SecureStringToGlobalAllocUnicode(${securePass1})
        )
        ${pass2Plain} = [Runtime.InteropServices.Marshal]::PtrToStringUni(
            [Runtime.InteropServices.Marshal]::SecureStringToGlobalAllocUnicode(${securePass2})
        )
    } until (${pass1Plain} -ceq ${pass2Plain})

    ##### Save...
    if (${Script:RuntimeTable}.Verbose.InDebugMode) {
        Processing 3 "${funcName}" "`${credential} | Export-CliXML -Path ${credPath}"
    } else {
        ${credential} = New-Object System.Management.Automation.PSCredential (${userName}, ${securePass1})
        try {
            ${credential} | Export-CliXML -Path ${credPath}
        } catch {
            Output-Error `
                -errorMessage    "${funcName}"               `
                -exception       "$(${_}.Exception.Message)" `
                -callingFuncName "${funcName}"               `
                -exitKey         'E3Code'
        }
        ##### Test it...
        ${credential} = Credential-Get ${userName}
        ${pass3Plain} = [Runtime.InteropServices.Marshal]::PtrToStringUni(
            [Runtime.InteropServices.Marshal]::SecureStringToGlobalAllocUnicode(${credential}.Password)
        )
        if (${pass3Plain} -cne ${pass1Plain}) {
            Output-Error `
                -errorMessage    ("${funcName} failed to save the credential in:`n"+( Get-Quoted 'Auto' "${credPath}" )) `
                -callingFuncName  "${funcName}"                                                                          `
                -exitKey          'E3Code'
        }
    } # END of if (${Script:RuntimeTable}.Verbose.InDebugMode) {} else {}

    ##### Announce what was done...
    Output-Credential "${userName}" 'saved to' "${credPath}"
} # END of function Credential-Save


function Draw-Box {
#####
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
} # END of function Draw-Box


function Get-Integer ([String]${numberString}) {
#####
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
} # END of function Get-Integer


function Get-Padded ([String]${textString}='', [Int]${textMaxWidth}=0, [String]${padString}=' ', [Switch]${padBefore}) {
#####
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
} # END of function Get-Padded


function Get-Public-DNS-Domain {
#####
# Purpose:
#  • Get the public DNS DomainName of the host at runtime, or return ${False} if it can't find it.
#  • ${Script:RuntimeTable}.Host.Public.IP must be set first.
#  • 2 different methods will be tried before it gives up.
#
# Returns:
#  • [String]${dnsDomain} — if ${Script:RuntimeTable}.Host.Public.IP is NOT ${False} AND ${dnsDomain} is retrieved AND valid.
#  • [Bool  ]${False}     — for any other condition.
#
# Usage:
#  • No parameters.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RegExTable}
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Get-Var-Quoted
#    • Is-Valid-Entry
#    • Output-Error
#    • Output-Warning
#    • Processing
#  • External...
#    • [System.Net.DNS]
#    • [System.Net.IPAddress]
#    • Resolve-DnsName
#####
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    if (${Script:RuntimeTable}.Host.Public.IP -eq ${False}) { return ${False} }
    ${publicIP} = ${Script:RuntimeTable}.Host.Public.IP

    Processing 2 "${funcName}" (
        "Service 1of2...`n"+
        ( Get-Var-Quoted 1 'publicIP' 0 'Brackets.Angled.Single' "${publicIP}" -nl )+
        ${Script:RuntimeTable}.Verbose.Indent+"[System.Net.DNS]::GetHostEntry(${publicIP}).HostName"
    )
    try {
        ${dnsDomain} = [System.Net.DNS]::GetHostEntry(${publicIP}).HostName
        if (( Is-Valid-Entry '${dnsDomain}:Service 1of2' ${dnsDomain} 'String' 'FQDN' ${False} )) { return ${dnsDomain} }
    } catch {}

    if (${publicIP} -Match ${Script:RegExTable}.PublicIPv4) { # It's IPv4...
        ##### Split into individual octets...
        ${ipOctet}    = ${publicIP} -Split '\.'
        ##### Reverse it and join with dots...
        ${ipReversed} = "$(${ipOctet}[3]).$(${ipOctet}[2]).$(${ipOctet}[1]).$(${ipOctet}[0])"
        ##### Append .in-addr.arpa...
        ${ptrDomain}  = "${ipReversed}.in-addr.arpa"
        ${verboseMessage} = (
            "Service 2of2...`n"+
            "IPv4...`n"+
            ( Get-Var-Quoted 1 'publicIP'    13 'Brackets.Angled.Single' "${publicIP}"   -nl )+
            ( Get-Var-Quoted 1 'ipOctet'     13 'Brackets.Angled.Single' "${ipOctet}"    -nl )+
            ( Get-Var-Quoted 1 'ipReversed'  13 'Brackets.Angled.Single' "${ipReversed}" -nl )+
            ( Get-Var-Quoted 1 'ptrDomain'   13 'Brackets.Angled.Single' "${ptrDomain}"      )
        )

    } else { # It's IPv6...
        ##### Expand compressed IPv6 and convert to Bytes (e.g., ::1 → 0000:0000:0000:0000:0000:0000:0000:0001)...
        ${ipInBytes}   = [System.Net.IPAddress]::Parse(${publicIP}).GetAddressBytes()
        ##### Convert to Hex digits...
        ${ipHexDigits} = foreach (${byte} in ${ipInBytes}) { ${byte}.ToString('x2').ToCharArray() }
        ##### Reverse it and join with dots...
        ${ipReversed}  = (${ipHexDigits}[(${ipHexDigits}.Length-1)..0]) -Join '.'
        ##### Append .ip6.arpa...
        ${ptrDomain}   = "${ipReversed}.ip6.arpa"
        ${verboseMessage} = (
            "Service 2of2...`n"+
            "IPv6...`n"+
            ( Get-Var-Quoted 1 'publicIP'    14 'Brackets.Angled.Single' "${publcIP}"     -nl )+
            ( Get-Var-Quoted 1 'ipInBytes'   14 'Brackets.Angled.Single' "${ipInBytes}"   -nl )+
            ( Get-Var-Quoted 1 'ipHexDigits' 14 'Brackets.Angled.Single' "${ipHexDigits}" -nl )+
            ( Get-Var-Quoted 1 'ipReversed'  14 'Brackets.Angled.Single' "${ipReversed}"  -nl )+
            ( Get-Var-Quoted 1 'ptrDomain'   14 'Brackets.Angled.Single' "${ptrDomain}"       )
        )

    } # END of if (${publicIP} -Match ${Script:RegExTable}.PublicIPv4) {} else {}
    ##### Do the reverse DNS lookup...
    Processing 2 "${funcName}" (
        "${verboseMessage}`n"+
        (${Script:RuntimeTable}.Verbose.Indent*1)+"Resolve-DnsName -Name ${ptrDomain} -Type PTR |`n"+
            (${Script:RuntimeTable}.Verbose.Indent*2)+"Where-Object { `${_}.Type -eq 'PTR' } |`n"+
            (${Script:RuntimeTable}.Verbose.Indent*2)+"Select-Object -ExpandProperty NameHost"
    )
    try {
        ${dnsDomain} = Resolve-DnsName -Name ${ptrDomain} -Type PTR |
            Where-Object { ${_}.Type -eq 'PTR' } |
            Select-Object -ExpandProperty NameHost
        if (( Is-Valid-Entry '${dnsDomain}:Service 2of2' ${dnsDomain} 'String' 'FQDN' ${False} )) { return ${dnsDomain} }
    } catch {}


    ##### If all failed...
    Output-Warning 'Unable to get public DNS domain from multiple sources — your workstation may be offline.'
    return ${False}
} # END of function Get-Public-DNS-Domain


function Get-Public-IP {
#####
# Purpose:
#  • Get the public IP address of the host at runtime, or return ${False} if it can't find it.
#  • 3 different public services will be tried before it gives up.
#
# Returns:
#  • [String]${publicIP} — when it's retrieved and valid.
#  • [Bool  ]${False}    — for any other condition.
#
# Usage:
#  • No parameters.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Is-Valid-Entry
#    • Output-Error
#    • Output-Warning
#    • Processing
#  • External...
#    • Invoke-RestMethod of...
#      • https://ipinfo.io/json
#      • https://ifconfig.me/ip
#    • Resolve-DnsName of...
#      • myip.opendns.com and resolver1.opendns.com
#####
    [CmdletBinding()]
    param()
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    ${publicIP} = ${Null}

    try {
        ${publicIP} = (Invoke-RestMethod 'https://ipinfo.io/json').ip
        Processing 2 "${funcName}" "Service 1of3:Got `${publicIP}='${publicIP}'"
        if (( Is-Valid-Entry '${publicIP}:Service 1of3 IPv4' ${publicIP} 'String' 'PublicIPv4' ${False} )) { return ${publicIP} }
        if (( Is-Valid-Entry '${publicIP}:Service 1of3 IPv6' ${publicIP} 'String' 'PublicIPv6' ${False} )) { return ${publicIP} }
    } catch {}

    try {
        ${publicIP} = Invoke-RestMethod 'https://ifconfig.me/ip'
        Processing 2 "${funcName}" "Service 2of3:Got `${publicIP}='${publicIP}'"
        if (( Is-Valid-Entry '${publicIP}:Service 2of3 IPv4' ${publicIP} 'String' 'PublicIPv4' ${False} )) { return ${publicIP} }
        if (( Is-Valid-Entry '${publicIP}:Service 2of3 IPv6' ${publicIP} 'String' 'PublicIPv6' ${False} )) { return ${publicIP} }
    } catch {}  

    try {
        ${publicIP} = Resolve-DnsName -Name myip.opendns.com -Server resolver1.opendns.com |
              Where-Object { ${_}.Type -eq 'A' } |
              Select-Object -ExpandProperty IPAddress
        Processing 2 "${funcName}" "Service 3of3:Got `${publicIP}='${publicIP}'"
        if (( Is-Valid-Entry '${publicIP}:Service 3of3 IPv4' ${publicIP} 'String' 'PublicIPv4' ${False} )) { return ${publicIP} }
        if (( Is-Valid-Entry '${publicIP}:Service 3of3 IPv6' ${publicIP} 'String' 'PublicIPv6' ${False} )) { return ${publicIP} }
    } catch {}

    ##### If all failed...
    Output-Warning 'Unable to get public IP address from multiple sources — your workstation may be offline.'
    return ${False}
} # END of function Get-Public-IP


function Get-Quoted {
#####
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
#    • E.g. (Get-Quoted 'Begin' "${textString}" 3) produces "///${textString}\\\"
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
    ${regExTable} = @{
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
} # END of function Get-Quoted


function Get-Var-Quoted {
#####
# Purpose:
#  • Similar to Get-Quoted, this returns a ${varName} = ${valueString} pair with ${valueString} quoted with several modifiers detailed below.
#  • If ${varName} is empty, it simply returns.
#
# Returns:
#  • Nothing                           — if ${varName} is empty.
#  • [String]${varName}=${valueString} — as described above and below.
#
# Usage:
#  • Parameter 1 — ${preIndent}:   Integer — the number of times to indent ${varName} using ${nameIndent}=${Script:VerbostTable}.Indent * ${preIndent}.
#  • Parameter 2 — ${varName}:     String  — the name of the variable to show before the =...
#    • If -noBrackets is used, ${varName} is left as is.
#    • Otherwise, it'll be set to "`${${varName}}".
#  • Parameter 3 — ${varMaxWidth}: Integer — the max width of ${varName}.
#    • If ${varMaxWidth}<${varName}.Length, it defaults to ${varName}.Length; a good way to ensure this always occurs is to pass in 0.
#    • If ${varName}.Length<${varMaxWidth}, it pads spaces after ${varName} until it equals ${varMaxWidth}.
#  • Parameter 4 — ${quoteKey}:    String  — the key to the ${quoteTable} in the Get-Quoted function with which to quote ${valueString}.
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
#    where Quote-Opening & Quote-Closing are chosen by Get-Quoted using ${quoteKey}.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Get-Padded
#    • Get-Quoted
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
    ${varName} = ( Get-Padded "${varName}" ${varMaxWidth} )
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
        ${valuePortion} = ("${equalSign}${varType}"+( Get-Quoted "${quoteKey}" "${valueString}" ${repeat} -multiline ${multiIndent} ))
    }
        ${tailPortion}  = "${suffix}${newline}"


    ##### Return the formatted results...
    return "${namePortion}${valuePortion}${tailPortion}"
} # END of function Get-Var-Quoted


function Get-Vars (${getVarsObject}, [String[]]${getVarsExclusions}=@(''), [Bool]${getVarsAliases}, [Int]${getVarsLevel}=1) {
#####
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
#    • Get-Padded
#    • Get-Quoted
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
                ( Get-Quoted 'Auto' ${getVarsTable}.ObjectType )+
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
        if (${getVarsTable}.VarType -eq 'String') { ${getVarsTable}.VarValue = ( Get-Quoted 'Auto' ${getVarsTable}.VarValue ) }
        if (${getVarsTable}.VarType -eq ${Null}) {
            ${getVarsTable}.VarType = ''
        } else {
            ${getVarsTable}.VarType = ( Get-Quoted 'Brackets.Square' ( Get-Padded ${getVarsTable}.VarType ${getVarsTable}.TypePadWidth ) )
        }
        ${getVarsTable}.VarsAndValues += (
            (${Script:RuntimeTable}.Verbose.Indent * ${getVarsLevel})+
            ( Get-Padded "${getVarsID1}" ${getVarsTable}.NamePadWidth )+
            ' = '+
            ${getVarsTable}.VarType+
            ' '+
            ${getVarsTable}.VarValue
        )
    } # END of foreach (${getVarsID1} in ${getVarsTable}.ListOfVars -Split ',\s*') {}

    ##### Return the list in the form Name1='Value1', Name2='Value2', ..., NameN='ValueN'...
    return ${getVarsTable}.VarsAndValues
} # END of function Get-Vars


function Is-Valid-Color ([String]${intendedColor}, [String]${fallbackColor}, [Switch]${returnOnlyTrueFalse}) {
#####
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
#    • via Output-Error         — when both are NOT valid.
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
#    • Output-Error
#    • Processing
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
            Processing 2 "${funcName}" (
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
            Processing 2 "${funcName}" (
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
            Output-Error `
                -errorMessage    "Both the `${intendedColor}='${intendedColor}' & `${fallbackColor}='${fallbackColor}' are INVALID." `
                -callingFuncName "${funcName}" -exitKey 'E3Code'
        }
    } # END of if (${validColors} -Contains ${intendedColor}.ToLower()) {} elseif {} else {}
} # END of function Is-Valid-Color


function Is-Valid-Entry {
#####
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
#    • Get-Quoted
#    • Get-Vars
#    • Output-Error
#    • Process-Debug
#    • Processing
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
            Output-Undefined-Error "${funcName}" 'varRegExKey' 'String'
        }
    }
    ${validation} = ${Script:RegExTable}.${varRegExKey}
    Process-Debug `
        -doIt            (${Script:RuntimeTable}.Verbose.Level -gt 1) `
        -callingFuncName "${funcName}"                                `
        -debugIndex      0                                            `
        -processValue    ( Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values )

    ##### Get the type of ${inputValue}...
    if (${inputValue} -eq ${Null}) {
        ${inputType}    = ${Null}
        ${verboseValue} = ${Script:RuntimeTable}.Verbose.NullString
    } else {
        ${inputType} = ${inputValue}.GetType().Name
        if (${inputType} -eq 'String') {
            ##### Structure of ${inputValue} is quoted...
            ${verboseValue} = ( Get-Quoted 'Auto' "${inputValue}" )
        } else {
            ##### Structure of ${inputValue} is unquoted...
            ${verboseValue} = ${inputValue}
        }
    }
    ${excludedVars} = @('keyName','varType','varRegExKey','mayBeEmpty')
    Process-Debug `
        -doIt            (${Script:RuntimeTable}.Verbose.Level -gt 1) `
        -callingFuncName "${funcName}"                                `
        -debugIndex      1                                            `
        -processValue    ( Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values ${excludedVars} )

    ${isValid} = ${False}
    if (${mayBeEmpty} -and ${inputValue} -eq '') {
        ${isValid} = ${True}
    } else {
        if (${inputType} -eq ${varType}) {
            Processing 2 "${funcName}" (
                ' '+
                ${Script:RuntimeTable}.Symbols.Bullet+
                ${Script:RuntimeTable}.Symbols.Good+
                'Variable Type matches '+
                ( Get-Quoted 'Brackets.Square' "${varType}" )+
                '.'
            ) -noPrefix
            ${isValid} = [Bool]([RegEx]::IsMatch(${inputValue}.ToString().Replace('\','\\'), ${validation}))
            if (${isValid}) {
                Processing 2 "${funcName}" (
                    ' '+${Script:RuntimeTable}.Symbols.Bullet+${Script:RuntimeTable}.Symbols.Good+'Contents match validation.'
                ) -noPrefix
            } else {
                Processing 2 "${funcName}" (
                    ' '+${Script:RuntimeTable}.Symbols.Bullet+${Script:RuntimeTable}.Symbols.Warn+'Contents do not match validation.'
                ) -noPrefix
            }
        } else {
            Processing 2 "${funcName}" (
                ' '+
                ${Script:RuntimeTable}.Symbols.Bullet+
                ${Script:RuntimeTable}.Symbols.Warn+
                'Variable Type '+
                ( Get-Quoted 'Brackets.Square' "${inputType}" )+
                "doesn't match "+
                ( Get-Quoted 'Brackets.Square' "${varType}"   )+
                '.'
            ) -noPrefix
            ${isValid} = ${False}
        }
    } # END of if (${mayBeEmpty} -and ${inputValue} -eq '') {} else {}

    Processing 2 "${funcName}" "  return ${isValid}" -noPrefix
    return ${isValid}
} # END of function Is-Valid-Entry


function JSON-Assemble ([String]${action}) {
#####
# Purpose:
#  • If ${action}='GET', it gets all values from JSON ${Script:EmailTable}.ConfigFile.JSON & populates them into the ${Script:EmailTable}.Set* fields.
#  • If ${action}='PUT', it gets all values from the ${Script:EmailTable}.Set* fields & assembles them into JSON to ${Script:EmailTable}.ConfigFile.Data.
#
# Returns:
#  • If ${action}='GET':  ${Script:EmailTable}.Set* populated from ${Script:EmailTable}.ConfigFile.JSON.
#  • If ${action}='PUT':  ${Script:EmailTable}.ConfigFile.JSON populated from ${Script:EmailTable}.Path.
#
# Usage:
#  • Parameter 1 — ${action}: String (REQUIRED) — must be 'GET' or 'PUT'.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:EmailTable}
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Get-Quoted
#    • Get-Var-Quoted
#    • Output-Error
#    • Process-Table
#    • Processing
#####
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )
    if (${action} -ne 'GET' -and ${action} -ne 'PUT') {
        Output-Error `
            -errorMessage    "Required parameter [String]`${action}='${action}' does not match required keywords GET or PUT." `
            -callingFuncName "${funcName}" -exitKey 'E3Code'
    }

    ##### Get the keys lists from ${Script:EmailTable}, including all Sets, and sort the list...
    ${keysLevel1} = ${Script:EmailTable}.Keys |
        Where-Object { ${_} -Match '^Set' } |
        Sort-Object
    ##### Get the index of the last item in ${keysLevel1A}...
    ${keysLevel1Last} = (${keysLevel1}.Count - 1)

    ##### Before iterating the list...
   if (${action} -eq 'GET') {
        Processing 1 'MAIN' 'ACTION Getting Config Data—Assembling HashTables ${Script:EmailTable}.Set* from JSON ${Script:EmailTable}.ConfigFile.JSON'
        ##### Profile0_ItemC_From_Set2 inherits properties from Profile0_ItemC_From_Set1...
        ${Script:EmailTable}.Set3_Profiles.Profile0_ItemC_From_Set2.Properties = `
        ${Script:EmailTable}.Set3_Profiles.Profile0_ItemC_From_Set1.Properties
    } elseif (${action} -eq 'PUT') {
        Processing 1 'MAIN' 'ACTION Updating Config File—Assembling JSON ${Script:EmailTable}.ConfigFile.JSON from HashTables ${Script:EmailTable}.Set*'
        ${objectJSON} = @{
            Set1_Internal = @{}
            Set2_External = @{}
            Set3_Profiles = @{}
        }
    }

    ##### Iterate ${keysLevel1}...
    Processing 2 "${funcName}" (
        "Iterating `${Script:EmailTable}...`n"+
        ( Get-Var-Quoted 1 'keysLevel1' 0 'Array' "${keysLevel1}" )
    ) -nl

    foreach (${level1Key} in ${keysLevel1}) {
        Processing 2 "${funcName}" ( Get-Var-Quoted 1 'tableKey' 0 'Auto' "${level1Key}" -preBullet ) -noPrefix

        ##### Get the keys list for level 2...
        ${keysLevel2} = ${Script:EmailTable}.${level1Key}.Keys | Sort-Object
        Processing 2 "${funcName}" ( Get-Var-Quoted 1 'keysLevel2' 0 'Auto' "${keysLevel2}" -preBullet ) -noPrefix

        ##### Iterate the ${keysLevel2}...
        foreach (${level2Key} in ${keysLevel2}) {
            if (${action} -eq 'GET') {
                ##### Populate each ${level2Key} in the ${Script:EmailTable}.Set* HashTables from the ${Script:EmailTable}.ConfigFile.JSON JSON....
                ${keyValue} = ${Script:EmailTable}.ConfigFile.JSON.${level1Key}.${level2Key}
                if (${keyValue} -eq ${Null}) {
                    ${verboseValue} = ${Script:RuntimeTable}.Verbose.NullString
                } else {
                    ${keyType} = ${keyValue}.GetType().Name
                    if (${keyType} -eq 'Boolean') {
                        ${verboseValue} = "${keyValue}"
                    } else {
                        ${verboseValue} = ( Get-Quoted 'Auto' "${keyValue}" )
                    }
                }
                Processing 2 "${funcName}" (
                    ( Get-Var-Quoted 1 'keyName' 1 'Auto' "${level2Key}"      -tighten -preBullet -scs )+
                    ( Get-Var-Quoted 0 'Value'   0 'None' "${verboseValue}" -tighten                 )
                ) -noPrefix

                ${Script:EmailTable}.${level1Key}.${level2Key}.Value = ${keyValue}
            } elseif (${action} -eq 'PUT') {
                ##### Get the key value and type...
                ${keyValue} = ${Script:EmailTable}.${level1Key}.${level2Key}.Value
                if (${keyValue} -eq ${Null}) {
                    ${keyType} = ${Null}
                } else {
                    ${keyType} = ${keyValue}.GetType().Name
                }
                ##### Based on ${keyType}, Determine proper quoting...
                ${quoteKey} = 'Auto'
                Processing 2 "${funcName}" (
                        ( Get-Var-Quoted 1 'keyName'                                  0 'Auto'        "${level2Key}" -tighten -preBullet      )+
                        ' BEFORE '+
                        ( Get-Var-Quoted 0 "`${objectJSON}.${level1Key}.${level2Key}" 0 "${quoteKey}" "${keyValue}" -tighten -noBrackets -scs )+
                        ( Get-Var-Quoted 0 'keyType'                                  0 'Auto'        "${keyType}"  -tighten                  )
                ) -noPrefix

                ##### Assign to ${objectJSON} with key ${level2Key}, the ${keyValue} as...
                if (${keyType} -eq 'String') {
                    ##### quoted...
                    ${objectJSON}.${level1Key}.${level2Key} = "${keyValue}"
                } else {
                    ##### unquoted...
                    ${quoteKey} = 'None'
                    ${objectJSON}.${level1Key}.${level2Key} = ${keyValue}
                }
                Processing 2 "${funcName}" (
                    ( Get-Var-Quoted 1 'keyName'                                  0 'Auto'        "${level2Key}" -tighten -preBullet       )+
                    ' SCOPED '+
                    ( Get-Var-Quoted 0 "`${objectJSON}.${level1Key}.${level2Key}" 0 "${quoteKey}" "${keyValue}"  -tighten -noBrackets -scs )+
                    ( Get-Var-Quoted 0 'keyType'                                  0 'Auto'        "${keyType}"   -tighten                  )
                ) -noPrefix
            } # END of (1of2) if (${action} -eq 'GET') {} elseif (${action} -eq 'PUT') {}
        } # END of foreach (${level2Key} in ${keysLevel2}) {}
    } # END of foreach (${level1Key} in ${keysLevel1}) {}
    Processing 2 "${funcName}" (${Script:RuntimeTable}.Verbose.Indent+'End of table iteration.') -noPrefix

    ##### After iterating the list...
    if (${action} -eq 'GET') {
        Process-Table `
            2 `
            'MAIN' `
            '${Script:EmailTable} BEFORE' `
             ${Script:EmailTable}
    } elseif (${action} -eq 'PUT') {
        ##### Assemble an array from JSON by the sorted keys list and pad after all keys according to ${padWidth}...

        ##### Initialize the array with the JSON opening {...
        ${arrayFromJSON} = @('{')
        ##### Iterate ${keysLevel1}...
        Processing 2 "${funcName}" (
            "Iterating `${Script:EmailTable}...`n"+
            ( Get-Var-Quoted 1 'keysLevel1' 0 'Array' "${keysLevel1}" )
        ) -nl
        ${tableCount} = -1
        foreach (${level1Key} in ${keysLevel1}) {
            ${tableCount}++
            Processing 2 "${funcName}" (
                ( Get-Var-Quoted 1 'tableKey'   0 'Auto' "${level1Key}"   -tighten -preBullet -scs )+
                ( Get-Var-Quoted 0 'tableCount' 0 'None' "${tableCount}" -tighten                 )
            ) -noPrefix
            ##### JSON opening line for this ${level1Key}...
            ${arrayFromJSON} += "  `"${level1Key}`" : {"
            ##### Get the keys list for level 2...
            ${keysLevel2} = ${Script:EmailTable}.${level1Key}.Keys | Sort-Object
            Processing 2 "${funcName}" ( Get-Var-Quoted 2 'keysLevel2' 0 'Array' "${keysLevel2}" -preBullet ) -noPrefix
            ##### Get the index of the last key...
            ${keysLevel2Last} = (${keysLevel2}.Count - 1)
            ##### Get the width of the largest key for padding...
            ${padWidth} = (${keysLevel2} | ForEach-Object { ${_}.Length } | Measure-Object -Maximum).Maximum
            ${keyCount} = -1
            ##### Iterate the ${keysLevel2}...
            foreach (${level2Key} in ${keysLevel2}) {
                ${keyCount}++
                ##### Add the next line of the array according to ${level2Key}...
                ${padding}  = ' ' * (${padWidth} - ${level2Key}.Length)
                ${keyValue} = ${objectJSON}.${level1Key}.${level2Key}
                if ([String]::IsNullOrEmpty(${keyValue})) {
                    ${keyType}  = 'String'
                    ${keyValue} = ''
                } else {
                    ${keyType}  = ${keyValue}.GetType().Name
                }
                if (${keyType} -eq 'String') {
                    ##### Structure for ${keyValue} is case as-is and quoted...
                    ${keyNameValuePair} = "    `"${level2Key}`"${padding} : `"${keyValue}`""
                } else {
                    ##### Structure for ${keyValue} is lower case and unquoted...
                    ${keyValue} = ${keyValue}.ToString().ToLower()
                    ${keyNameValuePair} = "    `"${level2Key}`"${padding} : ${keyValue}"
                }
                ##### If ${keyCount}<${keysLevel2Last}, append a comma for the next key/value pair...
                if (${keyCount} -lt ${keysLevel2Last}) { ${keyNameValuePair} += ',' }
                Processing 2 "${funcName}" (
                    ( Get-Var-Quoted 2 'keyName'          0 'Auto' "${level2Key}"        -tighten -preBullet -scs )+
                    ( Get-Var-Quoted 0 'keyCount'         0 'None' "${keyCount}"         -tighten            -scs )+
                    ( Get-Var-Quoted 0 'keyNameValuePair' 0 'None' "${keyNameValuePair}" -tighten                 )
                ) -noPrefix

                ##### Append this key/value pair...
                ${arrayFromJSON} += "${keyNameValuePair}"
            } # END of foreach (${level2Key} in ${keysLevel2}) {}
            if (${tableCount} -lt ${keysLevel1Last}) {
                ##### JSON closing } for this ${level1Key} with a , to continue for the next table...
                ${arrayFromJSON} += '  },'
            } else {
                ##### JSON closing } for this ${level1Key} with no , because this is the last table...
                ${arrayFromJSON} += '  }'
            }
        } # END of foreach (${level1Key} in ${keysLevel1}) {}
        Processing 2 "${funcName}" "  End of table iteration." -noPrefix
        ##### Finalize the array with the JSON closing }...
        ${arrayFromJSON} += '}'
        ##### Convert the array to a string by joining each line with a newline, and assign it to ${Script:EmailTable}.ConfigFile.Data...
        ${Script:EmailTable}.ConfigFile.Data = ${arrayFromJSON} -Join "`n"
        Processing 2 'MAIN' '${Script:EmailTable}.ConfigFile.Data' ${Script:EmailTable}.ConfigFile.Data
    } # END of (2of2) if (${action} -eq 'GET') {} elseif (${action} -eq 'PUT') {}
} # END of function JSON-Assemble


function Output-Credential {
#####
# Purpose:
#  • To write friendly output to the console in Green after a credential is either saved or removed.
#
# Returns:
#  • via Output-Error  — if ${userName}, ${scopePhrase}, or ${credPath} are NOT properly defined.
#  • via Output-Writer — for all other conditions.
#
# Usage:
#  • Parameter 1 — ${userName}:    String (REQUIRED) — the user name to show in the console.
#  • Parameter 2 — ${scopePhrase}: String (REQUIRED) — the phrase, describing the scope of what was just done, to show after the user name.
#  • Parameter 3 — ${credPath}:    String (REQUIRED) — the full path to the credential file to inform the user where it's stored.
#
# Dependencies:
# • Global declarations...
#   • ${Script:RuntimeTable}
# • Functions...
#   • Get-Quoted
#   • Output-Error
#   • Output-Writer
#####
    param(
        [String]${userName},
        [String]${scopePhrase},
        [String]${credPath}
    )
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    if ([String]::IsNullOrWhitespace(${userName})   ) { Output-Undefined-Error "${funcName}" 'userName'    'String' }
    if ([String]::IsNullOrWhitespace(${scopePhrase})) { Output-Undefined-Error "${funcName}" 'scopePhrase' 'String' }
    if ([String]::IsNullOrWhitespace(${credPath})   ) { Output-Undefined-Error "${funcName}" 'credPath'    'String' }

    ${credMessageTable} = @{
        Prefix  = ${Script:RuntimeTable}.Symbols.Good
        BgColor = 'Black'
        FgColor = 'Green'
        Newline = ${False}
    }
    if (${scopePhrase} -eq 'not found in') {
        ${credMessageTable} = @{
            Prefix  = "`nA"
            BgColor = 'DarkYellow'
            FgColor = 'Black'
            Newline = ${True}
        }
    }
    ${credMessageArray} = @(
        (' Credential for '+( Get-Quoted 'Auto' "${userName}" )+' was ${scopePhrase} the Windows Credential Manager')
        ('in path '+( Get-Quoted 'Auto' "${credPath}" )+'.')
    )
    ${credMessageText}  = ${credMessageTable}.Prefix
    ${credMessageText} += ${credMessageArray} -Join "`n"
    if (${scopePhrase} -eq 'saved to') {
        ${credMessageArray} = @(
            ''
            ' ▄▄▄▄▄▄▄▄▄▄                                                                               '
            ' ▌ CAVEAT ▐                                                                               '
            ' ▀▀▀▀▀▀▀▀▀▀                                                                               '
            ' The encryption method used is specific to this user account on this host only.           '
            ' To use this credential on any other host or user account, you must re-create it on each. '
            ' To remove this credential at any time, simply use parameter -rm|-Remove.                 '
            '                                                                                          '
        )
        ${credMessageCaveat} = ${credMessageArray} -Join "`n"
    } else {
        ${credMessageCaveat} = ${Null}
    }

    ##### This is not an error condition, so -niExitKey 'E0Good'...
    Output-Writer `
        -textOutput        "${credMessageText}"        `
        -streamWord        'Information'               `
        -backgroundColor   ${credMessageTable}.BgColor `
        -foregroundColor   ${credMessageTable}.FgColor `
        -newlineAfter      ${credMessageTable}.Newline `
        -niCallingFunction "${funcName}"               `
        -niCallingVarNames "`"`${credMessageText}`""   `
        -niExitKey         'E0Good'
    if (${credMessageCaveat}) {
        Output-Writer `
            -textOutput        "${credMessageCaveat}"      `
            -streamWord        'Information'               `
            -backgroundColor   'White'                     `
            -foregroundColor   'Black'                     `
            -newlineAfter      ${True}                     `
            -niCallingFunction "${funcName}"               `
            -niCallingVarNames "`"`${credMessageCaveat}`"" `
            -niExitKey         'E0Good'
    }
} # END of function Output-Credential


function Output-Error {
#####
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
#  • via Output-Writer — in all cases; then
#  • [Console]::Beep() — if ${Script:RuntimeTable}.ExitStatus.${exitKey} (where ${exitKey} is E0Good, E1Warn, E2User, E3Code, or EXMore) is True; then
#  • via Process-Exit  — when ${exitCode}>0.
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
#    • Get-Var-Quoted
#    • Is-Valid-Color
#    • Output-Writer
#    • Process-Exit
#    • Processing
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
        Processing 2 "${funcName}" (${Script:RuntimeTable}.Symbols.Warn+"ExitCode=${exitCode} is less than 0, defaulting to 0.")
        ${exitCode} = 0
    } elseif (${exitCode} -gt 255) {
        Processing 2 "${funcName}" (${Script:RuntimeTable}.Symbols.Warn+"ExitCode=${exitCode} is more than 255, defaulting to 255.")
        ${exitCode} = 255
    } else {
        Processing 2 "${funcName}" (${Script:RuntimeTable}.Symbols.Good+"ExitCode=${exitCode} is valid.")
    }


    ##### If ${undefinedParam} is defined...
    if (-not [String]::IsNullOrWhitespace(${undefinedParam})) {
        ##### Set ${errorMessage} to "Required function parameter ${undefinedType}`${${undefinedParam}} is undefined."...
        if ([String]::IsNullOrWhitespace(${exitKey})) { ${exitCode} = ${Script:RuntimeTable}.ExitStatus.E3Code }
        Processing 2 "${funcName}" (
            ( Get-Var-Quoted 1 'undefinedParam'  18 'Auto' "${undefinedParam}"  -nl )+
            ( Get-Var-Quoted 1 'undefinedType'   18 'Auto' "${undefinedType}"   -nl )+
            ( Get-Var-Quoted 1 'exitCode'        18 'None' "${exitCode}"        -nl )+
            ( Get-Var-Quoted 1 'backgroundColor' 18 'Auto' "${backgroundColor}" -nl )+
            ( Get-Var-Quoted 1 'foregroundColor' 18 'Auto' "${foregroundColor}"     )
        ) -nl
        if ([String]::IsNullOrWhitespace(${undefinedType})) { ${undefinedType} = '' } else { ${undefinedType} = "[${undefinedType}]" }
        ${errorMessage} = "Required function parameter ${undefinedType}`${${undefinedParam}} is undefined."

    ##### Else if ${customMessage} is defined...
    } elseif (-not [String]::IsNullOrEmpty(${customMessage})) {
        ##### Set ${errorMessage} to ${customMessage} without any formatting...
        Processing 2 "${funcName}" (
            ( Get-Var-Quoted 1 'customMessage'    0                    -noValue -nl )+
            ( Get-Var-Quoted 1 'exitCode'        18 'None' "${exitCode}"        -nl )+
            ( Get-Var-Quoted 1 'backgroundColor' 18 'Auto' "${backgroundColor}" -nl )+
            ( Get-Var-Quoted 1 'foregroundColor' 18 'Auto' "${foregroundColor}"     )
        ) -nl
        ${errorMessage} = ${customMessage}

    ##### Else if ${customMessage} is NOT defined, format ${errorMessage} as follows...
    } else {
        Processing 2 "${funcName}" (
            ( Get-Var-Quoted 1 'errorMessage'     0                    -noValue -nl )+
            ( Get-Var-Quoted 1 'exitCode'        18 'None' "${exitCode}"        -nl )+
            ( Get-Var-Quoted 1 'backgroundColor' 18 'Auto' "${backgroundColor}" -nl )+
            ( Get-Var-Quoted 1 'foregroundColor' 18 'Auto' "${foregroundColor}"     )
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
        if (-not [String]::IsNullOrWhitespace(${callingfunction})) {
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
        ${backgroundColor} = ( Is-Valid-Color -intendedColor "${backgroundColor}" -fallbackColor 'DarkYellow' )
        ${foregroundColor} = ( Is-Valid-Color -intendedColor "${foregroundColor}" -fallbackColor 'Black'      )

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
        ${backgroundColor} = ( Is-Valid-Color -intendedColor "${backgroundColor}" -fallbackColor 'Black'      )
        ${foregroundColor} = ( Is-Valid-Color -intendedColor "${foregroundColor}" -fallbackColor 'Red'        )
    }


    #####
    # Write the ${errorMessage}...
    #  • This uses -niExitKey 'E0Good' to the Process-Non-Interactive function, because it should honor the ${exitCode} of this function.
    #####
    Output-Writer `
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
    Processing 2 "${funcName}" (
        "For ExitStatus.${exitKey}, `${Script:RuntimeTable}.ErrorBeepsOn.${exitKey}="+${Script:RuntimeTable}.ErrorBeepsOn.${exitKey}
    )
    if (${Script:RuntimeTable}.ErrorBeepsOn.${exitKey}) { [Console]::Beep() }


    #####
    # If ${exitCode}>0, then exit with that code...
    #####
    if (${exitCode} -gt 0) { Process-Exit ${exitCode} "${funcName}" }
} # END of function Output-Error


function Output-Feedback ([String]${feedbackMessage}, [Switch]${success}) {
#####
# Purpose:
#  • Outputs "${prefix}${feedbackMessage}" as feedback as defined in the Processing function when ${processPrefix}='Feedback'.
#
# Returns:  via Processing in all cases.
#
# Usage:
#  • Parameter 1 — ${feedbackMessage}: String — the message to output as feedback.
#  • Parameter -success:               Switch — if used, sets ${prefix}=${Script:RuntimeTable}.Symbols.Good.
#
# Dependencies:
#  • Functions...
#    • Processing
#####
    if (${success}) { ${prefix} = ${Script:RuntimeTable}.Symbols.Good } else { ${prefix} = '' }

    Processing 0 'Feedback' "${prefix}${feedbackMessage}"
} # END of function Output-Feedback


function Output-Help-Page {
#####
# Purpose:
#  • Output the help block from the top of this script, between the <#-HELP-# and #-HELP-#> lines.
#  • If it doesn't find the block, it prints an error.
#
# Returns:
#  • via Wrap-text      — if ${helpTagBegin} AND ${helpTagClose} are both FOUND in this script; or
#  • via Output-Warning — if either ${helpTagBegin} AND/OR ${helpTagClose} are NOT found in this script; then
#  • via Process-Exit   — in all cases.
#
# Usage:
#  • No parameters (uses ${Script:RuntimeTable}.FullPath as input between the lines beginning with <#-HELP-# & #-HELP-#>
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Get-Padded
#    • Get-Quoted
#    • Get-Var-Quoted
#    • Output-Warning
#    • Process-Exit
#    • Processing
#    • Wrap-Text
#  • Other...
#    • There must be a commented help section somewhere in the script bounded by ${helpTagBegin} and ${helpTagClose}.
#####
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    ${scriptPath} = ${Script:RuntimeTable}.FullPath

    ${scriptLines}   = Get-Content -Path ${scriptPath}
    ${termWidth}     = ${Host}.UI.RawUI.WindowSize.Width
    ${helpBlock}     = ''
    ${helpTagBegin}  = '<#-HELP-#'
    ${helpTagClose}  = '#-HELP-#>'
    ${helpLineClose} = -1
    ${helpLineStart} = -1
    Processing 2 "${funcName}" (
        ( Get-Var-Quoted 1 'scriptPath'           20 'Auto' "${scriptPath}"                   -nl )+
        ( Get-Var-Quoted 1 '${scriptLines}.Count' 20 'None'  ${scriptLines}.Count -noBrackets -nl )+
        ( Get-Var-Quoted 1 'termWidth'            20 'None' "${termWidth}"                    -nl )+
        ( Get-Var-Quoted 1 'helpTagBegin'         20 'Auto' "${helpTagBegin}"                 -nl )+
        ( Get-Var-Quoted 1 'helpTagClose'         20 'Auto' "${helpTagClose}"                     )
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
            ${verboseVName1} = ('${scriptLines}'+( Get-Quoted 'Brackets.Square' ( Get-Padded (${helpLineStart}-1) ${verboseWidth} -padBefore ) ))
            ${verboseVNameN} = ('${scriptLines}'+( Get-Quoted 'Brackets.Square' ( Get-Padded (${helpLineClose}+1) ${verboseWidth} -padBefore ) ))
            ${verboseValue1} = ${scriptLines}[(${helpLineStart}-1)..(${helpLineStart}-1)]
            ${verboseValueN} = ${scriptLines}[(${helpLineClose}+1)..(${helpLineClose}+1)]
            Processing 2 "${funcName}" (
                ( Get-Var-Quoted 1 'helpLineCount'    20 'None'  ${helpLineCount}              -nl )+
                ( Get-Var-Quoted 1 'helpLineStart'    20 'None'  ${helpLineStart}              -nl )+
                ( Get-Var-Quoted 1 'helpLineClose'    20 'None'  ${helpLineClose}              -nl )+
                ( Get-Var-Quoted 1 "${verboseVName1}" 20 'Auto' "${verboseValue1}" -noBrackets -nl )+
                ( Get-Var-Quoted 1 "${verboseVNameN}" 20 'Auto' "${verboseValueN}" -noBrackets     )
            ) -noPrefix

            ${helpBlock} = (${scriptLines}[(${helpLineStart})..(${helpLineClose})] -Join "`n") -Split '\r?\n'

            foreach (${lineString} in ${helpBlock}) {
                if ([String]::IsNullOrWhiteSpace(${lineString})) {
                    ''
                } else {
                    ${lineString} = ${lineString} `
                        -Replace '^\.PARAMETER ',    ''                                                           `
                        -Replace '^\.',              ''                                                           `
                        -Replace 'EmailBot\.ps1',    ${Script:RuntimeTable}.Basename                              `
                        -Replace 'EmailBot',         ${Script:RuntimeTable}.BareName                              `
                        -Replace 'exit with code 1', ('exit with code '+${Script:RuntimeTable}.ExitStatus.E2User) `
                        -Replace 'exit with code 2', ('exit with code '+${Script:RuntimeTable}.ExitStatus.E3Code) `
                        -Replace 'exit with code 3', ('exit with code '+${Script:RuntimeTable}.ExitStatus.E4NIMR)
                    Wrap-Text "${lineString}"
                } # END of if ([String]::IsNullOrWhiteSpace(${lineString})) {} else {}
            } # END of foreach (${lineString} in ${helpBlock}) {}
            break # from the for loop
        } # END of if (${helpLineStart} -ge 0 -and ${helpLineClose} -gt ${helpLineStart}) {}
    } # END of for (${lineNum} = 0; ${lineNum} -lt ${scriptLines}.Count; ${lineNum}++) {}

    if (${helpLineStart} -ge 0 -and ${helpLineClose} -gt ${helpLineStart}) {
        ##### Do nothing here.
    } else {
        Output-Warning (
            'No help block found in '+( Get-Quoted 'Auto' "${scriptPath}" )+".`n"+
            "The help block must begin with ${helpTagBegin} & end with ${helpTagClose} each at the beginning of the line.`n"
        )
    }

    Process-Exit ${Script:RuntimeTable}.ExitStatus.E0Good "${funcName}"
} # END of function Output-Help-Page


function Output-Undefined-Error ([String]${undefinedFunc}, [String]${undefinedParam}, [String]${undefinedType}) {
#####
# Purpose:
#  • Wrapper for Output-Error
#       -undefinedParam  "${undefinedParam}" `
#       -undefinedType   "${undefinedType}"  `
#       -callingFuncName "${undefinedFunc}"
#  • If either ${undefinedFunc} or ${undefinedParam} are undefined, it'll issue a "that's embarrassing" error.
#
# Returns:  via Output-Error as described above and below.
#
# Usage:
#  • Parameter 1 — ${undefinedFunc}:  String (REQUIRED) — the name of the calling function.
#  • Parameter 2 — ${undefinedParam}: String (REQUIRED) — the name of the undefined parameter.
#  • Parameter 3 — ${undefinedType}:  String            — if used, the expected variable type of the undefined parameter.
#
# Dependencies:
#  • Functions...
#    • Output-Error
#####
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    ${embarrassingPrefix} = "Well, that's embarrassing, required function parameter [String]`${"
    ${embarrassingSuffix} = '} is undefined.'
    if ([String]::IsNullOrWhitespace(${undefinedFunc})) {
        Output-Error `
            -errorMessage    "${embarrassingPrefix}undefinedFunc${embarrassingSuffix}" `
            -callingFunction "${funcName}" -exitKey 'E3Code'
    }
    if ([String]::IsNullOrWhitespace(${undefinedParam})) {
        Output-Error `
            -errorMessage    "${embarrassingPrefix}undefinedParam${embarrassingSuffix}" `
            -callingFunction "${callingFuncName}:${funcName}" -exitKey 'E3Code'
    }


    Output-Error `
        -undefinedParam  "${undefinedParam}" `
        -undefinedType   "${undefinedType}"  `
        -callingFuncName "${undefinedFunc}"
} # END of function Output-Undefined-Error


function Output-Warning {
#####
# Purpose:
#  • Calls Output-Error with...
#    • -customMessage   "${prefix}${warningMessage}"
#    • -exception       "${exception}"
#    • -backgroundColor "${backgroundColor}"
#    • -foregroundColor "${foregroundColor}"
#    • -exitKey         'E1Warn'
#
# Returns:  via Output-Error as described above and below.
#
# Usage:
#  • Parameter 1 — ${warningMessage}: String — the message to write to the console, prepended with ${prefix}=${Script:RuntimeTable}.Symbols.Warn.
#  • Parameter -prefix:               String — [Default=''] if used, additional text to prepend before ${Script:RuntimeTable}.Symbols.Warn.
#  • Parameter -preSpace:             Switch — if used, prepends an extra space to ${prefix}.
#  • Parameter -noPrefix:             Switch — if used (takes priority over -prefix & -preSpace), omits ${prefix} entirely.
#  • Parameter -backgroundColor:      String — [Default=''] if used, override the default ${backgroundColor} in Output-Error.
#  • Parameter -foregroundColor:      String — [Default=''] if used, override the default ${foregroundColor} in Output-Error.
#  • Parameter -exception:            String — [Default=''] if used, also pass in -exception "${exception}" to Output-Error.
#
# Dependencies:
#  • Functions...
#    • Output-Error
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


    Output-Error `
        -customMessage   "${prefix}${warningMessage}" `
        -exception       "${exception}"               `
        -backgroundColor "${backgroundColor}"         `
        -foregroundColor "${foregroundColor}"         `
        -exitKey         'E1Warn'
} # END of function Output-Warning


function Output-Writer {
#####
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
#  • If ${niActive} is True, it calls Process-Non-Interactive to re-frame the message.
#  • Otherwise, it outputs ${textOutput}, honoring -extraNewline & -noNewline, and using...
#    • If ${outFile} is defined and valid, it writes to it using Out-File.
#    • If ${streamNum} is 1, it uses Write-Output, otherwise if 6, it uses Write-Host.
#      • If using Write-Host, it can also use...
#        • -BackgroundColor ${backgroundColor}
#        • -ForegroundColor ${foregroundColor}
#
# Returns:
#  • via Process-Non-Interactive  — if -thisIsAnNiMessage is NOT used AND ${Script:RuntimeTable}.NonInteractive.IsTrue is True.
#  • via Out-File/Output-Feedback — if ${outFile} is defined AND valid.
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
#  • Parameter -niCallingFunction:   String  — in -NonInteractive mode, the function name to show in the Process-Non-Interactive function.
#  • Parameter -niCallingVarNames:   String  — in -NonInteractive mode, the var name(s) to show instead of '${textOutput}' in Process-Non-Interactive.
#  • Parameter -niExitCode:          Integer — [Default=${Script:RuntimeTable}.ExitStatus.E4NIMR] for -NonInteractive mode,
#     the exit code to pass into the Process-Non-Interactive function.
#  • Parameter -niExitKey:           String  — [Default=''] in lieu of an ${niExitCode}, use ${Script:RuntimeTable}.ExitStatus.${niExitKey}.
#  • Parameter -thisIsAnNiMessage:   Boolean — indicates whether or not the call to this function was from Process-Non-Interactive, and if True, prevents
#     calling it again.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Check-Path
#    • Get-Quoted
#    • Is-Valid-Color
#    • Output-Error
#    • Output-Feedback
#    • Process-Non-Interactive
#    • Processing
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
        ##### Use Check-Path only to check for errors and don't output any warning messages...
        ${Null} = ( Check-Path 'Output File' "${outFile}" -noWarn -callingFuncName "${funcName}" )

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
            -not ( Is-Valid-Color -intendedColor "${backgroundColor}" -fallbackColor '' -returnOnlyTrueFalse ) -or
            -not ( Is-Valid-Color -intendedColor "${foregroundColor}" -fallbackColor '' -returnOnlyTrueFalse )
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
    # If ${thisIsAnNiMessage} is True, then the call to this function is ultimately from Process-Non-Interactive, so set ${niActive} to False so it
    #  won't call Process-Non-Interactive again to prevent an infinite loop.
    #####
    if (${thisIsAnNiMessage}) {
        ${niActive} = ${False}
    #####
    # Else if ${thisIsAnNiMessage} is False, then the call to this function is NOT from Process-Non-Interactive, so set ${niActive} to
    #  ${Script:RuntimeTable}.NonInteractive.IsTrue to determine if Process-Non-Interactive is called or not.
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
        # Redirect all output to the Process-Non-Interactive function...
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
        Process-Non-Interactive `
            "${niCallingFunction}" `
            "${verboseWriter}" `
            (
                "Where ${niCallingVarNames} is...`n"+
                ( Get-Quoted 'Divider.Upper' 'CONTENT BEGIN' -nl )+
                "${textOutput}`n"+
                ( Get-Quoted 'Divider.Lower' 'CONTENT CLOSE'     )
            ) `
            -exitCode ${niExitCode}

    ##### Else if ${niActive} is False, proceed with normal output...
    } else {
        ##### If ${outFile} is defined, write ${textOutput} to it...
        if (${outFile}) {
            ${verboseOutFile} = ( Get-Quoted 'Auto' "${outFile}" )
            Processing `
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
                    Output-Feedback "Output written to:${verboseOutFile}" -success
                } catch {
                    if (${niCallingFunction}) { ${errorCallFunc} = "${niCallingFunction}" } else { ${errorCallFunc} = "${funcName}" }
                    Output-Error `
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
} # END of function Output-Writer


function Process-Array ([Int]${processLevel}, [String]${processPrefix}, [String]${arrayTitle}, ${arrayList}, [Int]${arrayLevel}) {
#####
# Purpose:
#  • Part of the Verbose set of functions.
#  • If ${Script:RuntimeTable}.Verbose.Level is less than the processing level integer, simply do nothing by returning.
#  • Otherwise...
#    • Convert the arrayList to text.
#    • Call the Processing function with the data.
#
# Returns:
#  • Nothing                — if ${Script:RuntimeTable}.Verbose.Level<${processLevel}.
#  • [String]${arrayAsText} — when ${arrayLevel}>0.
#  • via Processing         — when ${arrayLevel}=0.
#
# Usage:
#  • Parameter 1 — ${processLevel}:  Integer      — the number where ${Script:RuntimeTable}.Verbose.Level is at or above to activate this function.
#  • Parameter 2 — ${processPrefix}: String       — the prefix title preceeding ${processTitle}.
#  • Parameter 3 — ${arrayTitle}:    String       — the title of the array being processed.
#  • Parameter 4 — ${arrayList}:     String Array — the array being processed.
#  • Parameter -arrayLevel:          Integer      — if used, return the raw result, indented (${arrayLevel}+1) times, instead of through Processing.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Get-Padded
#    • Get-Quoted
#    • Get-Var-Quoted
#    • Processing
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
            Get-Var-Quoted `
                (${arrayLevel}+1) `
                ( Get-Quoted 'Brackets.Square' ( Get-Padded "${arrayIndex}" ${indexPadWidth} ) ) `
                0 `
                "${quoteKey}" `
                "${arrayValue}" `
                -noBrackets `
                -varType ( Get-Padded "${valueType}" ${typePadWidth} )
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
        Processing `
            -processLevel   ${processLevel}   `
            -processPrefix "${processPrefix}" `
            -processTitle  "${arrayTitle}"    `
            -processValue  "${arrayAsText}"
    }
} # END of function Process-Array


function Process-Debug {
#####
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
#    • Call the Processing function with...
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
#  • via Processing — if ${doIt} is True.
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
#    • Processing
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

    if (-not ${doIt}) {
        Processing 2 "${callingFuncName}:${funcName}" "`${doIt} = ${doIt}; return"
        return
    }

    ${indexTable} = @{
        ColorBg = 0
        ColorFg = 1
        PrTitle = 2
    }
    ##### If ${debugArray} is undefined, setup a basic Null array, so the next if condition is possible...
    if (${debugArray} -eq ${Null}) {
        Processing 2 "${funcName}" '${debugArray} is undefined, using a default.'
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
            Processing 2 "${funcName}" "`${debugArray} has no elements for `${debugIndex}=${debugIndex}, using a default."
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
        Processing 2 "${funcName}" "`${debugIndex}=${debugIndex} exceeds `${debugArray} size=${debugMaxIndex}."
        ${processTitle} = "debugIndex=${debugIndex}"
        ##### If there are at least 2 elements in the array...
        if (${debugMaxIndex} -gt 0) {
            ##### Alternate odds & evens...
            if ((${debugIndex} % 2) -eq 0) {
                Processing 2 "${funcName}" '${debugIndex} is even, so defaulting to 0.'
                ${debugIndex} = 0
            } else {
                Processing 2 ":${funcName}" '${debugIndex} is odd, so defaulting to 1.'
                ${debugIndex} = 1
            }
        ##### If there's only 1 element in the array, just use that one...
        } else {
            Processing 2 "${funcName}" '${debugIndex} defaulting to 0.'
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
    Processing `
        -processLevel    0                    `
        -processPrefix   "${callingFuncName}" `
        -processTitle    "${processTitle}"    `
        -processValue    "${processValue}"    `
        -backgroundColor "${backgroundColor}" `
        -foregroundColor "${foregroundColor}" `
        -extraNewline    ${extraNewline}
} # END of function Process-Debug


function Process-Exit ([Int]${exitCode}=0, [String]${processPrefix}='', [String]${exitKey}='E0Good') {
#####
# Purpose:
#  • Part of the Verbose set of functions and necessary to exit with ${exitCode} from the script.
#  • Calls the Processing function at level 1 for Verbose output and then exits.
#
# Returns:
#  • via Processing   — in all cases; then
#  • exit ${exitCode} — in all cases.
#
# Usage:
#  • Parameter 1 — ${exitCode}:      Integer — [Default=0 ] the exit code to use when exiting from the script, and this is range checked...
#    • As a failsafe...
#      • If ${exitCode}<0,   it defaults to 0.
#      • If ${exitCode}>255, it defaults to 255.
#  • Parameter 2 — ${processPrefix}: String  — [Default=''] the prefix title to pass to the Processing function.
#  • Parameter -exitKey:             String  — [Default='E0Good'] in lieu of an ${exitCode}, use ${Script:RuntimeTable}.ExitStatus.${exitKey}.
#
# Dependencies:
#  • Functions...
#    • Processing
#####
    ##### If ${exitKey} is defined, get ${exitCode} from ${Script:RuntimeTable}.ExitStatus.${exitKey}...
    if (-not [String]::IsNullOrWhitespace(${exitKey})) { ${exitCode} = ${Script:RuntimeTable}.ExitStatus.${exitKey} }
    ##### Range-check ${exitCode}...
    if (${exitCode} -lt 0) { ${exitCode} = 0 } elseif (${exitCode} -gt 255) { ${exitCode} = 255 }
    ##### Give the final Processing message...
    Processing `
        -processLevel   1                 `
        -processPrefix "${processPrefix}" `
        -processTitle  "exit ${exitCode}" `
        -isLast
    ##### Exit with ${exitCode}...
    exit ${exitCode}
} # END of function Process-Exit


function Process-Non-Interactive {
#####
# Purpose:
#  • Part of the Verbose set of functions.
#  • Calls the Processing function at level ${Script:RuntimeTable}.NonInteractive.Verbose.Level for Verbose output.
#  • If ${exitCode}>0, it then exits with that code.
#
# Returns:
#  • via Processing   — if...
#    • ${Script:RuntimeTable}.NonInteractive.Verbose.IsTrue is True AND/OR
#    • ${Script:RuntimeTable}.Verbose.Level>${Script:RuntimeTable}.NonInteractive.Verbose.Level; then
#  • via Process-Exit — if ${exitCode}>0.
#
# Usage:
#  • Parameter 1 — ${processPrefix}: String  — the name of the calling function to pass to the Processing function for Verbose output.
#  • Parameter 2 — ${processTitle}:  String  — the title message to pass to the Processing function for Verbose output.
#    • This will always be prepended with "-NonInteractive SKIPPING:".
#  • Parameter 3 — ${processValue}:  String  — [Default=''] the value it would have processed outside of -NonInteractive mode.
#  • Parameter 4 — ${exitCode}:      Integer — [Default=${Script:RuntimeTable}.ExitStatus.E4NIMR] exit with this code if >0.
#  • Parameter -exitKey:             String  — [Default=''] in lieu of an ${exitCode}, use ${Script:RuntimeTable}.ExitStatus.${exitKey}.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Process-Exit
#    • Processing
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
        Processing `
            -processLevel  0                                        `
            -processPrefix "${processPrefix}"                       `
            -processTitle  "In -NonInteractive mode CANNOT PROCESS" `
            -processValue  "${processTitle}${processValue}"         `
            -thisIsAnNiMessage
    }

    ##### If ${exitCode}>0, then exit with that code...
    if (${exitCode}) { Process-Exit ${exitCode} "${processPrefix}" }
} # END of function Process-Non-Interactive


function Process-Params ([Int]${processLevel}, [String]${processPrefix}, [String]${processScope}) {
#####
# Purpose:
#  • Part of the Verbose set of functions.
#  • If ${Script:RuntimeTable}.Verbose.Level is less than the processing level integer, simply do nothing by returning.
#  • Otherwise...
#    • Get the parameter list of names & values from ${Script:RuntimeTable}.Parameters.
#    • Call the Processing function with the data.
#
# Returns:
#  • Nothing        — if ${Script:RuntimeTable}.Verbose.Level<${processLevel}.
#  • via Processing — otherwise.
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
#    • Get-Vars
#    • Processing
#####
    if (${Script:RuntimeTable}.Verbose.Level -lt ${processLevel}) { return }

    Processing `
        -processLevel   ${processLevel}             `
        -processPrefix "${processPrefix}"           `
        -processTitle  "Parameters ${processScope}" `
        -processValue  ( Get-Vars ${Script:RuntimeTable}.Parameters )
} # END of function Process-Params


function Process-Table {
#####
# Purpose:
#  • Part of the Verbose set of functions.
#  • If ${Script:RuntimeTable}.Verbose.Level is less than the processing level integer, simply do nothing by returning.
#  • Otherwise...
#    • Convert the table to text.
#    • Call the Processing function with the data.
#
# Returns:
#  • Nothing                — if ${Script:RuntimeTable}.Verbose.Level<${processLevel}.
#  • via Processing         — if ${tableLevel}=1.
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
#    • Get-Var-Quoted
#    • Get-Vars
#    • Output-Warning
#    • Process-Array
#    • Process-Table
#    • Processing
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

    if ([String]::IsNullOrWhitespace(${processPrefix})) { Output-Undefined-Error "${funcName}" 'processPrefix' 'String' }
    if ([String]::IsNullOrWhitespace(${tableTitle})   ) { Output-Undefined-Error "${funcName}" 'tableTitle'    'String' }
    if ([String]::IsNullOrWhitespace(${tableVar})     ) { Output-Undefined-Error "${funcName}" 'tableVar'      'Object' }

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
            Output-Warning (
                "${funcName}:"+
                ( Get-Var-Quoted 0 'tableVar' 0 'Auto' "${tableVar}" )+
                ' of type '+
                ( Get-Quoted 'Auto' "${inputType}" )+
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
                ${subResult} = Process-Array `
                     ${processLevel}          `
                    "${processPrefix}"        `
                    ''                        `
                     ${tableVar}.${level1Key} `
                     ${tableLevel}

                if (${subResult} -eq '') { ${multiline} = ${False} } else { ${multiline} = ${True} }
                ${level1Key} = ( Get-Padded "${level1Key}" ${keysPadWidth} )
                ${valueType} = ( Get-Padded "${valueType}" ${typePadWidth} )

                ( Get-Var-Quoted `
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
                ${subResult} = Get-Vars `
                    -getVarsObject ${tableVar}.${level1Key} `
                    -getVarsLevel (${tableLevel}+1)

                if (${subResult} -eq '') { ${multiline} = ${False} } else { ${multiline} = ${True} }
                ${level1Key} = ( Get-Padded "${level1Key}" ${keysPadWidth} )
                ${valueType} = ( Get-Padded "${valueType}" ${typePadWidth} )

                ( Get-Var-Quoted `
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
                ${subResult} = Process-Table `
                     ${processLevel}          `
                    "${processPrefix}"        `
                    "${tableTitle}"           `
                     ${tableVar}.${level1Key} `
                     ${onlyThisKey}           `
                    (${tableLevel}+1)

                if (${subResult} -eq '') { ${multiline} = ${False} } else { ${multiline} = ${True} }
                ${level1Key} = ( Get-Padded "${level1Key}" ${keysPadWidth} )
                ${valueType} = ( Get-Padded "${valueType}" ${typePadWidth} )

                ( Get-Var-Quoted `
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
                ${level1Key} = ( Get-Padded "${level1Key}" ${keysPadWidth} )
                ${valueType} = ( Get-Padded "${valueType}" ${typePadWidth} )

                ( Get-Var-Quoted `
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
            Processing `
                -processLevel   ${processLevel}              `
                -processPrefix "${processPrefix}"            `
                -processTitle  "${tableTitle}${arrayAsText}"
        } else {
            if (-not ${keyList}) { ${arrayAsText} = (${Script:RuntimeTable}.Verbose.Indent+${Script:RuntimeTable}.Verbose.NullString) }
            ${arrayAsText} = "{`n${arrayAsText}`n}"
            Processing `
                -processLevel   ${processLevel}   `
                -processPrefix "${processPrefix}" `
                -processTitle  "${tableTitle}"    `
                -processValue  "${arrayAsText}"
        }
    } else {
        return ${arrayAsText}
    }
} # END of function Process-Table


function Processing {
#####
# Purpose:
#  • Part of the Verbose set of functions, and it's responsible for formatting all verbose, debug, or feedback messages, as follows.
#  • If ${Script:RuntimeTable}.Verbose.Level is less than ${processLevel}, simply do nothing by returning.
#  • Otherwise...
#    • If ${processPrefix}, ${processTitle}, and ${processValue} are all Null or Empty, it simply writes an empty string.
#    • Otherwise...
#      • If ${processPrefix} is 'Feedback', it sets ${processFeedback}=${True} and ${processPrefix}=''.
#      • Otherwise...
#        • If ${processPrefix} is not empty, it appends ':' to it.
#        • It then prepends 'Processing:' to it.
#        • If ${processLevel}>2, it appends 'DEBUG-SKIPPING:' to it.
#        • If -Continuation and ${processPrefix} is not empty, it replaces the prefix with an equal number of spaces.
#    • It then sets ${processMessage} to "${processPrefix}${processTitle}".
#    • If ${processValue} is defined, it sets ${processMessage} in the form...
#      (
#          "${processMessage}"+( Get-Quoted 'Divider.Upper' 'CONTENT BEGIN' )
#          "${processValue}`n"+
#          "${processMessage}"+( Get-Quoted 'Divider.Lower' 'CONTENT CLOSE' )
#      )
#    • It then uses...
#        Output-Writer
#            -textOutput        "${processMessage}"
#            -streamWord        'Verbose'
#            -backgroundColor   ${Script:RuntimeTable}.Verbose.ColorBG.${processLevel}
#            -foregroundColor   ${Script:RuntimeTable}.Verbose.ColorFG.${processLevel}
#            -extraNewline      ${extraNewline}
#            -niCallingFunction "${funcName}"
#            -niCallingVarNames "`"`${processMessage}`""
#            -niExitKey         'E0Good'
#
# Returns:
#  • via Output-Error  — if ${processLevel}<0 or >3.
#  • Nothing           — if ${Script:RuntimeTable}.Verbose.Level<${processLevel}.
#  • via Output-Writer — otherwise.
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
#  • Parameter 5 — ${extraNewline}:  Boolean — value passed directly into the Output-Writer function.
#  • Parameter -Continuation:        Switch  — if used, omits the entire prefix and indents an equal number of spaces instead.
#  • Parameter -noPrefix:            Switch  — if used, omits the entire prefix and does not indent.
#  • Parameter -isFirst:             Switch  — if used, prepends the following, relative to ${processMessage}...
#    • an extra newline before to set it apart from the CLI prompt,
#    • an introduction message in a box to make it very visible where Verbose output started, and
#    • an extra newline after to set it apart from the Verbose output.
#  • Parameter -isLast:              Switch  — if used, appends the following, relative to ${processMessage}...
#    • an extra newline before to set it apart from the Verbose output,
#    • a conclusion message in a box to make it very visible where Verbose output ended, and
#    • an extra newline after to set it apart from the CLI prompt.
#  • Parameter -thisIsAnNiMessage:   Switch  — if used, indicates that this is coming from the Process-Non-Interactive function.
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
#    • Draw-Box
#    • Get-Quoted
#    • Output-Error
#    • Output-Writer
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
        Output-Error `
            -errorMessage    "Required parameter [Int]`${processLevel}=${processLevel} is out of range 0-3." `
            -callingFuncName "${funcName}" -exitKey 'E3Code'
    }

    if (${Script:RuntimeTable}.Verbose.Level -lt ${processLevel}) { return }

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
                "${processMessage}"+( Get-Quoted 'Divider.Upper' 'CONTENT BEGIN' -nl )+
                "${processValue}`n"+
                "${processMessage}"+( Get-Quoted 'Divider.Lower' 'CONTENT CLOSE'     )
            )
        }
    } # END of if (${processPrefix} -eq '' -and ${processTitle} -eq '' -and ${processValue} -eq '') {} else {}


    #####
    # If -isFirst, prepend...
    #  • an extra newline before to set it aparty from the CLI prompt,
    #  • an introduction message in a box to make it very visible where Verbose output started, and
    #  • an extra newline after to set it apart from the Verbose output.
    #####
    if (${isFirst}) {
        ${textString} = Draw-Box `
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
        ${textString} = Draw-Box `
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
    # • Since this isn't an error, use -niExitCode 0.
    #####

    if (${thisIsAnNiMessage}) { ${processLevel} = ${Script:RuntimeTable}.NonInteractive.Verbose.Color }
    if (-not ${backgroundColor}) { ${backgroundColor} = ${Script:RuntimeTable}.Verbose.ColorBG.${processLevel} }
    if (-not ${foregroundColor}) { ${foregroundColor} = ${Script:RuntimeTable}.Verbose.ColorFG.${processLevel} }
    Output-Writer `
        -textOutput        "${processMessage}"      `
        -streamWord        'Verbose'                `
        -backgroundColor   "${backgroundColor}"     `
        -foregroundColor   "${foregroundColor}"     `
        -extraNewline      ${extraNewline}          `
        -niCallingFunction "${funcName}"            `
        -niCallingVarNames "`"`${processMessage}`"" `
        -niExitKey         'E0Good'                 `
        -thisIsAnNiMessage ${thisIsAnNiMessage}
} # END of function Processing


function Prompt-For-From ([String]${level1Key}, [String]${level2Key}, [String]${defaultAnswer}) {
#####
# Purpose:
#  • Prompt for which From address to use and return it.
#
# Returns:
#  • via Output-Error                       — if ${level1Key} and/or ${level2Key} are undefined.
#  • via Process-Non-Interactive            — if ${Script:RuntimeTable}.NonInteractive.IsTrue is True.
#  • [String]returned from Prompt-For-Value — if ${selection}=1.
#  • [String]${fromChoices}[${selection}-1] — if ${selection}>1.
#
# Usage:
#  • Parameter 1 — ${level1Key}:     String (REQUIRED) — the key to level 1 of the ${Script:EmailTable}.
#  • Parameter 2 — ${level2key}:     String (REQUIRED) — the key to the next level.
#  • Parameter 3 — ${defaultAnswer}: String            — if used, an additional default answer to show in the ${fromChoices} list.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:EmailTable}
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Get-Quoted
#    • Output-Error
#    • Process-Non-Interactive
#    • Processing
#    • Prompt-For-Value
#####
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    if ([String]::IsNullOrEmpty(${level1Key})) { Output-Undefined-Error "${funcName}" 'level1Key' 'String' }
    if ([String]::IsNullOrEmpty(${level2Key})) { Output-Undefined-Error "${funcName}" 'level2Key' 'String' }


    if (${level2Key}[-1] -eq '1') { ${fromSetName} = ', Set1_Internal' } else { ${fromSetName} = ', Set2_External' }
    ${profileIndex} = ${Script:EmailTable}.Condition.ProfileIndex
    ${toKey}        = "Profile${profileIndex}_ItemB_To"
    ${domainsUsed}  = @() # Will contain all (lower case) domain entries already used in the loop below to avoid duplicates.
    ${defaultIndex} = ${Null}
    ${fromChoices}  = @(
        'Enter a custom From email address not listed below.'
    )

    ##### Also offer in ${fromChoices} each ${toAddress}, as long as it's not a duplicate...
    foreach (${toAddress} in @((${Script:EmailTable}.${level1Key}.${toKey}.Value -Split ',').Trim())) {
        ${fromChoices}     += "${toAddress}"
        if (${defaultAnswer}) {
            if (${defaultAnswer}.ToLower() -eq ${toAddress}.ToLower()) {
                ${defaultIndex} = ${fromChoices}.Count
            }
        }
        ${toDomainName}     = ${toAddress}.Split('@')[1] # Same case as entered by the user (e.g. Example.com).
        ${toDomainLower}    = ${toDomainName}.ToLower()  # Converted to lower case (e.g. example.com) for easy comparison.
        if (${toDomainLower} -NotIn ${domainsUsed}) {
            ${fromChoices} += (${Script:RuntimeTable}.Host.Local.Hostname+"@${toDomainName}")
            ${domainsUsed} += "${toDomainLower}"
        } # Else skip this ${toDomainName} as a duplicate.
    } # END of foreach (${toAddress} in @((${Script:EmailTable}.${level1Key}.${toKey}.Value -Split ',').Trim())) {}

    #####
    # If...
    #  • ${level2Key} ends with '2', and
    #  • Set2_External.Group1_SMTP4_Authenticate.Value is True, and
    #  • Set2_External.Group1_SMTP4_UserName.Value is defined
    #####
    if (
        ${level2Key}[-1] -eq '2' -and
        ${Script:EmailTable}.Set2_External.Group1_SMTP4_Authenticate.Value -eq ${True} -and
        -not [String]::IsNullOrEmpty(${Script:EmailTable}.Set2_External.Group1_SMTP4_UserName.Value)
    ) {
        ##### If Set2_External.Group1_SMTP4_UserName.Value matches the RegExTable pattern 'EmailFrom'...
        if ( Is-Valid-Entry 'Group1_SMTP4_UserName' ${Script:EmailTable}.Set2_External.Group1_SMTP4_UserName.Value 'String' 'EmailFrom' ) {
            ##### Also offer in ${fromChoices} Set2_External.Group1_SMTP4_UserName...
            ${fromChoices} += ${Script:EmailTable}.Set2_External.Group1_SMTP4_UserName.Value
        }
    }

    ##### If Host.Local.Domain is defined...
    if (${Script:RuntimeTable}.Host.Local.Domain) {
        ##### Also offer in ${fromChoices} Host.Local.Hostname+'@'+Host.Local.Domain...
        ${hostEntry}    = (${Script:RuntimeTable}.Host.Local.Hostname+'@'+${Script:RuntimeTable}.Host.Local.Domain)
        ${fromChoices} += "${hostEntry}"
        if (${defaultAnswer}) {
            if (${defaultAnswer}.ToLower() -eq ${hostEntry}.ToLower()) {
                ${defaultIndex} = ${fromChoices}.Count
            }
        }
    }

    ##### Build the ${choicesPrompt}...
    ${choicesPrompt} = @()
    ${choicesPrompt} += (
        "`nFor ${level1Key}, Profile ${profileIndex}${fromSetName}...`n"+
        ${Script:EmailTable}.${level1Key}.${level2Key}.Properties.Meta2_Prompt1.Replace(':CUSTOM:', '')+'Your choices are...'
    )
    for (${i}=0; ${i} -lt ${fromChoices}.Count; ${i}++) { ${choicesPrompt} += "  $(${i}+1) — $(${fromChoices}[${i}])" }
        ${answers}  = "1-$(${fromChoices}.Count)"
    if (${defaultIndex}) {
        ${answers} += ", Default=${defaultIndex}"
    }
    ${choicesPrompt} += "Enter an option number [${answers}]"
    ${choicesPrompt}  = ${choicesPrompt} -Join "`n"

    ##### Read-Host until valid (unless redirecting to Process-Non-Interactive)...
    if (${Script:RuntimeTable}.NonInteractive.IsTrue) {
        Process-Non-Interactive "${funcName}" "Read-Host -Prompt `${choicesPrompt}" "${choicesPrompt}"
    }
    do {
        ${selection} = Read-Host -Prompt "${choicesPrompt}"
        if (${defaultIndex} -and [String]::IsNullOrEmpty(${selection})) { ${selection} = ${defaultIndex} }
    } until (${selection} -Match "^[1-$(${fromChoices}.Count)]$")

    ##### If ${selection} is 1, return Prompt-for-Value to get a custom entry...
    if (${selection} -eq 1) {
        return (
            Prompt-For-Value `
                -level1Key    ${level1Key}                                                            `
                -level2Key    ${level2Key}                                                            `
                -varType      ${Script:EmailTable}.${level1Key}.${level2Key}.Properties.Meta1_VarType `
                -promptText   ${Script:EmailTable}.${level1Key}.${level2Key}.Properties.Meta2_Prompt1 `
                -varRegExKey  ${Script:EmailTable}.${level1Key}.${level2Key}.Properties.Meta3_RegExKey
        )

    ##### Else if any other ${selection}, return ${selection}-1 from the ${fromChoices} array...
    } else {
        Processing 2 "${funcName}" ('return '+( Get-Quoted 'Auto' ${fromChoices}[${selection}-1] ))
        return ${fromChoices}[${selection}-1]
    }
} # END of function Prompt-For-From


function Prompt-For-Value {
#####
# Purpose:
#  • Formulates a prompt string as "${promptText}${answers}".
#  • Reads input from the user and validates it using ${Validation}.
#  • If the input value is invalid, it prompts again.
#  • Once it's valid, it returns the input value.
#
# Returns:
#  • via Process-Non-Interactive — if ${Script:RuntimeTable}.NonInteractive.IsTrue is True.
#  • [Bool   ]${inputValue}      — if ${varType} is Boolean.
#  • [Integer]${inputValue}      — if ${varType} is Int32.
#  • [String ]${inputValue}      — otherwise.
#
# Usage:
#  • Parameter -level1Key:     String (REQUIRED)  — the key to which table in ${Script:EmailTable} it's using.
#  • Parameter -level2Key:     String (REQUIRED)  — the key to which item in ${level1Key} it's using.
#  • Parameter -varType:       String (REQUIRED)  — the variable type that the input must conform to.
#  • Parameter -promptText:    String (REQUIRED)  — a description of what it's prompting for.
#  • Parameter -varRegExKey:   String (REQUIRED)  — the key to which RegEx pattern to use for validation in ${Script:RegExTable}.
#  • Parameter -defaultAnswer: [untyped]          — if set, the default answer (in the ${varType}) to show & use if the user enters nothing.
#  • Parameter -mayBeCSV:      Boolean            — whether or not the input can be a single item or a CSV list.
#  • Parameter -mayBeEmpty:    Boolean            — whether or not the input can be and stored as empty.
#  • Parameter -defaultEmpty:  Boolean            — whether or not the default answer is shown as Default='' when ${defaultAnswer}=''.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Get-Quoted
#    • Get-Vars
#    • Is-Valid-Entry
#    • Output-Warning
#    • Process-Debug
#    • Process-Non-Interactive
#    • Processing
#####
    param(
        [String]${level1Key},
        [String]${level2Key},
        [String]${varType},
        [String]${varRegExKey},
        [String]${promptText},
                ${defaultAnswer},
        [Bool  ]${mayBeCSV},
        [Bool  ]${mayBeEmpty},
        [Bool  ]${defaultEmpty}
    )
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    Process-Debug `
        -doIt            (${Script:RuntimeTable}.Verbose.Level -gt 1) `
        -callingFuncName "${funcName}"                                `
        -debugIndex      0                                            `
        -processValue    ( Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values )

    ${answers_True} = @('true',  't', 'yes', 'y')
    ${answersFalse} = @('false', 'f', 'no',  'n')
    ${profileIndex} = ${Null}
    ${fromSetName}  = ''
    if (${level1Key} -eq 'Set3_Profiles') {
        ${profileIndex} = ${Script:EmailTable}.Condition.ProfileIndex
        if (${level2Key} -Match 'Profile[0-9]+_ItemC_From_Set[12]$') {
            if (${level2Key}[-1] -eq '1') { ${fromSetName} = ', Set1_Internal' } else { ${fromSetName} = ', Set2_External' }
        }
    }
    if ([String]::IsNullOrWhitespace(${promptText})) { ${promptText} = "unspecified item (I guess it's a mystery)" }

    if ([String]::IsNullOrWhitespace(${defaultAnswer})) { ${defaultAnswer} = '' }
    if (${varType} -eq 'Boolean') {
        #####
        ##### Set these up for a Boolean response...
        #####

        ##### These options are invalid in this mode...
        ${mayBeCSV}   = ${False}
        ${mayBeEmpty} = ${False}

        ##### If ${promptText} begins with :CUSTOM:...
        if (${promptText}.Replace('\','\\') -Match '^:CUSTOM:') {
            ##### Use ${promptText} as is...
            ${promptText} = ${promptText}.Replace(':CUSTOM:', '')
        ##### Else if ${promptText} is not custom...
        } else {
            ##### Format ${promptText}...
            ${promptText} = "Is ${promptText} required?"
        }

        ##### Setup ${answers} to include all of the possible answer choices...
        ${answers} = '(t)rue/(y)es or (f)alse/(n)o'
        ${defaultAnswer} = ${defaultAnswer}.ToString().ToLower()
        if (${defaultAnswer} -eq 'true') {
            [Bool  ]${defaultAnswer} = ${True}
        } elseif (${defaultAnswer} -eq 'false') {
            [Bool  ]${defaultAnswer} = ${False}
        } else {
            [String]${defaultAnswer} = ''
        }
            ${answers}  = "Enter ${answers}"
        ##### If ${defaultAnswer} is not empty, include it...
        if ([String]${defaultAnswer} -ne '') {
            ${answers} += ", Default=${defaultAnswer}"
        }
            ${answers}  = ( Get-Quoted 'Brackets.Square' "${answers}" )
        if (${promptText} -NotMatch "`n") {
            ${answers}  = " ${answers}"
        }
    } else {
        #####
        ##### Set these up for a String or Int32 response...
        #####

        ##### If ${promptText} begins with :CUSTOM:...
        if (${promptText}.Replace('\','\\') -Match '^:CUSTOM:') {
            ##### Use ${promptText} as is...
            ${promptText} = ${promptText}.Replace(':CUSTOM:', '')
        ##### Else if ${promptText} is not custom...
        } else {
            ##### Format ${promptText}...
            ${promptText} = "Enter the ${promptText}"
            if (${mayBeCSV}) { ${promptText} += '(es) to use (if multiple separate with commas)' } else { ${promptText} += ' to use' }
        }

        ##### Only setup ${answers} if there is a default answer...
        ${answers} = ''
        if ( 
            (     ${defaultEmpty} -and ${defaultAnswer} -eq '') -or
            (-not ${defaultEmpty} -and ${defaultAnswer} -ne '')
        ) {
            if (${varType} -eq 'String') {
                ${answers} = ('Default='+( Get-Quoted 'Auto' "${defaultAnswer}" ))
            } else {
                ${answers} =  "Default=${defaultAnswer}"
            }
                ${answers} = ( Get-Quoted 'Brackets.Square' "${answers}" )
        }

        ##### If ${promptText} is not multiline...
        if (${promptText} -NotMatch "`n") {
            ##### It's on the same line, so prepend a space...
            ${answers}  = " ${answers}"
        }
    } # END of if (${varType} -eq 'Boolean') {} else {}

    ##### Prepend the ${level1Key}, and if applicable, the ${profileIndex} being used...
    if (${profileIndex} -eq ${Null}) {
        ${promptText} = "`nFor ${level1Key}...`n${promptText}"
    } else {
        ${promptText} = "`nFor ${level1Key}, Profile ${profileIndex}${fromSetName}...`n${promptText}"
    }
    Process-Debug `
        -doIt            (${Script:RuntimeTable}.Verbose.Level -gt 1) `
        -callingFuncName "${funcName}"                                `
        -debugIndex      1                                            `
        -processValue    ( Get-Vars (Get-Command -Name ${MyInvocation}.MyCommand.Name).Parameters.Values )

    do {
        if (${Script:RuntimeTable}.NonInteractive.IsTrue) {
            Process-Non-Interactive "${funcName}" "Read-Host -Prompt `${promptText}${answers}" "${promptText}${answers}"
        }
        ${inputValue} = Read-Host -Prompt "${promptText}${answers}"

        ${quote} = "'"
        if (${varType} -eq 'Boolean') {
            ${quote} = ''
            ${inputLower} = ${inputValue}.ToLower()
            if (${answers_True} -Contains ${inputLower}) {
                Processing 2 "${FuncName}" ("Substituting ${True} for equivalent response "+( Get-Quoted 'Auto' "${inputValue}" )+'.')
                [Bool]${inputValue} = ${True}
            }
            if (${answersFalse} -Contains ${inputLower}) {
                Processing 2 "${FuncName}" ("Substituting ${False} for equivalent response "+( Get-Quoted 'Auto' "${inputValue}" )+'.')
                [Bool]${inputValue} = ${False}
            }
        } elseif (${varType} -eq 'Int32') {
            ${quote} = ''
            ${inputValue} = Get-Integer "${inputValue}"
        }

        if (${inputValue} -eq ${Null}) {
            ${verboseValue} = ${Script:RuntimeTable}.Verbose.NullString
        } else {
            ${verboseValue} = "${quote}${inputValue}${quote}"
        }
        Processing 2 "${funcName}" "BEFORE:`${inputValue}=${verboseValue}"

        ##### If ${inputValue} is Null or Empty...
        if ([String]::IsNullOrEmpty(${inputValue})) {
            ##### If ${mayBeEmpty} is True...
            if (${mayBeEmpty}) {
                ##### If ${inputValue} is Null...
                if (${inputValue} -eq ${Null}) {
                    ##### Then ${isValid} is False...
                    ${isValid} = ${False}
                ##### Else if ${inputValue} is Empty...
                } else {
                    ##### Then ${isValid} is True and ${inputValue} gets an empty string ''...
                    ${isValid} = ${True}
                    ${inputValue} = ''
                }
                ##### Since ${isValid} is already known, set ${varRegExKey} to Null, so it won't run Is-Valid-Entry below...
                ${varRegExKey} = ${Null}
            ##### Else if ${mayBeEmpty} is False...
            } else {
                ##### If ${defaultAnswer} is defined, set ${inputValue} to ${defaultAnswer}...
                if (-not [String]::IsNullOrEmpty(${defaultAnswer})) { ${inputValue} = ${defaultAnswer} }
            }
        }

        if (${inputValue} -eq ${Null}) {
            ${verboseValue} = ${Script:RuntimeTable}.Verbose.NullString
        } else {
            ${verboseValue} = "${quote}${inputValue}${quote}"
        }
        Processing 2 "${funcName}" "SCOPED:`${inputValue}=${verboseValue}"

        ##### If ${mayBeCSV} is True...
        if (${mayBeCSV}) {
            ##### Remove Dupes...
            ${uniqueItems} = @()
            ${inputValue} = foreach (${inputItem} in @((${inputValue} -Split ',').Trim())) {
                if (${inputItem}.ToLower() -In ${uniqueItems}) {
                    Output-Warning ('DUPLICATE REMOVED '+( Get-Quoted 'Auto' "${inputItem}" )+'.') -preSpace
                } else {
                    ${uniqueItems} += ${inputItem}.ToLower()
                    ${inputItem}
                }
            } # END of ${inputValue} = foreach (${inputItem} in @((${inputValue} -Split ',').Trim())) {}
            ##### Convert back to a String...
            ${inputValue} = ${inputValue} -Join ','
        }

        ##### If ${varRegExKey} is still defined, run Is-Valid-Entry...
        if (${varRegExKey}) { ${isValid} = ( Is-Valid-Entry ${level2Key} ${inputValue} "${varType}" "${varRegExKey}" ${mayBeEmpty} ) }

        Processing 2 "${funcName}" "`${isValid}=${isValid}"
        if (-not ${isValid}) {
            Output-Warning ('Invalid Input:'+( Get-Quoted 'Auto' "${inputValue}" )) -noPrefix
        }
    ##### If ${isValid} is False, keep looping...
    } until (${isValid})

    ##### When we have valid input, return ${inputValue}...
    if (${varType} -eq 'String') { ${quoteKey} = 'Auto' } else { ${quoteKey} = 'None' }
    Processing 2 "${funcName}" ('return '+( Get-Quoted "${quoteKey}" "${inputValue}" ))
    return ${inputValue}
} # END of function Prompt-For-Value


function Send-Email ([String]${level1Key}) {
#####
# Purpose:
#  • To send the email message.
#  • Only if ${Script:EmailTable}.Condition.TestEmail is True, it does the following substitutions...
#    • :SET:  is replaced with ${level1Key} in ${Script:EmailTable}.Field.Part2_Subject & ${Script:EmailTable}.Field.Part3_Body.
#    • :FROM: is replaced with ${Script:EmailTable}.(${addressKey}.SetName).(${addressKey}.ItemC_From).Value in ${Script:EmailTable}.Field.Part3_Body.
#
# Returns:
#  • If Send-MailMessage SUCCEEDS...
#    • [Bool]${True}
#  • Else if Send-MailMessage FAILS...
#    • via Output-Warning; then
#    • [Bool]${False}
#
# Usage:
#  • Parameter 1 — ${level1Key}: String (REQUIRED) — the level 1 key to the ${Script:EmailTable}.
#
# Dependencies:
#  • Global declarations...
#    • ${Script:EmailTable}
#    • ${Script:RuntimeTable}
#  • Functions...
#    • Credential-Get
#    • Get-Var-Quoted
#    • Output-Warning
#    • Process-Table
#    • Processing
#####
    ${funcName} = $( ${MyInvocation}.MyCommand.Name )

    if ([String]::IsNullOrWhitespace(${level1Key})) { Output-Undefined-Error "${funcName}" 'level1Key' 'String' }

    Process-Table 2 "${funcName}" "`${Script:EmailTable}.Set3_Profiles" ${Script:EmailTable}.Set3_Profiles
    Process-Table 2 "${funcName}" "`${Script:EmailTable}.${level1Key}"  ${Script:EmailTable}.${level1Key}


    #####
    ##### Set all address key names for the Profile number in ${Script:EmailTable}.Condition.ProfileIndex...
    #####
    # • Profile${profileIndex}_ItemA_IgnoreDNS is not used here.
    #####

    ${profileIndex}    = ${Script:EmailTable}.Condition.ProfileIndex
    ${setString}       = ${level1Key} -Replace '_.+$', '' # Gets Set1 without _Internal or Set2 without _External
    ${addressKeyTable} = @{
        Level1_Set     = 'Set3_Profiles'
        Level2_B_To    = "Profile${profileIndex}_ItemB_To"
        Level2_C_From  = "Profile${profileIndex}_ItemC_From_${setString}"
        Level2_D_CC    = "Profile${profileIndex}_ItemD_CC"
        Level2_E_BCC   = "Profile${profileIndex}_ItemE_BCC"
    }
    Process-Table 2 "${funcName}" "Keys for `${profileIndex}=${profileIndex} in `${addressKeyTable}" ${addressKeyTable}


    #####
    ##### Set these to the initial values...
    #####

    ${valueOfSubject} = ${Script:EmailTable}.Field.Part2_Subject
    ${valueOfBody}    = ${Script:EmailTable}.Field.Part3_Body


    #####
    ##### Do these replacements only if ${Script:EmailTable}.Condition.TestEmail is True...
    #####

    if (${Script:EmailTable}.Condition.TestEmail) {
        ${valueOfSubject} = "${valueOfSubject}" `
            -Replace ':SET:',  ${level1Key}
        ${valueOfBody}    = "${valueOfBody}" `
            -Replace ':SET:',  ${level1Key}  `
            -Replace ':FROM:', ${Script:EmailTable}.(${addressKeyTable}.Level1_Set).(${addressKeyTable}.Level2_C_From).Value
    }


    #####
    ##### All required parameters are defined first...
    #####

    ${emailParameters} = @{
        From        = ${Script:EmailTable}.(${addressKeyTable}.Level1_Set).(${addressKeyTable}.Level2_C_From).Value
        To          = ${Script:EmailTable}.(${addressKeyTable}.Level1_Set).(${addressKeyTable}.Level2_B_To).Value
        SmtpServer  = ${Script:EmailTable}.${level1Key}.Group1_SMTP1_Server_FQDN.Value
        Port        = ${Script:EmailTable}.${level1Key}.Group1_SMTP2_Port.Value
        UseSsl      = ${Script:EmailTable}.${level1Key}.Group1_SMTP3_UseSSL.Value
        Encoding    = ${Script:EmailTable}.Field.Part1_Encoding
        Subject     = "${valueOfSubject}"
        ErrorAction = 'Stop'
    }
    ##### Choose one of Body or BodyAsHTML...
    if (${Script:EmailTable}.Field.Part3_IsHTML) {
        ${emailParameters}.BodyAsHTML = "${valueOfBody}"
    } else {
        ${emailParameters}.Body       = "${valueOfBody}"
    }


    #####
    ##### All optional parameters are added only if defined...
    #####

    ##### CC...
    if (-not [String]::IsNullOrWhitespace(${Script:EmailTable}.(${addressKeyTable}.Level1_Set).(${addressKeyTable}.Level2_D_CC).Value)) {
        ${emailParameters}.CC = ${Script:EmailTable}.(${addressKeyTable}.Level1_Set).(${addressKeyTable}.Level2_D_CC).Value
    }
    ##### BCC...
    if (-not [String]::IsNullOrWhitespace(${Script:EmailTable}.(${addressKeyTable}.Level1_Set).(${addressKeyTable}.Level2_E_BCC).Value)) {
        ${emailParameters}.BCC = ${Script:EmailTable}.(${addressKeyTable}.Level1_Set).(${addressKeyTable}.Level2_E_BCC).Value
    }
    ##### Attachments...
    if (-not [String]::IsNullOrWhitespace(${Script:EmailTable}.Field.Part4_Attach)) {
        ${emailParameters}.Attachments = ${Script:EmailTable}.Field.Part4_Attach
    }
    ##### Credential...
    if (-not [String]::IsNullOrWhitespace(${Script:EmailTable}.${level1Key}.Group1_SMTP4_UserName.Value)) {
        ${emailParameters}.Credential = Credential-Get ${Script:EmailTable}.${level1Key}.Group1_SMTP4_UserName.Value
    }

    Process-Table `
        2 `
        "${funcName}" `
        '${emailParameters}' `
         ${emailParameters}
    if (${Script:RuntimeTable}.Verbose.InDebugMode) {
        Processing 3 "${funcName}" 'Send-MailMessage'
        return ${True}
    }


    #####
    ##### Send...
    #####

    try {
        Send-MailMessage @emailParameters
        return ${True}
    } catch {
        Output-Warning `
            "`n${funcName}"                              `
            -exception       "$(${_}.Exception.Message)" `
            -backgroundColor 'Black'                     `
            -foregroundColor 'Red'                       `
            -noPrefix

        if ([Bool]([RegEx]::IsMatch($(${_}.Exception.Message).Replace('\','\\'), 'blocked using Spamhaus'))) {
            ${customMessage} = @(
                ''
                'This error may indicate you are connected to the Internet from a home ISP service.'
                'Typically, IPs of broadband or dial-up customers will be included in this list.'
                'If you are connecting to work via a VPN, it may be configured to use a split tunnel.'
                'If so, then your outgoing SMTP traffic will route through your home ISP, not your work.'
            )
            if ([String]::IsNullOrWhitespace(${Script:EmailTable}.${level1Key}.Group1_SMTP4_UserName.Value)) {
                ${customMessage} += 'If you are configuring this from home, then you need to use authentication.'
            } else {
                ${customMessage} += 'Since you have authentication configured, you may need to visit Spamhaus to find out why you are being blocked.'
            }
            ${customMessage} += "Here is your ISP info...`n$( Invoke-RestMethod 'https://ipinfo.io/json' | ConvertTo-Json -Depth 3)"
            Output-Warning ((${customMessage} -Join "`n")+"`n") -preSpace
        } # END of if ([Bool]([RegEx]::IsMatch($(${_}.Exception.Message).Replace('\','\\'), 'blocked using Spamhaus'))) {}
        return ${False}
    } # END of try {} catch {}
} # END of function Send-Email


function Wrap-Text {
#####
# Purpose:
#  • For each line of text in the ${textToWrap} string array, input received from a pipeline, wrap lines longer than ${termWidth} at word breaks.
#
# Returns:  via Output-Writer — in all cases.
#
# Usage:
#  • Parameter 1 — ${textToWrap}: String Array (REQUIRED) — an array of text lines to be wrapped according to ${termWidth}.
#  • Parameter 2 — ${termWidth}:  Integer                 — [Default=${Host}.UI.RawUI.WindowSize.Width] the desired width or width of the terminal.
#
# Dependencies:
#  • Functions...
#    • Output-Writer
#####
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=${True}, ValueFromPipeline=${True})][String[]]${textToWrap},
        [Parameter(Mandatory=${False}                          )][Int     ]${termWidth}=${Host}.UI.RawUI.WindowSize.Width
    )

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
                Output-Writer (${lineIndent} + ${currentLine}.TrimEnd())
                ${currentLine}  = "${currentWord} "
            } else {
                ${currentLine} += "${currentWord} "
            }
        } # END of foreach (${currentWord} in ${lineWords}) {}
        if (${currentLine}) {
            Output-Writer (${lineIndent} + ${currentLine}.TrimEnd())
        }
    } # END of foreach (${originalLine} in ${textToWrap}) {}
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



##########
########## Parameter Processing...
##########
# Parameters are processed in the following order of precedence...
#   1. -d|-Debugging takes precedence over -v|-Verbosity.
#      1b. (Internal only, not mentioned in help) Range-checking the ExitStatus table.
#   2. -Silent (also triggered by -niv|-ni|-NonInteractive).
#   3. -niv takes precedence over -ni|-NonInteractive, ignores -h|-Help, but errors on -rs|-RunSetup|-RerunSetup.
#   4. -h|-Help is processed immediately and exits.
#   5. -rm|-Remove takes precedence over and ignores the rest of parameters and is processed immediately after parameter processing and exits.
#   6. From this point, all other parameters are processed in alphabetical order.
#      6a. -bt|-BodyText takes precedence over -bf|-BodyFile.
#      6b. After all parameters are processed, if any of -a|-Attachment, -bt|-BodyText, -bf|-BodyFile, and/or -s|-Subject were used, it makes sure one of
#           -bt|-BodyText or -bf|-BodyFile, and -s|-Subject were specified together, otherwise it's an error.
##########

#####
##### General parameters...
#####

#####
# -d
# -Debugging
# -v
# -Verbosity
#####
# • Precedence level 1.
# • -d|-Debugging takes precedence over -v|-Verbosity.
#####
if (${Debugging}) {
    #####
    # -d
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
    Processing 1 'MAIN' 'BEGIN:Parameter Processing' -isFirst
if (${Debugging}) {
    Processing 1 'MAIN' ('PARAMETER '+( Get-Var-Quoted 0 'Debugging' 0 'None' ${Debugging} ))
}
if (${Verbosity}) {
    Processing 1 'MAIN' ('PARAMETER '+( Get-Var-Quoted 0 'Verbosity' 0 'None' ${Verbosity} ))
}
Process-Table  2 'MAIN' '${Script:RuntimeTable} BEFORE' ${Script:RuntimeTable}

#####
# (Internal code) Range-check the ExitStatus table...
#####
# • Precedence level 1b.
# • It also ensures E1Warn<E2User<E3Code<E4NIMR<=255.
#####

##### E0Good Validity...
if (-not ( Is-Valid-Entry  'ExitStatus.E0Good'    ${Script:RuntimeTable}.ExitStatus.E0Good 'Int32' 'ExitStatus' )) {
     Processing 2 'MAIN'   'ExitStatus.E0Good =   0'
     ${Script:RuntimeTable}.ExitStatus.E0Good =   0
}
##### There is no other range-check associated with E0Good.

##### E1Warn Validity...
if (-not ( Is-Valid-Entry  'ExitStatus.E1Warn'    ${Script:RuntimeTable}.ExitStatus.E1Warn 'Int32' 'ExitStatus' )) {
     Processing 2 'MAIN'   'ExitStatus.E1Warn =   0'
     ${Script:RuntimeTable}.ExitStatus.E1Warn =   0
}
##### E1Warn Range-check (since every code after this must be greater than this, the max this can be is 252)...
if ( ${Script:RuntimeTable}.ExitStatus.E1Warn -gt 252                                       ) {
     Processing 2 'MAIN'   'ExitStatus.E1Warn =   252'
     ${Script:RuntimeTable}.ExitStatus.E1Warn =   252
}

##### E2User Validity...
if (-not ( Is-Valid-Entry  'ExitStatus.E2User'    ${Script:RuntimeTable}.ExitStatus.E2User 'Int32' 'ExitStatus' )) {
     Processing 2 'MAIN'   'ExitStatus.E2User =   1'
     ${Script:RuntimeTable}.ExitStatus.E2User =   1
}
##### E2User Range-check...
if ( ${Script:RuntimeTable}.ExitStatus.E2User -le ${Script:RuntimeTable}.ExitStatus.E1Warn  ) {
     Processing 2 'MAIN'  ('ExitStatus.E2User =  (${Script:RuntimeTable}.ExitStatus.E1Warn+1) = '+(${Script:RuntimeTable}.ExitStatus.E1Warn+1))
     ${Script:RuntimeTable}.ExitStatus.E2User =  (${Script:RuntimeTable}.ExitStatus.E1Warn+1)
}

##### E3Code Validity...
if (-not ( Is-Valid-Entry  'ExitStatus.E3Code'    ${Script:RuntimeTable}.ExitStatus.E3Code 'Int32' 'ExitStatus' )) {
     Processing 2 'MAIN'   'ExitStatus.E3Code =   2'
     ${Script:RuntimeTable}.ExitStatus.E3Code =   2
}
##### E3Code Range-check...
if ( ${Script:RuntimeTable}.ExitStatus.E3Code -le ${Script:RuntimeTable}.ExitStatus.E2User  ) {
     Processing 2 'MAIN'  ('ExitStatus.E3Code =  (${Script:RuntimeTable}.ExitStatus.E2User+1) = '+(${Script:RuntimeTable}.ExitStatus.E2User+1))
     ${Script:RuntimeTable}.ExitStatus.E3Code =  (${Script:RuntimeTable}.ExitStatus.E2User+1)
}

##### E4NIMR Validity...
if (-not ( Is-Valid-Entry  'ExitStatus.E4NIMR'    ${Script:RuntimeTable}.ExitStatus.E4NIMR 'Int32' 'ExitStatus' )) {
     Processing 2 'MAIN'   'ExitStatus.E4NIMR =   3'
     ${Script:RuntimeTable}.ExitStatus.E4NIMR =   3
}
##### E4NIMR Range-check...
if ( ${Script:RuntimeTable}.ExitStatus.E4NIMR -le ${Script:RuntimeTable}.ExitStatus.E3Code  ) {
     Processing 2 'MAIN'  ('ExitStatus.E4NIMR =  (${Script:RuntimeTable}.ExitStatus.E3Code+1) = '+(${Script:RuntimeTable}.ExitStatus.E3Code+1))
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
    Processing 1 'MAIN' ('PARAMETER '+( Get-Var-Quoted 0 'Silent' 0 'None' ${Silent} ))
   #There is no corresponding value for E0Good, since that mode is never used in Output-Error.
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
# • This must be processed before parameters -h|-Help or -rs|-RunSetup|-RerunSetup.
# • -niv takes precedence over -ni|-NonInteractive.
#####

##### If ${niv} and/or ${NonInteractive} are True...
if (${niv} -or ${NonInteractive}) {
    ##### If ${niv} is True, this takes precedence...
    if (${niv}) {
        Processing 1 'MAIN' ('PARAMETER '+( Get-Var-Quoted 0 'niv' 0 'None' ${niv} ))
        ${Script:RuntimeTable}.NonInteractive.Verbose.Param = '-niv'
        ${Script:RuntimeTable}.NonInteractive.Verbose.IsTrue = ${True}
    ##### Else if ${NonInteractive} is True...
    } else {
        Processing 1 'MAIN' ('PARAMETER '+( Get-Var-Quoted 0 'NonInteractive' 0 'None' ${NonInteractive} ))
        ${Script:RuntimeTable}.NonInteractive.Verbose.Param = '-ni|-NonInteractive'
    }
        ${Script:RuntimeTable}.NonInteractive.IsTrue         = ${True}

    ##### Override parameter -h|-Help if specified...
    if (${Help}) {
        Processing 1 'MAIN' ('OVERRIDING PARAMETER -h|-Help with parameter '+${Script:RuntimeTable}.NonInteractive.Verbose.Param+'.')
        ${Help} = ${False}
    }
    ##### However, if parameter -rs|-RunSetup|-RerunSetup was specified, it's an error in combination with -niv|-ni|-NonInteractive...
    if (${RerunSetup}) {
        Output-Error `
            -errorMessage    ('Parameter -rs|-RunSetup|-RerunSetup is invalid with parameter '+${Script:RuntimeTable}.NonInteractive.Verbose.Param+'.') `
            -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
    }
}

#####
# -h
# -Help
#####
# • Precedence level 4.
# • Processed immediately and exits.
#####
if (${Help}) {
    Processing 1 'MAIN' 'PARAMETER Help = True'
    Processing 1 'MAIN' 'ACTION IMMEDIATE Output-Help-Page'
    Output-Help-Page
}


#####
##### Email-specific parameters...
#####

#####
# -rm
# -Remove
#####
# • Precedence level 5.
# • -rm|-Remove takes precedence over and ignores the rest of parameters.
#####
if (${Remove}) {
    Processing 1 'MAIN' ('PARAMETER '+( Get-Var-Quoted 0 'Remove' 0 'Auto' "${Remove}" ))
    if (-not { ${Remove}.Replace('\','\\') -Match ${Script:RegExTable}.UserName }) {
        Output-Error `
            -errorMessage    ('The user name you specified for removal '+( Get-Quoted 'Auto' "${Remove}" )+' is invalid.') `
            -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
    }

#####
# Else if not ${Remove}...
#####
# • Precedence level 6.
# • All other parameters are processed in alphabetical order.
#####
} else {
    Processing 1 'MAIN' 'Not in Remove mode, processing more parameters.'

    #####
    # -a
    # -Attachment
    #####
    if (${Attachment}) {
        Processing 1 'MAIN' ('PARAMETER '+( Get-Var-Quoted 0 'Attachment' 0 'Auto' "${Attachment}" ))
        ${Script:EmailTable}.Field.Part4_Attach = @()
        foreach (${attachFile} in ${Attachment}) {
            if (-not (Test-Path ${attachFile})) {
                Output-Error `
                    -errorMessage    ('Attachment file '+( Get-Quoted 'Auto' "${attachFile}" )+' does not exist or is not readable.') `
                    -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
            } else {
                ${Script:EmailTable}.Field.Part4_Attach += ${attachFile}
            }
        } # END of foreach (${attachFile} in ${Attachment}) {}
    }

    #####
    # -bt
    # -BodyText
    # -bf
    # -BodyFile
    #####
    # • Precedence level 6a.
    # • -bt|-BodyText takes precedence over -bf|-BodyFile.
    #####
    
    ##### -bt|-BodyText takes precedence over -bf|-BodyFile.
    if (${BodyText}) {
        #####
        # -bt
        # -BodyText
        #####
        Processing 1 'MAIN' ('PARAMETER '+( Get-Var-Quoted 0 'BodyText' 0 'Auto' "${BodyText}" ))
        ${Script:EmailTable}.Field.Part3_Body = ${BodyText}
    ##### Else if -bf|-BodyFile was specified...
    } elseif (${BodyFile}) {
        #####
        # -bf
        # -BodyFile
        #####
        Processing 1 'MAIN' ('PARAMETER '+( Get-Var-Quoted 0 'BodyFile' 0 'Auto' "${BodyFile}" ))
        ##### If ${BodyFile} doesn't exist...
        if (-not (Test-Path ${BodyFile})) {
            Output-Error `
                -errorMessage    ('Body text file '+( Get-Quoted 'Auto' "${BodyFile}" )+' does not exist or is not readable.') `
                -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
        ##### Else if ${BodyFile} exists...
        } else {
            ##### Try to get contents...
            try {
                ${Script:EmailTable}.Field.Part3_Body = Get-Content ${BodyFile} -Raw -ErrorAction Stop
            ##### If it fails, it's an error...
            } catch {
                Output-Error `
                    -errorMessage    ('Body text file '+( Get-Quoted 'Auto' "${BodyFile}" )+' could not be read.') `
                    -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
            }
        }
    } # END of if (${BodyText}) {} elseif (${BodyFile}) {}

    #####
    # -c
    # -ConfigFile
    #####

    ##### If ${ConfigFile} was specified...
    if (${ConfigFile}) {
        Processing 1 'MAIN' ('PARAMETER '+( Get-Var-Quoted 0 'ConfigFile' 0 'Auto' "${ConfigFile}" ))
        if (( Check-Path 'Config File' "${ConfigFile}" -returnOnlyTrueFalse -noWarn )) {
            ${Script:EmailTable}.ConfigFile.Path = ${ConfigFile}
        } else {
            Output-Error `
                -errorMessage    ('Config File entered as '+( Get-Quoted 'Auto' "${ConfigFile}" )+' is INVALID.') `
                -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
        }
    ##### Else, use the default...
    } else {
        ${Script:EmailTable}.ConfigFile.Path = (${Script:RuntimeTable}.FullName+'.json')
    }
    Processing 1 'MAIN' ('USING: '+( Get-Var-Quoted 0 'ConfigFile' 0 'Auto' ${Script:EmailTable}.ConfigFile.Path ))

    #####
    # -i
    # -IgnoreDNS
    #####
    if (${IgnoreDNS}) {
        Processing 1 'MAIN' 'PARAMETER IgnoreDNS = True'
    }

    #####
    # -p
    # -Profile
    #####

    ##### If ${Profile} was specified...
    if (${Profile}) {
        Processing 1 'MAIN' ('PARAMETER '+( Get-Var-Quoted 0 'Profile' 0 'None' ${Profile} ))
        if (${Profile} -lt 0) {
            Output-Error `
                -errorMessage    "Invalid Profile number ${Profile}; specify a positive Integer value." `
                -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
        }
        ${Script:EmailTable}.Condition.ProfileIndex = ${Profile}
    } # Else the default is 0.
    Processing 1 'MAIN' ('USING: '+( Get-Var-Quoted 0 'Profile' 0 'None' ${Script:EmailTable}.Condition.ProfileIndex ))

    #####
    # -rs
    # -RunSetup
    # -RerunSetup
    #####
    if (${RerunSetup}) {
        Processing 1 'MAIN' 'PARAMETER RerunSetup = True'
    }

    #####
    # -s
    # -Subject
    #####
    if (${Subject}) {
        Processing 1 'MAIN' 'PARAMETER Subject'
        ${Script:EmailTable}.Field.Part2_Subject = ${Subject}
    }

    #####
    # -UseHTML
    #####
    if (${UseHTML}) {
        Processing 1 'MAIN' 'PARAMETER UseHTML = True'
        ${Script:EmailTable}.Field.Part3_IsHTML = ${True}
    }

    #####
    # Make sure all required parameters were given...
    #####
    # • Precedence level 6b.
    #####
    if (${Attachment} -or ${BodyFile} -or ${BodyText} -or ${Subject}) {
        if (
            (-not ${BodyFile} -and -not ${BodyText}) -or
            (-not ${Subject}                       )
        ) {
            Output-Error `
                -errorMessage    'When using any of the email parameters (-a, -bf, -bt, -s), you must specify -s and one of -bf or -bt.' `
                -callingFuncName 'MAIN' -callingSection 'Parameter Processing'
        }
    }
} # END of if (${Remove}) {} else {}

Process-Table 2 'MAIN' '${Script:RuntimeTable} SCOPED' ${Script:RuntimeTable}
Processing 1 'MAIN' 'CLOSE:Parameter Processing.'


#####
##### If -rm|-Remove is used, process it and exit...
#####

if (${Remove}) {
    Processing 1 'MAIN' ('ACTION Credential-Remove '+( Get-Quoted 'Auto' "${Remove}" ))
    Credential-Remove "${Remove}"
    Process-Exit ${Script:RuntimeTable}.ExitStatus.E0Good 'MAIN'
}


#####
##### Config File Processing...
#####

Processing 1 'MAIN' (
    'ACTION Loading '+
    ( Get-Var-Quoted 0 '${Script:EmailTable}.ConfigFile.Path' 0 'Auto' ${Script:EmailTable}.ConfigFile.Path -noBrackets -suffix '...' -nl )+
    ( Draw-Box -textString ('LOADING '+${Script:EmailTable}.ConfigFile.Path) -textPrefix ${Script:RuntimeTable}.Verbose.Indent -textPadAll 1 -nl )
)

#####
# If Check-Path returns 'Warning'...
#  • If it encounters an error, it will output the error and exit.
#  • If everything is OK, it'll return ${True}, and trigger the else clause below.
#####
if ([String]( Check-Path 'Config File' ${Script:EmailTable}.ConfigFile.Path -warnIfEmpty -warnSuffix ' — Starting fresh') -eq 'Warning') {
    ##### Set ${Script:EmailTable}.ConfigFile.JSON to an empty HashTable to start fresh...
    Processing 2 'MAIN' 'Starting fresh.'
    ${Script:EmailTable}.ConfigFile.JSON = @{}

##### Else, if it is a plain file with data...
} else {
    ##### Try to load it as JSON data...
    Processing 2 'MAIN' 'Parsing JSON data.'
    try {
        ${Script:EmailTable}.ConfigFile.JSON = `
            Get-Content ${Script:EmailTable}.ConfigFile.Path -Raw -Encoding Unicode | ConvertFrom-JSON -ErrorAction Stop
        #####
        # If this succeeds, then ${Script:EmailTable}.ConfigFile.JSON will contain valid JSON data.
        # Otherwise, it'll trigger the catch clause below.
        #####
        Processing 1 'MAIN' (${Script:RuntimeTable}.Symbols.Good+'Reading from config file SUCCEEDED.')

    ##### If it contains invalid JSON data, warn and start fresh...
    } catch {
        ##### Warn...
        Output-Warning `
            ('JSON parse of config file '+( Get-Quoted 'Auto' ${Script:EmailTable}.ConfigFile.Path )) `
            -exception "$(${_}.Exception.Message)" -failSuffix "`nStarting fresh."
        ##### Set ${Script:EmailTable}.ConfigFile.JSON to an empty HashTable to start fresh...
        Processing 2 'MAIN' 'Starting fresh.'
        ${Script:EmailTable}.ConfigFile.JSON = @{}
    }
} # END of if ([String]( Check-Path 'Config File' ${Script:EmailTable}.ConfigFile.Path ... ) -eq 'Warning') {} else {}
Process-Table 2 'MAIN' '${Script:EmailTable}.ConfigFile.JSON' ${Script:EmailTable}.ConfigFile.JSON


#####
##### Set all values in the ${Script:EmailTable}.Set* from ${Script:EmailTable}.ConfigFile.JSON...
#####

JSON-Assemble 'GET'


#####
##### Assemble Host.Local.* Addresses...
#####
# • Assemble ${Script:RuntimeTable}.Host.Local.FQDN from ${Script:RuntimeTable}.Host.Local.Hostname & ${Script:RuntimeTable}.Host.Local.Domain if set.
# • If parameter -i|-IgnoreDNS is used, or Profile${Profile}_ItemA_IgnoreDNS.Value is true, this'll be overriden so Local.Domain='' & Local.FQDN=Hostname.
#####

Processing 1 'MAIN' 'Getting Host_FQDN'
if (${IgnoreDNS} -or [Bool]${Script:EmailTable}.Set3_Profiles.('Profile'+${Profile}+'_ItemA_IgnoreDNS').Value) {
    ${IgnoreDNS} = ${True}
    ${Script:RuntimeTable}.Host.Local.Domain = ''
    ${Script:RuntimeTable}.Host.Local.FQDN   = ${Script:RuntimeTable}.Host.Local.Hostname
} else {
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
} # END of if (${IgnoreDNS} -or [Bool]${Script:EmailTable}.Set3_Profiles.('Profile'+${Profile}+'_ItemA_IgnoreDNS').Value) {} else {}


#####
##### Get the public DNS domain and populate the necessary values in ${Script:EmailTable}.Set1_Internal.Group0_ItemB_PublicAddresses.*...
#####

Processing 1 'Main' 'Get-Public-DNS-Domain'
${Script:RuntimeTable}.Host.Public.IP   = Get-Public-IP
${Script:RuntimeTable}.Host.Public.FQDN = Get-Public-DNS-Domain
if (${Script:RuntimeTable}.Host.Public.IP -eq ${False} -and ${Script:RuntimeTable}.Host.Public.FQDN -eq ${False}) {
    ${Script:EmailTable}.Set1_Internal.Group0_ItemB_PublicAddresses.Properties.Meta2_Prompt1 = `
    ${Script:EmailTable}.Set1_Internal.Group0_ItemB_PublicAddresses.Properties.Meta2_Prompt1.Replace(
        ':INSERT_ANSWER_HERE:',
        'UNKNOWN'
    )
} else {
        ${Script:EmailTable}.Set1_Internal.Group0_ItemB_PublicAddresses.Properties.Meta5_Default  = ${Script:RuntimeTable}.Host.Public.IP
    if (${Script:RuntimeTable}.Host.Public.FQDN -ne ${False}) {
        ${Script:EmailTable}.Set1_Internal.Group0_ItemB_PublicAddresses.Properties.Meta5_Default += (','+${Script:RuntimeTable}.Host.Public.FQDN)
    }

    ${Script:EmailTable}.Set1_Internal.Group0_ItemB_PublicAddresses.Properties.Meta2_Prompt1 = `
    ${Script:EmailTable}.Set1_Internal.Group0_ItemB_PublicAddresses.Properties.Meta2_Prompt1.Replace(
        ':INSERT_ANSWER_HERE:',
        ${Script:EmailTable}.Set1_Internal.Group0_ItemB_PublicAddresses.Properties.Meta5_Default
    )
} # END of if (${Script:RuntimeTable}.Host.Public.IP -eq ${False} -and ${Script:RuntimeTable}.Host.Public.FQDN -eq ${False}) {} else {}
Process-Table 2 'MAIN' '${Script:RuntimeTable}.Host' ${Script:RuntimeTable}.Host


#####
##### Scope check &/or prompt for all data...
#####

Check-All-Entries ${RerunSetup} ${IgnoreDNS}


#####
##### If applicable, update the config file with all data...
#####

if (${Script:EmailTable}.Condition.UpdateConfig) {
    Processing 1 'MAIN' 'ACTION UpdateConfig = True'
    JSON-Assemble 'PUT'
    Output-Writer `
        -textOutput        ${Script:EmailTable}.ConfigFile.Data `
        -outFile           ${Script:EmailTable}.ConfigFile.Path `
        -niCallingFunction 'MAIN'                               `
        -niCallingVarNames '${Script:EmailTable}.ConfigFile.Data'
} else {
    Processing 1 'MAIN' 'ACTION UpdateConfig = False'
}


#####
##### If applicable, get and save the credential...
#####

##### Set1_Internal is a given...
    ${Script:EmailTable}.Condition.SetsToUse  = @('Set1_Internal')
##### Set2_External is only used if Group0_ItemA_UseExternal.Value is True...
if (${Script:EmailTable}.Set1_Internal.Group0_ItemA_UseExternal.Value) {
    ${Script:EmailTable}.Condition.SetsToUse +=   'Set2_External'
}
foreach (${level1Key} in ${Script:EmailTable}.Condition.SetsToUse) {
    if (${Script:EmailTable}.${level1Key}.Group1_SMTP4_Authenticate.Value) {
        Processing 1 'MAIN' "ACTION ${level1Key}.Group1_SMTP4_Authenticate = True"
        if (-not (Credential-Get ${Script:EmailTable}.${level1Key}.Group1_SMTP4_UserName.Value)) {
            Processing 1 'MAIN' (
                'ACTION Credential-Get '+
                    ${Script:EmailTable}.${level1Key}.Group1_SMTP4_UserName.Value+
                    '...'+
                    ${Script:RuntimeTable}.Symbols.Warn+
                    'NOT FOUND.'
            )
            Processing 1 'MAIN' (
                'ACTION Credential-Save '+
                    ${Script:EmailTable}.${level1Key}.Group1_SMTP4_UserName.Value
            )

            Credential-Save ${Script:EmailTable}.${level1Key}.Group1_SMTP4_UserName.Value

        } else {
            Processing 1 'MAIN' (
                'ACTION Credential-Get '+
                    ${Script:EmailTable}.${level1Key}.Group1_SMTP4_UserName.Value+
                    '...'+
                    ${Script:RuntimeTable}.Symbols.Good+
                    'it already exists.'
            )
        }
    } else {
        Processing 1 'MAIN' "ACTION ${level1Key}.Group1_SMTP4_Authenticate = False"
    }
} # END of foreach (${level1Key} in ${Script:EmailTable}.Condition.SetsToUse) {}


#####
##### Send-Email(s)...
#####

##### If any of these were set by user parameters...
if (
    ${Script:EmailTable}.Field.Part2_Subject -or
    ${Script:EmailTable}.Field.Part3_Body    -or
    ${Script:EmailTable}.Field.Part4_Attach
) {
    ##### Send a single email as directed by those parameters...
    Processing 1 'MAIN' 'ACTION Send-Email According To Parameters'
    ${Script:EmailTable}.Condition.TestEmail = ${False}
} else {
    ##### Send a test email(s)...
    Processing 1 'MAIN' 'ACTION Send-Email Test Message(s) (no parameters specified)'

    #####
    # Assemble the fields of the test email...
    #  • The following will be replaced dynamically in the Send-Email function with each invocation (which will be 1 or 2 test emails)...
    #    • :SET:  the name of the set used
    #    • :FROM: the from address used
    #####

    ##### Subject...
    ${Script:EmailTable}.Field.Part2_Subject = (
        'TEST from '+(
            Get-Quoted 'Brackets.Angled.Double' (
                ${Script:RuntimeTable}.Host.Local.Hostname+':'+${Script:RuntimeTable}.Basename+'::SET::'+${Script:EmailTable}.Condition.ProfileIndex
            )
        )
    )

    ##### Body...
    ${Script:EmailTable}.Field.Part3_Body = (
        "This is a TEST message.`n"+
        "`n"+
        "It was sent from...`n"+
        ${Script:RuntimeTable}.Symbols.Bullet+'Host '+(    Get-Quoted 'Brackets.Angled.Double' ${Script:RuntimeTable}.Host.Local.FQDN      -nl )+
        ${Script:RuntimeTable}.Symbols.Bullet+'Path '+(    Get-Quoted 'Brackets.Angled.Double' ${Script:RuntimeTable}.FullPath             -nl )+
        "Using...`n"+
        ${Script:RuntimeTable}.Symbols.Bullet+'SMTP '+(    Get-Quoted 'Brackets.Angled.Double' ':SET:'                                         )+
        ${Script:RuntimeTable}.Symbols.EmDash+'Profile '+( Get-Quoted 'Brackets.Angled.Double' ${Script:EmailTable}.Condition.ProfileIndex -nl )+
        ${Script:RuntimeTable}.Symbols.Bullet+'From '+(    Get-Quoted 'Brackets.Angled.Double' ':FROM:'                                    -nl )+
        "`n"+
        'The configuration file used to send this message is attached.'
    )

    ##### Attach...
    ${Script:EmailTable}.Field.Part4_Attach = ${Script:EmailTable}.ConfigFile.Path
} # END of if {} else {}

##### Determine which set(s) to use...
${Script:EmailTable}.Condition.SetsToUse = @('Set1_Internal')
if (${Script:EmailTable}.Set1_Internal.Group0_ItemA_UseExternal.Value) {
    Processing 2 'MAIN' (
        Get-Var-Quoted `
            0 `
            'Group0_ItemA_UseExternal' `
            0 `
            'None' `
            'True' `
            -noBrackets `
            -preBullet
    )
    Processing 2 'MAIN' (
        Get-Var-Quoted `
            0 `
            'Group0_ItemB_PublicAddresses' `
            0 `
            'Auto' `
            ${Script:EmailTable}.Set1_Internal.Group0_ItemB_PublicAddresses.Value `
            -noBrackets `
            -preBullet
    )
    ##### Convert into an array and trim whitespace before & after each comma...
    ${Script:EmailTable}.Set1_Internal.Group0_ItemB_PublicAddresses.ValueSet = `
        @(${Script:EmailTable}.Set1_Internal.Group0_ItemB_PublicAddresses.Value -Split ',').Trim()
    Processing 2 'MAIN' (
        Get-Var-Quoted `
            0 `
            'Public.IP' `
            0 `
            'Auto' `
            ${Script:RuntimeTable}.Host.Public.IP `
            -noBrackets `
            -preBullet
    )
    Processing 2 'MAIN' (
        Get-Var-Quoted `
            0 `
            'Public.FQDN' `
            0 `
            'Auto' `
            ${Script:RuntimeTable}.Host.Public.FQDN `
            -noBrackets `
            -preBullet
    )
    if (${Script:EmailTable}.Condition.TestEmail) {
        ${Script:EmailTable}.Condition.SetsToUse += 'Set2_External'
    } else {
        if (${Script:RuntimeTable}.Host.Public.IP -eq ${False}) {
            Processing 2 'MAIN' (
            Get-Var-Quoted `
                0 `
                'Public.IP' `
                0 `
                'None' `
                ${Script:RuntimeTable}.Verbose.NullString `
                -noBrackets `
                -preBullet
        )
        } else {
            if (${Script:RuntimeTable}.Host.Public.IP -In ${Script:EmailTable}.Set1_Internal.Group0_ItemB_PublicAddresses.ValueSet) {
                Processing 2 'MAIN' (
                    ${Script:RuntimeTable}.Symbols.Bullet+${Script:RuntimeTable}.Symbols.Good+'Public.IP IS in Group0_ItemB_PublicAddresses.'
                )
            } else {
                Processing 2 'MAIN' (
                    ${Script:RuntimeTable}.Symbols.Bullet+${Script:RuntimeTable}.Symbols.Warn+'Public.IP is NOT in Group0_ItemB_PublicAddresses.'
                )
                if (${Script:RuntimeTable}.Host.Public.FQDN -eq ${False}) {
                    Processing 2 'MAIN' (
                        Get-Var-Quoted `
                            0 `
                            'Public.FQDN' `
                            0 `
                            'None' `
                            ${Script:RuntimeTable}.Verbose.NullString `
                            -noBrackets `
                            -preBullet
                    )
                } else {
                    if (${Script:RuntimeTable}.Host.Public.FQDN -In ${Script:EmailTable}.Set1_Internal.Group0_ItemB_PublicAddresses.ValueSet) {
                        Processing 2 'MAIN' (
                            ${Script:RuntimeTable}.Symbols.Bullet+
                            ${Script:RuntimeTable}.Symbols.Good+
                            'Public.FQDN IS in Group0_ItemB_PublicAddresses.'
                        )
                    } else {
                        Processing 2 'MAIN' (
                            ${Script:RuntimeTable}.Symbols.Bullet+
                            ${Script:RuntimeTable}.Symbols.Warn+
                            'Public.FQDN is NOT in Group0_ItemB_PublicAddresses.'
                        )
                        ${Script:EmailTable}.Condition.SetsToUse = @('Set2_External') # only
                    }
                } # END of if (${Script:RuntimeTable}.Host.Public.FQDN -eq ${False}) {} else {}
            } # END of if (${Script:RuntimeTable}.Host.Public.IP -In ${Script:EmailTable}.Set1_Internal.Group0_ItemB_PublicAddresses.ValueSet) {} else {}
        } # END of if (${Script:RuntimeTable}.Host.Public.IP -eq ${False}) {} else {}
    } # END of if (${Script:EmailTable}.Condition.TestEmail) {} else {}
} else {
    Processing 2 'MAIN' (
        Get-Var-Quoted `
            0 `
            'Group0_ItemA_UseExternal' `
            0 `
            'None' `
            'False' `
            -noBrackets `
            -preBullet
    )
} # END of if (${Script:EmailTable}.Set1_Internal.Group0_ItemA_UseExternal.Value) {} else {}
Process-Array 2 'MAIN' 'SetsToUse' ${Script:EmailTable}.Condition.SetsToUse

#####
# Where ${Script:EmailTable}.Condition.SetsToUse is one of...
#  • @('Set1_Internal')
#  • @('Set2_External')
#  • @('Set1_Internal','Set2_External')
#####
foreach (${level1Key} in ${Script:EmailTable}.Condition.SetsToUse) {
    ##### Call Send-Email and based on its return value, call either Output-Feedback or Output-Warning...
    if (( Send-Email ${level1Key} )) {
        Output-Feedback "Email send using ${level1Key} is done." -success
    } else {
        Output-Warning  "Email send using ${level1Key}"          -failed
    }
} # END of foreach (${level1Key} in ${Script:EmailTable}.Condition.SetsToUse) {}


#####
##### The end.
#####

Process-Exit ${Script:RuntimeTable}.ExitStatus.E0Good 'MAIN'


