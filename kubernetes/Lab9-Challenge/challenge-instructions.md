# 🛠️ Lab 9 Challenge: Stateful Architecture Troubleshooting

🕒 **Estimated Time**: 20–25 minutes  
🎯 **Difficulty**: Intermediate (Real-World Stateful Workload Challenge)

---

## 🎯 Challenge Overview

A junior engineer attempted to deploy and manage database workloads across standard Kubernetes resource types (`Deployment`, `StatefulSet`, and `Operator`). However, 3 critical incident tickets were submitted due to configuration errors and misapplied resource types.

Your objective as a Kubernetes Administrator is to **investigate why each workload is broken** and **fix the manifests in `broken_manifests/`** within 20–25 minutes.

---

## 🚀 Environment Setup

1. Ensure Minikube is active:
   ```bash
   minikube start
   ```

2. Run the environment setup script to prepare namespace `lab9-challenge` and active workloads:

   **Linux / Mac / Git Bash:**
   ```bash
   bash setup-challenge.sh
   ```

   **Windows PowerShell:**
   ```powershell
   .\setup-challenge.ps1
   ```

3. Check the initial status of the pods in `lab9-challenge`:
   ```bash
   kubectl get pods -n lab9-challenge
   ```

---

## 🎫 INCIDENT TICKETS

---

### 🎫 Ticket #1: "Database Pod Stuck Pending with Multi-Attach Error" (Deployment vs StatefulSet)

> **Ticket Details**:  
> **From**: Database Operations  
> *"We tried scaling our legacy database `legacy-db-dep` to 2 replicas in `broken_manifests/ticket1-db-deployment.yaml`, but the second replica remains stuck in `Pending` / `ContainerCreating` with volume errors. Fix the workload type so each database replica gets dedicated, non-conflicting storage."*

#### 🔍 Investigation Steps:
1. Inspect the pods and event log in `lab9-challenge`:
   ```bash
   kubectl get pods -n lab9-challenge
   kubectl describe pod -l app=legacy-db -n lab9-challenge
   ```
2. Read the volume error: `Multi-Attach error for volume ... Volume is already exclusively attached to one node`.

#### 💡 HINTS:
- Standard `Deployment` resources use a single shared PVC (`shared-db-pvc`).
- PersistentVolumes with `ReadWriteOnce` (RWO) cannot be attached to multiple pods simultaneously.
- Which Kubernetes workload controller automatically generates a dedicated PVC for each pod index using `volumeClaimTemplates`?
- **Goal**: Convert `broken_manifests/ticket1-db-deployment.yaml` into a **`StatefulSet`** (e.g. `legacy-db-sts`) with `volumeClaimTemplates` to ensure each pod replica gets dedicated persistent storage!

---

### 🎫 Ticket #2: "Headless Service Endpoint Discovery Failed" (StatefulSet Headless Service Selector)

> **Ticket Details**:  
> **From**: Backend Application Team  
> *"Our StatefulSet `mongo-sts` is running 2 pods (`mongo-sts-0` and `mongo-sts-1`), but applications cannot resolve pod IP addresses via the headless service `mongo-headless`. `kubectl get endpoints` shows 0 endpoints!"*

#### 🔍 Investigation Steps:
1. Check the StatefulSet and Pod labels:
   ```bash
   kubectl get pods -n lab9-challenge --show-labels
   ```
2. Check the Headless Service and its Endpoints:
   ```bash
   kubectl get svc mongo-headless -n lab9-challenge
   kubectl get endpoints mongo-headless -n lab9-challenge
   ```

#### 💡 HINTS:
- Notice that `kubectl get endpoints mongo-headless` displays `<none>`.
- Compare the pod labels in `broken_manifests/ticket2-statefulset.yaml` (`app: mongo-sts`) with the service selector in `broken_manifests/ticket2-headless-svc.yaml`.
- **Goal**: Edit `broken_manifests/ticket2-headless-svc.yaml` to fix the `spec.selector` label so it matches the StatefulSet pod labels (`app: mongo-sts`), allowing Kubernetes to route headless DNS requests to the pod instances!

---

### 🎫 Ticket #3: "Custom Resource Rejected by Database Operator" (Operator CRD Schema Mismatch)

> **Ticket Details**:  
> **From**: Automation Team  
> *"We are trying to deploy a production database cluster using our new Operator CRD. However, running `kubectl apply -f broken_manifests/ticket3-database-cr.yaml` fails with an API version or schema error!"*

#### 🔍 Investigation Steps:
1. Attempt to apply the manifest:
   ```bash
   kubectl apply -f broken_manifests/ticket3-database-cr.yaml
   ```
2. Inspect the installed CustomResourceDefinition (CRD) schema:
   ```bash
   kubectl get crd mongoclusters.database.example.com -o yaml
   ```

#### 💡 HINTS:
- Check the error returned when applying `broken_manifests/ticket3-database-cr.yaml`:
  - Is `apiVersion: database.example.com/v1` supported, or is the installed CRD version `database.example.com/v1alpha1`?
  - Does the OpenAPI schema define `spec.replicaCount` or `spec.members`?
- **Goal**: Update `broken_manifests/ticket3-database-cr.yaml` to set `apiVersion: database.example.com/v1alpha1` and fix the spec field to `members: 3`, then re-apply it successfully.

---

## 🔍 Final Verification Matrix

After editing and applying all manifests in `broken_manifests/`, run:

```bash
kubectl get statefulset,pods,svc,endpoints,mongocluster -n lab9-challenge
```

### ✅ Expected Cluster State:

- [ ] **Ticket #1**: `legacy-db` is running as a `StatefulSet` with 2 pods (`legacy-db-sts-0`, `legacy-db-sts-1`) each bound to its own dedicated PVC.
- [ ] **Ticket #2**: `mongo-headless` service endpoints list active pod IP addresses for `mongo-sts-0` and `mongo-sts-1`.
- [ ] **Ticket #3**: `prod-mongo-cluster` Custom Resource (`kind: MongoCluster`) is successfully created and recognized by the Operator.

---

## 🧹 Cleanup

To clean up all challenge resources:

```bash
kubectl delete namespace lab9-challenge
```
