Overnight
=

This repository provides a Ruby gem to monitor an instance of [Nightscout](https://nightscout.github.io/) and send notifications of any issues via [Pushover](https://pushover.net/). It can integrate with an instance of Nightscout either [installed locally](https://github.com/swebster/nightscout-installer) or hosted on a remote server. It is designed to run in a rootless container under [Podman](https://podman.io/) as a service managed by systemd.

## Prerequisites

You need a Linux server (or virtual machine) to run the various scripts included in this repository. They have been tested on Ubuntu and Fedora, so derivatives of those distros are likely to work too. All intended recipients of Pushover notifications must have a [licensed copy of Pushover](https://pushover.net/pricing) installed, and you will need to generate an [API token](https://pushover.net/api#registration) and a [user (or group) identifier](https://pushover.net/api#identifiers) as well.

# Configuration

- Ensure that [Task](https://taskfile.dev/installation/) is installed
- Switch to a user account that has been [configured to run rootless Podman](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md#etcsubuid-and-etcsubgid-configuration), such as the podman user created by [this Nightscout installer](https://github.com/swebster/nightscout-installer/blob/main/bootstrap.sh)
- Clone this repository and cd to the working directory
- Run ```task podman:run -- bin/overnight --push-notifications --log```
- Respond to the prompts requesting your Nightscout details, Pushover tokens, etc.

If all goes well, you should see several values from Nightscout logged to the console every five minutes. If not, double-check the contents of the generated .env.local and .env.secrets config files. If you find any errors, correct the config files directly and then run ```podman secret rm nightscout_user pushover_user_key pushover_app_token``` before retrying the podman:run task listed above.

Stop the running container with Ctrl+C before proceeding to the next section.

# Installation

- Delete the contents of the generated secrets file with ```truncate -s 0 .env.secrets```
- Run ```task service:install``` to install the service with the same settings you just tested
- Run ```systemctl --user status overnight``` to verify that the service is up and running

# Uninstallation

You can uninstall the service at any time by running ```task service:uninstall``` as your rootless Podman user.
