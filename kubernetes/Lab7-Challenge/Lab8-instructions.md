
# 🚀 Kubernetes Challenge: Deploy Node.js with MongoDB

In this challenge, you will deploy a Node.js application connected to MongoDB using Kubernetes. The setup includes two services and uses Persistent Volumes for MongoDB.

---

## 🎯 Objective
- Complete the missing parts in the provided YAML files.
- Deploy a Node.js app with 3 replicas and MongoDB with 1 replica.
- Expose Node.js externally via NodePort.
- Use Persistent Volume for MongoDB storage.
- Access your app using the public IP of your EC2 instance.

---

## 🧾 Setup Overview

## ☘️ Pre-requiste : Verify Cluster
1. make sure your minikube cluster is running, if not run below to start cluster

```bash
minikube start --driver=docker --ports=30000:30000
```

## ☘️ Cleanup 📦🧰🔍
```bash
kubectl delete --all deployment
kubectl delete --all replicaset
kubectl delete --all pod
kubectl delete svc minio-service
kubectl delete --all statefulsets
```

### 🧩 Kubernetes Resources

| Component     | Type         | Details                     |
|---------------|--------------|-----------------------------|
| Node.js App   | Deployment   | 3 replicas                  |
| MongoDB       | Deployment   | 1 replica + PVC             |
| Node.js App   | Service      | NodePort (30000 → 3000)     |
| MongoDB       | Service      | ClusterIP (port 27017)      |

---

## 📦 Files Provided

- `nodeapp-deployment.yaml`  — Deployment for Node.js (contains TODOs)
- `mongodb-deployment.yaml`  — Deployment for MongoDB (contains TODOs)
- `nodeapp-service.yaml`     — NodePort service for Node.js
- `mongodb-service.yaml`     — ClusterIP service for MongoDB
- `mongo-pvc.yaml`           — PVC for MongoDB
- `start.sh`                 — Script to deploy everything
- `stop.sh`                  — Script to delete all resources

---

## 🧠 Environment Variables (inside Node.js)

The Node.js app expects the following environment variables:

- `MONGO_HOST` → should be `mongodb-service complete url --> domain name:port`
- `MONGO_PORT` → `27017`
- `MONGO_DATABASE` → `docker-node-mongo`

Use `env:` or `envFrom:` in your `nodeapp-deployment.yaml` to pass these values via a ConfigMap or directly.

---


## ▶️ Start the Project

Run this command to apply all resources:

```bash
chmod +x start.sh
./start.sh
```

At the end of `start.sh`, you’ll see the public URL of your Node.js app. Example:



```bash
echo "Your Node.js app is available at:"
echo "http://$(curl -s http://checkip.amazonaws.com):30000"
```

Open your browser and run above URL

---

## 🛠️ Verify

```bash
kubectl get pods
kubectl get svc
kubectl get pvc
```

Make sure:
- You see 3 `nodeapp` pods
- 1 `mongodb` pod
- 1 PVC bound to MongoDB

---

## 🛑 Stop/Cleanup

Run the cleanup script:

```bash
chmod +x stop.sh
./stop.sh
```

---

## ✅ Completion Criteria

- Node.js app loads in browser at `http://<EC2-IP>:30000`
- MongoDB is connected and data persists after a pod restart
- All Kubernetes YAML files are correctly completed

Good luck! 💡
