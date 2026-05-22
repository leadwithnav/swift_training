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
4. **Proposed Fix:** What needs to be changed in the StatefulSet manifest to allow the PVC to bind?

### Task 2: The API Failure (Deployments, ConfigMaps)
The `inventory-api` Deployment is supposed to run our Node.js backend.
1. Are the `inventory-api` pods in a `Running` state? If not, what state are they in?
2. Investigate the pods to find out *why* they are failing to start. What missing resource is preventing the containers from initializing?
3. There is a ConfigMap in the namespace. What is its name, and why aren't the pods using it?
4. **Proposed Fix:** What specific field in the Deployment manifest needs to be updated?

### Task 3: The Background Worker (ReplicaSets, Pods)
We have an independent ReplicaSet named `inventory-worker` running background cron jobs.
1. Describe the issue preventing the worker pods from starting.
2. What `kubectl` command provides the explicit error message about the container image?
3. **Proposed Fix:** What is the correct action to resolve this?

### Task 4: The Frontend Disconnect (Services, Deployments)
The frontend UI pods are running successfully, but users cannot reach the application.
1. Verify the `inventory-frontend` pods. Are they `Running` and ready?
2. Check the `inventory-frontend-svc` Service. Run the command to check its endpoints. What do you see?
3. Compare the Service's `selector` with the `labels` applied to the frontend pods. What is the discrepancy?
4. **Proposed Fix:** How do you fix the routing so the Service successfully targets the frontend pods?

## Remediation
Once you have documented your answers, edit the live cluster resources (using `kubectl edit` or by fixing the manifest file and re-applying) to bring the entire platform to a healthy state.
