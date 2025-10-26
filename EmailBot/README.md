# Shell Scripts

Hello and welcome to my Shell Scripts repository.

These are some of my more useful shell scripts.  In this folder...

- **EmailBot** — PowerShell
  - Prompts for all required email info. Set up multiple email address profiles (-p N). Sends a test email (or 2 emails if setting up an Internal & External SMTP services). You can use
  a custom config file (-c "C:\path\to\config.json") or (without -c) simply default to EmailBot.json in the same directory as this script. Send an email: specify the text of the email
  body (-bt "text" or -bf "C:\path\to\body.txt"). Add an attachment(s) (-a "C:\path\to\attachment.ext"). If your SMTP service(s) require user authentication, it'll store the password
  you enter (securely) in the Windows Credential Manager and not in the config file. When you no longer need a stored credential, you can remove it (-rm "OldUserName") from the
  Windows Credential Manager. More customization parameters are available below.

Complete Help & Release Notes pages...
```
SYNOPSIS
  Notify by email from the command line or automated using Task Scheduler.
DESCRIPTION
  Prompts for all required email info. Set up multiple email address profiles (-p N). Sends a test email (or 2 emails if setting up an Internal & External SMTP services). You can use
  a custom config file (-c 'C:\path\to\config.json') or (without -c) simply default to EmailBot.json in the same directory as this script. Send an email: specify the text of the email
  body (-bt 'text' or -bf 'C:\path\to\body.txt'). Add an attachment(s) (-a 'C:\path\to\attachment.ext'). If your SMTP service(s) require user authentication, it'll store the password
  you enter (securely) in the Windows Credential Manager and not in the config file. When you no longer need a stored credential, you can remove it (-rm 'OldUserName') from the
  Windows Credential Manager. More customization parameters are available below.
  If the script encounters an error it can't handle (whichever it encounters first)...
   • Usage error, it will exit with code 1.
   • Coding error, it will exit with code 2.
   • Missing requirements in -NonInteractive mode, it will exit with code 3.
  IMPORTANT:If you do not specify the email parameters (at least -s|-Subject and one of -bf|-BodyFile or -bt|-BodyText), it will only send a test email message(s).
  Parameters are processed in the following order of precedence...
    1. -dbg|-Debugging takes precedence over -v|-Verbosity.
    2. -Silent (also triggered by -niv|-ni|-NonInteractive).
    3. -niv takes precedence over -ni|-NonInteractive, ignores -h|-Help, but errors on -rs|-RunSetup|-RerunSetup.
    4. -h|-Help takes precedence over -Releases|-ReleaseNotes, and if either is used, it's processed immediately and exits.
    5. -rm|-Remove takes precedence over and ignores the rest of parameters and is processed immediately after parameter processing and exits.
    6. From this point, all other parameters are processed in alphabetical order.
       6a. -bt|-BodyText takes precedence over -bf|-BodyFile.
       6b. After all parameters are processed, if any of -a|-Attachment, -bt|-BodyText, -bf|-BodyFile, and/or -s|-Subject were used, it makes sure one of -bt|-BodyText or
       -bf|-BodyFile, and -s|-Subject were specified together, otherwise it's an error.
INPUTS
  This script does not accept pipeline input, it prompts in the console for required data during setup, it uses a config file to save data, and it uses CLI parameters to send email
  messages. For all parameters that take a quoted argument (e.g. -bt 'multi-line text'), the examples in this help page all show the use of single quotes, which takes all text within
  the quotes as literal plain text. That's fine if your content doesn't contain any single quotes (e.g. when using contractions like "doesn't") and you don't use any variables (e.g.
  "${varName}"), but if so, you're better off using double quotes. If you use double quotes, keep in mind that certain references are no longer taken as literal text, and certain
  characters must be escaped using ` — if your content contains any double quotes, escape each " as `" (e.g. -bt "A line of complex text that's `"complex`"."). If your content
  contains something that looks like code, such as a variable reference, like ${varName} or $varName, and you want it taken as literal text, not interpreted as code, also escape each
  $ as `$ (e.g. -bt "A line of complex text with a variable name `${varName} in it."). For very complex text for the body of the email, you're probably better off using parameter
  -bf|-BodyFile.
OUTPUTS
  Output is sent to the following...
   • All normal text: the Success stream, 1, using Write-Output, and this does not support color.
   • Everything else: [Console], using Write-Host (includes all Error, Warning, Verbose, and Debug messages), and this supports color.
     • Error, Warning, Verbose, & Debug go to [Console], because if they went to stream 1, output would be captured as return statuses from functions.
     • Streams 2-6 can't be used, because Write-Host (to support -BackgroundColor & -ForegroundColor) cannot be redirected to those streams.

-a|-Attachment 'C:\path\to\attachment.ext'
  Specify a quoted comma-separated path(s) to an attachment(s) to the email with -a|-Attachment 'C:\path\to\attachment.ext', including directory, file name, and extension desired. See
  INPUTS above regarding proper quoting.
-bf|-BodyFile 'C:\path\to\body.txt'
  Specify the text to insert into the email body with -bf|-BodyFile 'C:\path\to\body.txt', including directory, file name, and extension desired. The text in the file may contain
  UTF-8 characters. -bt|-BodyText takes precedence over -bf|-BodyFile. When using -bf|-BodyFile, as opposed to -bt|-BodyText, all text in the file is taken as literal text without the
  need to escape or quote any special characters or references. See INPUTS above regarding proper quoting.
-bt|-BodyText 'multi-line text'
  Specify the text to insert into the email body with -bt|-BodyText 'multi-line text'. The text in the quoted argument may contain UTF-8 characters. -bt|-BodyText takes precedence
  over -bf|-BodyFile. See INPUTS above regarding proper quoting.
-c|-cf|-ConfigFile 'C:\path\to\configfile.json'
  Specify a custom configuration file with -c|-cf|-ConfigFile 'C:\path\to\configfile.json', including directory, file name, and extension desired. If this parameter is not used, the
  config file defaults to EmailBot.json in the same directory as this script. To setup all new info, simply specify this parameter with a new file, rename/remove/empty the default
  EmailBot.json file, or use parameter -rs|-RunSetup|-RerunSetup, and the script will prompt for all necessary info. If you manually edit the config file, please keep it mind it must
  be properly JSON-formatted, or it might reject some or all of it; tag names and strings are quoted, while numbers and booleans are unquoted, and each item within the {} as well as
  the trailing } must end with a comma, except for the last item and the last } must NOT have a comma after it. If you do manually edit it, I recommend using parameter -dbg|-Debugging
  to see how it's parsing the data. If anything required is missing from the config file, it will prompt for it. See INPUTS above regarding proper quoting.
-dbg|-Debugging
  Enables Verbosity to its max+1 and it will not write any changes or send any email. Since this sets the Verbosity level automatically, parameter -v|-Verbosity is ignored.
-h|-Help
  Output this help page and exit.
-i|-IgnoreDNS
  If the local DNS of the host is fictitious (i.e. only relevant within an intranet, as opposed to public DNS on the Internet), you can ignore the local DNS DomainName of the host.
  Normally, the local DNS DomainName is offered as an option in the multiple choice prompt to set the From address, as well as being used in the test email message that's sent after
  all config file items have been properly entered. If you use -i|-IgnoreDNS, then that option will not be offered in the multiple choice prompt for the From address, and the test
  email will only use the Hostname. This parameter will be saved in the config file once used.
-ni|-NonInteractive
  Simply carry out the required operation and exit without any input or output, other than the exit code. Automatically enables -Silent. By using this parameter, if any required
  information is missing, it will exit with code 3. The only exceptions to this parameter are -dbg|-Debugging, -v|-Verbosity, or -niv. Parameter -rs|-RunSetup|-RerunSetup will cause a
  Usage error. IMPORTANT:Ensure you complete all setup and test it prior to using this parameter.
-niv
  The same as parameter -ni|-NonInteractive, it also enables Non-interactive mode, except -niv will also output verbose messages for any missing requirements but none of the other
  verbose or debug messages. -niv takes precedence over -ni|-NonInteractive.
-p|-Profile N
  This sets the profile number to use for all email addresses (To, From, CC, BCC) to N, which must be a positive Integer. By default N=0. Profile numbers don't need to be sequential.
-Releases|-ReleaseNotes
  Output the release notes page and exit.
-rm|-Remove 'OldUserName'
  When you no longer need the stored credential for a particular SMTP UserName, you can remove it from the Windows Credential Manager with -rm|-Remove 'OldUserName'. If this parameter
  is specified, all other email parameters will be ignored, and it will remove the credential and exit. See INPUTS above regarding proper quoting.
-rs|-RunSetup|-RerunSetup
  Normally, this script prompts only when there is missing required data. By using this parameter, you force it to rerun setup again for every prompt, even ones that already have
  answers. For each prompt, if it already has an answer that passes validity-checking, it will show it as a default answer, or you can enter a new answer to replace it.
-Silent
  Normally, any warning or error message also beeps in the console, but by using this parameter, the beep is silenced.
-s|-Subject 'single line of text'
  Specify the text to insert into the email subject with -s|-Subject 'single line of text'. The text in the quoted argument may contain UTF-8 characters. See INPUTS above regarding
  proper quoting.
-UseHTML
  Indicates that the body text is in HTML format. Without this parameter, the body text is taken as all literal plain text; by using this parameter, you're telling the SMTP service
  and the receiving email client to interpret the body text as HTML code. If you use this parameter, make sure that any text you want to be interpreted literally is properly encased
  within a <pre></pre> block.
-v|-Verbosity N
  Set the verbosity level to N (0=none, 1=basic, 2=very) to indicate what it's doing. Verbose messages are not included in an email message.
  Very verbose output may exceed the history size of your console, and if so, you can...
   1.  Redirect the Information stream (6) to a file by appending this to the end of script execution:
         EmailBot.ps1 6>'log.txt'
   2a. Newer systems — Increase the History Size of your console to something much larger (e.g. my default is 2000000, i.e. 2 million lines).
   2b. Older systems — Increase the Screen Buffer Size, Height, of your console to 9999 (the max it supports; if it isn't enough see 1).

EXAMPLES
 • Use the default config file & profile number (it will prompt initially for all the required info)...
     EmailBot.ps1
 • Use a custom config file & profile number...
     EmailBot.ps1 -c 'C:\path\to\config.json' -p 1
 • Send an email specifying the body text, a subject, and an attachment...
     EmailBot.ps1 -bt 'multi-line text' -s 'single line of text' -a 'C:\path\to\attachment.ext'
 • Send an email specifying the body from a file, the body is in HTML format, and a subject...
     EmailBot.ps1 -bf 'C:\path\to\body.txt' -UseHTML -s 'single line of text'
 • Remove a credential
     EmailBot.ps1 -rm 'OldUserName'

AUTHOR  Jeremy Gagliardi
VERSION 2025-10-21.1.1
LINK    https://github.com/jjg8/Shell-Scripts/tree/main/EmailBot

NOTES
 • PowerShell does not allow direct script execution by default. To enable, you need to...
   • Launch the PowerShell console using "Run as Administrator", and execute one of the following commands, depending on your needed scope...
     • Set-ExecutionPolicy Bypass -Scope CurrentUser
     • Set-ExecutionPolicy Bypass -Scope LocalMachine
   • Usually, when you download a script from the Internet, it'll be blocked by default, and you can unblock it with this command...
     • Unblock-File -Path 'C:\path\to\EmailBot.ps1'
 • During setup, you will be walked through 3 sets of data...
   • Set1_Internal — This may be the only SMTP service you set up or 1 of 2, and if so, it's probably a service that uses IP/Domain-matching.
   • Set2_External — This may be set up if needed, and is probably a personal or other private SMTP service, usable from anywhere on the Internet where strict IP/Domain-matching isn't
   possible or practical, but user authentication is.
   • Set3_Profiles — At least one profile needs to be set up (by default 0), and will set the To, From, CC, and BCC addresses it'll use to send an email.
     • This script doesn't currently support specifying any of these addresses on the fly, so they need to be configured and a test email sent beforehand.
 • Private IP address ranges are 10.0.0.0/8 (class A), 172.16.0.0/12 (class B), or 192.168.0.0/16 (class C) for IPv4 or fc00::/7 (often fd00::/8) (classless) for IPv6. If a network is
 NATed, which most are, each computer will most likely have a private IP for internal use, but the network as a whole will have one, possibly more, public IP(s). Some organizations
 opt to use public IPs even internally, especially if the organization is very large, which would exceed the capacity of private IP ranges. However, they too are most likely NATed, &
 although the internal IPs in use fall within the "public" ranges, they aren't used publicly on the Internet. Therefore, each computer will often have at least 2 IP addresses —
 private & public. Some computers, especially those with multiple interfaces (physical or logical) will have multiple private IPs. However, only the public IP can be used to determine
 if a mobile workstation is local to the business network or remote somewhere else on the Internet.
 • This script was tested with the following configurations, which are typical...
   • Internal — Port 25, STARTTLS, no user authentication, only accepts requests from trusted IPs/Domains, only accepts a From address matching its Domain.
   • External — Port 587, STARTTLS, user auth required, accepts requests from anywhere on the Internet, only accepts a From address matching the account holder's full email address.
     • This is why, when you configure both services (see below) using this script, you need to provide 2 different From addresses for every profile. It's very likely that most modern
     SMTP services won't let you send an email with it using a From address that doesn't match its strict criteria. It prevents spoofing, spam, and other such abuse.
 • Unicode characters & encoding...
   • All email sent by this script uses Encoding = UTF-8.
   • For widespread compatibility, most SMTP services can handle up to UTF-8 (as opposed to full Unicode, UTF-16 LE BOM, which some choke on).
   • Even if you don't have any advanced UTF-8 characters in your message, it's still good practice to encode for UTF-8.
   • This script has many UTF-8 characters in it above and beyond the Basic Latin block.
   • Sometimes, data sources from other services (e.g. Event Log data) may have UTF-8 characters in them you might not be aware of.
   • Many modern text & document editors use more than Basic Latin (what many old-timers might call ASCII), probably without many even realizing it...
     • E.g. Word, Confluence, and I'm sure others, automatically use En Dash, Em Dash, bullets, curved quotes, and other special characters, all of which aren't in Basic Latin, and
     much of which end up in email messages & documents.
   • If a UTF character doesn't render, it's your font, not your app or OS, unless your app doesn't let you choose the best font, then it's your app.
 • You can read the comments in the script for a lot more detail.

Release Notes for EmailBot.ps1, below Script Conventions, most recent at the bottom:

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

2025-10-04.1
 • Initial release.
 • I worked on the functionality of this script exhaustively before initial release.
 • Supports CLI parameters:  -a|-Attachment, -bf|-BodyFile, -bt|-BodyText, -c|-cf|-ConfigFile, -d|-Debugging, -h|-Help, -i|-IgnoreDNS, -ni|-NonInteractive, -niv, -p|-Profile,
 -rm|-Remove, -rs|-RunSetup|-RerunSetup, -Silent, -s|-Subject, -UseHTML, -v|-Verbosity
 • Tested extensively with the configurations detailed in the NOTES section of the help page.
 • Thoroughly commented the entire script.
 • Finally uploaded it to GitHub.

2025-10-10.1.1
 • No major functionality changes.
 • Common functions...
   • Replaced a lot of common functions with better written versions.
   • When copying a lot of the common functions between scripts, I noticed ways to improve them and rename them all beginning with Do- to distinguish them from all other functions
   that are unique to each script.
   • I began ordering all Do-* functions first alphabetically, followed by all other functions unique to this script next alphabetically.
 • Release Notes...
   • Added this Release Notes page.
   • Added a -releaseNotes switch to function Do-Output-Help-Page.
   • Added CLI parameter -Releases|-ReleaseNotes.
 • Renamed CLI parameter alias -d to -dbg to avoid conflicts with scripts that use -d for other purposes.
 • Replaced all references to EmailBot in the help block with EmailBot, and re-wrote the function Do-Output-Help-Page logic to replace it dynamically with
 ${Script:RuntimeTable}.BareName, so the same function can be copied from script-to-script and work in each without any rewrites necessary.
 • Incorporated the Script Conventions comment block as the bottom of this release notes page.
```

View the script for more details.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
