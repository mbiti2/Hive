#!/bin/bash
set -e

NAMESPACE="soc"
ENV="lab"

# Ensure we are running from the soc-platform root directory
cd "$(dirname "$0")/.."

# Helper: roll back any stuck pending/failed release before upgrading
# Usage: helm_safe_upgrade <release-name> <chart> [extra helm args...]
helm_safe_upgrade() {
  local release="$1"
  shift
  local status
  status=$(helm status "$release" -n "$NAMESPACE" -o json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['info']['status'])" 2>/dev/null || echo "not-found")
  if [[ "$status" == "pending-install" || "$status" == "pending-upgrade" || "$status" == "pending-rollback" ]]; then
    echo "  Release '$release' is stuck in state '$status' — rolling back..."
    helm rollback "$release" -n "$NAMESPACE" --wait 2>/dev/null || \
      helm delete "$release" -n "$NAMESPACE" --no-hooks 2>/dev/null || true
  elif [[ "$status" == "failed" ]]; then
    echo "  Release '$release' is in failed state — rolling back..."
    helm rollback "$release" -n "$NAMESPACE" --wait 2>/dev/null || \
      helm delete "$release" -n "$NAMESPACE" --no-hooks 2>/dev/null || true
  fi
  helm upgrade --install "$release" "$@"
}


echo "Deploying SOC Platform to namespace: $NAMESPACE using $ENV environment..."

# 1. Create Namespace
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# 2. Add Bitnami Repo for Cassandra
# echo "Adding Bitnami Helm repository..."
# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm repo update

# 3. Deploy Cassandra
# echo "Deploying Cassandra..."
# helm_safe_upgrade cassandra bitnami/cassandra \
#   --version 12.3.9 \
#   --namespace $NAMESPACE \
#   -f environments/$ENV/cassandra.yaml \
#   --wait --timeout 10m

# 4. Build and Push Webhook Adapter Image
# Note: Assuming local k3s for lab. In prod, push to a registry.
echo "Building Webhook Adapter Docker Image..."
cd charts/webhook-adapter/app
docker build -t webhook-adapter:latest .
cd ../../../

# Load the image into k3s (if using k3s without a registry)
echo "Loading webhook adapter image into k3s..."
if docker save webhook-adapter:latest | k3s ctr images import -; then
  echo "Webhook adapter image loaded into k3s."
else
  echo "Warning: Could not load image into k3s automatically."
  echo "Try manually: docker save webhook-adapter:latest | k3s ctr images import -"
fi

# 5. Deploy TheHive
echo "Deploying TheHive..."
helm_safe_upgrade thehive ./charts/thehive \
  --namespace $NAMESPACE \
  -f environments/$ENV/thehive.yaml \
  --wait --timeout 10m

# 6. Deploy Cortex
echo "Deploying Cortex..."
helm_safe_upgrade cortex ./charts/cortex \
  --namespace $NAMESPACE \
  -f environments/$ENV/cortex.yaml \
  --wait --timeout 10m

# 7. Deploy Webhook Adapter
echo "Deploying Webhook Adapter..."
helm_safe_upgrade webhook-adapter ./charts/webhook-adapter \
  --namespace $NAMESPACE \
  -f environments/$ENV/webhook-adapter.yaml \
  --wait --timeout 5m

echo "SOC Platform deployment complete."
echo "Run ./scripts/verify.sh to check the status."
