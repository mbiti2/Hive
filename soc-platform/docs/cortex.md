# Cortex Configuration

Cortex allows SOC analysts to run automated analyzers against observables (IPs, hashes, domains) collected during incident response.

## Analyzers

Analyzers are scripts (mostly Python) that query third-party services like VirusTotal, AbuseIPDB, or MISP.

In this deployment:
- Cortex is configured to store analyzers in the PVC mapped to `/opt/cortex/analyzers`.
- You will need to clone the official Cortex-Analyzers repository into this path.

**To initialize analyzers (Post-Deployment):**
1. Exec into the Cortex pod:
   ```bash
   kubectl exec -it deployment/cortex -n soc -- bash
   ```
2. Clone the repository into the analyzers directory:
   ```bash
   cd /opt/cortex/analyzers
   git clone https://github.com/TheHive-Project/Cortex-Analyzers.git .
   ```
3. Refresh the analyzers in the Cortex UI.

## Integration with TheHive
Once Cortex is running and configured, go to TheHive UI -> Organization -> Cortex -> Add Cortex Server.
URL: `http://cortex:9001`
Provide an API key generated from the Cortex UI.
