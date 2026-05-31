#!/bin/bash

NAMESPACE="soc"

# Ensure we are running from the soc-platform root directory
cd "$(dirname "$0")/.."


echo "Uninstalling SOC Platform from namespace: $NAMESPACE..."

helm uninstall webhook-adapter --namespace $NAMESPACE || true
helm uninstall cortex --namespace $NAMESPACE || true
helm uninstall thehive --namespace $NAMESPACE || true
helm uninstall cassandra --namespace $NAMESPACE || true

echo "Removing namespace $NAMESPACE (this will delete PVCs if not retained)..."
kubectl delete namespace $NAMESPACE

echo "Uninstall complete."
