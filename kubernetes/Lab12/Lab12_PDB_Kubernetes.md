# ✅ Lab 12: Understanding PodDisruptionBudgets (PDB) and Horizontal Pod Autoscaler (HPA) in Kubernetes

🕒 **Estimated Time**: 25–30 minutes

---

## 🎯 Objective
This lab introduces two core Kubernetes features for high availability and dynamic scaling:
1. **PodDisruptionBudget (PDB)**: Ensures a minimum number of replicas remain available during voluntary disruptions (e.g. node drains, upgrades).
2. **Horizontal Pod Autoscaler (HPA)**: Automatically scales the number of pod replicas based on observed CPU utilization.

---

# 🧩 PART 1 — PodDisruptionBudget (PDB)

PDB ensures that a minimum number of Pods remain available during voluntary disruptions like node drains or cluster upgrades.

## ☘️ Step 1: Start Minikube Cluster
Start minikube with 3 nodes:
```bash
minikube start --nodes=3
```
Check cluster nodes:
```bash
kubectl get nodes
```

Ensure your kubectl context points to minikube:
```bash
kubectl config use-context minikube
```

---

## ☘️ Step 2: Deploy the Web Application

Explore the deployment file `web-deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  labels:
    app: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 100m
            memory: 128Mi
```

Apply the deployment:
```bash
cd ~/swift_training/Lab12
kubectl apply -f web-deployment.yaml
```

Check pod locations across nodes:
```bash
kubectl get pods -o wide
```

---

## ☘️ Step 3: Create & Apply PodDisruptionBudget (PDB)

Explore `pdb.yaml`:
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: web
```

Apply the PDB:
```bash
kubectl apply -f pdb.yaml
```

Check PDB status:
```bash
kubectl get pdb
```
*Expected Output*: `MIN AVAILABLE = 2`, `ALLOWED DISRUPTIONS = 1`.

---

## ☘️ Step 4: Simulate Node Drain to Test PDB

Drain node `minikube-m02`:
```bash
kubectl drain minikube-m02 --ignore-daemonsets --delete-emptydir-data
```

Check pod status again:
```bash
kubectl get pods -o wide
```

Now try draining `minikube-m03`:
```bash
kubectl drain minikube-m03 --ignore-daemonsets --delete-emptydir-data
```

*Observation*: Kubernetes blocks or delays evictions if draining the node would violate `minAvailable: 2` until replacement pods become ready on another node.

---

## ☘️ Step 5: Uncordon Nodes

Allow nodes to accept pods again:
```bash
kubectl uncordon minikube-m02
kubectl uncordon minikube-m03
```

Verify node status:
```bash
kubectl get nodes
```

---

# 🧩 PART 2 — Horizontal Pod Autoscaler (HPA)

HPA automatically scales the number of pod replicas up or down based on CPU utilization metrics collected by `metrics-server`.

---

## ☘️ Step 6: Enable Metrics Server in Minikube

Enable `metrics-server`:
```bash
minikube addons enable metrics-server
```

Verify metrics-server is active (it may take 1–2 minutes to gather initial metrics):
```bash
kubectl top nodes
```

---

## ☘️ Step 7: Configure and Apply HPA

Explore `hpa.yaml`:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  minReplicas: 2
  maxReplicas: 6
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

Apply the HPA manifest:
```bash
kubectl apply -f hpa.yaml
```

Check HPA status:
```bash
kubectl get hpa
```

---

## ☘️ Step 8: Simulate High Load to Test HPA Scaling

To trigger autoscaling, generate CPU load inside one of the `web` pods:

Identify a running `web` pod:
```bash
kubectl get pods -l app=web
```

Exec into the pod:
```bash
kubectl exec -it <web-pod-name> -- /bin/sh
```

Inside the container, run a CPU-intensive loop:
```sh
while true; do :; done
```
*(Keep this terminal open)*

---

## ☘️ Step 9: Observe HPA Scaling Up

Open a **second terminal** and monitor the HPA and pod replicas:

```bash
kubectl get hpa -w
```
or
```bash
kubectl get pods -l app=web -w
```

*Observation*: As CPU utilization rises above 50%, HPA will automatically scale the `web` deployment replicas up towards `maxReplicas: 6`.

---

## ☘️ Step 10: Stop Load and Observe Scale Down

Return to the first terminal and press `Ctrl + C` to stop the CPU loop.

Monitor the HPA in the second terminal:
```bash
kubectl get hpa -w
```

*Observation*: As CPU utilization drops back down, HPA will scale the replicas down to `minReplicas: 2`.

---

## ☘️ Step 11: Cleanup

Clean up all resources created in Lab 12:

```bash
cd ~/swift_training/Lab12
kubectl delete -f .
```

---

## ✅ End of Lab
You have successfully tested:
1. **PodDisruptionBudget (PDB)** to protect availability during node maintenance.
2. **Horizontal Pod Autoscaler (HPA)** to automatically scale pods under heavy CPU load!