
# ✅ Lab 3: Expose Flask App using NodePort

**Time:** 15 Minutes

---

## 🧾 Lab Summary

In this lab, you will expose your Python-Flask application running on Kubernetes using a **NodePort** service. This allows you to access the app using a specific port on the Node.

---

## 🎯 Objectives

- 🌐 Create a NodePort service to expose the Flask app
- 🚪 Access the app via external IP and port 30000

---

## ☘️ Pre-requisite: Setup Minikube with NodePort Support

Stop & Start Minikube with the following command to ensure port 30000 is exposed:

```bash
minikube stop
minikube start --driver=docker --ports=30000:30000
```


## ☘️ Step 1: Run the Flask APP Replica Set

Go to folder

```bash
cd ~/swift_training/kubernetes/Lab3
```

Create the same replica set again with 3 replicas as we explored in the last lab.

```bash
kubectl apply -f flask_replicaset.yaml
```

---

## ☘️ Step 2: Explore NodePort YAML File

Open the file `flask_nodeport_service.yaml`. Here's what it contains:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-nodeport
spec:
  type: NodePort
  selector:
    app: flask
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
      nodePort: 30000
```

**Key Points:**
- `type: NodePort` - Exposes the service on a static port on every Node
- `nodePort: 30000` - The external port for accessing the service
- `targetPort: 5000` - The port the Flask app listens on

---

## ☘️ Step 3: Deploy the NodePort Service

```bash
kubectl apply -f flask_nodeport_service.yaml
```

Verify the service was created successfully:

```bash
kubectl get svc flask-nodeport
```

You should see output similar to:

```
NAME               TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
flask-nodeport     NodePort   10.96.xxx.xxx   <none>        5000:30000/TCP   1m
```

---

## ☘️ Step 5: Access the Flask App

Access the Flask app via curl:

```bash
curl localhost:30000
```

---

## ☘️ Step 6: Cleanup

```bash
kubectl delete svc flask-nodeport
kubectl delete rs flask-replicaset
```

---

## ✅ Conclusion

🎉 **Congratulations! You have completed this lab.**

In this lab, you learned how to:

- Create a NodePort service to expose your Flask app
- Access the app via port 30000

✨ **END OF LAB** ✨
