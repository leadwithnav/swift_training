🧩 CHALLENGE PART 1 — Namespace Design
Create frontend and database namespace
NodeJS -->	frontend namespace
MongoDB --> database namespace


🧩 CHALLENGE PART 2 — Add Resource Requests & Limits
Add below resource limit to Nodejs
requests:
  cpu: 100m
  memory: 256Mi
limits:
  cpu: 300m
  memory: 512Mi

🧩 CHALLENGE PART 3 — Node Affinity
MongoDB must run ONLY on database nodes:
node-type=database

Label the node minikube-m02 with above label and then make sure your mongodb nodes run only on that node

🧩 CHALLENGE PART 4 — Taints and Tolerations
Apply taints on minikube-m02 and make sure that MongoDB also tolerate the taint
kubectl taint nodes minikube-m02 db=true:NoSchedule

🧩 CHALLENGE PART 5 — Pod Disruption Budget (PDB)
Frontend must have a pdb with: maxUnavailable: 1

🧩 CHALLENGE PART 6 — Horizontal Pod Autoscaler (HPA)

There must be a HPA for NodeJS frontend:
minReplicas: 2
maxReplicas: 6
targetCPUUtilization: 50%

🧩 CHALLENGE PART 7 — RBAC

Create user:
student-user

User permissions:

Action	Namespace	Allowed?
get pods	frontend	YES
get pods	database	NO
delete pods	any	NO

🧩 CHALLENGE PART 9 — Helm Chart
You must build a working Helm chart using below command:
helm create myhelmchart

myhelmchart/
  Chart.yaml
  values.yaml
  templates/
    frontend-deployment.yaml
    frontend-service.yaml
    mongodb-statefulset.yaml
    mongodb-service.yaml
    ingress.yaml
    pdb.yaml
    hpa.yaml
    rbac.yaml

🧩 CHALLENGE PART 10 — Install the Helm Chart
helm install myhelm ./myhelmchart

