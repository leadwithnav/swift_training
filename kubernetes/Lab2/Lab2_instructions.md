
# ✅ Lab 2: Kubernetes Fundamentals with Pods and ReplicaSets – Deploy a Flask App

**Time:** 25–30 Minutes  

---

## 🧾 Lab Summary

In this lab, you will deploy a simple **Python-Flask application**—previously containerized in Lab 1—on Kubernetes. This lab introduces essential Kubernetes concepts like **Pods**, **ReplicaSets**, and **basic container management**, and provides hands-on practice with a real-world microservice.

---

## 🎯 Objectives

- 🚀 Deploy a Python-Flask app as a Pod  
- 🔄 Ensure availability using a ReplicaSet  
- 🔍 View logs and inspect containers  
- ✅ Scale and clean up resources

---

## ☘️ Step 1: Start Your Kubernetes Cluster

Start your Minikube cluster:

```bash
minikube start
```

Verify that the node is up and running:

```bash
kubectl get nodes
```

You should see a `Ready` status.

---

## 🧩 PART 1: Deploy Flask App as a Pod

### ☘️ Step 1: Explore Pod YAML File

Open `Lab2/flask_pod.yaml` and review the configuration:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: flask-app
  labels:
    app: flask
spec:
  containers:
  - name: flask-container
    image: technoavengers/flask-app:v1
    ports:
    - containerPort: 5000
```

---

### ☘️ Step 2: Deploy the Pod
Open terminal and run below command to run a Pod

```bash
cd ~/swift_training/kubernetes/Lab2
kubectl apply -f flask_pod.yaml
```

---

### ☘️ Step 3: Verify the Pod

```bash
kubectl get pods
```
Did you check the state of Pod? Is it ContainerCreating?

---

### ☘️ Step 4: Describe the Pod

```bash
kubectl describe pod flask-app
```
Notice the last Event section and see image is getting pulled from dockerHub.


### ☘️ Step 5: Check the Pod Status again
```bash
kubectl get pods
```
Is it running now? If not wait for few seconds and run above command again.

---

### ☘️ Step 6: View Pod Logs

```bash
kubectl logs flask-app
```

---

### ☘️ Step 7: Connect to Pod Shell

```bash
kubectl exec -it flask-app bash
```

Exit using:

```bash
exit
```

---

### ☘️ Step 8: Delete the Pod

```bash
kubectl delete pod flask-app
```

---

## 🧩 PART 2: Deploy Flask App with ReplicaSet

### ☘️ Step 1: Explore ReplicaSet YAML File

Explore replicaset file in `Lab2/flask_replicaset.yaml`:

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: flask-replicaset
  labels:
    app: flask
spec:
  replicas: 3
  selector:
    matchLabels:
      app: flask
  template:
    metadata:
      labels:
        app: flask
    spec:
      containers:
      - name: flask-container
        image: technoavengers/flask-app:v1
        ports:
        - containerPort: 5000
```

---

### ☘️ Step 2: Deploy the ReplicaSet

Inside terminal and run below command

```bash
kubectl apply -f flask_replicaset.yaml
```

---

### ☘️ Step 3: Verify ReplicaSet and Pods

```bash
kubectl get replicaset
kubectl get pods
```

---

### ☘️ Step 4: Delete One Pod

```bash
kubectl delete pod <one-flask-pod-name>
```

Recheck if the pod is recreated:

```bash
kubectl get pods
```

---

### ☘️ Step 5: Scale Up ReplicaSet

```bash
kubectl scale replicaset flask-replicaset --replicas=5
kubectl get pods
```

---

### ☘️ Step 6: Scale Down ReplicaSet

```bash
kubectl scale replicaset flask-replicaset --replicas=2
kubectl get pods
```

---

### ☘️ Step 7: Delete the ReplicaSet

```bash
kubectl delete replicaset flask-replicaset
```

---

## ✅ Conclusion

In this lab, you:

- Deployed your custom Flask Docker image as a Pod
- Managed it using a ReplicaSet for resilience and scalability
- Explored `kubectl` commands to monitor, connect, scale, and clean up workloads

---

🎉 **Congratulations**, you have successfully deployed and managed your Flask app on Kubernetes!  
✨ **END OF LAB** ✨
