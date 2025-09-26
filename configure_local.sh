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

function config_overnight_override() {
  cat <<- EOF
		If you have configured a custom override in Loop for exercise, overnight can
		suppress notifications about high blood glucose when that override is active.
	EOF
  read -rp "Enter the name of your override to enable this behaviour: " high_override
  echo "OVERNIGHT_HIGH_OVERRIDE=${high_override}"
}

function config_overnight_begin() {
  local -r default_begin=23
  read -rp "Start priority monitoring at hour [${default_begin}]: " overnight_begin
  overnight_begin=${overnight_begin:-$default_begin}
  printf 'OVERNIGHT_PERIOD_BEGIN=%02d:00\n' "${overnight_begin}"
}

function config_overnight_end() {
  local -r default_end=7
  read -rp "Stop priority monitoring at hour [${default_end}]: " overnight_end
  overnight_end=${overnight_end:-$default_end}
  printf 'OVERNIGHT_PERIOD_END=%02d:00\n' "${overnight_end}"
}

function config_timezone() {
  local -r default_timezone=$(timedatectl show | sed -ne 's/^Timezone=//p')
  read -rp "Enter your local timezone [${default_timezone}]: " timezone
  timezone=${timezone:-$default_timezone}
  echo "TZ=${timezone}"
}

config_nightscout_host
config_nightscout_port
config_overnight_override
config_overnight_begin
config_overnight_end
config_timezone

printf '%s=%s\n' \
  NIGHTSCOUT_HOST "${nightscout_host}" \
  NIGHTSCOUT_PORT "${nightscout_port}" \
  OVERNIGHT_HIGH_OVERRIDE "${high_override}" \
  OVERNIGHT_PERIOD_BEGIN "${overnight_begin}" \
  OVERNIGHT_PERIOD_END "${overnight_end}" \
  TZ "${timezone}" \
  > "${TMP_LOCAL}"

# exclude the default port and any empty override from the configuration file
grep -xv \
  -e "NIGHTSCOUT_PORT=${DEFAULT_PORT}" \
  -e "OVERNIGHT_HIGH_OVERRIDE=" \
  "${TMP_LOCAL}" > "${ENV_LOCAL}"
