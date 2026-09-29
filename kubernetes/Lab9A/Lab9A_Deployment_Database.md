# 🧪 Lab 9A: Deploying MongoDB with a Deployment — Understanding Stateful Workload Limitations

🕒 **Estimated Time:** 20 minutes  
🎯 **Progression Step 1 of 3:** `Deployment` ➡️ `StatefulSet` ➡️ `Operator`

---

## 🎯 Objectives

In this lab, you will:

1. Deploy MongoDB using a standard Kubernetes **Deployment**.
2. Observe how Deployment pods get non-stable names and IP addresses.
3. Test what happens when multiple MongoDB replicas reference the **same PVC**.
4. Understand why **Running pods do not necessarily mean the database architecture is correct**.
5. Identify the problems that StatefulSets solve in Lab 9B.

---

## ☘️ Pre-requisites

Ensure Minikube is running.

> If you want to observe scheduling across multiple nodes, use a multi-node Minikube cluster.

```bash
minikube start --nodes 2
```

Create a namespace for Lab 9A:

```bash
kubectl create namespace lab9a
kubectl config set-context --current --namespace=lab9a
```

---

## 🛠️ Step 1: Deploy MongoDB using a Deployment

Inspect:

- `mongodb-pvc.yaml`
- `mongodb-deployment.yaml`
- `mongodb-service.yaml`

Then deploy them:

```bash
cd ~/swift_training/kubernetes/Lab9A

kubectl apply -f mongodb-pvc.yaml
kubectl apply -f mongodb-deployment.yaml
kubectl apply -f mongodb-service.yaml
```

Check the resources:

```bash
kubectl get deployment
kubectl get pods -o wide
kubectl get pvc
```

You may see both MongoDB pods in `Running` state, even when they are scheduled on different Minikube nodes.

> **Important:** Do not assume that `Running` means the storage design is safe for MongoDB.

---

## 🔍 Step 2: Observe Non-Stable Pod Identity

Check the pod names:

```bash
kubectl get pods -o wide
```

**Example:**

```text
NAME                                      READY   STATUS    IP           NODE
mongodb-deployment-7c6fc846ff-9djnj      1/1     Running   10.244.0.4   minikube
mongodb-deployment-7c6fc846ff-cl6d9      1/1     Running   10.244.1.6   minikube-m02
```

### ❓ Key Observation #1: Deployment Pods Do Not Have Stable Identities

Deployment pod names contain generated suffixes:

```text
mongodb-deployment-7c6fc846ff-9djnj
mongodb-deployment-7c6fc846ff-cl6d9
```

Delete one pod:

```bash
kubectl delete pod <pod-name>
```

Then watch the replacement:

```bash
kubectl get pods -o wide -w
```

Observe:

- Kubernetes creates another pod automatically.
- The replacement pod gets a **different pod name**.
- Its pod IP may also change.

For stateless applications this is normally fine.

For clustered databases, however, stable member identity is often useful or required for predictable peer discovery and storage mapping.

---

## 🔍 Step 3: Inspect the Shared PVC

Check the PVC used by the Deployment:

```bash
kubectl get pvc
kubectl get pv
kubectl get storageclass
```

Inspect the claim:

```bash
kubectl describe pvc shared-mongo-pvc
```

The important point is that **both Deployment replicas reference the same PVC**:

```text
MongoDB Pod A ──┐
                ├── shared-mongo-pvc
MongoDB Pod B ──┘
```

### ⚠️ Important: What `ReadWriteOnce` Actually Means

`ReadWriteOnce` (**RWO**) means the volume is intended to be mounted read-write from a **single node**.

It does **not** mean:

```text
"Only one pod can ever reference this PVC."
```

Depending on the storage driver and local Minikube configuration, both pods may still appear as `Running`.

With some storage backends—especially attachable block storage—a pod scheduled on another node may instead encounter a `Multi-Attach` or volume attachment error.

Therefore:

> **Do not make "the second pod must remain Pending" the expected result of this lab. Storage behavior depends on the provisioner.**

---

## 🧪 Step 4: Test Whether the Pods See the Same Data

First list the pods:

```bash
kubectl get pods
```

Choose the first pod and create a test file in the MongoDB data directory:

```bash
kubectl exec <pod-1> -- \
  sh -c 'echo "written-by-pod-1" > /data/db/lab9a-demo.txt'
```

Now try to read it from the second pod:

```bash
kubectl exec <pod-2> -- \
  cat /data/db/lab9a-demo.txt
```

> If your MongoDB volume is mounted somewhere other than `/data/db`, use the mount path from `mongodb-deployment.yaml`.

### Outcome A — Pod 2 can see the file

```text
written-by-pod-1
```

This means both MongoDB processes can see the same underlying data directory.

```text
mongo-pod-A ──┐
              ├── Same database files  ❌
mongo-pod-B ──┘
```

Two independent MongoDB instances should **not simply share the same database data files**. This is not the same thing as MongoDB replication and can lead to unsafe concurrent access or corruption.

### Outcome B — Pod 2 cannot see the file

Your Minikube storage implementation is not exposing the same underlying data to both pods in the way you expected.

That is also an important observation:

> **PVC behavior depends on the StorageClass and storage driver.**

Inspect the backend with:

```bash
kubectl get storageclass
kubectl describe pv <pv-name>
```

---

## 💡 Key Lesson: Running ≠ Correct Database Architecture

The purpose of this lab is **not** to prove that the second Deployment pod always fails.

The real problem is the storage topology:

```text
Deployment
    │
    ├── MongoDB Pod A ──┐
    │                   ├── One shared PVC
    └── MongoDB Pod B ──┘
                              ❌
```

For a replicated database, each database member normally needs its **own persistent data directory**:

```text
MongoDB-0 ───── PVC-0
MongoDB-1 ───── PVC-1
MongoDB-2 ───── PVC-2
                   ✅
```

A **StatefulSet + `volumeClaimTemplates`** provides this pattern.

---

## 📊 Why Deployment Is Not the Preferred Abstraction Here

| Feature | Deployment Behavior | Database Consideration |
| --- | --- | --- |
| **Pod Identity** | Generated pod names | No stable ordinal identity such as `mongodb-0`, `mongodb-1` |
| **Pod IP** | May change when pods are replaced | Do not rely on pod IPs as permanent database member addresses |
| **Storage Assignment** | A manually referenced PVC can be shared by all replicas | Independent DB replicas should not simply share one database data directory |
| **Per-Pod PVCs** | Not automatically created from a per-replica template | Requires additional manual storage management |
| **Startup / Termination** | Deployment replicas are generally managed without StatefulSet ordering guarantees | Some stateful systems benefit from ordered lifecycle behavior |

---

## 🧠 Instructor Takeaway

```text
Deployment
    ↓
Can run MongoDB containers
    ↓
But does not give each replica
stable identity + automatically dedicated storage
    ↓
Running pods ≠ correct database topology
```

The key question is not:

> **"Did Kubernetes successfully start two containers?"**

The better question is:

> **"Does every database member have the identity and persistent storage model that the database architecture requires?"**

---

## 🧹 Cleanup Lab 9A

```bash
kubectl delete namespace lab9a
kubectl config set-context --current --namespace=default
```

---

## ➡️ Next Step: Lab 9B — StatefulSet

In Lab 9B, replace the shared-storage Deployment pattern with:

```text
mongodb-0 ─── PVC-0
mongodb-1 ─── PVC-1
mongodb-2 ─── PVC-2
```

You will use a **StatefulSet** and `volumeClaimTemplates` to provide:

- Stable pod names
- Stable network identities
- Dedicated persistent storage per replica
- Stateful lifecycle semantics

Then Lab 9C will show why a database **Operator** is useful when you also want database-aware Day-2 automation such as supported clustering, failover, backups, and upgrades.
