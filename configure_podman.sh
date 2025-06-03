#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
readonly ENV_LOCAL="${SCRIPT_DIR}/.env.local"
readonly SECRETS_TEMPLATE="${SCRIPT_DIR}/.env.secrets.template"
readonly SECRET_OPTS='uid=101,gid=101,mode=0400'
readonly PODMAN_MIN_VER=5.3
readonly PODMAN_OPTIONS_FILE="${SCRIPT_DIR}/.task/podman_run.options"
readonly PODMAN_OPTIONS_TMP="${PODMAN_OPTIONS_FILE%.options}.tmp"
trap 'rm -f ${PODMAN_OPTIONS_TMP}' EXIT

function supports_host_gateway() {
  local -r podman_version=$(podman --version | \
    sed -E 's/podman version ([0-9]+\.[0-9]+).*/\1/')

  # check that this version is greater than the minimum supported version
  printf '%s\n' $PODMAN_MIN_VER "$podman_version" | sort -C -V
}

function service_exists () {
  systemctl --user list-unit-files "$1.service" &>/dev/null
}

function add_host_gateway () {
  read -rp 'Are you installing this service on your Nightscout server? [y/N] ' response
  response=${response,,} # to lowercase
  if [[ "$response" =~ ^(yes|y)$ ]]; then
    if ! supports_host_gateway; then
      # refer to https://github.com/eriksjolund/podman-networking-docs for alternatives
      printf >&2 "Please upgrade podman to at least version %s before you continue.\n" \
        $PODMAN_MIN_VER
      exit 1
    fi

    if ! service_exists 'nightscout' || ! service_exists 'caddy'; then
      printf >&2 'Please install Nightscout (and caddy) before you continue.\n'
      exit 1
    fi

    NIGHTSCOUT_HOST="$(sed -n 's/^NIGHTSCOUT_HOST=//p' .env.local)"
    printf -- "--add-host %s:host-gateway\n" "$NIGHTSCOUT_HOST"
  fi
}

function name_container() {
  echo '--name overnight'
}

function set_environment() {
  sed -e '/^$/D;s/^/--env /g' "$ENV_LOCAL"
  mapfile -t secret_names < <(cut -d= -f1 "$SECRETS_TEMPLATE")
  for SECRET in "${secret_names[@]}"; do
    secret=$(echo "$SECRET" | awk '{print tolower($0)}')

    printf -- "--env %s_FILE=/run/secrets/%s\n--secret %s,%s\n" \
      "$SECRET" "$secret" "$secret" $SECRET_OPTS
  done
}

if [[ ! -f "$ENV_LOCAL" ]]; then
  printf "%s does not exist. Please generate it then try again.\n" "$ENV_LOCAL"
  exit 1
fi

# determine the relevant 'podman run' options and write them to a file
add_host_gateway > "$PODMAN_OPTIONS_TMP"
name_container  >> "$PODMAN_OPTIONS_TMP"
set_environment >> "$PODMAN_OPTIONS_TMP"

sort "$PODMAN_OPTIONS_TMP" > "$PODMAN_OPTIONS_FILE"
