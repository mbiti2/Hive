# Architecture

This document describes the architecture of the SOC platform integrating Wazuh, TheHive, and Cortex.

## Components

1. **Wazuh**: Central log collection, rule evaluation, and indexing (Elasticsearch/OpenSearch).
2. **Webhook Adapter**: Custom Python application. It bridges the gap between Wazuh and TheHive by converting Wazuh webhooks into TheHive alerts.
3. **TheHive**: Security Incident Response platform where analysts manage cases, alerts, and observables.
4. **Cortex**: Analysis engine used by TheHive to query external threat intelligence feeds (e.g., VirusTotal, MISP) and run active responses.
5. **Cassandra**: NoSQL database holding the graph and state data for both TheHive and Cortex.

## Data Flow

1. **Detection**: Wazuh Agent sends logs to Wazuh Manager.
2. **Alerting**: Wazuh Manager evaluates rules. If an alert threshold is met, it triggers an integration block configured for our Webhook Adapter.
3. **Translation**: The Webhook Adapter receives the JSON payload, formats the description, maps severity levels, and creates a REST API call to TheHive.
4. **Case Management**: TheHive receives the alert. An analyst can convert it to a case.
5. **Enrichment**: Observables extracted from the Wazuh alert (IPs, hashes) are sent from TheHive to Cortex. Cortex runs analyzers and returns reports to TheHive.

## Kubernetes Deployment

- **Namespaces**: Wazuh remains in the `wazuh` namespace. The rest of the stack goes to `soc`.
- **Storage**: Cassandra, TheHive (for attachments), and Cortex (for analyzers) use Persistent Volume Claims (PVCs) for data persistence.
- **Networking**: Ingress resources expose TheHive and Cortex UIs, while internal ClusterIP services route traffic between Cortex, TheHive, Cassandra, and the Webhook Adapter.
