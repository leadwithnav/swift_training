# 📖 Solution Guide: Kubernetes Production Troubleshooting Challenge

This document provides the complete step-by-step root cause analysis and resolution for all 3 incident tickets in **Lab_resource_availability_challenge**.

---

## 🎫 Incident #1: LimitRange Policy Conflict — "Why can't I deploy?"

### 🔍 Root Cause Analysis:
When running `kubectl apply -f broken_manifests/incident1-app.yaml`, the Kubernetes API server returns:
```text
Error from server (Forbidden): error when creating "broken_manifests/incident1-app.yaml": 
pods "dev-app-..." is forbidden: maximum cpu usage per Container is 1, but limit is 2
```

Inspecting the LimitRange policy in `production`:
```bash
kubectl describe limitrange app-limits -n production
```
Shows:
```text
Type        Resource  Min   Max  Default Request  Default Limit  Max Limit/Request Ratio
----        --------  ---   ---  ---------------  -------------  -----------------------
Container   cpu       100m  1    200m             500m           -
```

The developer's manifest requested `cpu: "2"`, which exceeds the namespace maximum allowed container CPU limit (`1`).

### 🛠️ Resolution:
Edit `broken_manifests/incident1-app.yaml` to specify compliant resource requests and limits:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dev-app
  namespace: production
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dev-app
  template:
    metadata:
      labels:
        app: dev-app
    spec:
      containers:
      - name: app
        image: nginx:alpine
        resources:
          requests:
            cpu: "500m"
            memory: "256Mi"
          limits:
            cpu: "1"
            memory: "512Mi"
```

Apply the fix:
```bash
kubectl apply -f broken_manifests/incident1-app.yaml
```

---

## 🎫 Incident #2: HPA Metrics Calculation Failure — "Traffic increased, but why isn't it scaling?"

### 🔍 Root Cause Analysis:
Inspecting the HPA in `production`:
```bash
kubectl get hpa web-hpa -n production
```
Shows:
```text
NAME      REFERENCE        TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
web-hpa   Deployment/web   <unknown>/50%   1         10        1          2m
```

Describing the HPA:
```bash
kubectl describe hpa web-hpa -n production
```
Shows:
```text
Warning  FailedGetResourceMetric  failed to get cpu utilization: missing request for cpu
```

The deployment `web` (`broken_manifests/incident2-web.yaml`) omitted container `resources.requests.cpu`. Without explicit container CPU requests, the metrics server cannot calculate target CPU utilization percentage ($\frac{\text{Current CPU}}{\text{Requested CPU}}$).

### 🛠️ Resolution:
Edit `broken_manifests/incident2-web.yaml` to include container CPU requests:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: production
  labels:
    app: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "200m"
            memory: "256Mi"
```

Apply the fix:
```bash
kubectl apply -f broken_manifests/incident2-web.yaml
```

Verify HPA now shows active utilization metrics:
```bash
kubectl get hpa web-hpa -n production
```
Output: `TARGETS: 0%/50%`.

---

## 🎫 Incident #3: PDB Disruption Lockout — "Why is `kubectl drain` stuck?"

### 🔍 Root Cause Analysis:
Executing `kubectl drain minikube-m02 --ignore-daemonsets --delete-emptydir-data` hangs or fails with a PDB disruption error.

Inspecting PDB status:
```bash
kubectl describe pdb api-pdb -n production
```
Shows:
```text
Name:           api-pdb
Namespace:      production
Min available:  3
Selector:       app=api
Status:
  Allowed disruptions:  0
  Current:              3
  Desired:              3
```

Because total replicas is 3 and `minAvailable: 3`, `Allowed disruptions` is `0`. The API server blocks eviction of any pod belonging to the `api` deployment during voluntary node drains.

### 🛠️ Resolution:
Edit `broken_manifests/incident3-pdb.yaml` to allow at least 1 disruption during maintenance (`minAvailable: 2` or `maxUnavailable: 1`):

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: api-pdb
  namespace: production
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: api
```

Apply the fix:
```bash
kubectl apply -f broken_manifests/incident3-pdb.yaml
```

Now execute the node drain successfully:
```bash
kubectl drain minikube-m02 --ignore-daemonsets --delete-emptydir-data
```

---

## 🚀 Complete Automated Solution

To quickly apply all fixes:

```bash
bash solution/fix-all.sh
```
