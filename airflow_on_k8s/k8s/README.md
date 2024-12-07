
# Airflow Kubernetes Setup Command Summary

## Step 1: Create Namespace
Create a dedicated namespace for Airflow:
```bash
kubectl apply -f airflow-namespace.yaml 

```
---
## Step 2. Persistent Volume and Persistent Volume Claim  
Airflow requires shared storage for DAG files so all components (scheduler, webserver, workers) can access the same files.  
```bash  
kubectl apply -f airflow-pv.yaml
```
---

## Step 3: ConfigMap for KubernetesExecutor
The ConfigMap stores Airflow configurations for all components, including enabling the KubernetesExecutor.  
```bash  
kubectl apply -f airflow-config.yaml
```  
---  

## Step 4. Role-Based Access Control (RBAC)  
The KubernetesExecutor needs permissions to create and manage worker pods.  
```bash    
kubectl apply -f aairflow-rbac.yaml

```

---

## Step 5: Deploy PostgreSQL
Deploy a PostgreSQL database to store Airflow metadata. Use an appropriate YAML file for the deployment (replace with your file):

```bash
kubectl apply -f postgres.yaml
```
---

## Step 6: Initialize Database
Initialize the Airflow metadata database using a temporary pod:
```bash
kubectl run airflow-init -n airflow --env="AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow" \
--image=apache/airflow:2.7.0 \
--restart=Never airflow db init 

kubectl delete pod airflow-init -n airflow
``` 

## Step 7: Create an Admin User
Create an admin user for accessing the Airflow Web UI:
```bash 
kubectl run airflow-user-create -n airflow \
--env="AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow" \
--image=apache/airflow:2.7.0 \
--restart=Never \
--command -- /bin/bash -c "airflow users create \
--username admin \
--firstname adam \
--lastname fuzum \
--role Admin \
--email admin@admin.com \
--password secret" 
 
``` 
 
---

## Step 7. Scheduler Deployment
The Scheduler is the core component of Airflow. It is responsible for:
    1. Reading and scheduling tasks from DAGs.  
    2. Communicating with the Kubernetes API to request worker pods for task execution.  
```bash 
kubectl apply -f  airflow-scheduler.yaml
```

---
 
## Step 8. Deploy Web Service Expose the Airflow Web UI as a Kubernetes service:

 ```bash 
kubectl apply -f airflow-web-service.yaml
```
---

## Step 9 . Webserver Deployment  
The Webserver provides the Airflow UI where users can:  
    1. View and manage DAGs.  
    2. Monitor task states.  
    3. Access logs and trigger tasks manually.  
```bash 
kubectl apply -f airflow-web.yaml

```
---

 
## Step 10 :Deploy Web Service Expose the Airflow Web UI as a Kubernetes service:
 

1. **Using Minikube**:
```bash
minikube service airflow-web -n airflow
```

2. **Using Port Forwarding**:
```bash
kubectl port-forward svc/airflow-web 8090:8080 -n airflow
```
---
## Step 10.  Verify all components are running:
```bash
   kubectl get pods -n airflow
```

Open your browser and navigate to:
```
http://localhost:8090
```

Log in using the credentials:
- **Username**: `admin`
- **Password**: `secret`
---
 
##  Restart Scheduler and Webserver
Restart the Scheduler and Webserver pods to ensure the new DAG is picked up:

1. Restart Scheduler:
   ```bash
   kubectl delete pod -l app=airflow-scheduler -n airflow
   ```

2. Restart Webserver:
   ```bash
   kubectl delete pod -l app=airflow-web -n airflow
   ```


---

## Step 13: Trigger and Monitor the DAG
1. Enable the DAG in the Airflow Web UI.
2. Trigger the DAG.
3. Use the Graph View and Task Logs in the UI to monitor execution.

 