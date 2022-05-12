#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
MODULE_DIR=$(cd ${SCRIPT_DIR}/..; pwd -P)

CLUSTER_ID="$1"
INSTANCE_ID="$2"
INGESTION_KEY="$3"
PRIVATE="${4:-false}"

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if [[ -z "${IBMCLOUD_API_KEY}" ]]; then
  echo "IBMCLOUD_API_KEY must be provided as an environment variable" >&2
  exit 1
fi

TOKEN_RESULT=$(curl -s -X POST "https://iam.cloud.ibm.com/identity/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=${IBMCLOUD_API_KEY}")
TOKEN=$(echo "${TOKEN_RESULT}" | jq -r '.access_token')
REFRESH_TOKEN=$(echo "${TOKEN_RESULT}" | jq -r '.refresh_token')

BASE_URL="https://containers.cloud.ibm.com/global/v2/observe/logging"

echo "Configuring LogDNA for ${CLUSTER_ID} cluster and ${INSTANCE_ID} LogDNA instance"

EXISTING_INSTANCE_ID=$(curl -s -X GET "${BASE_URL}/getConfigs?query=${CLUSTER_ID}" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "X-Auth-Refresh-Token: ${REFRESH_TOKEN}" \
  jq -r '.[] | .instanceId // empty')

echo "Existing instance id: ${EXISTING_INSTANCE_ID}"

if [[ -n "${EXISTING_INSTANCE_ID}" ]]; then
  if [[ "${EXISTING_INSTANCE_ID}" == "${INSTANCE_ID}" ]]; then
    echo "LogDNA configuration already exists on this cluster"
    exit 0
  else
    echo "Existing LogDNA configuration found on this cluster for a different LogDNA instance: ${EXISTING_INSTANCE_ID}."
    echo "Removing the config before creating the new one"

    curl -s -X POST "${URL}/removeConfig" \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      -H "X-Auth-Refresh-Token: ${REFRESH_TOKEN}" \
      -d $(jq -n --arg CLUSTER "${CLUSTER_ID}" --arg INSTANCE "${EXISTING_INSTANCE_ID}" '{"cluster": $CLUSTER, "instance": $INSTANCE}')

    echo "  Waiting for the old configuration to be removed..."
    while true; do
      RESPONSE=$(curl -s -X GET "${BASE_URL}/getConfigs?query=${CLUSTER_ID}" \
                   -H "Authorization: Bearer ${TOKEN}" \
                   -H "X-Auth-Refresh-Token: ${REFRESH_TOKEN}" \
                   jq -r '.[] | .instanceId // empty')

      if [[ -z "${RESPONSE}" ]]; then
        echo "    LogDNA instances removed"
        break
      else
        echo "    LogDNA instance still exists. Waiting..."
        echo "    ${RESPONSE}"
        sleep 30
      fi
    done
  fi
else
  echo "No existing logging config found for ${CLUSTER_ID} cluster"
fi

set -e

echo "Creating LogDNA configuration for ${CLUSTER_ID} cluster and ${INSTANCE_ID} LogDNA instance"
curl -s -X POST "${URL}/createConfig" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "X-Auth-Refresh-Token: ${REFRESH_TOKEN}" \
  -H "Content-Type: application/json" \
  -d $(jq -n --arg CLUSTER "${CLUSTER_ID}" --arg INGESTION "${INGESTION_KEY}" --arg INSTANCE "${INSTANCE_ID}" --argjson PRIVATE "${PRIVATE}" '{"cluster": $CLUSTER, "instance": $INSTANCE, "ingestionKey": $INGESTION, "privateEndpoint": $PRIVATE}')
