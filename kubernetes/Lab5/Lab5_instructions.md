# ✅ Lab 7: Collect User Data with Flask Form and Store in PostgreSQL (ClusterIP)

**Time:** 25–30 Minutes

---

## 🧾 Lab Summary

In this lab, you will deploy a Flask application on Kubernetes that shows a form to collect a user's name and age, and stores the data in a PostgreSQL database using a ClusterIP service. You’ll test the entire flow end-to-end.

---

## 🎯 Objectives

- 🚀 Deploy PostgreSQL with a ClusterIP service
- 🐍 Deploy Flask app that inserts submitted form data into PostgreSQL
- 🧪 Submit user data through a browser
- ✅ Confirm successful insertions

---

## ☘️ Pre-requiste : Setup K3s Cluster
1. Stop Minikube
```bash
minikube stop
minikube delete
```


1. Run below to start k3s cluster

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/k3s.yaml
sudo chown $USER:$USER $HOME/k3s.yaml
export KUBECONFIG=$HOME/k3s.yaml
```

## ☘️ Step 1: Flask App Code (`app.py`)

Explore the new code in Lab5/app.py file. Don't worry the image for this code is already pushed in Dockerhub.


```python
from flask import Flask, request
import psycopg2

app = Flask(__name__)

@app.route('/')
def index():
    return '''
        <h2>User Form</h2>
        <form method="POST" action="/submit">
            <label>Username:</label>
            <input type="text" name="username" required><br><br>
            <label>Age:</label>
            <input type="number" name="age" required><br><br>
            <input type="submit" value="Submit">
        </form>
    '''

@app.route('/submit', methods=['POST'])
def submit():
    username = request.form.get('username')
    age = request.form.get('age')

    try:
        conn = psycopg2.connect(
            host="postgres-service",
            database="flaskdb",
            user="flaskuser",
            password="flaskpass"
        )
        cur = conn.cursor()
        cur.execute("""
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                username TEXT NOT NULL,
                age INTEGER NOT NULL
            );
        """)
        cur.execute("INSERT INTO users (username, age) VALUES (%s, %s);", (username, age))
        conn.commit()
        cur.close()
        conn.close()
        return f"<h3>Thank you, {username}! Your age {age} has been recorded.</h3>"
    except Exception as e:
        return f"<h3>Error: {str(e)}</h3>"
```

---

## ☘️ Step 2: Explore PostgreSQL Deployment 

Explore the posgtres deployment file 

### `postgres-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: flaskdb
        - name: POSTGRES_USER
          value: flaskuser
        - name: POSTGRES_PASSWORD
          value: flaskpass
        ports:
        - containerPort: 5432
  ```

## ☘️ Step 3: Deploy Postgres

```bash
cd ~/swift_training/Lab5
kubectl apply -f postgres-deployment.yaml
```
check pod status

```bash
kubectl get pod
```
Wait for Pod to come in running state.


## ☘️ Step 4: Explore Postgres Service

### `postgres-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
spec:
  type: ClusterIP
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
```

## ☘️ Step 5: Deploy Postgres Service

```bash
kubectl apply -f postgres-service.yaml
kubectl get svc
```


## ☘️ Step 6: Flask Deployment

### `flask-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: flask
  template:
    metadata:
      labels:
        app: flask
    spec:
      containers:
      - name: flask-container
        image: technoavengers/flask-app-userform
        ports:
        - containerPort: 5000
```

---

## ☘️ Step 7: Deploy Flask APP

```bash
kubectl apply -f flask-deployment.yaml
```

## ☘️ Step 8: Expose Flask APP

```bash
kubectl apply -f flask-service.yaml
```


## ☘️ Step 9: Access the Flask App

### 🔍 To get the EC2 public IP address:
Run the following command in terminal and it will provide you public IP address of EC2 machine you are using:
```bash
curl http://169.254.169.254/latest/meta-data/public-ipv4
```
### 🔍 Open your local browser and go to:
Replace the EC2-Address that you have recieved in last command in below URL

  👉 `http://<your-ec2-public-ip>:30000`

---

## ☘️ Step 10: Test the App

- Fill in a **username** and **age**
- Click **Submit**
- You should see:  
  `Thank you, <name>! Your age <age> has been recorded.`

---

## ☘️ Step 11: Verify DB (Optional)

Inside terminal, connect to the postgres pod:

```bash
kubectl exec -it <postgres-pod-name> -- psql -U flaskuser -d flaskdb
```

Then run:

```sql
SELECT * FROM users;
```

---

## ☘️ Step 12: Cleanup

```bash
kubectl delete -f flask-deployment.yaml
kubectl delete -f flask-service.yaml
kubectl delete -f postgres-deployment.yaml
kubectl delete -f postgress-service.yaml
```

---

## ✅ Conclusion

In this lab, you:

- Built a form-based Flask web app
- Inserted submitted data into PostgreSQL via Kubernetes networking
- Validated the full workflow with a browser

---

🎉 **Well done!** You've now built and deployed a flask app on Kubernetes using a database backend.  
✨ **END OF LAB** ✨