# Citron Collection Partitioner
Python script used to test AWS Athena partition strategy performances for data stored on S3.

### 1. Install Poetry
1. Install `poetry` (see [here](https://python-poetry.org/docs/#installation))

### 2. Install Dependencies
1. From the citron-collection-partitioner folder run the poetry cmd `poetry install` .

### 3. Create .env file
1. Create .env file et set `BUCKET` and `CITRON_ROLE_ARN`.

### 4. Authentication to aws
1. Get credentials of aws account.

### 5. Run the Partitioner
To run the script and get the result of the partitioning, follow these steps:
1. Select source folder in s3 bucket (must be partitioned by year, month and day).
2. Select a result folder where the resulting partitioning will be stored.
3. Select arguments of partitioning.
4. Run `main.py`