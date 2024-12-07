from airflow.decorators import dag, task
from datetime import datetime

# Define the default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 1, 1),
    'retries': 1,
}

# Define the DAG using the TaskFlow API
@dag(default_args=default_args, schedule_interval='@daily', catchup=False)
def example_taskflow_api():

    @task
    def extract():
        data = {"field1": "value1", "field2": "value2"}
        print("Extracting data... ")
        return data

    @task
    def transform(data: dict):
        transformed_data = {k: v.upper() for k, v in data.items()}
        print("Transforming data...")
        return transformed_data

    @task
    def load(data: dict):
        print("Loading data...")
        print(data)

    # Define the task dependencies
    data = extract()
    transformed_data = transform(data)
    load(transformed_data)

# Instantiate the DAG
example_dag = example_taskflow_api()