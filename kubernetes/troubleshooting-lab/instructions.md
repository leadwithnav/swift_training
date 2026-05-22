# Kubernetes Troubleshooting Challenge: Break-Fix Lab

## Overview
The platform engineering team applied a series of manifests to deploy the new Inventory Platform into the `break-fix-lab` namespace. 
However, the application is completely broken. None of the components are communicating, and some pods won't even start. 

Your job is to investigate the cluster, identify the root causes, and answer the following questions. DO NOT modify the resources until you have answered the questions.

## Investigation Tasks

### Task 1: The Database Outage (StatefulSets, PVCs, StorageClasses)
The database is deployed as a StatefulSet named `inventory-db`. 
1. What is the current status of the `inventory-db-0` pod?
2. Inspect the PersistentVolumeClaim (PVC) associated with this pod. Why is it stuck in the `Pending` state?
3. What `kubectl` command did you use to find the exact error message regarding the storage?
4. **Proposed Fix:** Fix theStatefulSet manifest file and apply the changes. What specific field did you change to resolve the storage issue?

### Task 2: The API Failure (Deployments, ConfigMaps)
The `inventory-api` Deployment is supposed to run our Node.js backend.
1. Are the `inventory-api` pods in a `Running` state? If not, what state are they in?
2. Investigate the pods to find out *why* they are failing to start. What missing resource is preventing the containers from initializing?
3. There is a ConfigMap in the namespace. What is its name, and why aren't the pods using it?
4. **Proposed Fix:** Fix the Deployment manifest file and apply the changes. What specific field did you change to resolve the configuration issue?

### Task 3: The Background Worker (ReplicaSets, Pods)
We have an independent ReplicaSet named `inventory-worker` running background cron jobs.
1. Describe the issue preventing the worker pods from starting.
2. What `kubectl` command provides the explicit error message about the container image?
3. **Proposed Fix:** Fix the ReplicaSet manifest file and apply the changes. What specific field did you change to resolve the image issue? *(Note: The correct image tag to use is `busybox:latest`)*

### Task 4: The Frontend Disconnect (Services, Deployments)
The frontend UI pods are running successfully, but users cannot reach the application.
1. Verify the `inventory-frontend` pods. Are they `Running` and ready?
2. Check the `inventory-frontend-svc` Service. Run the command to check its endpoints. What do you see?
3. Compare the Service's `selector` with the `labels` applied to the frontend pods. What is the discrepancy?
4. **Proposed Fix:** Fix the Service manifest file and apply the changes. What specific field did you change to resolve the connectivity issue?

## Remediation
Bring the entire platform to a healthy state.
