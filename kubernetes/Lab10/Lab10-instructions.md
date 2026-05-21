
# ✅ Lab 10: Using and Understanding Helm Commands in Kubernetes

**Time**: 20–25 mins

## 🧠 Lab Summary
In this lab, participants will learn how to use Helm—the package manager for Kubernetes—to manage applications with ease. You will understand how to install Helm charts, inspect available charts, customize deployments with values files, and manage release lifecycles. Helm simplifies deployments by abstracting complex Kubernetes configurations into reusable charts.

---

## 🎯 Objectives
- Install and configure Helm.
- Add a Helm repository.
- Search for available charts.
- Install a chart with default and custom values.
- Upgrade and rollback a release.
- Uninstall a Helm release.

---

## 🔍 Introduction

### 🔧 What is Helm?
Helm is a package manager for Kubernetes. It simplifies the deployment and management of applications by packaging Kubernetes resources into charts.

Think of Helm charts like "apt" or "yum" but for Kubernetes.

### 📦 What is a Helm Chart?
A Helm chart is a collection of YAML files that define a related set of Kubernetes resources.

### ✅ Benefits of Helm:
- Easy application deployment
- Version control for Kubernetes apps
- Parameterized templates via `values.yaml`

---
## ☘️ Pre-requiste : Setup Minikube Cluster
```bash
minikube start --driver=docker --ports=30000:30000
```

check your nodes
```bash
kubectl get node
```

## 🪜 Step 1: Verify or Install Helm

Check if Helm is already installed:

```bash
helm version
```

If not installed, install Helm (for Linux):

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

---

## 📦 Step 2: Add a Helm Repository

Add the Bitnami Helm chart repository:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Update the repo to fetch the latest charts:

```bash
helm repo update
```

---

## 🔍 Step 3: Search for Available Charts

Search for charts related to mysql:

```bash
helm search repo mysql
```

---

## 🚀 Step 4: Install a Helm Chart

Install the Bitnami mysql chart:

```bash
helm install mysql bitnami/mysql \
  --set image.repository=bitnamilegacy/mysql \
  --set image.tag=8.4
```

## 🚀 Step 5: Check the release and pods:

```bash
helm list
kubectl get pods
```

## 🚀 Step 6: Check the service type:

Above helm chart also has created a service my-nginx, let's check the type of service
```bash
kubectl get svc
```

Did you noticed that svc type is LoadBalancer, let's change it to NodePort with custom-values.yaml file.

---

## 🧰 Step 7: Customize with `values.yaml`

You have been provided with a `custom-values.yaml` file in Lab9 folder with below content

```yaml
service:
  type: NodePort
```

## 🧰 Step 8: Upgrade Helm with custom values

Let's upgrade the helm chart with custom values using `custom-values.yaml` file:

```bash
helm upgrade mysql bitnami/mysql -f custom-values.yaml
```

It will override default service type to type NodePort because of my custom value.

---

## 🚀 Step 9: Check the service type:

```bash
kubectl get svc
```

Did you noticed that this time svc type is NodePort



## 🔄 Step 10: Upgrade with --set command

You can also Upgrade your release with a new value by setting in command itself:
Make sure you are in Lab10 folder in vscode terminal before running below command

```bash
helm upgrade mysql bitnami/mysql --set primary.service.type=ClusterIP
```

## 🚀 Step 11: Check the service type:

```bash
kubectl get svc
```

Did you noticed that this time svc type is ClusterIP

## 🔄 Step 12: Rollback to previous Version

Rollback to the previous version:

```bash
helm rollback mysql
```


## 🚀 Step 13: Check the service type:

```bash
kubectl get svc
```

Did you noticed that this time service type is NodePort again because of rollback

---

## 🧹 Step 7: Uninstall a Release

Remove the deployed Helm release:

```bash
helm uninstall mysql
```

---

## ✅ End of Lab
