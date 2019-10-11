#!/bin/bash

set -eu

: "${CF_API:?required}"

[[ -n "${ROUTER_IP_ENVVAR:-}" && -n "${CF_SYSTEM_DOMAIN:-}" ]] && {
  echo "Setting up /etc/hosts to *.${CF_SYSTEM_DOMAIN}..."
  eval "export router_ip=\"\$$ROUTER_IP_ENVVAR\"" # works on alpine
  {
    echo "${router_ip}  login.${CF_SYSTEM_DOMAIN}"
    echo "${router_ip}  api.${CF_SYSTEM_DOMAIN}"
    echo "${router_ip}  uaa.${CF_SYSTEM_DOMAIN}"
  } >> /etc/hosts
}

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

