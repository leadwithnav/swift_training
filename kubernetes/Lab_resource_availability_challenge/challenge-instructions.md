# 🛠️ Kubernetes Production Troubleshooting Challenge

🕒 **Estimated Time**: 45–60 minutes  
🎯 **Difficulty**: Advanced Production Incident Handling

---

## 🎯 Lab Overview: "Why is my Production Application Unhealthy?"

Welcome to the **Kubernetes Production Support On-Call Shift**! 

An infrastructure upgrade was completed, but immediately afterward, 3 urgent incident tickets arrived in your queue from development, monitoring, and operations teams.

Your objective as the Lead Site Reliability Engineer (SRE) is to investigate and resolve each production incident ticket in the `production` namespace within 45–60 minutes.

---

## 🚀 Environment Setup

1. Ensure a 3-node Minikube cluster is active:
   ```bash
   minikube start --nodes=3
   ```

2. Run the environment setup script to initialize the `production` namespace policies and active workloads:

   **Linux / Mac / Git Bash:**
   ```bash
   bash setup-challenge.sh
   ```

   **Windows PowerShell:**
   ```powershell
   .\setup-challenge.ps1
   ```

3. Verify active workloads in the `production` namespace:
   ```bash
   kubectl get all -n production
   ```

---

## 🎫 INCIDENT TICKETS

---

### 🎫 Ticket #1: "Why can't I deploy?" (LimitRange Policy Conflict)

> **Ticket Details**:  
> **From**: Lead Developer  
> *"Our deployment manifest `broken_manifests/incident1-app.yaml` works completely fine in our local development cluster, but when we try to deploy it to the `production` namespace, Kubernetes rejects it immediately. Please fix it without deleting any namespace security/policy configurations!"*

#### 🔍 Investigation Steps:
1. Attempt to apply the developer's manifest:
   ```bash
   kubectl apply -f broken_manifests/incident1-app.yaml
   ```
2. Read the exact admission error returned by the API server.

#### 💡 HINTS:
- Notice that the API server returns an `Error from server (Forbidden)`.
- What namespace-level policies constrain container resource requests and limits?
- Inspect active policies in the `production` namespace:
  ```bash
  kubectl get limitrange -n production
  kubectl describe limitrange -n production
  ```
- Compare the `max.cpu` limit defined in the `LimitRange` policy with the `requests.cpu` in `broken_manifests/incident1-app.yaml`.
- **Goal**: Update `broken_manifests/incident1-app.yaml` so CPU requests/limits comply with the `LimitRange` policy (e.g. `cpu: 500m`), then re-apply it successfully.

---

### 🎫 Ticket #2: "Traffic increased, but why isn't it scaling?" (HPA Metrics Calculation Failure)

> **Ticket Details**:  
> **From**: Monitoring & Alerting System  
> *"Application `web` is receiving sustained high CPU traffic, but the Horizontal Pod Autoscaler (`web-hpa`) is not scaling up replicas as expected. Replicas remain stuck at 1!"*

#### 🔍 Investigation Steps:
1. Inspect the current HPA status in `production`:
   ```bash
   kubectl get hpa -n production
   kubectl describe hpa web-hpa -n production
   ```
2. Inspect current CPU usage of running pods:
   ```bash
   kubectl top pods -n production
   ```
3. Inspect the deployment specification:
   ```bash
   kubectl get deployment web -n production -o yaml
   ```

#### 💡 HINTS:
- Look at the `TARGETS` column in `kubectl get hpa -n production`. Does it show `<unknown>/50%`?
- Check the **Events** or **Conditions** section of `kubectl describe hpa web-hpa -n production`. Does it mention `failed to get cpu utilization: missing request for cpu`?
- **Core Concept**: $\text{HPA Target \%} = \frac{\text{Current CPU Usage}}{\text{Requested CPU}}$. If a container has no container CPU **requests** specified, the metric server cannot compute the CPU percentage!
- **Goal**: Edit `broken_manifests/incident2-web.yaml` to add container CPU resource requests (e.g., `requests.cpu: 100m`), apply the fix, generate CPU load using a busybox loop or `kubectl exec`, and observe `kubectl get hpa -w -n production` scale replicas up from 1 to 2+!

---

### 🎫 Ticket #3: "Why is `kubectl drain` stuck?" (PDB Disruption Lockout)

> **Ticket Details**:  
> **From**: Infrastructure Operations Team  
> *"We need to perform kernel maintenance on worker node `minikube-m02`. We ran `kubectl drain minikube-m02`, but Kubernetes refuses to evict the `api` deployment pods and the command hangs indefinitely! Why is Kubernetes blocking node eviction?"*

#### 🔍 Investigation Steps:
1. Attempt to drain `minikube-m02`:
   ```bash
   kubectl drain minikube-m02 --ignore-daemonsets --delete-emptydir-data
   ```
2. Read the error or warning message emitted by `kubectl drain`.
3. Inspect PodDisruptionBudgets in the namespace:
   ```bash
   kubectl get pdb -n production
   kubectl describe pdb api-pdb -n production
   ```

#### 💡 HINTS:
- Look at the key fields in `kubectl describe pdb api-pdb -n production`:
  - `Desired Healthy`: `3`
  - `Current Healthy`: `3`
  - `Disruptions Allowed`: `0`
- If `minAvailable: 3` and total replicas = 3, **0 evictions are allowed**, completely locking out voluntary disruptions like node drains!
- **Core Concept**: PDBs protect applications against voluntary disruptions (e.g. `kubectl drain`), but if misconfigured, they can block cluster maintenance operations.
- **Goal**: Edit `broken_manifests/incident3-pdb.yaml` to set a realistic budget (e.g., `minAvailable: 2` or `maxUnavailable: 1`) allowing 1 pod to be disrupted during node maintenance. Re-apply the PDB and run `kubectl drain minikube-m02` successfully!

---

## 🔍 Final Verification Matrix

After resolving all 3 incident tickets, verify your cluster status:

```bash
kubectl get pods,hpa,pdb,limitrange -n production
```

### ✅ Expected Production State:

- [ ] **Ticket #1**: `dev-app` is successfully deployed and running within LimitRange policy bounds.
- [ ] **Ticket #2**: `web-hpa` displays active CPU utilization percentages (e.g., `0%/50%`) instead of `<unknown>` and scales up when under load.
- [ ] **Ticket #3**: `api-pdb` displays `Disruptions Allowed: 1` and node `minikube-m02` drains cleanly without blocking.

---

## 🧹 Cleanup & Restoration

After completing the challenge, uncordon nodes and delete the production namespace:

```bash
kubectl uncordon minikube-m02 minikube-m03
kubectl delete namespace production
```
