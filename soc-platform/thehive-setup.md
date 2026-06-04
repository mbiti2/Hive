# TheHive 5 Initial Setup Guide

If the database is ever wiped or redeployed from scratch, TheHive will require an initial UI setup. This document tracks the exact steps required to initialize the system and generate the API key for the Wazuh Webhook Adapter.

## 1. Initial Login
- **URL**: `http://thehive.lab.local` (or `http://localhost:9000` via port-forward)
- **Default Username**: `admin@thehive.local`
- **Default Password**: `secret`

You will be prompted to change the default password immediately upon your first login.

## 2. Organization Setup
1. On the left sidebar, click on **Management** (building icon) and navigate to **Organisations**.
2. Click the **`+`** button to create a new organization.
3. Name it `Wazuh-SOC` (or any preferred name).

## 3. Webhook User Creation
The webhook adapter needs a dedicated user account with the proper permissions to create alerts.

1. Navigate to the **Users** tab.
2. Click the **`+`** button to create a new user.
3. **Login**: `wazuh-webhook`
4. **Name**: `Wazuh Adapter`
5. **Profile**: `Analyst` *(This profile is required so the webhook has permission to create alerts).*
6. **Organisation**: Assign the user to the `Wazuh-SOC` organization you just created.
7. Set a password for this user.

## 4. API Key Generation
1. Click on the newly created `wazuh-webhook` user in the list to open their profile.
2. Find the **API Key** section (key icon `🗝️`) and click **Create API Key**.
3. Copy the generated alphanumeric string.

## 5. Applying the Key to the Cluster
Once you have the key, update the Kubernetes secret so the webhook adapter can authenticate with TheHive:

```bash
# Replace YOUR_API_KEY with the generated key
kubectl create secret generic webhook-adapter-secret -n soc \
  --from-literal=thehive-apikey="YOUR_API_KEY" \
  --dry-run=client -o yaml | kubectl apply -f -

# Restart the webhook deployment to load the new key
kubectl rollout restart deployment/webhook-adapter -n soc
```
