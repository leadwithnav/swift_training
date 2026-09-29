# PowerShell Setup Script for Lab9-Challenge

Write-Host "⚙️ Creating namespace lab9-challenge..." -ForegroundColor Cyan
kubectl create namespace lab9-challenge --dry-run=client -o yaml | kubectl apply -f -

Write-Host "⚙️ Installing Custom Resource Definition (mongoclusters.database.example.com)..." -ForegroundColor Cyan
$crd = @"
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: mongoclusters.database.example.com
spec:
  group: database.example.com
  versions:
    - name: v1alpha1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                members:
                  type: integer
                  minimum: 1
                  maximum: 5
                version:
                  type: string
                storageSize:
                  type: string
                autoFailover:
                  type: boolean
  scope: Namespaced
  names:
    plural: mongoclusters
    singular: mongocluster
    kind: MongoCluster
    shortNames:
    - mc
"@
$crd | kubectl apply -f -

Write-Host "⚙️ Deploying broken workloads for Ticket 1 & Ticket 2..." -ForegroundColor Cyan
kubectl apply -f broken_manifests/ticket1-db-deployment.yaml
kubectl apply -f broken_manifests/ticket2-statefulset.yaml
kubectl apply -f broken_manifests/ticket2-headless-svc.yaml

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Yellow
Write-Host "❌ Setup complete! Lab 9 Challenge environment is ready." -ForegroundColor Yellow
Write-Host "Read challenge-instructions.md for details on investigating the 3 tickets." -ForegroundColor Yellow
Write-Host "==============================================================================" -ForegroundColor Yellow
