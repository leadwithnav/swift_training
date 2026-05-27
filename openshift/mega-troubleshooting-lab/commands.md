# Instructor Guide: Troubleshooting & Solutions

This guide will walk you through how to troubleshoot each issue with your students and how to fix them.

## 1. Setup the Lab
Apply the broken application:
```bash
oc apply -f resource_files/01-setup.yaml
```

Check the status of everything:
```bash
oc get all
oc get hpa
oc get pdb
oc get route
```

---

## Issue 1: Frontend Pods are Pending (Resource Limits)
**Troubleshooting steps:**
1. Check the pods: `oc get pods`
2. Describe a pending frontend pod: `oc describe pod -l app=frontend`
3. Look at the `Events` section at the bottom. You will see a `FailedScheduling` error indicating insufficient CPU.

**The Fix:**
The developer requested `10` CPU cores, which exceeds the sandbox capacity (and the LimitRange).
Edit the deployment:
```bash
oc edit deployment frontend
```
Change `cpu: "10"` to `cpu: "100m"`. The pods will immediately start creating.

---

## Issue 2: Frontend PDB is Misconfigured
**Troubleshooting steps:**
1. Check the PDBs: `oc get pdb`
2. Notice that `ALLOWED DISRUPTIONS` is 0, and it requires `5` `MIN AVAILABLE`.
3. Look at the frontend deployment replicas: It is only set to `2`. A PDB requiring 5 available pods for a deployment that only has 2 replicas is impossible to satisfy.

**The Fix:**
Edit the PDB:
```bash
oc edit pdb frontend-pdb
```
Change `minAvailable: 5` to `minAvailable: 1`.

---

## Issue 3: Backend HPA shows `<unknown>`
**Troubleshooting steps:**
1. Check the HPA: `oc get hpa`
2. The `TARGETS` column shows `<unknown>/50%`.
3. Describe the HPA: `oc describe hpa backend-hpa`
4. Look at the `Events` or `Conditions`. It will say: `failed to get cpu utilization: missing request for cpu`.
5. Explain to the students: The HPA requires the Pod to have CPU requests defined so it can calculate the utilization percentage!

**The Fix:**
Edit the backend deployment to add CPU requests:
```bash
oc edit deployment backend
```
Add the `resources` block to the container:
```yaml
        resources:
          requests:
            cpu: 100m
```
*(Wait a couple of minutes, run `oc get hpa`, and the `<unknown>` will change to a real percentage).*

---

## Issue 4: Database Pod stuck in Pending (Pod Anti-Affinity)
**Troubleshooting steps:**
1. Check the database pods: `oc get pods -l app=database` (One is running, one is pending).
2. Describe the pending pod: `oc describe pod <pending-database-pod-name>`
3. Look at the `Events`. It will say `node(s) didn't match pod anti-affinity topology key`.
4. The topology key used is `topology.kubernetes.io/non-existent-zone`. This zone label doesn't exist on any nodes in the cluster!

**The Fix:**
Edit the database deployment to use the standard hostname topology key.
```bash
oc edit deployment database
```
Change `topologyKey: "topology.kubernetes.io/non-existent-zone"` to `topologyKey: "kubernetes.io/hostname"`.

---

## Issue 5: Frontend cannot reach Backend (Network Policies)
**Troubleshooting steps:**
*(Note: You must fix Issue 1 first so the frontend pod is running!)*
1. Exec into the frontend pod: `oc exec -it <frontend-pod-name> -- sh`
2. Try to curl the backend: `curl -m 3 http://backend` (It will time out).
3. Exit the pod. Check network policies: `oc get networkpolicy`
4. Describe the policy: `oc describe networkpolicy backend-policy`
5. The policy only allows traffic from pods with the label `app=wrong-frontend`.

**The Fix:**
Edit the network policy:
```bash
oc edit networkpolicy backend-policy
```
Change `app: wrong-frontend` to `app: frontend`.

---

## Issue 6: Route returns 503 Error
**Troubleshooting steps:**
1. Get the route URL: `oc get route frontend-route`
2. Try to access it via curl or a browser: `curl http://<route-url>`
3. You will get an "Application is not available" (503) error.
4. Check the route configuration: `oc describe route frontend-route`
5. Check the service configuration: `oc describe svc frontend`
6. Notice that the Service exposes port `80`, but the Route is trying to send traffic to `targetPort: 8080`.

**The Fix:**
Edit the route:
```bash
oc edit route frontend-route
```
Change `targetPort: 8080` to `targetPort: 80`. The application will immediately be reachable!

---

## Issue 7: DB Migrator Job fails due to RBAC
**Troubleshooting steps:**
1. Check the jobs and pods: `oc get pods`
2. Notice the `db-migrator-xxx` pod has a status of `Error`.
3. Check the logs of the pod: `oc logs <db-migrator-pod-name>`
4. You will see an error: `Error from server (Forbidden): configmaps is forbidden: User "system:serviceaccount:<your-project>:migrator-sa" cannot list resource "configmaps"`.
5. Check the RoleBinding: `oc get rolebinding migrator-binding -o yaml`
6. Notice that the subject ServiceAccount is named `migrator-serviceaccount` but the actual ServiceAccount used by the job is `migrator-sa`.

**The Fix:**
Edit the RoleBinding:
```bash
oc edit rolebinding migrator-binding
```
Change the `name` under `subjects` from `migrator-serviceaccount` to `migrator-sa`.
Wait for the job to retry (or delete and recreate it), and it will succeed!
