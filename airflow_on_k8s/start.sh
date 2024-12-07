#!/bin/bash

## link aifflow dir to k8s volume dir
sudo mount --bind /opt/camelot/airflow-rancher-tilt/airflow_on_k8s/dags /mnt/wsl/rancher-desktop/airflow/dags
sudo mount --bind /opt/camelot/airflow-rancher-tilt/airflow_on_k8s/logs /mnt/wsl/rancher-desktop/airflow/logs

## Step 1: Create Namespace
kubectl apply -f k8s/namespace.yaml 
             
## Step 3: ConfigMap for KubernetesExecutor  
kubectl apply -f k8s/configuration.yaml

## Step 2. Persistent Volume and Persistent Volume Claim
kubectl apply -f k8s/persistent_volume.yaml

## Step 4. Role-Based Access Control (RBAC)
kubectl apply -f k8s/role_based_access_control.yaml

## Step 5: Deploy PostgreSQL
kubectl apply -f k8s/postgres.yaml
 
 
## Step 7: Create an Admin User          
kubectl run airflow-init  -n airflow \
--env="AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow" \
--image=apache/airflow:2.7.0 \
--restart=Never \
--command -- /bin/bash -c "airflow db init && airflow users create \
--username admin \
--firstname adam \
--lastname fuzum \
--role Admin \
--email admin@admin.com \
--password secret"  

## Step 8. Scheduler Deployment
kubectl apply -f k8s/airflow_scheduler.yaml
                                                   
## Step 9 . Webserver Deployment  
kubectl apply -f k8s/airflow_web_access.yaml

## tep 10. Deploy Web Service Expose the Airflow Web UI as a Kubernetes service:
kubectl apply -f k8s/airflow_web_service.yaml
                                                         
        

## Access Web UI (Port Forward)  
kubectl port-forward svc/airflow_web_access 8097:8080 -n airflow
                                  
    

