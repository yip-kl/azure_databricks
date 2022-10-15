# azure_databricks

## Useful resources
- [Spark Data Operations](https://github.com/patilvijay23/MLinPython/blob/main/pyspark/2_Spark_data_ops.ipynb): Showcases code snippets for the frequently used data operations on Spark dataframes

## Concepts
- **Types of API**:
    - RDD: Can work with both structured and unstructured data. Fairly low-level e.g. need to collect() the RDD to collect the data to the driver before you can print anything, less efficient too
    - DataFrame: It works only on structured and semi-structured data. More efficient
    - DataSets: It efficiently processes structured and unstructured data. Not available for Python though as of Spark version 2.1.1
- **Entry point**:
    - SparkContext: Use RDD API only. Initialized by default as `sc` so you can do things like `sc.textFile(inputUri)` from the get go
    - SparkSession: Can use all the APIs. Initialized by default as `spark`
- **File interaction**:
    - Spark works on HDFS, if we want to read a file on the local file system, the file must also be accessible at the same path on worker nodes, meaning either to copy the file to all workers or use a network-mounted shared file system. That's why reading the files from GCS is preferrable

## Tips
Assuming the data concerned is a DataFrame

- **Read**: Specify schema to improve performance of your queries, for files whose field types are not explicitly defined e.g. csv
- **Join**: The `SortMerge` join is used when the size of both tables/DataFrames is large (i.e. larger than `spark.sql.autoBroadcastJoinThreshold`), otherwise `BroadcastHash` join will be used. With `BroadcastHash` join, smaller tables are transferred to every executor on the worker nodes, and cached locally in memory, and thus avoid data shuffle between the nodes. We can also define what kind of join to be used with df.hint(`{broadcast/merge}`)
- **Partitioning**: Spark divides data into chunks (partitions) with a default block size of 128 MB, and send each partition to the specific executors to achieve parallelism. The more partitions there are, the more work will be distributed across the executors, meaning one can manipulate partitions to speed up data processing. However, this introduces a trade-off between parallelism and data shuffles. In general, when the data is small, then the number of partitions should be reduced
    - Adjust default partition size by `spark.conf.set("spark.sql.files.maxPartitionBytes", {byte size, e.g. 1048576 for 1 MB})`
    - Review how many partitions are created for a df by `df.rdd.getNumPartitions()`
    - Change the number of partitions:
        - Increase/Decrease `df.repartition({number of partitions e.g. 8})`, which is an expensive operation and involves fully shuffling the data over the network and redistributing the data evenly
        - Reduce only `df.coalesce({number of partitions})`, which usually runs faster because executor leaves data in a minimum number of partitions and only moves data from redundant nodes
    - Control the number of output files by `df.write.option("maxRecordsPerFile", {number of files e.g. 1000})`
    - Sets the the number of partitions to use during data shuffling, which is triggered by data transformations such as join(), union(),
    groupByKey(), reduceBykey(), and so on. `spark.conf.set("spark.sql.shuffle.partitions", {number of partitions})`
- **Storage**: Parquet, being a columnar storage format which supports partition pruning and predicate pushdown, is ideal for Big Data applications. `df.write.mode("overwrite").format("parquet")`

## Interaction with GCP
The connectors can be installed when you create the cluster (refer to `dataproc.sh`), or alternatively they can be added as an external jar if applicable.
- BigQuery: See [here](https://github.com/GoogleCloudDataproc/spark-bigquery-connector)
- Cloud Storage: For Dataproc it is installed automatically 