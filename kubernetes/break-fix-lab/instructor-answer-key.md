# Instructor Answer Key: Break-Fix Lab

This document contains the answers and remediation steps for the student troubleshooting lab. 

## How to Set Up the Lab
Before the students arrive, simply apply the broken deployment file to the cluster:
`kubectl apply -f setup-broken-app.yaml`

---

## Task 1: The Database Outage (StatefulSets, PVCs, StorageClasses)
**Bugs Introduced:** The `volumeClaimTemplate` in the StatefulSet requests a `storageClassName` called `ultra-fast-ssd` which does not exist.

**Answers:**
1. **Pod Status:** The `inventory-db-0` pod is stuck in `Pending`.
2. **PVC Status:** The PVC is stuck in `Pending` because there is no StorageClass named `ultra-fast-ssd` to dynamically provision the volume. 
3. **Command:** `kubectl describe pvc data-inventory-db-0` (Events will show "storageclass.storage.k8s.io \"ultra-fast-ssd\" not found").
4. **Proposed Fix:** Edit the StatefulSet and remove the `storageClassName: ultra-fast-ssd` line (so it defaults to the standard class) or change it to an existing storage class on the cluster (e.g., `standard`). Note: Modifying `volumeClaimTemplates` on an existing StatefulSet is forbidden. Students will have to delete the StatefulSet (`kubectl delete sts inventory-db -n break-fix-lab`) and recreate it, or delete the PVC and the StatefulSet.

## Task 2: The API Failure (Deployments, ConfigMaps)
**Bugs Introduced:** The `inventory-api` Deployment uses `envFrom` pointing to a ConfigMap named `api-config-wrong`. The actual ConfigMap is named `inventory-api-config`.

**Answers:**
1. **Pod Status:** The pods are stuck in `CreateContainerConfigError`.
2. **Reason:** The kubelet cannot find the referenced ConfigMap to inject the environment variables.
3. **ConfigMap Name:** The existing ConfigMap is named `inventory-api-config`. The deployment is looking for the wrong name.
4. **Proposed Fix:** Edit the deployment (`kubectl edit deploy inventory-api -n break-fix-lab`) and change the `configMapRef.name` from `api-config-wrong` to `inventory-api-config`.

## Task 3: The Background Worker (ReplicaSets, Pods)
**Bugs Introduced:** The image tag for the ReplicaSet is `busybox:1.99.9-typo`, which does not exist.

**Answers:**
1. **Issue:** The container runtime cannot pull the image, resulting in `ImagePullBackOff` or `ErrImagePull`.
2. **Command:** `kubectl describe pod <worker-pod-name> -n break-fix-lab`
3. **Proposed Fix:** Edit the ReplicaSet (`kubectl edit rs inventory-worker -n break-fix-lab`) and fix the image tag (e.g., `busybox:latest` or `busybox:1.36`). Since modifying a ReplicaSet template does not automatically restart existing pods, students must also delete the broken pods (`kubectl delete pods -l app=inventory-worker -n break-fix-lab`) so the ReplicaSet can recreate them with the correct image.

## Task 4: The Frontend Disconnect (Services, Deployments)
**Bugs Introduced:** The Service selector is `app: inventory-ui`, but the Deployment labels the pods as `app: inventory-frontend`.

**Answers:**
1. **Pod Status:** Yes, the frontend pods are perfectly healthy and `Running`.
2. **Endpoints:** `kubectl get endpoints inventory-frontend-svc -n break-fix-lab` will show `<none>` because the selector does not match any pods.
3. **Discrepancy:** Service selector expects `inventory-ui`, but pods have `inventory-frontend`.
4. **Proposed Fix:** Edit the Service (`kubectl edit svc inventory-frontend-svc -n break-fix-lab`) and change the selector to `app: inventory-frontend`. Traffic will immediately begin routing.
