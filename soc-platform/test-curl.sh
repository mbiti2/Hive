#!/bin/bash
kubectl exec -n soc debug-curl -- curl -X POST -H "Content-Type: application/json" -d '{"rule": {"level": 12,"description": "SSH Brute Force Attack Detected"},"agent": {"id": "001","name": "ubuntu-server-prod"},"location": "/var/log/auth.log","full_log": "Failed password for root from 192.168.1.100 port 54321 ssh2"}' http://webhook-adapter:5000/webhook
