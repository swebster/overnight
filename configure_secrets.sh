#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
readonly ENV_SECRETS="${SCRIPT_DIR}/.env.secrets"
readonly TMP_SECRETS="${ENV_SECRETS}.tmp"
trap 'rm -f ${TMP_SECRETS}' EXIT

function config_nightscout_user() {
  read -rp "Enter your Nightscout user: " nightscout_user
  echo "NIGHTSCOUT_USER=${nightscout_user}"
}

function config_pushover_app_token() {
  read -rp "Enter your Pushover app token: " pushover_app_token
  echo "PUSHOVER_APP_TOKEN=${pushover_app_token}"
}

function config_pushover_user_key() {
  read -rp "Enter your Pushover user key: " pushover_user_key
  echo "PUSHOVER_USER_KEY=${pushover_user_key}"
}

if [[ ! -f "${ENV_SECRETS}" ]]; then
  grep COMPOSE_FILE "${ENV_SECRETS}.template" > "${TMP_SECRETS}"

  config_nightscout_user
  config_pushover_app_token
  config_pushover_user_key

  printf '%s=%s\n' \
    NIGHTSCOUT_USER "${nightscout_user}" \
    PUSHOVER_APP_TOKEN "${pushover_app_token}" \
    PUSHOVER_USER_KEY "${pushover_user_key}" \
    > "${TMP_SECRETS}"

  mv -f "${TMP_SECRETS}" "${ENV_SECRETS}"
  chmod 0600 "${ENV_SECRETS}"
fi
