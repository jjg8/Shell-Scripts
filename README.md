# Shell Scripts

Hello and welcome to my Shell Scripts repository.

These are some of my more useful shell scripts, and what shell they're written in (e.g. bash, PowerShell)

- **jira-get-filters** — bash
  - Export all of the filters owned by you in Jira Cloud, and format it in a GitHub-style README.md file using markdown syntax.
- **weather** — bash
  - Uses curl or wget to get the CLI-friendly weather from https://wttr.in and is very configurable with CLI options to control output.
- **EmailBot** — PowerShell
  - Prompts for all required email info. Set up multiple email address profiles (-p N). Sends a test email (or 2 emails if setting up an Internal & External SMTP services). You can use a custom config file (-c "C:\path\to\config.json") or (without -c) simply default to EmailBot.json in the same directory as this script. Send an email: specify the text of the email body (-bt "text" or -bf "C:\path\to\body.txt"). Add an attachment(s) (-a "C:\path\to\attachment.ext"). If your SMTP service(s) require user authentication, it'll store the password you enter (securely) in the Windows Credential Manager and not in the config file. When you no longer need a stored credential, you can remove it (-rm "OldUserName") from the Windows Credential Manager. More customization parameters are available.
- **WinGetEvents** — PowerShell
  - Filters Windows event logs based on severity (-l), date/interval (-d, -r), excluded event IDs (-x), and outputs results in XML format with a summary. Event exclusions (-x) are passed as a quoted comma-separated list. Date range (-r) must include exactly two dates (from,to) in "yyyy-mm-dd,yyyy-mm-dd" format.

View each script's folder for more info.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
