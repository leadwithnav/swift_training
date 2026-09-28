#!/bin/bash
# ==============================================================================
# Troubleshooting Challenge Setup Script
# ==============================================================================

echo "⚙️ Setting up nodes (Labels & Taints)..."
kubectl label nodes minikube-m02 tier=app-node --overwrite
kubectl label nodes minikube-m03 tier=db-node --overwrite
kubectl taint nodes minikube-m03 dedicated=db:NoSchedule --overwrite

echo "🚀 Deploying broken manifests..."
kubectl apply -f broken_manifests/01-db-deployment.yaml
kubectl apply -f broken_manifests/02-backend-deployment.yaml
kubectl apply -f broken_manifests/03-cache-deployment.yaml
kubectl apply -f broken_manifests/04-frontend-deployment.yaml

echo ""
echo "=============================================================================="
echo "❌ Setup complete! Pods have been deployed."
echo "Run 'kubectl get pods -o wide' to see the pending pods."
echo "Read instructions.md for details on diagnosing and fixing the issues."
echo "=============================================================================="
