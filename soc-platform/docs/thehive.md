# TheHive Configuration

TheHive is a scalable Security Incident Response Platform.

## Initial Setup

On first launch, TheHive will create its database schema in Cassandra and its search indices in the Wazuh indexer.
Default Login:
- Username: `admin@thehive.local`
- Password: `secret` (You will be prompted to change this immediately)

## API Key Generation
To allow the Webhook Adapter to push alerts:
1. Login to TheHive.
2. Go to the Admin panel -> Users.
3. Create a service account (e.g., `wazuh_adapter`) and assign it the `alert` profile.
4. Generate an API Key for this user.
5. Update `environments/lab/values.yaml` (under `webhook-adapter.thehive.apikey`) and run `helm upgrade webhook-adapter` or restart the pod.
