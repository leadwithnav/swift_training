# 🧪 Lab: Kubernetes Resource Management — Requests, Limits, QoS & LimitRanges

🕒 **Estimated Time**: 25 minutes  
🎯 **Target Topics**: Resource Requests & Limits, Quality of Service (QoS) Classes, Namespace LimitRanges

---

## 🎯 Lab Overview

Efficient resource management is vital in production Kubernetes environments. In this lab, you will learn how to:
1. Define **CPU & Memory Requests and Limits** for containers.
2. Understand and inspect Kubernetes **Quality of Service (QoS)** classes (`Guaranteed`, `Burstable`, `BestEffort`).
3. Configure a **LimitRange** to set default resource allocations and min/max boundaries for pods in a namespace.
4. Observe how Kubernetes handles pods that exceed LimitRange rules or memory limits.

---

## ☘️ Step 1: Create a Dedicated Namespace

To isolate our lab experiments, create a namespace named `resource-demo`:

```bash
kubectl create namespace resource-demo
kubectl config set-context --current --namespace=resource-demo
```

---

## ☘️ Step 2: Understanding QoS Classes

Kubernetes classifies Pods into three **Quality of Service (QoS)** classes depending on how requests and limits are set.

### 🔹 1. Guaranteed QoS Class
A pod is assigned the `Guaranteed` QoS class if **every container** in the pod has both CPU and Memory requests and limits explicitly set, and `requests == limits`.

Inspect `01-pod-guaranteed-qos.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-guaranteed
spec:
  containers:
  - name: app
    image: nginx:alpine
    resources:
      requests:
        cpu: "200m"
        memory: "256Mi"
      limits:
        cpu: "200m"
        memory: "256Mi"
```

Apply and inspect the QoS class:
```bash
kubectl apply -f 01-pod-guaranteed-qos.yaml
kubectl get pod pod-guaranteed -o jsonpath='{.status.qosClass}'
```
*Expected Output*: `Guaranteed`

---

### 🔹 2. Burstable QoS Class
A pod is assigned `Burstable` if at least one container has a request or limit set, but it does not satisfy the criteria for `Guaranteed` (e.g., limits are greater than requests).

Inspect `02-pod-burstable-qos.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-burstable
spec:
  containers:
  - name: app
    image: nginx:alpine
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "500m"
        memory: "512Mi"
```

Apply and inspect:
```bash
kubectl apply -f 02-pod-burstable-qos.yaml
kubectl get pod pod-burstable -o jsonpath='{.status.qosClass}'
```
*Expected Output*: `Burstable`

---

### 🔹 3. BestEffort QoS Class
A pod is assigned `BestEffort` if **no containers** in the pod have any CPU or Memory requests or limits specified.

Inspect `03-pod-besteffort-qos.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-besteffort
spec:
  containers:
  - name: app
    image: nginx:alpine
```

Apply and inspect:
```bash
kubectl apply -f 03-pod-besteffort-qos.yaml
kubectl get pod pod-besteffort -o jsonpath='{.status.qosClass}'
```
*Expected Output*: `BestEffort`

---

### 💡 Summary of QoS Eviction Priority
When a node runs out of memory, Kubernetes evicts pods in the following order:
1. **`BestEffort`** pods (evicted first).
2. **`Burstable`** pods (evicted second, if consuming beyond their requests).
3. **`Guaranteed`** pods (evicted last, highly protected).

---

## ☘️ Step 3: Enforcing Resource Governance with LimitRanges

A **LimitRange** enforces resource policies within a namespace. It can:
- Assign **default requests and limits** to pods that do not specify them.
- Enforce **minimum and maximum** allowed CPU/Memory boundaries.

### 🔹 Apply the LimitRange
Inspect `04-limitrange.yaml`:
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-mem-limit-range
spec:
  limits:
  - default:          # Default limit if unspecified
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:   # Default request if unspecified
      cpu: "200m"
      memory: "256Mi"
    max:              # Maximum limit allowed for any container
      cpu: "1"
      memory: "1Gi"
    min:              # Minimum request required for any container
      cpu: "50m"
      memory: "64Mi"
    type: Container
```

Apply the LimitRange:
```bash
kubectl apply -f 04-limitrange.yaml
kubectl describe limitrange cpu-mem-limit-range
```

---

### 🔹 Test Default Resource Injection
Create a pod without specifying any resource requests or limits (`05-pod-without-resources.yaml`):

```bash
kubectl apply -f 05-pod-without-resources.yaml
```

Inspect the pod's container resources to verify the LimitRange automatically injected the default values:

```bash
kubectl get pod pod-auto-resources -o jsonpath='{.spec.containers[0].resources}'
```

*Expected Output*:
```json
{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"200m","memory":"256Mi"}}
```

---

### 🔹 Test Exceeding LimitRange Bounds
Attempt to create a pod that requests resources exceeding the `max` boundary set by the LimitRange (`06-pod-exceeding-limitrange.yaml`):

```bash
kubectl apply -f 06-pod-exceeding-limitrange.yaml
```

*Expected Output*:
```text
Error from server (Forbidden): error when creating "06-pod-exceeding-limitrange.yaml": 
pods "pod-too-large" is forbidden: maximum cpu usage per Container is 1, but limit is 2
```

The Kubernetes admission controller **rejects** the pod creation because it violates the LimitRange policy!

---

## 🔍 Verification Checklist

Verify your lab context and resources:

```bash
kubectl get pods -n resource-demo
kubectl get limitrange -n resource-demo
```

Check QoS classes for all running pods:
```bash
kubectl get pods -n resource-demo -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass,CPU_REQ:.spec.containers[*].resources.requests.cpu,MEM_REQ:.spec.containers[*].resources.requests.memory
```

---

## 🧹 Cleanup

To clean up all resources created in this lab:

```bash
kubectl delete namespace resource-demo
kubectl config set-context --current --namespace=default
```

---

## ✅ End of Lab
You have successfully learned how to configure CPU & Memory requests/limits, inspect Pod QoS classes, and enforce LimitRange policies!
