
# ✅ Lab 9: Deploying MongoDB as a StatefulSet in Kubernetes

**Time**: 25 mins

## Lab Summary
In this lab, participants will deploy MongoDB as a StatefulSet in Kubernetes, ensuring data persistence using Persistent Volumes. Participants will also configure both a headless service and a ClusterIP service to observe DNS-based communication between MongoDB pods.

---

## 🎯 Objectives
- Deploy MongoDB as a StatefulSet.
- Create and test a headless service.
- Create and test a ClusterIP service.
- Observe stable network identities and ordered deployment.
- Validate Persistent Volume Claims (PVCs).
- Clean up resources.

---

## ☘️ Pre-requisite: Run Minikube cluster

```bash
minikube start --driver=docker --ports=30000:30000
```

Verify cluster

```bash
kubectl get node
```


---

## ☘️ Cleanup Existing Resources

```bash
kubectl delete --all deployment
kubectl delete --all replicaset
kubectl delete --all pod
kubectl delete svc mongodb-service mongodb-headless
kubectl delete --all pvc
```

---

## 🛠️ Step 1: Create Headless and ClusterIP Services

### Headless Service (`mongodb-headless-service.yaml`)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mongodb-headless
spec:
  clusterIP: None
  selector:
    app: mongo
  ports:
  - port: 27017
    name: mongo
```

```bash
cd ~/swift_training/Lab9
kubectl apply -f mongodb-headless-service.yaml
kubectl get svc
```

### ClusterIP Service (`mongodb-service.yaml`)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mongodb-service
spec:
  selector:
    app: mongo
  ports:
  - port: 27017
    targetPort: 27017
```

```bash
kubectl apply -f mongodb-service.yaml
kubectl get svc
```

---

## 🛠️ Step 2: Deploy MongoDB as a StatefulSet

**YAML File**: `mongo_statefulset.yaml`

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb
spec:
  serviceName: "mongodb-h"
  replicas: 2
  selector:
    matchLabels:
      app: mongo
  template:
    metadata:
      labels:
        app: mongo
    spec:
      containers:
      - name: mongo
        image: mongo:5.0
        ports:
        - containerPort: 27017
        volumeMounts:
        - name: data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
      storageClassName: standard
```

Apply it:

```bash
kubectl apply -f mongodb-statefulset.yaml
```

---

## ✅ Step 3: Verify StatefulSet and Pods

```bash
kubectl get statefulset mongodb
kubectl get pods
```

Expected pods:
- mongodb-0
- mongodb-1

---

## 🔍 Step 4: Test Headless Service (Stable DNS)

```bash
kubectl exec -it mongodb-0 -- bash
```

Inside the pod:

```bash
apt update && apt install dnsutils -y
```
Lookup Mongodb headless service

```bash
nslookup mongodb-h
```
Did you noticed that it gave you IP address for all underlying pod

Let's get IP adress/DNS of a particular pod

```bash
nslookup mongodb-1.mongodb-h
```


Expected DNS format:
```
mongodb-0.mongodb-headless.default.svc.cluster.local
```

---

## 🔧 Step 5: Test ClusterIP Service

Let's lookup clusterIP service

```bash
nslookup mongodb-service
```

Did you noticed that mongodb service just provides its own dns and ip address and does not provide any Info for underlying pod

Let's come out of pod

```bash
exit
```

---

## 🔄 Step 6: Observe Ordered Deployment

```bash
kubectl scale statefulset mongodb --replicas=5
```

```bash
kubectl get pods
```
Observe pod creation order:
- mongodb-0
- mongodb-1
- ...
- mongodb-4

---

## 🧾 Step 7: Inspect PVCs

```bash
kubectl get pvc
```

Each pod has its own PVC, such as:
- data-mongodb-0
- data-mongodb-1

---

## 🧹 Step 8: Clean Up Resources

```bash
kubectl delete statefulset mongodb
kubectl delete svc mongodb-h mongodb-service
kubectl delete --all pvc
```

---

✅ **END OF LAB**
