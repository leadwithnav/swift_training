# PowerShell Setup Script for Lab_affinities_challenge

Write-Host "⚙️ Setting up nodes (Labels & Taints)..." -ForegroundColor Cyan
kubectl label nodes minikube-m02 tier=app-node --overwrite
kubectl label nodes minikube-m03 tier=db-node --overwrite
kubectl taint nodes minikube-m03 dedicated=db:NoSchedule --overwrite

Write-Host "🚀 Deploying broken manifests..." -ForegroundColor Cyan
kubectl apply -f broken_manifests/01-db-deployment.yaml
kubectl apply -f broken_manifests/02-backend-deployment.yaml
kubectl apply -f broken_manifests/03-cache-deployment.yaml
kubectl apply -f broken_manifests/04-frontend-deployment.yaml

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Yellow
Write-Host "❌ Setup complete! Pods have been deployed." -ForegroundColor Yellow
Write-Host "Run 'kubectl get pods -o wide' to see the pending pods." -ForegroundColor Yellow
Write-Host "Read instructions.md for details on diagnosing and fixing the issues." -ForegroundColor Yellow
Write-Host "==============================================================================" -ForegroundColor Yellow
