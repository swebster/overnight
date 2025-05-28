#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
readonly ENV_LOCAL="${SCRIPT_DIR}/.env.local"
readonly SECRETS_TEMPLATE="${SCRIPT_DIR}/.env.secrets.template"
readonly SECRET_OPTS='uid=101,gid=101,mode=0400'

function set_local() {
  if [[ -f "${ENV_LOCAL}" ]]; then
    sed -e 's/^/--env /g' "${ENV_LOCAL}"
  fi
}

function add_secrets() {
  local -r secrets=($(awk -F= '{print tolower($1)}' "${SECRETS_TEMPLATE}"))
  for secret in "${secrets[@]}"; do
    SECRET=$(echo "$secret" | awk '{print toupper($0)}')
    printf -- "--env ${SECRET}_FILE=/run/secrets/$secret --secret $secret,$SECRET_OPTS\n"
  done
}

# convert local and secret env vars into 'podman run' options
{ set_local; add_secrets; } | paste -s -d ' '
