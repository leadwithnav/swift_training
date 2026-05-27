# Mega Troubleshooting Lab: The Broken E-Commerce App

## Scenario
You are the lead DevOps instructor. A junior developer has just deployed the new "E-Commerce" application to your OpenShift Sandbox environment. However, absolutely nothing is working correctly!

Your students will act as the troubleshooting team. You will run commands together to investigate the cluster, identify the misconfigurations, and fix them. Since you are in a Sandbox environment, you do not have `cluster-admin` privileges, meaning you must fix everything within the boundaries of your current project.

## The Application Architecture
- **Frontend Deployment**: A web server that should run 2 replicas.
- **Backend Deployment**: An API that should automatically scale based on CPU usage using an HPA.
- **Database Deployment**: A database that should run 2 replicas, but must NEVER run on the same node for high availability (Anti-Affinity).

## Reported Issues to Investigate
1. **Frontend Pending**: The frontend pods are not starting. They seem to be stuck in a `Pending` state.
2. **PDB Warnings**: The cluster is throwing warnings about the PodDisruptionBudget for the frontend.
3. **Broken HPA**: The Horizontal Pod Autoscaler for the backend shows `<unknown>/50%` for CPU utilization and refuses to scale.
4. **Database Anti-Affinity**: Only one database pod is running. The second one is stuck in `Pending`.
5. **Network Connectivity**: Once you finally get the frontend pods running, they cannot communicate with the backend.

## Objective
Work together to use `oc` commands to diagnose why each of these issues is occurring, and then edit the resources to fix them!
