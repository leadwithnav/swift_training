# 🛠️ Troubleshooting Challenge: Pod Scheduling Outage

🕒 **Estimated Time**: 25 minutes  
🎯 **Difficulty**: Intermediate (Real-World Troubleshooting Scenario)

---

## 🎯 Challenge Overview

An engineer deployed a 4-tier application stack (`db`, `backend`, `cache`, and `frontend`) to a 3-node Minikube cluster. However, after deployment, multiple pods are stuck in **`Pending`** state due to misconfigured scheduling constraints!

Your task as a DevOps / Kubernetes Engineer is to **diagnose why each pod is stuck** using `kubectl describe` commands and **fix the deployment manifests** (or node configurations) to bring all pods into a **`Running`** state within 25 minutes.

---

## 🚀 Step 1: Launch the Broken Environment

Start a 3-node Minikube cluster (if not already running):

```bash
minikube start --nodes=3
```

Run the setup script to simulate the broken environment:

**Linux / Mac / Git Bash:**
```bash
bash setup-challenge.sh
```

**Windows PowerShell:**
```powershell
.\setup-challenge.ps1
```

Now, check the status of all pods:

```bash
kubectl get pods -o wide
```

Notice that several pods are stuck in **`Pending`** state!

---

## 🧩 TROUBLESHOOTING TASKS

### 📍 Task 1: Diagnose & Fix `db-deployment` (Taints & Tolerations)

**Symptom**: Pod `db-deployment-*` is stuck in `Pending`.

1. **Investigate**: Run `kubectl describe pod -l app=db` and check the **Events** section.
2. **Root Cause**: Node `minikube-m03` has a taint (`dedicated=db:NoSchedule`) and `db-deployment` has node affinity targeting `minikube-m03`, but the pod is missing a matching **Toleration**.
3. **Fix**: Edit `broken_manifests/01-db-deployment.yaml` (or apply your fix) to add the required toleration:
   ```yaml
   tolerations:
   - key: "dedicated"
     operator: "Equal"
     value: "db"
     effect: "NoSchedule"
   ```
4. **Apply Fix**:
   ```bash
   kubectl apply -f broken_manifests/01-db-deployment.yaml
   ```

---

### 📍 Task 2: Diagnose & Fix `backend-deployment` (Node Affinity Mismatch)

**Symptom**: Pods `backend-deployment-*` are stuck in `Pending`.

1. **Investigate**: Run `kubectl describe pod -l app=backend`.
2. **Root Cause**: The deployment requires node label `tier=application-node`, but the actual worker node `minikube-m02` is labeled `tier=app-node`.
3. **Fix**: Update `broken_manifests/02-backend-deployment.yaml` so the `nodeAffinity` matches `tier=app-node`.
4. **Apply Fix**:
   ```bash
   kubectl apply -f broken_manifests/02-backend-deployment.yaml
   ```

---

### 📍 Task 3: Diagnose & Fix `cache-deployment` (Pod Affinity Label Typo)

**Symptom**: Pod `cache-deployment-*` is stuck in `Pending`.

1. **Investigate**: Run `kubectl describe pod -l app=cache`.
2. **Root Cause**: The cache pod has `podAffinity` configured to co-locate with `app=backend-service`, but the backend pods are actually labeled `app=backend`.
3. **Fix**: Edit `broken_manifests/03-cache-deployment.yaml` and update the `labelSelector` under `podAffinity` from `backend-service` to `backend`.
4. **Apply Fix**:
   ```bash
   kubectl apply -f broken_manifests/03-cache-deployment.yaml
   ```

---

### 📍 Task 4: Diagnose & Fix `frontend-deployment` (Hard Pod Anti-Affinity Constraint)

**Symptom**: 2 pods of `frontend-deployment` are running, but the 3rd replica is stuck in `Pending`.

1. **Investigate**: Run `kubectl describe pod -l app=frontend`.
2. **Root Cause**:
   - `frontend` uses **Node Anti-Affinity** (`NotIn: db-node`), excluding `minikube-m03`. This leaves only 2 available nodes (`minikube` and `minikube-m02`).
   - `frontend` has a hard **Pod Anti-Affinity** rule (`requiredDuringSchedulingIgnoredDuringExecution`) preventing 2 frontend pods from sharing the same hostname. With 3 replicas and only 2 eligible nodes, the 3rd replica cannot schedule.
3. **Fix**: Edit `broken_manifests/04-frontend-deployment.yaml` to change `podAntiAffinity` from `requiredDuringSchedulingIgnoredDuringExecution` to `preferredDuringSchedulingIgnoredDuringExecution` (soft constraint with `weight: 100`).
4. **Apply Fix**:
   ```bash
   kubectl apply -f broken_manifests/04-frontend-deployment.yaml
   ```

---

## 🔍 Final Verification Checklist

Run the validation command:

```bash
kubectl get pods -o wide
```

### ✅ Expected Result:

- [ ] All **7 pods** (`1x db`, `2x backend`, `1x cache`, `3x frontend`) must be in the **`Running`** state.
- [ ] `db` pod is running on `minikube-m03`.
- [ ] `backend` pods are running on `minikube-m02`.
- [ ] `cache` pod is co-located on `minikube-m02` with `backend`.
- [ ] `frontend` pods are scheduled across available non-DB nodes without remaining `Pending`.

---

## 🧹 Cleanup

To delete all challenge resources:

```bash
kubectl delete -f broken_manifests/
kubectl label nodes minikube-m02 tier-
kubectl label nodes minikube-m03 tier-
kubectl taint nodes minikube-m03 dedicated-
```
