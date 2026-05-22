# Kubernetes Troubleshooting Command Reference

This cheat sheet provides the essential `kubectl` commands needed to diagnose, investigate, and resolve issues across various Kubernetes resources.

## 🧭 General Troubleshooting & Cluster State
Commands to get a high-level overview of what is failing in a namespace.

* `kubectl get all -n <namespace>` - Lists all core resources in the namespace.
* `kubectl get events -n <namespace> --sort-by='.metadata.creationTimestamp'` - Extremely useful for finding why pods are failing to schedule, storage issues, or image pull errors.
* `kubectl api-resources` - Lists all resource types available on the cluster.
* `kubectl explain <resource>` - Explains the fields available in a resource's YAML spec (e.g., `kubectl explain pod.spec.containers`).

---

## 📦 Pods
Pods are the smallest deployable units. When things go wrong, they often manifest here.

* `kubectl get pods` - List pods and their current `STATUS` (Running, Pending, CrashLoopBackOff, ImagePullBackOff).
* `kubectl get pods -o wide` - List pods with extra details, including the Node they are running on and their internal IP address.
* `kubectl describe pod <pod-name>` - Deep dive into a pod. Look at the `Events:` section at the bottom for errors (e.g., failed scheduling, missing ConfigMaps, readiness probe failures).
* `kubectl logs <pod-name>` - View standard output (stdout) logs from the application running inside the pod.
* `kubectl logs <pod-name> -c <container-name>` - View logs for a specific container (if the pod has multiple containers).
* `kubectl logs <pod-name> --previous` - View logs for a pod that crashed and was restarted (CrashLoopBackOff).
* `kubectl exec -it <pod-name> -- /bin/sh` - Open an interactive shell inside a running pod to test connectivity or view files (use `/bin/bash` if available).
* `kubectl delete pod <pod-name>` - Delete a pod. (If managed by a Deployment/ReplicaSet, a new one will instantly be recreated).

---

## 🚀 Deployments & ReplicaSets
These resources manage the lifecycle and scaling of Pods.

* `kubectl get deployments` - View the desired vs. actual ready state of Deployments.
* `kubectl describe deployment <deployment-name>` - View deployment rollout history, scaling events, and the ReplicaSets it manages.
* `kubectl get replicaset` - View the active ReplicaSets. If a pod isn't being created, check the ReplicaSet events.
* `kubectl describe replicaset <rs-name>` - Check why a ReplicaSet is failing to create pods (e.g., quota issues, bad image).
* `kubectl edit deployment <deployment-name>` - Open the live YAML manifest in your terminal editor to fix bugs on the fly.
* `kubectl rollout history deployment <deployment-name>` - View previous deployment revisions.
* `kubectl rollout undo deployment <deployment-name>` - Instantly rollback to the previous working version if a new deployment breaks.

---

## 💾 StatefulSets
Used for stateful applications like databases that require stable network IDs and persistent storage.

* `kubectl get statefulsets` - List StatefulSets.
* `kubectl describe statefulset <sts-name>` - View events related to PVC creation, pod ordering, and storage binding.
* `kubectl edit statefulset <sts-name>` - Edit the StatefulSet. *(Note: Many fields in a StatefulSet, like `volumeClaimTemplates`, are immutable and cannot be edited on the fly. You may need to delete and recreate).*
* `kubectl delete statefulset <sts-name> --cascade=orphan` - Deletes the StatefulSet but leaves the Pods running (useful for delicate migrations).

---

## 🔌 Services & Network Routing
If pods are running but cannot communicate, the issue is usually at the Service or Label Selector level.

* `kubectl get svc` - List Services, their ClusterIPs, and exposed Ports.
* `kubectl describe svc <svc-name>` - Crucial for troubleshooting networking. Pay attention to the `Endpoints:` field.
* `kubectl get endpoints <svc-name>` - Shows the actual Pod IPs the Service is routing traffic to. **If this says `<none>`, your Service `selector` labels do NOT match your Pod `labels`.**
* `kubectl get pods --show-labels` - Use this to compare your Pod labels against your Service selector.
* `kubectl port-forward svc/<svc-name> 8080:80` - Forward a local port (8080) to the Service port (80) to test an application from your local machine without needing an Ingress or NodePort.

---

## ⚙️ ConfigMaps & Secrets
Used for injecting configuration and sensitive credentials into Pods.

* `kubectl get cm` - List ConfigMaps.
* `kubectl describe cm <cm-name>` - View the plaintext configuration data stored inside the ConfigMap.
* `kubectl get secrets` - List Secrets.
* `kubectl describe secret <secret-name>` - View the keys within a secret (the values will be hidden).
* `kubectl get secret <secret-name> -o yaml` - View the Base64 encoded values of the secret.
* **Pro-tip for decoding secrets:** `echo "encoded-string" | base64 --decode` (Linux/Mac)
* `kubectl create secret generic <name> --from-literal=password=my-password` - Quickly create a secret from the CLI.

---

## 📂 Storage (PVCs & StorageClasses)
Used when a database or stateful app is stuck in `Pending` due to volume mounting issues.

* `kubectl get pvc` - Check if PersistentVolumeClaims are `Bound` or `Pending`.
* `kubectl describe pvc <pvc-name>` - Find out exactly why a PVC is pending (e.g., requested StorageClass doesn't exist, insufficient cloud provider quota).
* `kubectl get pv` - List the actual physical PersistentVolumes provisioned by the cluster.
* `kubectl get sc` (or `storageclasses`) - List the available storage classes you can request in your PVC.
