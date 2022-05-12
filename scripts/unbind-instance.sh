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

if [[ -z "${REGION}" ]]; then
  echo "REGION must be provided as an environment variable" >&2
  exit 1
fi

if [[ -z "${RESOURCE_GROUP}" ]]; then
  echo "RESOURCE_GROUP must be provided as an environment variable" >&2
  exit 1
fi

ibmcloud login -r "${REGION}" -g "${RESOURCE_GROUP}"

ibmcloud ob logging config delete \
  --cluster "${CLUSTER_ID}" \
  --instance "${INSTANCE_ID}" \
  --force || \
  echo "Error deleting logging instance from cluster"
