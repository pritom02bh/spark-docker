from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType

def create_spark_session():
    return SparkSession.builder \
        .appName("SparkExample") \
        .config("spark.driver.host", "spark-dev") \
        .config("spark.driver.bindAddress", "0.0.0.0") \
        .config("spark.network.timeout", "600s") \
        .config("spark.executor.heartbeatInterval", "60s") \
        .master("local[*]") \
        .getOrCreate()

if __name__ == "__main__":
    try:
        # Initialize Spark session
        print("Initializing Spark...")
        spark = create_spark_session()
        
        # Set log level to reduce noise
        spark.sparkContext.setLogLevel("WARN")
        
        # Define schema explicitly
        schema = StructType([
            StructField("name", StringType(), False),
            StructField("age", IntegerType(), False)
        ])
        
        # Create a sample DataFrame with schema
        print("\nCreating sample data...")
        data = [
            ("John", 30),
            ("Alice", 25),
            ("Bob", 35)
        ]
        
        df = spark.createDataFrame(data, schema)
        
        print("\nSample DataFrame:")
        df.show()
        
        print("\nDataFrame Schema:")
        df.printSchema()
        
        print("\nBasic Statistics:")
        df.describe().show()
        
        print("\nGroupBy and Aggregate Operations:")
        df.groupBy().agg({"age": "avg", "age": "max", "age": "min"}).show()
        
        # Stop the Spark session
        print("\nStopping Spark session...")
        spark.stop()
        print("Done!")
        
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        raise