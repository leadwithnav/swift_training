#!/bin/bash
# ==============================================================================
# Solution script for Lab_affinities_challenge (Troubleshooting Challenge)
# ==============================================================================

echo "=== Applying Solution Manifests to fix all Pending pods ==="
kubectl apply -f solution/01-db-deployment.yaml
kubectl apply -f solution/02-backend-deployment.yaml
kubectl apply -f solution/03-cache-deployment.yaml
kubectl apply -f solution/04-frontend-deployment.yaml

echo "=== Checking Pod Status ==="
sleep 5
kubectl get pods -o wide
