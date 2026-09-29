# 🧪 Lab 9A: Deploying Databases with Deployments & Understanding Limitations

🕒 **Estimated Time**: 20 minutes  
🎯 **Progression Step 1 of 3**: `Deployment` vs `StatefulSet` vs `Operator`

---

## 🎯 Objectives
In this lab, you will:
1. Deploy a database (MongoDB) as a standard Kubernetes **Deployment**.
2. Observe how Deployments manage pod identities and IP addresses.
3. Discover why Deployments fail when handling stateful databases with persistent volumes.

---

## ☘️ Pre-requisites

Ensure Minikube is running:

```bash
minikube start
```

Create a namespace for Lab 9A:

```bash
kubectl create namespace lab9a
kubectl config set-context --current --namespace=lab9a
```

---

## 🛠️ Step 1: Deploy MongoDB using a Deployment

Inspect `mongodb-pvc.yaml` and `mongodb-deployment.yaml`:

```bash
cd ~/swift_training/Lab9A
kubectl apply -f mongodb-pvc.yaml
kubectl apply -f mongodb-deployment.yaml
kubectl apply -f mongodb-service.yaml
```

Check the status of the Deployment and Pods:

```bash
kubectl get deployment
kubectl get pods -o wide
```

---

## 🔍 Step 2: Observe Anonymous Pod Identities

Look closely at the names of the created pods:

```bash
kubectl get pods
```

*Example Output*:
```text
NAME                                  READY   STATUS    RESTARTS   AGE
mongodb-deployment-6f9479b478-x9z2p   1/1     Running   0          45s
mongodb-deployment-6f9479b478-k4l1q   0/1     Pending   0          45s
```

### ❓ Key Observation #1: Random Hashes
Pods created by a Deployment get **random, non-deterministic names** (e.g. `mongodb-deployment-6f9479b478-x9z2p`).
If a pod crashes or is deleted, Kubernetes replaces it with a pod with a **new random hash name and new IP address**.

Delete one of the pods:

```bash
kubectl delete pod -l app=mongo-dep --field-selector status.phase=Running
kubectl get pods -o wide
```

Notice that the old pod is gone and the new replacement pod has a completely different name and IP address!

---

## 🔍 Step 3: Discover the Storage & Scaling Problem

Look at the status of the second pod replica:

```bash
kubectl describe pod -l app=mongo-dep
```

Look at the **Events** section of the pending pod:

```text
Events:
  Type     Reason              Age   From                     Message
  ----     ------              ----  ----                     -------
  Warning  FailedAttachVolume  20s   attachdetach-controller  Multi-Attach error for volume "pvc-..." Volume is already exclusively attached to one node and cannot be attached to another.
```

### ❓ Key Observation #2: Volume Mounting Conflict
- Deployments use shared volume templates.
- Standard PersistentVolumes with `ReadWriteOnce` (RWO) access mode can only be attached to **one node / one pod at a time**.
- When you scale a `Deployment` with a single PVC, multiple database instances try to attach to the same volume simultaneously, resulting in `Multi-Attach` errors or **data corruption**!

---

## 💡 Summary of Why Deployments Fail for Databases

| Feature | Deployment Behavior | Impact on Databases |
| :--- | :--- | :--- |
| **Pod Identity** | Anonymous & Random (`dep-xyz12`) | Database nodes cannot identify master/slaves or establish stable cluster peer addresses. |
| **Network Address** | Ephemeral (IP changes on pod restart) | Database replication configuration breaks whenever a pod restarts. |
| **Storage Assignment** | Shared PVC or unmanaged PVCs | Multiple database instances clash over the same data files, risking lock files and corruption. |
| **Scaling Order** | Parallel / Unordered | Database clusters require ordered startup (Master first, then Replicas). |

---

## 🧹 Cleanup Lab 9A

```bash
kubectl delete namespace lab9a
kubectl config set-context --current --namespace=default
```

---

## ➡️ Next Step: Move to Lab 9B
Now that you understand why Deployments fail for databases, proceed to **Lab 9B** to see how **StatefulSets** solve pod identity and dedicated storage allocation!
