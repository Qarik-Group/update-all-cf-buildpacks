#!/bin/bash

set -eu

export TIMEOUT=${TIMEOUT:-1800}
export POLLING=${POLLING:-5}

export SERVICE_NAME=${SERVICE_NAME:-"scf-router-0"}
export NAMESPACE=${NAMESPACE:-"scf"}
: ${KUBERNETES_SERVICE_HOST:?this script is assumed to be run inside a k8s pod}

checkSvcExists() {
  [[ "$(curl -sk \
      -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
      "https://${KUBERNETES_SERVICE_HOST}/api/v1/namespaces/${NAMESPACE}/services" \
    | jq --arg svc "$SERVICE_NAME" '.items[] | select(.metadata.name == $svc)')X" != "X" ]]
}
export -f checkSvcExists

waitForSvc() {
  checkSvcExists && { echo "$SERVICE_NAME already available"; return 0; }
  echo "Waiting for service $SERVICE_NAME in $NAMESPACE for ${TIMEOUT}s:"
  until checkSvcExists; do
    printf "."
    sleep ${POLLING}
  done;
}

export -f waitForSvc
timeout ${TIMEOUT} bash -c waitForSvc
