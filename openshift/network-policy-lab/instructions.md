# Network Policy Troubleshooting Lab

## Scenario
You are a developer deploying a 3-tier application in your OpenShift project. The application consists of three components:
- **Frontend**
- **Backend**
- **Database**

For security reasons, you want to implement the following Network Policy requirements:
1. **Default Deny**: No pod should accept incoming traffic by default.
2. **Frontend -> Backend**: The `frontend` pod should be allowed to send traffic to the `backend`.
3. **Backend -> Database**: The `backend` pod should be allowed to send traffic to the `database`.
4. **No other traffic**: For example, a random `test-pod` should NOT be able to reach the `backend` or the `database`.

The security team has applied the initial Network Policies, but the application is broken!

## Issues Reported
1. The **frontend** pod gets a "connection timeout" when trying to reach the **backend**.
2. A random **test-pod** was successfully able to connect to the **database**, which is a huge security vulnerability!

## Objective
Troubleshoot and fix the Network Policies so that they meet the original security requirements. 
*Note: Because you are a limited user, these policies only apply to your current project. You do not need cluster-level permissions to fix them, nor do they specify a namespace, so they will safely deploy exactly where you run the commands.*
