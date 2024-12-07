#!/bin/bash

# Update package list and install pip3
sudo apt update
sudo apt install python3-pip python3.11-venv  -y  
sudo apt install pkg-config  -y 

# Create a virtual environment
python3 -m venv airflow_venv
source airflow_venv/bin/activate

# Install libs 
pip install apache-airflow==2.10.3

export AIRFLOW_HOME=/opt/camelot/airflowDemo/bare_metal_airflow 