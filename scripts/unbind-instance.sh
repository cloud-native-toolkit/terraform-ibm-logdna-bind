#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
MODULE_DIR=$(cd ${SCRIPT_DIR}/..; pwd -P)

CLUSTER_ID="$1"
INSTANCE_ID="$2"

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if [[ -z "${IBMCLOUD_API_KEY}" ]]; then
  echo "IBMCLOUD_API_KEY must be provided as an environment variable" >&2
  exit 1
fi

export TOKEN=$(curl -s -X POST "https://iam.cloud.ibm.com/identity/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=${IBMCLOUD_API_KEY}" | jq -r '.access_token')

curl -s -X POST "${URL}/removeConfig" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d $(jq -n --arg CLUSTER "${CLUSTER_ID}" --arg INSTANCE "${INSTANCE_ID}" '{"cluster": $CLUSTER, "instance": $INSTANCE}')

echo "  Waiting for the instance to be removed..."
while true; do
  RESPONSE=$(curl -s -X GET "${BASE_URL}/getConfigs?query=${CLUSTER_ID}" \
               -H "Authorization: Bearer ${TOKEN}" \
               jq -r '.[] | .instanceId // empty')

  if [[ -z "${RESPONSE}" ]]; then
    echo "    LogDNA instances removed"
    break
  else
    echo "    LogDNA instance still exists. Waiting..."
    sleep 30
  fi
done
