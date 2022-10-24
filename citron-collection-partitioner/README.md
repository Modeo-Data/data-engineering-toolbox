# Data Stack Scrapper
Python script used to partition mongo collections data stored on aws s3 bucket.

### 1. Install Poetry
1. Install `poetry` (see [here](https://python-poetry.org/docs/#installation))

### 2. Install Dependencies
1. From the citron-collection-partitioner folder run the poetry cmd `poetry install` .

### 4. Run the Scrapper
To run the script and get the result of the partitioning, follow these steps:
1. Get credentials of aws account.
2. Select source folder in s3 bucket (must be partitioned by year, month and day).
3. Select a result folder where the resulting partitioning will be stored.
4. Select arguments of partitioning.
5. Run `main.py`