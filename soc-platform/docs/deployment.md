# Deployment Guide

## Prerequisites
- A running Kubernetes cluster (k3s, minikube, or managed K8s)
- Helm 3 installed
- `kubectl` configured
- Wazuh already deployed (specifically, the Wazuh Indexer)

## Installation

1. **Configure Environment:**
   Review and modify `environments/lab/values.yaml` (or `dev/values.yaml`).
   Ensure that the `thehive.elasticsearch` and `cortex.elasticsearch` host and credentials match your Wazuh Indexer deployment.
   Update the `webhook-adapter.thehive.apikey` with a valid API key. Since you cannot generate an API key until TheHive is running, you have two options:
   - **Option A (Two-step deployment):** Deploy the stack as-is. The webhook-adapter will be deployed but will fail to authenticate with TheHive. Once TheHive is up, log in, generate an API key (see `docs/thehive.md`), update the values file, and run the Helm upgrade command below.
   - **Option B (Phased deployment):** Comment out the webhook-adapter from `install.sh`, deploy the stack, generate the API key, add it to your values file, uncomment the webhook-adapter from `install.sh`, and run it.

2. **Run Install Script:**
   ```bash
   ./scripts/install.sh
   ```
   This script will:
   - Create the `soc` namespace
   - Add the Bitnami repo and deploy Cassandra
   - Deploy TheHive and Cortex
   - Deploy the Webhook Adapter (which will loop/fail until the API key is provided and upgraded)

## Upgrade Process

To upgrade an existing deployment with new configuration:
```bash
helm upgrade thehive ./charts/thehive -n soc -f environments/lab/values.yaml
```

## Troubleshooting

- **Pods Pending**: Check PVC bindings. You may need to specify a `storageClass` in `values.yaml` if your cluster doesn't have a default.
- **TheHive/Cortex Fails to Start**: 
  - Ensure Cassandra is fully ready before TheHive/Cortex starts.
  - Verify the `application-secret` is at least 64 characters long.
  - Verify connectivity to the Wazuh indexer.

## Future Argo CD Deployment

This repository structure is ready for GitOps with Argo CD.
To deploy via Argo CD:
1. Commit this structure to a Git repository.
2. Create an Argo CD `Application` custom resource pointing to the `charts/thehive`, `charts/cortex`, etc.
3. Use the "Helm" source type in Argo CD and pass the values from `environments/lab/values.yaml`.
