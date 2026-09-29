# 📖 Solution Guide: Lab 9 Stateful Architecture Troubleshooting Challenge

This document provides the complete step-by-step root cause analysis and resolution for all 3 incident tickets in **Lab9-Challenge**.

---

## 🎫 Incident #1: "Database Pod Stuck Pending with Multi-Attach Error" (Deployment vs StatefulSet)

### 🔍 Root Cause Analysis:
Running `kubectl describe pod -l app=legacy-db -n lab9-challenge` shows:
```text
Events:
  Type     Reason              Age   From                     Message
  ----     ------              ----  ----                     -------
  Warning  FailedAttachVolume  25s   attachdetach-controller  Multi-Attach error for volume "pvc-..." Volume is already exclusively attached to one node and cannot be attached to another.
```

The manifest `broken_manifests/ticket1-db-deployment.yaml` created a `Deployment` with 2 replicas attached to a single shared `ReadWriteOnce` PVC (`shared-db-pvc`). Because RWO volumes cannot be attached to multiple pods simultaneously, the 2nd pod remains stuck in `Pending` / `ContainerCreating`.

### 🛠️ Resolution:
Delete the legacy deployment and convert the workload into a **`StatefulSet`** using `volumeClaimTemplates` to provision dedicated storage per pod:

Create `solution/ticket1-db-statefulset.yaml`:
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: legacy-db-sts
  namespace: lab9-challenge
spec:
  serviceName: "legacy-db-headless"
  replicas: 2
  selector:
    matchLabels:
      app: legacy-db
  template:
    metadata:
      labels:
        app: legacy-db
    spec:
      containers:
      - name: mongo
        image: mongo:5.0
        ports:
        - containerPort: 27017
        volumeMounts:
        - name: data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
```

Apply the fix:
```bash
kubectl delete deployment legacy-db-dep -n lab9-challenge --ignore-not-found
kubectl delete pvc shared-db-pvc -n lab9-challenge --ignore-not-found
kubectl apply -f solution/ticket1-db-statefulset.yaml
```

---

## 🎫 Incident #2: "Headless Service Endpoint Discovery Failed" (StatefulSet Headless Service Selector)

### 🔍 Root Cause Analysis:
Inspecting endpoints for `mongo-headless`:
```bash
kubectl get endpoints mongo-headless -n lab9-challenge
```
Shows:
```text
NAME             ENDPOINTS   AGE
mongo-headless   <none>      2m
```

Inspecting `broken_manifests/ticket2-headless-svc.yaml`:
```yaml
spec:
  selector:
    app: mongo-wrong-label
```
The service selector `app: mongo-wrong-label` does not match the actual labels on the StatefulSet pods (`app: mongo-sts`), preventing Kubernetes from building endpoint routing rules.

### 🛠️ Resolution:
Edit `broken_manifests/ticket2-headless-svc.yaml` to update the selector:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mongo-headless
  namespace: lab9-challenge
spec:
  clusterIP: None
  selector:
    app: mongo-sts
  ports:
  - port: 27017
    name: mongo
```

Apply the fix:
```bash
kubectl apply -f solution/ticket2-headless-svc.yaml
```

Verify endpoints:
```bash
kubectl get endpoints mongo-headless -n lab9-challenge
```
*Output*: Displays pod IPs for `mongo-sts-0` and `mongo-sts-1`.

---

## 🎫 Incident #3: "Custom Resource Rejected by Database Operator" (Operator CRD Schema Mismatch)

### 🔍 Root Cause Analysis:
Running `kubectl apply -f broken_manifests/ticket3-database-cr.yaml` returns:
```text
error: unable to recognize "broken_manifests/ticket3-database-cr.yaml": no matches for kind "MongoCluster" in version "database.example.com/v1"
```

Inspecting the installed CRD:
```bash
kubectl get crd mongoclusters.database.example.com -o yaml
```
Shows:
- `group`: `database.example.com`
- `version`: `v1alpha1`
- Allowed spec fields: `members`, `version`, `storageSize`, `autoFailover`.

`broken_manifests/ticket3-database-cr.yaml` used `apiVersion: database.example.com/v1` (should be `v1alpha1`) and `spec.replicaCount` (should be `spec.members`).

### 🛠️ Resolution:
Edit `broken_manifests/ticket3-database-cr.yaml` to match the CRD specification:

```yaml
apiVersion: database.example.com/v1alpha1
kind: MongoCluster
metadata:
  name: prod-mongo-cluster
  namespace: lab9-challenge
spec:
  members: 3
  version: "5.0"
  storageSize: "2Gi"
  autoFailover: true
```

Apply the fix:
```bash
kubectl apply -f solution/ticket3-database-cr.yaml
```

Verify Custom Resource status:
```bash
kubectl get mongocluster -n lab9-challenge
```

---

## 🚀 Complete Automated Solution

To quickly apply all fixes:

```bash
bash solution/fix-all.sh
```
