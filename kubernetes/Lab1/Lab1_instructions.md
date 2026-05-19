# ✅ Lab 1: Create Custom Docker Image for a Python-Flask App

🕒 **Estimated Time:** 20–30 Minutes

---

## 🎯 Objectives

In this lab, you will:

- Use an existing Flask application provided in `Lab1`.
- Build and tag a Docker image from the app.
- Push your custom image to Docker Hub.
- Run the Flask app from your Docker image.
- Access the application via browser on port `5000`.

---

## ☘️ Step 1: Sign Up / Log In to Docker Hub

1. Visit [Docker Hub](https://hub.docker.com).
2. Create an account or log in if you already have one.
3. Note your Docker Hub **username** — you’ll use it for tagging your image later.

---

## ☘️ Step 2: Review Provided Files

Navigate to the `Lab1` directory. You will find the following files already present:

- `app.py`: Flask application
- `Dockerfile`: Instructions to build the Docker image

📂 **Lab1/**
```
├── app.py
└── Dockerfile
```

### 🔍 `app.py` (pre-written)
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello From Python Flask App"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### 🔍 `Dockerfile` (pre-written)
```Dockerfile
FROM python:3.9.1  
ADD . /python-flask   
WORKDIR /python-flask
RUN pip install flask
EXPOSE 5000
ENTRYPOINT [ "python","app.py" ]
```

---

## ☘️ Step 3: Build the Docker Image

Open a terminal and run below commands in the terminal 

```bash
cd ~/swift_training/kubernetes/Lab1
docker build -t flask-app:v1 .
```

---

## ☘️ Step 4: Verify the Built Image

```bash
docker images
```

You should see `flask-app` listed.

---

## ☘️ Step 5: Tag the Image for Docker Hub

Replace `yourdockerhubuser` with your Docker Hub username:

```bash
docker tag flask-app:v1 yourdockerhubuser/flask-app:v1
```

---

## ☘️ Step 6: Login to Docker Hub

```bash
docker login
```

Enter your Docker Hub **username** and **password** (or access token if 2FA is enabled).

---

## ☘️ Step 7: Push the Image to Docker Hub

```bash
docker push yourdockerhubuser/flask-app:v1
```

---

## ☘️ Step 8: Run a Container from Your Custom Image

```bash
docker run -d -p 5000:5000   --name flask-demo   yourdockerhubuser/flask-app:v1
```

## ☘️ Step 9: Check the running Container

```bash
docker ps
```

## ☘️ Step 10: Check the logs of container

```bash
docker logs flask-demo
```

---

## ☘️ Step 11: Access the Flask App

### 🔍 To get the EC2 public IP address:
Run the following command in terminal and it will provide you public IP address of EC2 machine you are using:
```bash
curl http://169.254.169.254/latest/meta-data/public-ipv4
```
### 🔍 Open your local browser and go to:
Replace the EC2-Address that you have recieved in last command in below URL

  👉 `http://<your-ec2-public-ip>:5000`


## ☘️ Step 12: Connect to Container shell
Connect inside the running container to debug:
```bash
docker exec -it flask-demo bash
```
Once connected, run below command to check all files inside container
```bash
ls
```

To come out of container shell, run below command
```bash
exit
```

## ☘️ Step 13: Cleanup
🧹 Stop and Remove the Container

```bash
docker stop flask-demo
docker rm flask-demo
```


## ✅ Conclusion

In this lab, you:

- Used existing Flask app files from `Lab1`.
- Created and pushed a custom Docker image.
- Ran your Flask app in a Docker container.
- Accessed the app via browser on port 5000.

---

🎉 **Congratulations**, you have successfully completed the lab!  
✨ **END OF LAB** ✨