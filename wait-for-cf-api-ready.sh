#!/bin/bash

set -eu

export TIMEOUT=${TIMEOUT:-1800}
export POLLING=${POLLING:-5}

export CF_API=${CF_API:-https://api.$CF_SYSTEM_DOMAIN}
export CF_USERNAME=${CF_USERNAME:-admin}

[[ -n "${ROUTER_IP_ENVVAR:-}" && -n "${CF_SYSTEM_DOMAIN:-}" ]] && {
  echo "Setting up /etc/hosts to *.${CF_SYSTEM_DOMAIN}..."
  eval "export router_ip=\"\$$ROUTER_IP_ENVVAR\"" # works on alpine
  {
    echo "${router_ip}  login.${CF_SYSTEM_DOMAIN}"
    echo "${router_ip}  api.${CF_SYSTEM_DOMAIN}"
    echo "${router_ip}  uaa.${CF_SYSTEM_DOMAIN}"
  } >> /etc/hosts
}

checkCFAPI() {
  cf api "$CF_API" ${CF_SKIP_SSL_VALIDATION:+--skip-ssl-validation} >/dev/null 2>&1
}
export -f checkCFAPI

waitForCloudFoundry() {
  checkCFAPI && { echo "$CF_API already available"; return 0; }
  echo "Waiting for $CF_API for ${TIMEOUT}s:"
  until checkCFAPI; do
    printf "."
    sleep "${POLLING}"
  done;
}

export -f waitForCloudFoundry
timeout "${TIMEOUT}" bash -c waitForCloudFoundry

echo "Using \$CF_HOME ${CF_HOME:-~/.cf}"
cf api \
  "$CF_API" \
  ${CF_SKIP_SSL_VALIDATION:+--skip-ssl-validation}

cf auth \
  "${CF_USERNAME:?required}" \
  "${CF_PASSWORD:?required}" \
  ${CF_CLIENT_CREDENTIALS:+--client-credentials}

# target org/space with $CF_ORG/$CF_SPACE
cf target \
  ${CF_ORG:+-o $CF_ORG} \
  ${CF_ORGANIZATION:+-o $CF_ORGANIZATION} \
  ${CF_SPACE:+-s $CF_SPACE}

