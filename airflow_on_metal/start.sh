#!/bin/bash

# Activate python virtual environment
source airflow_venv/bin/activate

# Stop any running Airflow web server and scheduler
pkill -f "airflow webserver"
pkill -f "airflow scheduler"

# Remove stale PID files if they exist
rm -f  airflow-webserver.pid
rm -f  airflow-scheduler.pid
# set home cd 
 
# Initialize the Airflow database
airflow db init

# Create a user account for the Airflow web interface
airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com

# Start the Airflow web server
airflow webserver --port 8091 &

# Start the Airflow scheduler
airflow scheduler &