#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
readonly ENV_LOCAL="${SCRIPT_DIR}/.env.local"
readonly TMP_LOCAL="${ENV_LOCAL}.tmp"
readonly DEFAULT_PORT=443
trap 'rm -f ${TMP_LOCAL}' EXIT

function config_nightscout_host() {
  read -rp "Enter your Nightscout hostname: " nightscout_host
  echo "NIGHTSCOUT_HOST=${nightscout_host}"
}

function config_nightscout_port() {
  read -rp "Enter your Nightscout port [${DEFAULT_PORT}]: " nightscout_port
  nightscout_port=${nightscout_port:-$DEFAULT_PORT}
  echo "NIGHTSCOUT_PORT=${nightscout_port}"
}

function config_timezone() {
  local -r default_timezone=$(timedatectl show | sed -ne 's/^Timezone=//p')
  read -rp "Enter your local timezone [${default_timezone}]: " timezone
  timezone=${timezone:-$default_timezone}
  echo "TZ=${timezone}"
}

if [[ ! -f "${ENV_LOCAL}" ]]; then
  config_nightscout_host
  config_nightscout_port
  config_timezone

  printf '%s=%s\n' \
    NIGHTSCOUT_HOST "${nightscout_host}" \
    NIGHTSCOUT_PORT "${nightscout_port}" \
    TZ "${timezone}" \
    > "${TMP_LOCAL}"

  # exclude the default port from the configuration file
  grep -xv "NIGHTSCOUT_PORT=${DEFAULT_PORT}" "${TMP_LOCAL}" > "${ENV_LOCAL}"
fi
