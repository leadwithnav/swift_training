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

*(Instructor Note: In the Developer Sandbox, there might only be 1 worker node available to your project. If so, the second pod will STILL stay pending because 2 pods cannot be scheduled on 1 node due to the anti-affinity rule. This is a great teaching moment about physical cluster constraints!)*

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

Test the connection again from the frontend pod, and it will immediately succeed!
