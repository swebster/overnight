Overnight
=

This repository provides a Ruby gem to monitor an instance of [Nightscout](https://nightscout.github.io/) and send notifications of any issues via [Pushover](https://pushover.net/). It can integrate with an instance of Nightscout either [installed locally](https://github.com/swebster/nightscout-installer) or hosted on a remote server. It is designed to run in a rootless container under [Podman](https://podman.io/) as a service managed by systemd.

## Prerequisites

You need a Linux server (or virtual machine) to run the various scripts included in this repository. They have been tested on Ubuntu and Fedora, so derivatives of those distros are likely to work too. All intended recipients of Pushover notifications must have a [licensed copy of Pushover](https://pushover.net/pricing) installed, and you will need to generate an [API token](https://pushover.net/api#registration) and copy your [user key](https://pushover.net/api#identifiers) from the [Pushover dashboard](https://pushover.net/dashboard).

# Configuration

- Ensure that [Task](https://taskfile.dev/installation/) is installed
- Switch to a user account that has been [configured to run rootless Podman](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md#etcsubuid-and-etcsubgid-configuration), such as the podman user created by [this Nightscout installer](https://github.com/swebster/nightscout-installer/blob/main/bootstrap.sh)
- Clone this repository and cd to the working directory
- Run ```task overnight:run -- --push-notifications --log```
- Respond to the prompts requesting your Nightscout details, Pushover tokens, etc.

If all goes well, you should see several values from Nightscout logged to the console every five minutes. If not, double-check the contents of the generated .env.local and .env.secrets config files. If you find any errors, correct the config files directly and then run ```podman secret rm nightscout_user pushover_user_key pushover_app_token``` before retrying the overnight:run task listed above.

Stop the running container with Ctrl+C before proceeding to the next section.

## Group Notifications (optional)

The default configuration will send Pushover notifications to a single user. If you want to send notifications to a group (e.g. family members), you should first identify their individual user keys (in the Settings tab of the Pushover app). Then perform the following:

- Run ```task pushover:groups -- --group GROUP_NAME``` to create the group GROUP_NAME
- Run ```task pushover:groups -- --group GROUP_NAME --user USER_KEY --name USER_NAME``` to add each user
- Edit the .env.secrets file and assign PUSHOVER_USER_KEY the new group key instead of your user key
- Run ```podman secret rm pushover_user_key``` and then try the overnight:run task again

# Installation

- Delete the contents of the generated secrets file with ```truncate -s 0 .env.secrets```
- Run ```task service:install``` to install the service with the same settings you just tested
- Run ```systemctl --user status overnight``` to verify that the service is up and running

# Uninstallation

You can uninstall the service at any time by running ```task service:uninstall``` as your rootless Podman user.
