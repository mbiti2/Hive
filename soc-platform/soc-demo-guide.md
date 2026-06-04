# SOC Platform Demo Guide & Workflow

This document explains the architecture flow of the integrated components, outlines the standard Incident Response workflow, and serves as a quick reference for all commands and scripts used during the demonstration.

---

## 1. Architecture Flow: How the Components Work Together

When explaining the platform to your project lead, you can describe the flow of data across the three main components:

1. **Detection (Wazuh):** 
   - Wazuh Agents monitor endpoints (servers, laptops) for malicious activities, configuration changes, or log anomalies.
   - When an event matches a security rule (e.g., multiple failed SSH logins), the Wazuh Manager generates a JSON security alert.

2. **Translation (Webhook Adapter - Python Application):**
   - Because Wazuh and TheHive use different API structures, they cannot talk directly.
   - The **Webhook Adapter** (`charts/webhook-adapter/app/app.py`) acts as the middleware. It is a lightweight Python Flask application that listens on the `/webhook` endpoint.
   - It receives Wazuh's JSON alerts, parses out the critical information (Agent Name, Rule Level, Full Logs), maps Wazuh's rule levels to TheHive's severity scale (1-4), and POSTs the formatted payload to TheHive's REST API using `THEHIVE_API_KEY`.

3. **Aggregation & Incident Response (TheHive):**
   - TheHive receives the formatted payload and generates an **Alert**.
   - This provides the SOC analysts with a single pane of glass to view all security events across the entire infrastructure.

4. **Enrichment (Cortex):**
   - *Note: Cortex is the analysis engine.* When an alert contains "Observables" (like a malicious IP address or file hash), Cortex can be triggered to automatically query external Threat Intelligence feeds (like VirusTotal or MISP) to enrich the alert with context.

---

## 2. Action Items: What Happens After an Alert?

During your demo, once the simulated SSH Brute Force alert appears in TheHive dashboard, you should walk the project lead through the standard **Triage and Response Workflow**:

### Step 1: Triage the Alert
- Click on the new Alert in TheHive's `Alerts` tab.
- Review the details provided by the webhook (Severity, Agent ID, Location, and the Raw Log).
- Determine if this is a **False Positive** (e.g., an administrator accidentally typing the wrong password) or a **True Positive** (an actual attack).

### Step 2: Promote to a Case
- If the alert is deemed a real threat, it must be investigated.
- Click the **Preview** button on the alert, and then click **Import**.
- This promotes the Alert into a **Case**. A Case is an active investigation workspace.
- *Demo Tip: Perform this action live during the presentation!*

### Step 3: Observable Analysis
- Inside the newly created Case, navigate to the **Observables** tab.
- You will see entities like the Attacker's IP Address (e.g., `192.168.1.100`).
- Explain that analysts would select this IP and run **Cortex Analyzers** against it to see if the IP is a known malicious actor on global threat feeds.

### Step 4: Task Assignment & Remediation
- Go to the **Tasks** tab inside the Case.
- Create response tasks for your team. Examples:
  - *"Block IP 192.168.1.100 on the external firewall."*
  - *"Isolate the ubuntu-server-prod agent from the network."*
- Assign these tasks to specific analysts.

### Step 5: Case Closure
- Once the tasks are completed and the threat is neutralized, change the Case status to **Resolved**.
- Provide a closing summary of the actions taken.

---

## 3. Command Reference & Scripts

Below is a cheat sheet of all the commands and scripts used to test and access the platform during the demo.

### The Simulated Alert Script (`test-curl.sh`)
Since we do not have a live Wazuh agent triggering malicious activity during the presentation, we use the `test-curl.sh` script to simulate an attack. 
- **What it does**: It uses the `debug-curl` pod running inside the Kubernetes cluster to send a perfectly crafted "fake" Wazuh JSON payload directly to the Python Webhook Adapter's `/webhook` endpoint.
- **How to use it**: Run the following command from your host machine to inject the alert:
  ```bash
  multipass exec k3s -- sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml bash /home/ubuntu/Projects/wazuh/Hive/soc-platform/test-curl.sh
  ```

### Accessing TheHive UI (Port-Forward)
If you haven't mapped the domain in your `/etc/hosts` file, you can access TheHive UI securely by port-forwarding the service to your local machine:
```bash
multipass exec k3s -- sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl port-forward -n soc svc/thehive 9000:9000
```
*Access at: `http://localhost:9000`*

### Live Tailing Logs (For the Demo Visuals)
It looks highly impressive to have terminal windows open showing the live traffic passing between the components when you trigger the `test-curl.sh` script. 

**Watch the Webhook Adapter parsing the JSON:**
```bash
multipass exec k3s -- sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl logs -n soc deployment/webhook-adapter -f
```

**Watch TheHive receiving the API request:**
```bash
multipass exec k3s -- sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl logs -n soc deployment/thehive -f
```
