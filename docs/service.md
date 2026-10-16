# Service management

[Back to Herdr Agent World](../README.md).

Agent World runs a local background service on port 43821. Closing the browser
does not stop it. Opening the plugin starts an installed service if needed and
attaches the calling Herdr workspace. Attachments expire when the service restarts.

## macOS

The installer creates the user LaunchAgent `local.herdr-grove`. It starts at
login and restarts after a crash. Use its installed helper to manage it:

```sh
"$HOME/Library/Application Support/Herdr Grove/bin/grove-service" status
"$HOME/Library/Application Support/Herdr Grove/bin/grove-service" logs
"$HOME/Library/Application Support/Herdr Grove/bin/grove-service" restart
"$HOME/Library/Application Support/Herdr Grove/bin/grove-service" stop
```

## Linux and WSL2

The installer uses a systemd user service when available, otherwise a local
background process. Packages are statically linked and do not require Rust.

```sh
"${XDG_DATA_HOME:-$HOME/.local/share}/herdr-grove/bin/grove-service" status
"${XDG_DATA_HOME:-$HOME/.local/share}/herdr-grove/bin/grove-service" logs
"${XDG_DATA_HOME:-$HOME/.local/share}/herdr-grove/bin/grove-service" restart
"${XDG_DATA_HOME:-$HOME/.local/share}/herdr-grove/bin/grove-service" stop
```

On WSL2, keep data on the Linux filesystem. Windows-mounted paths under `/mnt/`
are refused because they do not provide the required private file permissions.
Opening the browser uses Windows PowerShell. If browser integration fails,
the Open action reports it; check the service status and WSL integration.

## Troubleshooting

- Run the Open action from a shell pane inside Herdr. It needs the real calling
  workspace context. Do not manually set Herdr environment variables.
- After a restart or update, reopen the plugin from each workspace. A running
  service does not automatically regain permission to monitor old attachments.
- If installation cannot download a package, check GitHub connectivity and the
  [release page](https://github.com/lakeinlake/herdr-agent-world/releases).
- If the service cannot start, inspect its logs and check whether another
  process occupies port 43821. Report the error with your OS and plugin version;
  do not include private prompt bodies or browser edit tokens.
- If you previously installed a locally linked Grove plugin, Herdr may refuse
  to replace it. Run `herdr plugin unlink local.herdr-grove`, then the marketplace
  install command. Unlinking preserves files and recorded history.

## Remove

First uninstall the background service using the appropriate installed helper:

```sh
# macOS
"$HOME/Library/Application Support/Herdr Grove/bin/grove-service" uninstall

# Linux / WSL2
"${XDG_DATA_HOME:-$HOME/.local/share}/herdr-grove/bin/grove-service" uninstall
```

Then remove the plugin registration:

```sh
herdr plugin uninstall local.herdr-grove
```

Service removal preserves saved characters, configuration, logs and recorded
history in `~/Library/Application Support/Herdr Grove` on macOS or
`${XDG_DATA_HOME:-$HOME/.local/share}/herdr-grove` on Linux. Marketplace installation
does not add shell or agent shortcuts. Shortcuts from an older standalone
installation remain until removed separately.
