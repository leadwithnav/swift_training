# 🧪 Lab 9C: Automating Day-2 Operations with Official MongoDB Operator

🕒 **Estimated Time**: 25 minutes  
🎯 **Progression Step 3 of 3**: `Deployment` ➡️ `StatefulSet` ➡️ `Operator`

---

## 🎯 Objectives
In this lab, you will:
1. Understand why **Kubernetes Operators** are required over bare StatefulSets for production stateful databases.
2. Deploy the official **MongoDB Kubernetes Operator** (version 1.12.0) and its Custom Resource Definitions (CRDs).
3. Apply a production **`MongoDBCommunity`** Custom Resource to provision an automated 3-replica MongoDB ReplicaSet cluster.
4. Compare the full 3-step progression: **Deployment vs StatefulSet vs Operator**.

---

## ☘️ Pre-requisites

Ensure Minikube is running:

```bash
minikube start
```

Create a dedicated namespace named `mongodb`:

```bash
kubectl create namespace mongodb
kubectl config set-context --current --namespace=mongodb
```

---

## 💡 What is a Kubernetes Operator?

A **Kubernetes Operator** extends the Kubernetes API by embedding human operational knowledge (a DBA's expertise) into automated software controllers.

$$\text{Operator} = \text{Custom Resource Definition (CRD)} + \text{Custom Controller}$$

While a **StatefulSet** creates pods and volumes, an **Operator** handles Day-2 database operations:
- ⚡ **Auto-Clustering**: Runs `rs.initiate()` or primary-secondary replication setup automatically.
- ⚡ **Auto-Healing / Failover**: Promotes a replica pod to primary if the master pod crashes.
- ⚡ **Automated Backups**: Schedules WAL log archiving and S3 snapshots.
- ⚡ **Zero-Downtime Upgrades**: Performs rolling database version upgrades gracefully.

---

## 🛠️ Step 1: Install Official MongoDB Operator CRDs

Install the Custom Resource Definitions (CRDs) for the MongoDB Kubernetes Operator:

```bash
kubectl apply -f https://raw.githubusercontent.com/mongodb/mongodb-kubernetes/1.12.0/public/crds.yaml
```

Verify that the CustomResourceDefinitions are registered in your cluster:

```bash
kubectl get crd | grep mongodb
```

*Expected Output*:
```text
mongodbcommunity.mongodbcommunity.mongodb.com
mongodb.mongodb.com
mongodbusers.mongodb.com
opsmanagers.mongodb.com
```

---

## 🛠️ Step 2: Deploy the MongoDB Operator Controller

Deploy the official MongoDB Kubernetes Operator controller into the `mongodb` namespace:

```bash
kubectl apply -f https://raw.githubusercontent.com/mongodb/mongodb-kubernetes/1.12.0/public/mongodb-kubernetes.yaml
```

Verify that the Operator controller pod is active and running:

```bash
kubectl get pods -n mongodb
```

*Expected Output*: `mongodb-kubernetes-operator-*   1/1   Running`

---

## 🛠️ Step 3: Deploy a Production MongoDB Cluster using Custom Resource

Instead of manually crafting complex StatefulSet YAMLs, Services, and initialization scripts, a developer simply declares a high-level `MongoDBCommunity` Custom Resource!

Inspect `mongodb-community-cr.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-user-password
  namespace: mongodb
type: Opaque
stringData:
  password: my-password-123
---
apiVersion: mongodbcommunity.mongodb.com/v1
kind: MongoDBCommunity
metadata:
  name: my-mongodb-cluster
  namespace: mongodb
spec:
  members: 3
  type: ReplicaSet
  version: "5.0.5"
  security:
    authentication:
      modes: ["SCRAM"]
  users:
    - name: my-user
      db: admin
      passwordSecretRef:
        name: my-user-password
      roles:
        - name: clusterAdmin
          db: admin
        - name: userAdminAnyDatabase
          db: admin
      scramCredentialsSecretName: my-scram
```

Apply the Custom Resource:

```bash
cd ~/swift_training/kubernetes/Lab9C
kubectl apply -f mongodb-community-cr.yaml
```

Check the Custom Resource status:

```bash
kubectl get mongodbcommunity -n mongodb
```

When applied, the Operator controller automatically:
1. Provisions 3 StatefulSet pods (`my-mongodb-cluster-0`, `my-mongodb-cluster-1`, `my-mongodb-cluster-2`).
2. Configures authentication credentials and secrets.
3. Automatically executes database-level replica set initialization (`rs.initiate()`).
4. Continuously monitors health and triggers automated failover if the primary fails!

---

## 📊 Complete Progression Summary: Deployment vs StatefulSet vs Operator

| Feature | Lab 9A: Deployment | Lab 9B: StatefulSet | Lab 9C: Operator |
| :--- | :--- | :--- | :--- |
| **Primary Use Case** | Stateless Apps (Web / API) | Basic Stateful Apps (Legacy) | **Production Databases (MongoDB, Postgres, MySQL)** |
| **Pod Naming** | Random hashes (`app-xyz`) | Deterministic (`app-0`, `app-1`) | Managed by Controller (`app-0`, `app-1`) |
| **Network Identity** | Ephemeral IP | Stable Headless DNS | Managed Headless DNS + Primary Endpoint |
| **Storage Provisioning** | Single shared PVC (conflict!) | `volumeClaimTemplates` (dedicated PVC per pod) | Automated PVC management + Backup Storage (S3 / GCS) |
| **DB Replication** | ❌ Impossible | ❌ Manual (DBA must run scripts) | ✅ **100% Automated by Operator Controller** |
| **Auto-Failover** | ❌ No | ❌ K8s restarts pod, DB fails | ✅ **Automated (Promotes secondary DB node)** |
| **Backup & Restore** | ❌ No | ❌ Manual scripts | ✅ **Automated via Custom Resource** |

---

## 🧹 Cleanup Lab 9C

```bash
kubectl delete namespace mongodb
kubectl delete -f https://raw.githubusercontent.com/mongodb/mongodb-kubernetes/1.12.0/public/crds.yaml
kubectl config set-context --current --namespace=default
```

---

## ✅ End of Progression Lab Series (Lab 9A ➡️ Lab 9B ➡️ Lab 9C)
You have mastered the evolution of stateful workload management in Kubernetes—from stateless Deployments, to bare StatefulSets, to Cloud-Native Database Operators!
