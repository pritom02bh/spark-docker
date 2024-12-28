# Spark Docker Environment Setup and Usage Guide

## Table of Contents
1. [Project Structure](#project-structure)
2. [Setup Instructions](#setup-instructions)
3. [Basic Usage](#basic-usage)
4. [Working with Data](#working-with-data)
5. [Common Operations](#common-operations)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

## Project Structure
```
spark-docker/
├── Dockerfile              # Docker image configuration
├── docker-compose.yml      # Docker container configuration
├── workspace/              # Your working directory
│   └── sample.py          # Example PySpark script
└── .gitignore             # Git ignore file
```

## Setup Instructions

### Prerequisites
- Docker Desktop installed
- Git (optional)
- Basic Python knowledge

### Initial Setup
1. Create a new directory:
```bash
mkdir spark-docker
cd spark-docker
```

2. Create necessary files:
```bash
# Create workspace directory
mkdir workspace

# Create and place the provided Dockerfile, docker-compose.yml, and sample.py
```

3. Build and start the container:
```bash
docker-compose build
docker-compose up -d
```

4. Verify the setup:
```bash
docker-compose ps
docker-compose exec spark bash
python3 -c "import pyspark; print(pyspark.__version__)"
```

## Basic Usage

### Connecting to the Container
```bash
docker-compose exec spark bash
```

### Running PySpark Scripts
1. Place your Python scripts in the `workspace` directory
2. From inside the container:
```bash
python3 your_script.py
```

### Interactive PySpark Shell
```bash
pyspark
```

## Working with Data

### Supported Data Formats
- CSV
- JSON
- Parquet
- ORC
- AVRO
- Text files
- Database connections (JDBC)

### Reading Data Examples
```python
# Read CSV
df = spark.read.csv('data.csv', header=True, inferSchema=True)

# Read JSON
df = spark.read.json('data.json')

# Read Parquet
df = spark.read.parquet('data.parquet')
```

### Writing Data Examples
```python
# Write CSV
df.write.csv('output.csv', header=True)

# Write Parquet
df.write.parquet('output.parquet')

# Write to database
df.write \
    .format("jdbc") \
    .option("url", "jdbc:postgresql://host:5432/database") \
    .option("dbtable", "table_name") \
    .option("user", "username") \
    .option("password", "password") \
    .save()
```

### Data Storage Locations

1. **Local Storage**:
   - Use the `workspace` directory
   - Files persist between container restarts
   - Example:
   ```python
   df.write.parquet('/workspace/data/output.parquet')
   ```

2. **External Storage**:
   - Mount additional volumes in docker-compose.yml
   - Configure cloud storage connectors
   - Example docker-compose.yml addition:
   ```yaml
   volumes:
     - ./workspace:/workspace
     - /path/to/data:/data
   ```

## Common Operations

### Basic DataFrame Operations
```python
# Filter data
filtered_df = df.filter(df.age > 25)

# Select columns
selected_df = df.select("name", "age")

# Add new column
df_with_new = df.withColumn("age_plus_one", df.age + 1)

# Group By and Aggregate
summary_df = df.groupBy("department").agg({"salary": "avg", "age": "max"})
```

### Window Functions
```python
from pyspark.sql import Window
import pyspark.sql.functions as F

window_spec = Window.partitionBy("department").orderBy("salary")
df_with_rank = df.withColumn("rank", F.rank().over(window_spec))
```

### UDF (User Defined Functions)
```python
from pyspark.sql.functions import udf
from pyspark.sql.types import StringType

# Define UDF
@udf(returnType=StringType())
def age_category(age):
    if age < 25:
        return "Young"
    elif age < 50:
        return "Middle"
    else:
        return "Senior"

# Apply UDF
df_with_category = df.withColumn("age_category", age_category(df.age))
```

## Best Practices

1. **Resource Management**:
   - Configure memory appropriately in spark-defaults.conf
   - Monitor resource usage using Spark UI (http://localhost:4040)
   - Clean up temporary files regularly

2. **Performance Optimization**:
   - Use appropriate file formats (Parquet recommended)
   - Partition data when writing
   - Cache frequently used DataFrames
   - Use appropriate join strategies

3. **Development Workflow**:
   - Keep scripts in version control
   - Use meaningful variable names
   - Add comments and documentation
   - Use type hints in Python code

## Troubleshooting

### Common Issues and Solutions

1. **Container Won't Start**:
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   ```

2. **Memory Issues**:
   - Increase Docker memory allocation
   - Add to spark-defaults.conf:
   ```conf
   spark.driver.memory 4g
   spark.executor.memory 4g
   ```

3. **Network Timeout**:
   - Check hostname configuration
   - Verify network settings in docker-compose.yml
   - Increase timeout settings in Spark configuration

### Logs and Debugging
- Container logs: `docker-compose logs spark`
- Spark UI: http://localhost:4040
- Application logs in container: `/spark/logs/`
