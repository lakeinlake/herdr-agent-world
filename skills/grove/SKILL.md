---
name: grove
description: Open the local Herdr Grove agent monitor for the current Herdr workspace.
---

Open Grove by running this command in the agent's genuine Herdr-managed context:

```sh
test "${HERDR_ENV:-}" = 1 && herdr plugin action invoke open --plugin local.herdr-grove
```

If the context check fails, explain that opening and attaching requires running
inside Herdr. Never set HERDR_ENV or invent workspace/pane IDs to bypass it.
This action opens the browser with character editing and attaches the calling
workspace to the service. It starts an already-installed macOS, Linux or WSL2
service if needed and leaves a running service alone. It does not send prompts to agents.
Report success only when the command succeeds; summarize any reported failure.
Do not change focus, create test agents, reinstall, or restart services to open
the monitor. If the action reports a missing installation or startup failure,
summarize the error and point to the installer or service troubleshooting.

Development binary/data overrides require a running foreground `grove serve`.
