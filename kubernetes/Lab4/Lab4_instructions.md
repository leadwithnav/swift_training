# ✅ Lab 4: Deploy Flask App with Kubernetes Deployment and Rolling Updates

**Time:** 20 Minutes

---

## 🧾 Lab Summary

In this lab, you will learn how to use a **Kubernetes Deployment** to manage your Flask application. You’ll start by deploying version 1 of the application, then upgrade to version 2 and version 3 using rolling updates. You'll also learn how to inspect rollout history and perform rollbacks.

---

## 🎯 Objectives

- 📦 Deploy `flask-app:v1` using a Deployment
- 🔄 Upgrade to `flask-app:v2` and `flask-app:v3` with rolling updates
- 📜 Check rollout status and history
- ↩️ Perform rollback to previous versions

---

## ☘️ Step 1: Review Deployment YAML for v1

Open `Lab4/flask_deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-deployment
spec:
  replicas: 2
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

## ☘️ Step 2: Deploy the First Version (v1)

```bash
cd ~/swift_training/kubernetes/Lab4
kubectl apply -f flask_deployment.yaml
```

---

## ☘️ Step 3: Verify Deployment and Pods

```bash
kubectl get deployments
kubectl get pods
```
Did you noticed that pods are getting created in rolling update fashion as we discussed?

---

## ☘️ Step 4: Check Rollout Status

```bash
kubectl rollout status deployment flask-deployment
```

---

## ☘️ Step 5: Update Image to v2

Deploy new image and Check updated pods:

```bash
kubectl set image deployment flask-deployment flask-container=technoavengers/flask-app:v2
kubectl get pods
```

---

## ☘️ Step 6: Check Revision History

```bash
kubectl rollout history deployment flask-deployment
```

You should see revisions for both `v1` and `v2`.

---

## ☘️ Step 7: Update Image to v3

```bash
kubectl set image deployment flask-deployment flask-container=technoavengers/flask-app:v3
```

Again, check status and rollout:

```bash
kubectl rollout status deployment flask-deployment
kubectl rollout history deployment flask-deployment
```

---

## ☘️ Step 8: Perform Rollback

To rollback to the previous version (v2):

```bash
kubectl rollout undo deployment flask-deployment
```

Check the image version
```bash
kubectl describe deployment flask-deployment | grep -i image
```

If you want to roll back to a specific revision:

```bash
kubectl rollout undo deployment flask-deployment --to-revision=1
```

Check the image version again
```bash
kubectl describe deployment flask-deployment | grep -i image
```

---

## ☘️ Step 9: Cleanup

```bash
kubectl delete deployment flask-deployment
```

---

## ✅ Conclusion

In this lab, you:

- Created a Deployment to manage your Flask app
- Observed how Kubernetes handles rolling updates
- Explored deployment history and rollback capabilities

---

🎉 **Congratulations**, you've mastered rolling updates and rollback with Kubernetes Deployments!  
✨ **END OF LAB** ✨