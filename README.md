## Apache Airflow
Apache Airflow is an open-source platform for creating, scheduling, and monitoring batch-oriented workflows.

### Workflow
A workflow is comprised of several tasks. Each task represents a single unit of work that needs to be performed. These tasks can be dependent on one another, forming a directed acyclic graph (DAG). Airflow allows you to define these tasks and their dependencies programmatically, ensuring that they are executed in the correct order. Additionally, Airflow provides tools for monitoring and managing the execution of these workflows, making it easier to handle complex data pipelines.

#### Workflow features include:  

* Workflows are defined using Python code: This allows for easy customization and integration with other Python libraries.  

* Supports dynamic pipeline generation: Pipelines can be generated dynamically, which means that the structure and tasks of the workflow can be created and modified at runtime. This enables the creation of more complex and adaptable workflows that can respond to changing conditions and requirements.

* Extensible operators that can connect to external technologies: Operators can be extended to interact with various external systems and services.  

* Flexibility with Jinja templating: Allows for parameterization and dynamic content generation within workflows using Jinja templates.

### Architecture
![Architecture](images/architecture.png)

* **Metadata Database**: Stores the state and configuration of all DAGs and tasks. It is the central repository for all metadata related to workflows.
* **Scheduler**: Responsible for scheduling the tasks in the DAGs. It determines the order of task execution based on their dependencies and schedules them accordingly.
* **Executor**: Executes the tasks that have been scheduled by the scheduler. It can run tasks locally or distribute them across a cluster of workers.
* **DAG Directory**: A directory where all the DAG definitions are stored. Airflow scans this directory to discover and load DAGs.
* **WebServer**: Provides a web-based user interface for monitoring and managing workflows. It allows users to view the status of DAGs and tasks, trigger DAG runs, and access logs.

### DAGs (Directed Acyclic Graph)

A Directed Acyclic Graph (DAG) is a collection of all the tasks you want to run, organized in a way that reflects their relationships and dependencies. In Apache Airflow, a DAG is defined using Python code, which allows for dynamic pipeline generation and complex workflows.

Each DAG consists of multiple tasks, and the dependencies between these tasks determine the order in which they are executed. DAGs are used to represent workflows in a programmatic way, making it easier to manage and monitor the execution of tasks.

#### Example

Here is a simple example of a DAG in Apache Airflow:  
![Architecture](images/dags.png)

```python
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime

def extract_data(**kwargs):
    print("Extracting data...")

def transform_data(**kwargs):
    print("Transforming data...")

def load_data(**kwargs):
    print("Loading data...")

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 1, 1),
    'retries': 1,
}

dag = DAG('simple_etl', default_args=default_args, schedule_interval='@daily')

extract_task = PythonOperator(
    task_id='extract_data',
    python_callable=extract_data,
    dag=dag,
)

transform_task = PythonOperator(
    task_id='transform_data',
    python_callable=transform_data,
    dag=dag,
)

load_task = PythonOperator(
    task_id='load_data',
    python_callable=load_data,
    dag=dag,
)

extract_task >> transform_task >> load_task
```


### Scheduler

The Scheduler is a core component of Apache Airflow responsible for scheduling tasks in DAGs. It determines the order of task execution based on their dependencies and schedules them accordingly. The Scheduler continuously monitors the DAGs and triggers tasks when their dependencies are met and their scheduled time arrives.

The Scheduler uses a cron-like syntax to define the schedule intervals for DAGs. This syntax allows you to specify when and how often a DAG should run.

#### Cron Expression Syntax

A cron expression is a string consisting of five fields separated by spaces. Each field represents a specific unit of time. The fields are as follows:   

| Field         | Allowed Values | Description                                     |
|---------------|----------------|-------------------------------------------------|
| Minute        | 0-59           | Minute of the hour                              |
| Hour          | 0-23           | Hour of the day                                 |
| Day of Month  | 1-31           | Day of the month                                |
| Month         | 1-12           | Month of the year                               |
| Day of Week   | 0-7            | Day of the week (0 and 7 both represent Sunday) |
#### Examples

- `@daily`: Run once a day at midnight (0 0 * * *).
- `@hourly`: Run once an hour at the beginning of the hour (0 * * * *).
- `@weekly`: Run once a week at midnight on Sunday (0 0 * * 0).
- `@monthly`: Run once a month at midnight on the first day of the month (0 0 1 * *).
- `@yearly` or `@annually`: Run once a year at midnight on January 1st (0 0 1 1 *).

##### Custom Cron Expressions

- `0 6 * * *`: Run every day at 6:00 AM.
- `30 14 * * 1-5`: Run at 2:30 PM, Monday through Friday.
- `0 22 * * 5`: Run at 10:00 PM on Friday.
- `15 10 15 * *`: Run at 10:15 AM on the 15th of every month.

These cron expressions allow you to define flexible and precise schedules for your DAGs, ensuring that tasks are executed at the desired times.

### Airflow Features
1.  #### Tasks

Tasks are the basic units of work in Apache Airflow. Each task represents a single operation or step in a workflow. Tasks can perform a wide variety of actions, such as running a Python function, executing a SQL query, transferring data between systems, or triggering other workflows.

Tasks are defined using operators, which are predefined templates for common operations. Airflow provides a rich set of operators, including:

    - **PythonOperator**: Executes a Python function.
    - **BashOperator**: Runs a Bash command.
    - **MySqlOperator**: Executes a SQL query on a MySQL database.
    - **HttpOperator**: Makes an HTTP request.
    - **S3Operator**: Interacts with Amazon S3.  

2. #### Taskflow API
The TaskFlow API is a high-level programming interface introduced in Airflow 2.0. It provides a simplified and more expressive way to define and manage workflows. Built on top of core Airflow concepts such as DAGs, tasks, and operators, the TaskFlow API makes it easier to create and maintain complex workflows. It offers a more pythonic and intuitive syntax to work with operators   

#### Example  
```python
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
```
3. #### Sensors

Sensors are a type of operator in Apache Airflow that wait for a certain condition or external event to occur before proceeding with the next task. They are useful for tasks that depend on the availability of external resources or the completion of external processes.

Sensors continuously poll or listen for a specific condition to be met. Once the condition is satisfied, the sensor task is marked as successful, and the workflow can proceed to the next task.

##### Example

Here is an example of using a `FileSensor` to wait for a file to appear in a specific directory before proceeding with the next task:

```python
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.sensors.filesystem import FileSensor
from datetime import datetime

def process_file(**kwargs):
    print("Processing file...")

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 1, 1),
    'retries': 1,
}

dag = DAG('file_sensor_example', default_args=default_args, schedule_interval='@daily')

# Define the FileSensor task
wait_for_file = FileSensor(
    task_id='wait_for_file',
    filepath='/path/to/your/file.txt',
    poke_interval=30,  # Check every 30 seconds
    timeout=600,       # Timeout after 10 minutes
    dag=dag,
)

# Define the task to process the file
process_file_task = PythonOperator(
    task_id='process_file',
    python_callable=process_file,
    dag=dag,
)

# Set the task dependencies
wait_for_file >> process_file_task
```  

4. #### Hooks

Hooks provide an interface to interact with external systems such as databases, cloud platforms, APIs, and other services. They are used by operators to perform actions on these external systems. Hooks abstract the connection details and provide a consistent way to interact with different types of systems.

##### Example

Here is an example of using a `PostgresHook` to interact with a PostgreSQL database:

```python
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.hooks.postgres_hook import PostgresHook
from datetime import datetime

def fetch_data_from_postgres(**kwargs):
    # Create a PostgresHook instance
    pg_hook = PostgresHook(postgres_conn_id='my_postgres_connection')
    
    # Execute a query
    connection = pg_hook.get_conn()
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM my_table")
    results = cursor.fetchall()
    
    # Process the results
    for row in results:
        print(row)

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 1, 1),
    'retries': 1,
}

dag = DAG('postgres_hook_example', default_args=default_args, schedule_interval='@daily')

# Define the task to fetch data from PostgreSQL
fetch_data_task = PythonOperator(
    task_id='fetch_data_from_postgres',
    python_callable=fetch_data_from_postgres,
    dag=dag,
)
```
#### XCom

XCom (short for "cross-communication") is a feature in Apache Airflow that allows tasks to exchange small amounts of data. XComs enable tasks to share information with each other, making it possible to pass data between tasks in a workflow.

XComs are stored in the Airflow metadata database and can be pulled or pushed by any task. Each XCom entry is identified by a key, and tasks can push or pull XComs using these keys.

##### Example

Here is an example of using XComs to pass data between tasks in a DAG:

```python
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime

def push_data(**kwargs):
    # Push data to XCom
    kwargs['ti'].xcom_push(key='my_key', value='Hello, World!')

def pull_data(**kwargs):
    # Pull data from XCom
    value = kwargs['ti'].xcom_pull(key='my_key', task_ids='push_task')
    print(f"Pulled value: {value}")

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 1, 1),
    'retries': 1,
}

dag = DAG('xcom_example', default_args=default_args, schedule_interval='@daily')

# Define the task to push data to XCom
push_task = PythonOperator(
    task_id='push_task',
    python_callable=push_data,
    provide_context=True,
    dag=dag,
)

# Define the task to pull data from XCom
pull_task = PythonOperator(
    task_id='pull_task',
    python_callable=pull_data,
    provide_context=True,
    dag=dag,
)

# Set the task dependencies
push_task >> pull_task
```

### Airflow Configuration File  

The Airflow configuration file (airflow.cfg) is used to configure various settings for your Airflow instance. This file contains sections and key-value pairs that define how Airflow should behave. The configuration file is typically located in the Airflow home directory (~/airflow/airflow.cfg).  

#### Key Sections in airflow.cfg  
1. **[core]**: Core settings for Airflow, including the Airflow home directory, DAG folder, and logging settings.  
2. **[database]**: Database connection settings for the metadata database.  
3. **[webserver]**: Settings for the Airflow web server, including the port and authentication options.  
4. **[scheduler]**: Settings for the Airflow scheduler, including DAG directory and scheduling interval.  
5. **[logging]**: Logging configuration for Airflow.  
6. **[smtp]**: SMTP settings for sending email alerts.  

```yml 
[core]
# The home directory for Airflow
airflow_home = ~/airflow

# The folder where your DAGs are located
dags_folder = ~/airflow/dags

# The folder where Airflow should store its log files
base_log_folder = ~/airflow/logs

# The executor to use (e.g., SequentialExecutor, LocalExecutor, CeleryExecutor, KubernetesExecutor)
executor = KubernetesExecutor

# The default timezone to use for datetime objects
default_timezone = utc

[database]
# The SQLAlchemy connection string to the metadata database
sql_alchemy_conn = sqlite:////home/adam/airflow/airflow.db

[webserver]
# The port on which to run the Airflow web server
web_server_port = 8080

# The base URL for the Airflow web server
base_url = http://localhost:8080

# Enable authentication for the web server
authenticate = True
auth_backend = airflow.contrib.auth.backends.password_auth

[scheduler]
# The interval at which the scheduler should run (in seconds)
scheduler_interval = 30

# The folder where the DAGs are located
dags_folder = ~/airflow/dags

[logging]
# The logging level (e.g., DEBUG, INFO, WARNING, ERROR, CRITICAL)
logging_level = INFO

# The format for log messages
log_format = [%(asctime)s] {%(filename)s:%(lineno)d} %(levelname)s - %(message)s

[smtp]
# The SMTP server to use for sending email alerts
smtp_host = smtp.example.com
smtp_starttls = True
smtp_ssl = False
smtp_user = airflow@example.com
smtp_password = yourpassword
smtp_port = 587
smtp_mail_from = airflow@example.com

[kubernetes]
# The namespace to run worker pods in
namespace = airflow

# The name of the Kubernetes config file
kube_config = ~/.kube/config

# The name of the Airflow worker image
worker_container_repository = apache/airflow
worker_container_tag = latest

# The name of the Airflow scheduler image
scheduler_container_repository = apache/airflow
scheduler_container_tag = latest

# The name of the Kubernetes service account
worker_service_account_name = airflow
```