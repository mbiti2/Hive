#!/bin/bash

NAMESPACE="soc"

# Ensure we are running from the soc-platform root directory
cd "$(dirname "$0")/.."


echo "Checking Pods in namespace $NAMESPACE..."
kubectl get pods -n $NAMESPACE

echo ""
echo "Checking Services in namespace $NAMESPACE..."
kubectl get svc -n $NAMESPACE

echo ""
echo "Checking PVCs in namespace $NAMESPACE..."
kubectl get pvc -n $NAMESPACE

echo ""
echo "Checking Ingress in namespace $NAMESPACE..."
kubectl get ingress -n $NAMESPACE
