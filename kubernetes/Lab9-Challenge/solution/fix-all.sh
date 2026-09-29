#!/bin/bash
# ==============================================================================
# Solution script for Lab9-Challenge
# ==============================================================================

echo "=== Fixing Ticket 1: Replacing Deployment with StatefulSet ==="
kubectl delete deployment legacy-db-dep -n lab9-challenge --ignore-not-found
kubectl delete pvc shared-db-pvc -n lab9-challenge --ignore-not-found
kubectl apply -f solution/ticket1-db-statefulset.yaml

echo "=== Fixing Ticket 2: Correcting Headless Service Selector ==="
kubectl apply -f solution/ticket2-headless-svc.yaml

echo "=== Fixing Ticket 3: Applying valid MongoCluster CR ==="
kubectl apply -f solution/ticket3-database-cr.yaml

echo "=== Verification ==="
sleep 3
kubectl get statefulset,pods,svc,endpoints,mongocluster -n lab9-challenge
