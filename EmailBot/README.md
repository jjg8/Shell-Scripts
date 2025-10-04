# Shell Scripts

Hello and welcome to my Shell Scripts repository.

These are some of my more useful shell scripts.  In this folder...

- **EmailBot** -- PowerShell
  - Prompts for all required email info. Set up multiple email address profiles (-p N). Sends a test email (or 2 emails if setting up an Internal & External SMTP services). You can use
  a custom config file (-c "C:\path\to\config.json") or (without -c) simply default to EmailBot.json in the same directory as this script. Send an email: specify the text of the email
  body (-bt "text" or -bf "C:\path\to\body.txt"). Add an attachment(s) (-a "C:\path\to\attachment.ext"). If your SMTP service(s) require user authentication, it'll store the password
  you enter (securely) in the Windows Credential Manager and not in the config file. When you no longer need a stored credential, you can remove it (-rm "OldUserName") from the
  Windows Credential Manager. More customization parameters are available below.

Complete Help page...
```
SYNOPSIS
  Notify by email from the command line or automated using Task Scheduler.
DESCRIPTION
  Prompts for all required email info. Set up multiple email address profiles (-p N). Sends a test email (or 2 emails if setting up an Internal & External SMTP services). You can use
  a custom config file (-c "C:\path\to\config.json") or (without -c) simply default to EmailBot.json in the same directory as this script. Send an email: specify the text of the email
  body (-bt "text" or -bf "C:\path\to\body.txt"). Add an attachment(s) (-a "C:\path\to\attachment.ext"). If your SMTP service(s) require user authentication, it'll store the password
  you enter (securely) in the Windows Credential Manager and not in the config file. When you no longer need a stored credential, you can remove it (-rm "OldUserName") from the
  Windows Credential Manager. More customization parameters are available below.
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
       6b. After all parameters are processed, if any of -a|-Attachment, -bt|-BodyText, -bf|-BodyFile, and/or -s|-Subject were used, it makes sure one of -bt|-BodyText or
       -bf|-BodyFile, and -s|-Subject were specified together, otherwise it's an error.
INPUTS
  This script does not accept pipeline input, it prompts in the console for required data during setup, it uses a config file to save data, and it uses CLI parameters to send email
  messages.
OUTPUTS
  Output is sent to the following...
   • All normal text: the Success stream, 1, using Write-Output, and this does not support color.
   • Everything else: [Console], using Write-Host (includes all Error, Warning, Verbose, and Debug messages), and this supports color.
     • Error, Warning, Verbose, & Debug go to [Console], because if they went to stream 1, output would be captured as return statuses from functions.
     • Streams 2-6 can't be used, because Write-Host (to support -BackgroundColor & -ForegroundColor) cannot be redirected to those streams.
-a|-Attachment "C:\path\to\attachment.ext"
  Specify a quoted comma-separated path(s) to an attachment(s) to the email with -a or -Attachment "C:\path\to\attachment.ext".
-bf|-BodyFile "C:\path\to\body.txt"
  Specify the text to insert into the email body with -bf or -BodyFile "C:\path\to\body.txt". -bf and -bt are mutually exclusive. The text in the file may contain UTF8 characters.
  -bt|-BodyText takes precedence over -bf|-BodyFile.
-bt|-BodyText "multi-line text"
  Specify the text to insert into the email body with -bt or -BodyText "multi-line text". -bt and -bf are mutually exclusive. The text may contain UTF8 characters. -bt|-BodyText takes
  precedence over -bf|-BodyFile.
-c|-cf|-ConfigFile "C:\path\to\configfile.json"
  Specify a custom configuration file with -c|-cf|-ConfigFile "C:\path\to\configfile.json". If this parameter is not used, the config file defaults to EmailBot.json in the same
  directory as this script. To setup all new info, simply specify this parameter with a new file, rename/remove/empty the default EmailBot.json file, or use parameter
  -rs|-RunSetup|-RerunSetup, and the script will prompt for all necessary info. If you manually edit the config file, please keep it mind it must be properly JSON-formatted, or it
  might reject some or all of it; tag names and strings are quoted, while numbers and booleans are unquoted, and each item within the {} as well as the trailing } must end with a
  comma, except for the last item and the last } must not have a comma after it. If you do manually edit it, I recommend using parameter -d|-Debug to see how it's parsing the data. If
  anything required is missing from the config file, it will prompt for it.
-d|-Debugging
  Enables Verbosity to its max+1 and will not write any changes or send any email. Parameter -v|-Verbosity is ignored.
-h|-Help
  Output this help screen and exit.
-i|-IgnoreDNS
  If the local DNS of the host is fictitious (i.e. only relevant within an intranet, as opposed to public DNS on the Internet), you can ignore the DNS DomainName of the host.
  Normally, the local DNS DomainName is offered as an option in the multiple choice prompt to set the From address, as well as being used in the test email message that's sent after
  all email parameters have been properly entered. If you use -i|-IgnoreDNS, then that option will not be offered in the multiple choice prompt for the From address, and the test
  email will only use the Hostname. This parameter will be saved in the config file once used.
-ni|-NonInteractive
  Simply carry out the required operation and exit without any input or output, other than the exit code. Automatically enables -Silent. By using this parameter, if any required
  information is missing, it will exit with code 3. The only exceptions to this parameter are -d|-Debug, -v|-Verbosity, or -niv. Parameter -rs|-RunSetup|-RerunSetup will cause a Usage
  error. IMPORTANT:Ensure you complete all setup and test it prior to using this parameter.
-niv
  The same as parameter -ni|-NonInteractive, it also enables Non-interactive mode, except -niv will also output verbose messages for any missing requirements but none of the other
  verbose or debug messages. -niv takes precedence over -ni|-NonInteractive.
-p|-Profile N
  This sets the profile number to use for all email addresses (To, From, CC, BCC) to N, which must be a positive Integer. By default N=0. Profile numbers don't need to be sequential.
-rm|-Remove "OldUserName"
  When you no longer need the stored credential for a particular SMTP UserName, you can remove it from the Windows Credential Manager with -rm|-Remove "OldUserName". If this parameter
  is specified, all other email parameters will be ignored, and it will remove the credential and exit.
-rs|-RunSetup|-RerunSetup
  Normally, this script prompts only when there is missing required data. By using this parameter, you force it to rerun setup again for every prompt, even ones that already have
  answers. For each prompt, if it already has an answer that passes validity-checking, it will show it as a default answer, or you can enter a new answer to replace it.
-Silent
  Normally, any warning or error message also beeps the console, but by using this parameter, the beep is silenced.
-s|-Subject "single line of text"
  Specify the text to insert into the email subject with -s|-Subject "single line of text". The text may contain UTF8 characters.
-UseHTML
  Indicates that the body text is in HTML format.
-v|-Verbosity N
  Set the verbosity level to N (0=none, 1=basic, 2=very) to indicate what it's doing. Verbose messages are not included in an email message.
  Very verbose output may exceed the history size of your terminal, and if so, you can...
   1.  Redirect the Information stream (6) to a file by appending this to the end of script execution:
         EmailBot.ps1 6>"log.txt"
   2a. Newer systems — Increase the History Size of your terminal to something much larger (e.g. my default is 2000000, i.e. 2 million lines).
   2b. Older systems — Increase the Screen Buffer Size, Height, of your terminal to 9999 (the max it supports; if it isn't enough see 1).
EXAMPLES
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

AUTHOR  Jeremy Gagliardi
VERSION 2025-10-04.1
LINK    https://github.com/jjg8/Shell-Scripts/tree/main/EmailBot

NOTES
 • This script was tested with the following configurations, which are typical...
   • Internal — Port 25, STARTTLS, no user authentication, only accepts requests from trusted IPs/Domains, only accepts a From address matching its Domain.
   • External — Port 587, STARTTLS, user auth required, accepts requests from anywhere on the Internet, only accepts a From address matching the account holder's full email address.
     • This is why, when you configure both services (see below) using this script, you need to provide 2 different From addresses for every profile. It's very likely that most modern
     SMTP services won't let you send an email with it using a From address that doesn't match its strict criteria. It prevents spoofing, spam, and other such abuse.
 • During setup, you will be walked through 3 sets of data...
   • Set1_Internal — This may be the only SMTP service you set up or 1 of 2, and if so, it's probably a service that uses IP/Domain-matching.
   • Set2_External — This may be set up if needed, and is probably a personal or other private SMTP service, usable from anywhere on the Internet where strict IP/Domain-matching isn't
   possible or practical.
   • Set3_Profiles — At least one profile needs to be set up (by default 0), and will set the To, From, CC, and BCC addresses it'll use to send an email.
     • This script doesn't currently support specifying any of these addresses on the fly, so they need to be configured and a test email sent beforehand.
 • All email sent by this script uses Encoding = UTF8.
   • For widespread compatibility, most SMTP services can handle up to UTF8 (as opposed to full Unicode, UTF-16 LE BOM, which some choke on).
   • Even if you don't have any advanced UTF8 characters in your message, it's still good practice to encode for UTF8.
   • Sometimes, data sources from other services (e.g. Event Log data) may have UTF8 characters in them you might not be aware of.
   • This script has many UTF8 characters in it above and beyond the Basic Latin block.
   • Many modern text & document editors use more than Basic Latin (what many old-timers might call ASCII), probably without many even realizing it...
     • E.g. Word, Confluence, and I'm sure others, automatically use En Dash, Em Dash, bullets, curved quotes, and other special characters, all of which aren't in Basic Latin, and
     much of which end up in email messages.
   • If a UTF8 character doesn't render, it's your font, not your app or OS.
 • You can read the comments in the script for a lot more detail.
```

View the script for more details.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
