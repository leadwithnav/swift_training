#!/bin/bash
# ==============================================================================
# Solution script for Lab_resource_availability_challenge
# ==============================================================================

echo "=== 1. Fixing Ticket 1: Applying valid dev-app deployment within LimitRange ==="
kubectl apply -f solution/incident1-app.yaml

echo "=== 2. Fixing Ticket 2: Applying web deployment with CPU requests for HPA ==="
kubectl apply -f solution/incident2-web.yaml
kubectl apply -f solution/incident2-hpa.yaml

echo "=== 3. Fixing Ticket 3: Applying updated PDB with minAvailable: 2 ==="
kubectl apply -f solution/incident3-pdb.yaml

echo "=== Solution Applied Successfully! ==="
kubectl get pods,hpa,pdb,limitrange -n production
