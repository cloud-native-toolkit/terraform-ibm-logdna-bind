#!/usr/bin/env bash

KUBECONFIG=$(cat ./kubeconfig)

echo "Checking for logdna-agent daemonset"
if ! kubectl get daemonset logdna-agent -n ibm-observe; then
  echo "logdna-agent daemonset not found"
  exit 1
fi

echo "Checking logdna-agent pod status"
if ! kubectl rollout status daemonset/logdna-agent -n ibm-observe; then
  echo "daemonset/logdna-agent rollout status error"
  exit 1
fi
