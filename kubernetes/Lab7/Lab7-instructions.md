# Lab: Use ConfigMap for PostgreSQL Credentials in Flask App

## 🧩 Objective

You will:
- Create a ConfigMap and Secret to store PostgreSQL connection details.
- Inject values into PostgreSQL and Flask pods.
- Test Application

---

## ☘️ Pre-requiste : Setup K3s Cluster
1. Start Minikube
```bash
minikube start --driver=docker --ports=30000:30000
```


## 🚀 Step-by-Step Guide

### Step 1: Apply ConfigMap

```bash
cd ~/swift_training/Lab7
kubectl apply -f configmap.yaml
```

Check Configmap

```bash
kubectl get configmap
```

### Step 2: Create Secret for Postgres Credentials
```bash
kubectl create secret generic postgres-secret \
  --from-literal=DB_USER=flaskuser \
  --from-literal=DB_PASSWORD=flaskpass
```
Check Secrets
```bash
kubectl get secret
```

### Step 3: Create PVC with Storage Class

```bash
cd ~/swift_training/Lab6
kubectl apply -f postgres-pv-pvc.yaml
```

### Step 4: Deploy PostgreSQL

```bash
kubectl apply -f postgres-deployment.yaml
kubectl apply -f postgres-service.yaml
```
Check Postgres Pod & Service
```bash
kubectl get pod
kubectl get svc
```


### Step 5: Deploy Flask App

```bash
kubectl apply -f flask-deployment.yaml
kubectl apply -f flask-service.yaml
```

Check Flask Pod & Service
```bash
kubectl get pod
kubectl get svc
```

### Step 6: Connect to Flask Pod

Connect to Flask Pod terminal 
```bash
kubectl exec -it flask-pod-name -- bash
```
Once inside the pod, check for environment variables that you have set in configmap
```bash
env
```

Once inside the pod, check for mounted secret
```bash
cat /mnt/secrets/DB_USER
cat /mnt/secrets/DB_PASSWORD
```

Exit the pod
```bash
exit
```

## ☘️ Step 7: Access the Flask App

### 🔍 To get the EC2 public IP address:
Run the following command in terminal and it will provide you public IP address of EC2 machine you are using:
```bash
curl http://169.254.169.254/latest/meta-data/public-ipv4
```
### 🔍 Open your local browser and go to:
Replace the EC2-Address that you have recieved in last command in below URL

  👉 `http://<your-ec2-public-ip>:30000`

---

## ☘️ Step 8: Test the App

- Fill in a **username** and **age**
- Click **Submit**
- You should see:  
  `Thank you, <name>! Your age <age> has been recorded.`

---

## 🧹 Cleanup

```bash
cd ~/swift_training/Lab7
kubectl delete -f .
```
