# TheHive Presentation

## Introduction
TheHive is an open‑source incident response platform that enables security teams to collaborate on investigations, manage cases, and integrate with other tools such as Wazuh and Cortex. It provides a unified UI for tracking alerts, observables, and response tasks.

## How TheHive Works
1. **Alert Ingestion** – Alerts from sources (e.g., Wazuh) are received via a webhook adapter and transformed into TheHive alerts.
2. **Alert Enrichment** – Observables attached to alerts can be automatically analyzed by Cortex, enriching the data with threat‑intel.
3. **Case Management** – Analysts promote alerts to cases, assign tasks, and document investigations.
4. **Collaboration** – Multiple analysts work on the same case, commenting, attaching files, and updating statuses in real‑time.

## Features of TheHive
- **Case Management**: Centralized creation, tracking, and resolution of incident cases.
- **Alert Ingestion**: Supports multiple sources (Wazuh, Syslog, email, etc.) via webhooks and APIs.
- **Observable Enrichment**: Built‑in integration with Cortex for automatic threat‑intel lookups.
- **Collaboration**: Real‑time comments, file attachments, task assignments, and audit logs.
- **Customizable Workflows**: Define case templates, fields, and state machines to match your SOC processes.
- **Rich API & SDKs**: REST API and client libraries (`thehive4py`) for automation and integrations.
- **Reporting & Dashboards**: Built‑in statistics, charts, and exportable reports.

## Importance of Using Wazuh with TheHive
- **Unified Detection & Response**: Wazuh provides real‑time endpoint detection, while TheHive turns alerts into actionable cases.
- **Automatic Alert Enrichment**: Wazuh alerts are enriched with host, log, and vulnerability data before reaching TheHive.
- **Reduced Mean Time To Detect (MTTD) & Respond (MTTR)**: Correlate alerts, assign tasks, and track remediation in one place.
- **Compliance Support**: Centralized audit trails and evidence collection help meet regulatory requirements.


## Issues with TheHive Versions

### Version 4.x (End‑of‑Support)
- **No maintenance:** Reached End‑of‑Support on 31 Dec 2022 – no bug fixes or security patches.
- **Deprecated `thehive4py` v1 library:** Unmaintained, leads to import failures on newer Python runtimes.
- **Library version conflicts:** Scripts using `thehive4py` v2 are incompatible with a 4.x backend.
- **Wazuh embedded Python environment:** Integration scripts must be installed in `/var/ossec/framework/python/...`; otherwise `ModuleNotFoundError` occurs.
- **Strict parameter requirements:** Older community scripts miss mandatory fields (`type`, `source`, `title`, …) causing HTTP 400/403 errors.

### Version 5.x (Commercial / Freemium)
- **Commercial licensing:** Shifted to a freemium model; free Community License limits deployment to a single node (no HA/cluster).
- **Authentication restrictions:** Free tier only supports local DB auth; SAML/LDAP/SSO require paid enterprise tier.
- **Redesigned `thehive4py` v2 API client:** Complete rewrite; legacy import patterns break and payload format changed.
- **API key vs. username/password:** API now prefers scoped API keys; legacy username/password auth is rejected.
- **Dependency conflicts:** Bundled Java runtime may clash with custom Docker images, causing startup failures.

## Demo Workflow
1. **Trigger a Simulated Alert** – Run the `test‑curl.sh` script to send a fake Wazuh alert to the webhook adapter.
2. **View Alert in TheHive UI** – Open `http://localhost:9000` (or the configured domain) and locate the new alert.
3. **Promote to Case** – Convert the alert into a case, add observables, and launch Cortex analyzers.
4. **Assign Tasks & Remediate** – Create response tasks, assign them to team members, and track progress.
5. **Close the Case** – Once resolved, mark the case as *Resolved* and add a summary.
## Conclusion
Understanding TheHive’s architecture and being aware of version‑specific pitfalls ensures a smooth demo and a reliable incident response workflow.
