# Herdr Agent World

Watch your coding agents work as animated characters.

See live activity in your Herdr workspace, choose from 30 bundled Pokémon,
and switch between Forest, Coast and Town scenes. The monitor runs locally.

[![Herdr Agent World in the Forest scene, showing Pikachu, Eevee and Bulbasaur as three sample agents](https://raw.githubusercontent.com/lakeinlake/herdr-agent-world/main/docs/screenshots/forest.png)](https://github.com/lakeinlake/herdr-agent-world/blob/main/docs/screenshots/forest.png)

*Your agents, a little more alive. Forest scene with clearly labeled sample
agents and activity. Click either screenshot to view it at full size.*

<details>
<summary>See the Coast scene</summary>

[![The same sample workspace in the Coast scene, with a sandy beach, Pokémon decorations and a ferry](https://raw.githubusercontent.com/lakeinlake/herdr-agent-world/main/docs/screenshots/coast.png)](https://github.com/lakeinlake/herdr-agent-world/blob/main/docs/screenshots/coast.png)

*Same workspace, a change of scenery. Screenshots show the actual interface
using the read-only sample preview; no live workspace data is shown.*

</details>

## Install

Requires **Herdr 0.8.0+**, Git, curl, and macOS, Linux or WSL2 on Apple Silicon,
ARM64 or x86_64. Rust and Python are not required. On Linux, install `flock`
(util-linux) and `timeout` (coreutils) if unavailable. Native Windows is unsupported.

```sh
herdr plugin install lakeinlake/herdr-agent-world
```

The installer downloads this plugin version's prebuilt release, verifies its
SHA-256 checksum, and installs a local background service. It does not add shell
shortcuts or agent skills. Review the manifest and scripts before installing.

From a shell pane inside Herdr, open the plugin:

```sh
herdr plugin action invoke open --plugin local.herdr-grove
```

You can also select **Open Herdr Agent World** from Herdr's plugin actions.
Select an agent in the browser, expand **Choose a Pokémon**, and click
**Use character**. Custom image imports are not exposed in this release.

## Activity and privacy

Status updates automatically. Recorded communication appears only when sent
through the explicit recorder; full prompts are never displayed or saved.
**Submitted** means Herdr accepted a message, and **Done** means unseen idle;
neither confirms completed work. Sample activity is labeled separately.

After a service restart, open Agent World from each workspace again. Saved
characters and recorded history remain on your machine. Opening the plugin
attaches the calling workspace; it does not send prompts to agents.

## Update and help

Rerun the install command to update. Updates restart the service; reopen it
from each workspace afterward. Saved characters and recorded history are preserved.

- [Service management, troubleshooting and removal](docs/service.md)
- [Release downloads](https://github.com/lakeinlake/herdr-agent-world/releases)
- [Report an issue](https://github.com/lakeinlake/herdr-agent-world/issues)
- [Artwork credits](CREDITS.md) and [third-party software notices](THIRD_PARTY_NOTICES.md)

This repository contains the distribution scripts and user documentation.
The application is provided as prebuilt releases. The internal plugin ID and
service paths retain the earlier name `grove` for compatibility.
