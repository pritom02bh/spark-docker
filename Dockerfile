FROM openjdk:11-jdk-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    python3 \
    python3-pip \
    python3-venv \
    procps \
    bash \
    && rm -rf /var/lib/apt/lists/*

ENV SPARK_VERSION=3.5.3
ENV HADOOP_VERSION=3

# Download and setup Spark
RUN wget https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar -xvzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

ENV SPARK_HOME=/spark
ENV PATH=$PATH:$SPARK_HOME/bin
ENV PYSPARK_PYTHON=python3
ENV PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH

# Install PySpark with specific Python version
RUN python3 -m pip install --no-cache-dir pyspark==${SPARK_VERSION}

WORKDIR /workspace
COPY sample.py .

# Create an entrypoint script
RUN echo '#!/bin/bash\necho "Spark environment ready!"\nwhile true; do sleep 30; done' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]