# Part-2  Horizontal Pod Autoscaler (HPA)
HPA automatically adjusts the number of pod replicas based on observed CPU utilization or other metrics.

---

## ☘️ Step 1: Install Metrics Server (if not already)
The Metrics Server is a cluster-wide aggregator of resource usage data (like CPU and memory) in Kubernetes. It collects metrics from the Kubelets on each node and provides it through the Kubernetes API

```bash
minikube addons enable metrics-server
```


## ☘️ Step 2: Verify it's running:

```bash
kubectl top nodes
```
## ☘️ Step 3: Create deployment
Check the deployment file, check out the resource section to see requested resources and what is limit on resources.

```bash
cd ~/swift_training/Lab15
kubectl apply -f deployment_with_resources.yaml
```

---

## ☘️ Step 4: Apply HPA to the Deployment

You have been provided with hpa.yaml in your Lab13, apply the file to create Horizontal Pod Autoscaler

```bash
kubectl apply -f hpa.yaml
```

## ☘️ Step 4: Check HPA status:

```bash
kubectl get hpa
```
```


## ☘️ Step 5: Simulate High Load to Test HPA Scaling
To test the HPA, simulate CPU load on one of the  pods. You can do this by running a CPU-intensive process inside a  pod:
– Identify a running  pod:

```bash
kubectl get pods
```

## ☘️ Step 6: Connect to Pod terminal

```bash
kubectl exec -it <pod-name> -- /bin/sh
```


## ☘️ Step 7 : Run a CPU load inside the pod (e.g., an infinite loop):

```bash
while true; do :; done
```

Keep the above terminal open

This will artificially increase the CPU usage and trigger the HPA to scale up the number of pods.

## ☘️ Step 8 : Monitor the HPA
Open a new terminal and Run the following command to monitor the HPA and observe it scaling the MinIO pods:

```bash
kubectl get hpa -w
```


As the CPU usage increases, the HPA will increase the number of  replicas up to the maximum (5 replicas, in this case). Once the CPU usage decreases, the HPA will scale down the pods.


## ☘️ Step 9: Cleanup

```bash
cd ~/swift_training/Lab15
kubectl delete -f .
```

## ✅ End of Lab
