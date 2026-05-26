# Lab Commands

Ensure you are logged into your Sandbox and are currently inside your designated OpenShift project (you can verify with `oc project`).

## 1. Setup the Lab
Apply the application components and the broken network policies:
```bash
oc apply -f resource_files/01-setup.yaml
oc apply -f resource_files/02-broken-netpol.yaml
```

Wait for all the pods to be in the `Running` state:
```bash
oc get pods -w
```

## 2. Verify the Broken State

**Check Issue 1 (Frontend cannot reach Backend):**
Exec into the frontend pod and try to curl the backend service:
```bash
oc exec frontend -- curl -s -m 3 http://backend
```
*(Expected: It should hang and time out because the policy is broken).*

**Check Issue 2 (Test-pod can reach Database):**
Exec into the test-pod and try to curl the database service:
```bash
oc exec test-pod -- curl -s -m 3 http://database
```
*(Expected: It will succeed and return Nginx HTML, but it SHOULD timeout/fail if the policy was correct!).*

## 3. Identify and Fix the Issues

Inspect the current network policies to find the bugs:
```bash
oc get networkpolicy allow-backend -o yaml
oc get networkpolicy allow-database -o yaml
```

**Issues to fix:**
1. **Label Mismatch**: In the `allow-backend` policy, the `from:` selector looks for a pod with the label `tier: frontend`. However, the frontend pod actually has the label `app: frontend`.
2. **Over-permissive Rule**: In the `allow-database` policy, the `from:` selector uses an empty `namespaceSelector: {}`. This allows traffic from ANY namespace and ANY pod, which is why the `test-pod` can connect. It should be restricted to the backend pod using a `podSelector`.

**Corrected `allow-backend` policy:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend  # Fixed label here!
    ports:
    - port: 80
      protocol: TCP
```

**Corrected `allow-database` policy:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-database
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend  # Fixed selector here!
    ports:
    - port: 80
      protocol: TCP
```

## 4. Apply Fixes
You can edit the policies directly in your OpenShift cluster using the `oc edit` command (which opens vi/vim):
```bash
oc edit networkpolicy allow-backend
oc edit networkpolicy allow-database
```
*(Alternatively, you can fix the file in `resource_files/02-broken-netpol.yaml` and run `oc apply -f` again).*

## 5. Final Verification
Run the tests again to ensure everything works!

Frontend CAN reach backend:
```bash
oc exec frontend -- curl -s -m 3 http://backend
```
*(Should succeed and return HTML)*

Backend CAN reach database:
```bash
oc exec backend -- curl -s -m 3 http://database
```
*(Should succeed and return HTML)*

Test-pod CANNOT reach backend or database:
```bash
oc exec test-pod -- curl -s -m 3 http://backend
oc exec test-pod -- curl -s -m 3 http://database
```
*(Should time out for both!)*
