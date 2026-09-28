# 🛠️ Troubleshooting Challenge: Pod Scheduling Outage

🕒 **Estimated Time**: 25 minutes  
🎯 **Difficulty**: Intermediate (Real-World Troubleshooting Challenge)

---

## 🎯 Challenge Overview

An automated deployment pipeline just deployed a 4-tier application stack (`db`, `backend`, `cache`, and `frontend`) to a 3-node Minikube cluster. However, after deployment, multiple pods are stuck in **`Pending`** state due to misconfigured scheduling constraints!

Your task as a DevOps / Kubernetes Engineer is to **investigate why each pod is stuck** using Kubernetes diagnostic commands (`kubectl describe`, `kubectl get nodes`) and **fix the deployment manifests in `broken_manifests/`** to bring all pods into a **`Running`** state within 25 minutes.

---

## 🚀 Step 1: Launch the Broken Environment

1. Start a 3-node Minikube cluster (if not already running):
   ```bash
   minikube start --nodes=3
   ```

2. Run the setup script to prepare node taints/labels and deploy the broken application manifests:

   **Linux / Mac / Git Bash:**
   ```bash
   bash setup-challenge.sh
   ```

3. Check the initial status of the pods:
   ```bash
   kubectl get pods -o wide
   ```

Notice that several pods are stuck in **`Pending`** state!

---

## 🧩 CHALLENGE TASKS

---

### 📍 Task 1: Troubleshoot `db-deployment`

**Symptom**: Pod `db-deployment-*` remains in `Pending` state.

- **Investigation**:
  ```bash
  kubectl describe pod -l app=db
  kubectl describe node minikube-m03
  ```
- **Goal**: Enable the `db` pod to successfully schedule on the dedicated database node `minikube-m03`.
- 💡 **HINT**:
  - Check the **Events** output from `kubectl describe pod`. Does it mention an *untolerated taint* on `minikube-m03`?
  - Node `minikube-m03` has a taint applied (`dedicated=db:NoSchedule`).
  - Inspect `broken_manifests/01-db-deployment.yaml`. Does the pod spec have a matching `tolerations` block matching the key, value, and effect of the node's taint?

---

### 📍 Task 2: Troubleshoot `backend-deployment`

**Symptom**: Pods `backend-deployment-*` remain in `Pending` state.

- **Investigation**:
  ```bash
  kubectl describe pod -l app=backend
  kubectl get nodes --show-labels
  ```
- **Goal**: Ensure the two `backend` replicas schedule on the application worker node `minikube-m02`.
- 💡 **HINT**:
  - Check the `Events` section of `kubectl describe pod -l app=backend`. Does it say `0/3 nodes didn't match Pod's node affinity`?
  - Compare the node label applied to `minikube-m02` with the `nodeSelectorTerms` / `matchExpressions` key in `broken_manifests/02-backend-deployment.yaml`.
  - Look closely for a typo in the label key or value (e.g., `application-node` vs `app-node`).

---

### 📍 Task 3: Troubleshoot `cache-deployment`

**Symptom**: Pod `cache-deployment-*` remains in `Pending` state.

- **Investigation**:
  ```bash
  kubectl describe pod -l app=cache
  kubectl get pods --show-labels
  ```
- **Goal**: Ensure the `cache` pod is co-located on the same node as the `backend` pod for low latency.
- 💡 **HINT**:
  - Check the pod events for pod affinity errors: `0/3 nodes didn't match pod affinity rules`.
  - Inspect the `podAffinity` block in `broken_manifests/03-cache-deployment.yaml`.
  - What label is the `cache` pod's `labelSelector` searching for? Compare that label selector to the actual label on your running `backend` pods (`app=backend`).

---

### 📍 Task 4: Troubleshoot `frontend-deployment`

**Symptom**: 2 replicas of `frontend-deployment` are `Running`, but the 3rd replica remains stuck in `Pending`.

- **Investigation**:
  ```bash
  kubectl describe pod -l app=frontend
  kubectl get pods -o wide -l app=frontend
  ```
- **Goal**: Allow all 3 `frontend` replicas to run across the available non-database worker nodes.
- 💡 **HINT**:
  - Notice that `frontend` uses **Node Anti-Affinity** (`NotIn: db-node`), which excludes `minikube-m03`. This leaves only 2 eligible nodes (`minikube` and `minikube-m02`).
  - `frontend` has a hard `podAntiAffinity` constraint (`requiredDuringSchedulingIgnoredDuringExecution`). Because 2 frontend pods are already running on `minikube` and `minikube-m02`, the 3rd replica cannot find a host without violating the hard anti-affinity rule!
  - How can you soften this constraint in `broken_manifests/04-frontend-deployment.yaml` so Kubernetes *prefers* spreading pods across nodes, but still allows scheduling when nodes are limited? (Think `preferredDuringSchedulingIgnoredDuringExecution`).

---

## 🔍 Final Verification Checklist

After editing and applying all manifests in `broken_manifests/`, run:

```bash
kubectl get pods -o wide
```

### ✅ Expected Output:

All 7 pods must be in the **`Running`** state across your cluster:

| Pod Name | Target Node | Expected Placement Verification |
| :--- | :--- | :--- |
| `db-deployment-*` | `minikube-m03` | Running on dedicated database node |
| `backend-deployment-*` (2 pods) | `minikube-m02` | Running on application worker node |
| `cache-deployment-*` | `minikube-m02` | Co-located on same node as `backend` |
| `frontend-deployment-*` (3 pods) | `minikube` / `minikube-m02` | Distributed across available non-DB nodes |

---

## 🧹 Cleanup

To clean up all resources created during this challenge:

```bash
kubectl delete -f broken_manifests/
kubectl label nodes minikube-m02 tier-
kubectl label nodes minikube-m03 tier-
kubectl taint nodes minikube-m03 dedicated-
```
