# SOC Platform (Wazuh + TheHive + Cortex)

This repository contains a complete Helm-based deployment for a SOC platform integrating Wazuh, TheHive 5.6, and Cortex 3.x into a Kubernetes cluster.

## Architecture

1. **Wazuh**: Handles agent communication, rule evaluation, and log indexing (deployed separately in `wazuh` namespace).
2. **Webhook Adapter**: A custom Python Flask application that receives Wazuh alerts via webhook, translates them, and pushes them to TheHive as alerts.
3. **TheHive 5.6**: Security Incident Response Platform. Connects to Cassandra (for data storage) and the Wazuh Indexer (for search).
4. **Cortex 3.x**: Observable analysis and active response engine. Connects to Cassandra and Wazuh Indexer.
5. **Cassandra**: NoSQL database used as the primary data store for both TheHive and Cortex.

## Directory Structure

* `charts/`: Contains the Helm charts for TheHive, Cortex, and Webhook Adapter.
* `environments/`: Contains values overrides for different environments (e.g., dev, lab).
* `scripts/`: Helper scripts to install, uninstall, and verify the deployment.
* `docs/`: Detailed architectural and deployment documentation.

## Getting Started

Refer to `docs/deployment.md` for full installation instructions.

1. Review `environments/lab/values.yaml` and adjust settings as necessary.
2. Run `./scripts/install.sh` to build the adapter image, deploy Cassandra, and install the SOC components.
3. Follow the steps in `docs/wazuh-integration.md` to configure Wazuh to send alerts to the new webhook adapter.

## GitOps / ArgoCD

The structure of this repository is designed to be easily compatible with GitOps tools like Argo CD. See `docs/deployment.md` for more details on integrating this repo with an Argo CD application.
