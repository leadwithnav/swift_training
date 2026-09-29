# 🧪 Lab 9C: Automating Day-2 Operations with Database Operators

🕒 **Estimated Time**: 25 minutes  
🎯 **Progression Step 3 of 3**: `Deployment` ➡️ `StatefulSet` ➡️ `Operator`

---

## 🎯 Objectives
In this lab, you will:
1. Understand why **Kubernetes Operators** are required over bare StatefulSets for production stateful databases.
2. Understand the Operator Pattern: **Custom Resource Definition (CRD)** + **Custom Controller**.
3. Deploy a Database Custom Resource (`kind: MongoCluster`) and observe how the Operator automates clustering, self-healing, and failover without human intervention.
4. Compare the full 3-step progression: **Deployment vs StatefulSet vs Operator**.

---

## ☘️ Pre-requisites

Ensure Minikube is running:

```bash
minikube start
```

Create a namespace for Lab 9C:

```bash
kubectl create namespace lab9c
kubectl config set-context --current --namespace=lab9c
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

## 🛠️ Step 1: Install the Custom Resource Definition (CRD) & Operator Controller

Inspect `01-crd-and-operator.yaml`:

```bash
cd ~/swift_training/kubernetes/Lab9C
kubectl apply -f 01-crd-and-operator.yaml
```

Verify that the CustomResourceDefinition (`CRD`) and Operator Controller are active:

```bash
kubectl get crd
kubectl get pods
```

Notice the new API resource registered in your cluster: `mongoclusters.database.example.com`.

---

## 🛠️ Step 2: Deploy a Database Cluster using a Custom Resource (CR)

Instead of manually crafting complex StatefulSet YAMLs, Services, and initialization scripts, a developer simply declares a high-level `MongoCluster` resource!

Inspect `02-database-cluster-cr.yaml`:

```yaml
apiVersion: database.example.com/v1alpha1
kind: MongoCluster
metadata:
  name: production-mongo
spec:
  members: 3
  version: "5.0"
  storageSize: "2Gi"
  autoFailover: true
```

Apply the Custom Resource:

```bash
kubectl apply -f 02-database-cluster-cr.yaml
```

Verify the Custom Resource status:

```bash
kubectl get mongocluster
# or short name:
kubectl get mc
```

*Output*:
```text
NAME               AGE
production-mongo   12s
```

---

## 🔍 Step 3: Inspect Production MongoDB Community Operator Pattern

Explore `mongodb-community-operator.yaml` to see how enterprise production operators (like MongoDB Community Operator or CloudNativePG) allow declaring full replica sets, authentication, and encryption in a single file:

```yaml
apiVersion: mongodbcommunity.mongodb.com/v1
kind: MongoDBCommunity
metadata:
  name: production-mongodb
spec:
  members: 3
  type: ReplicaSet
  version: "5.0.5"
  security:
    authentication:
      modes: ["SCRAM"]
```

When applied, the Operator controller automatically:
1. Provisions 3 StatefulSet pods (`production-mongodb-0`, `production-mongodb-1`, `production-mongodb-2`).
2. Configures TLS certificates and authentication credentials.
3. Automatically executes database-level replica set initialization (`rs.initiate()`).
4. Continuously monitors health and triggers automated failover if the primary fails!

---

## 📊 Complete Progression Summary: Deployment vs StatefulSet vs Operator

| Feature | Lab 9A: Deployment | Lab 9B: StatefulSet | Lab 9C: Operator |
| :--- | :--- | :--- | :--- |
| **Primary Use Case** | Stateless Apps (Web / API) | Basic Stateful Apps (Legacy) | **Production Databases (Postgres, Mongo, MySQL, Redis)** |
| **Pod Naming** | Random hashes (`app-xyz`) | Deterministic (`app-0`, `app-1`) | Managed by Operator Controller (`app-0`, `app-1`) |
| **Network Identity** | Ephemeral IP | Stable Headless DNS | Managed Headless DNS + Primary Endpoint |
| **Storage Provisioning** | Single shared PVC (conflict!) | `volumeClaimTemplates` (dedicated PVC per pod) | Automated PVC management + Backup Storage (S3 / GCS) |
| **DB Replication** | ❌ Impossible | ❌ Manual (DBA must run setup scripts) | ✅ **100% Automated by Operator Controller** |
| **Auto-Failover** | ❌ No | ❌ K8s restarts pod, DB fails | ✅ **Automated (Promotes secondary DB node)** |
| **Backup & Restore** | ❌ No | ❌ Manual scripts | ✅ **Automated via CRD spec** |

---

## 🧹 Cleanup Lab 9C

```bash
kubectl delete namespace lab9c
kubectl config set-context --current --namespace=default
```

---

## ✅ End of Progression Lab Series (Lab 9A ➡️ Lab 9B ➡️ Lab 9C)
You have mastered the evolution of stateful workload management in Kubernetes—from stateless Deployments, to bare StatefulSets, to Cloud-Native Database Operators!
