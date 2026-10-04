# edge-remover

A simple batch script that gets rid of Microsoft Edge on Windows. Properly, not just "uninstall and leave junk behind".

## What it does

- Asks for admin rights by itself (no need to remember "Run as administrator")
- Kills every Edge process and removes its services and scheduled tasks
- Runs Edge's own uninstaller
- Deletes leftover files and folders (Program Files, ProgramData, AppData)
- Removes the shortcuts from the desktop, Start menu and taskbar
- Cleans up the registry (it saves a backup of the main keys as `edge_backup_*.reg` first)
- Optionally stops Windows Update from sneaking Edge back in

## How to use it

1. Download `edge_remover.bat`
2. Double-click it
3. Answer the prompts
4. Restart your PC

## Good to know

- Your Edge data (passwords, bookmarks, history) will be gone for good, so export anything you care about first.
- WebView2 Runtime is left alone. A lot of other apps need it and removing it would break them.
- Big Windows updates can bring Edge back. The block option helps, but I can't promise it works forever.
- Some antivirus programs might complain, since the script kills processes and edits the registry. That's a false positive. The whole thing is plain text, so feel free to read it before running.
- Making a restore point first is a good idea.

## Disclaimer

Use it at your own risk.

This script messes with system files, services and the registry. It comes "as is", with no warranty, and I'm not responsible if something breaks, you lose data, or Windows starts acting weird. If you run it, that's on you. Back up your stuff and make a restore point before you start.

## License

MIT
