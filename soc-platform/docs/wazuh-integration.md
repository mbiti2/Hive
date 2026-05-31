# Wazuh Integration

To forward Wazuh alerts to TheHive, we use the `webhook-adapter` deployed in the `soc` namespace.

## Wazuh Configuration

You must modify the Wazuh Manager configuration (`ossec.conf`). If Wazuh is deployed via Helm, this is likely managed in a ConfigMap or through the Wazuh Helm values.

Add the following `<integration>` block:

```xml
  <integration>
    <name>custom-webhook</name>
    <hook_url>http://webhook-adapter.soc.svc.cluster.local:5000/webhook</hook_url>
    <level>5</level>
    <alert_format>json</alert_format>
  </integration>
```

- `hook_url`: The internal Kubernetes DNS address of our webhook adapter service.
- `level`: Only forward alerts with a level of 5 or higher (adjust based on your noise tolerance).

After updating `ossec.conf`, restart the Wazuh Manager:
```bash
# If using kubernetes:
kubectl rollout restart statefulset wazuh-manager-master -n wazuh
```

## How it works

1. Wazuh generates an alert.
2. The `<integration>` block pushes the JSON to the webhook adapter.
3. The Python Flask app parses the JSON, structures it into TheHive's format, and POSTs it to TheHive API.
4. The alert appears in TheHive.
