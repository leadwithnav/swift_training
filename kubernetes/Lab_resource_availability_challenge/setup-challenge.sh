#!/bin/bash
# ==============================================================================
# Setup script for Kubernetes Production Troubleshooting Challenge
# ==============================================================================

echo "⚙️ Creating production namespace..."
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -

echo "⚙️ Enabling metrics-server addon in Minikube..."
minikube addons enable metrics-server

echo "⚙️ Applying LimitRange policy in production namespace..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: LimitRange
metadata:
  name: app-limits
  namespace: production
spec:
  limits:
  - type: Container
    min:
      cpu: "100m"
    max:
      cpu: "1"
      memory: "1Gi"
    defaultRequest:
      cpu: "200m"
      memory: "256Mi"
    default:
      cpu: "500m"
      memory: "512Mi"
EOF

echo "⚙️ Deploying broken workloads for Incident Ticket 2 & 3..."
kubectl apply -f broken_manifests/incident2-web.yaml
kubectl apply -f broken_manifests/incident2-hpa.yaml
kubectl apply -f broken_manifests/incident3-api.yaml
kubectl apply -f broken_manifests/incident3-pdb.yaml

echo ""
echo "=============================================================================="
echo "❌ Setup complete! Production environment incident tickets are ready."
echo "Read challenge-instructions.md for details on investigating the 3 tickets."
echo "=============================================================================="
