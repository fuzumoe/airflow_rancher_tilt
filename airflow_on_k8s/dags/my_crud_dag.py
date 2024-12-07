from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from datetime import datetime, timedelta  # Ensure timedelta is imported

# Define default args for the DAG
default_args = {
    'owner': 'airflow',
    'retries': 1,
    'start_date': datetime(2023, 1, 1),
    'retries': 1, 
}

# Define the DAG
with DAG(
    dag_id='postgres_crud_operations',
    default_args=default_args,
    description='A DAG to perform CRUD operations on PostgreSQL',
    schedule_interval=None,
    start_date=datetime(2023, 1, 1),
    catchup=False,
    tags=['example', 'postgres', 'CRUD'],
) as dag:

    # Task: Create table
    create_table = PostgresOperator(
        task_id='create_table',
        postgres_conn_id='my_connection',
        sql="""
        CREATE TABLE IF NOT EXISTS example_table (
            id SERIAL PRIMARY KEY,
            name VARCHAR(50),
            age INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """
    )

    # Task: Insert data
    insert_data = PostgresOperator(
        task_id='insert_data',
        postgres_conn_id='my_connection',
        sql="""
        INSERT INTO example_table (name, age) VALUES
        ('Alice', 25),
        ('Bob', 30);
        """
    )

    # Task: Query data
    query_data = PostgresOperator(
        task_id='query_data',
        postgres_conn_id='my_connection',
        sql="SELECT * FROM example_table;"
    )

    # Task: Update data
    update_data = PostgresOperator(
        task_id='update_data',
        postgres_conn_id='my_connection',
        sql="""
        UPDATE example_table
        SET age = age + 1
        WHERE name = 'Alice';
        """
    )

    # Task: Delete data
    delete_data = PostgresOperator(
        task_id='delete_data',
        postgres_conn_id='my_connection',
        sql="DELETE FROM example_table WHERE name = 'Bob';"
    )

    # Define task dependencies
    create_table >> insert_data >> query_data >> update_data >> delete_data
