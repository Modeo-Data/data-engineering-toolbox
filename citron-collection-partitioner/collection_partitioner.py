import os

import pandas as pd
import logging
from dotenv import load_dotenv
import click
import time
import re

import boto3

from s3 import create_s3_client


logging.basicConfig(level=logging.INFO)

load_dotenv()
BUCKET = os.getenv("BUCKET")


class S3Object:
    """Class containing characteristics of a file in s3 bucket"""

    def __init__(self, key):
        logging.info(f"File key: {key}")
        res = re.search(
            r"^.*year=(?P<year>\d+)/month=(?P<month>\d+)/day=(?P<day>\d+)/(?P<file_name>.*)$",
            key,
        )
        self.key = key
        self.file_name = res.group("file_name")
        self.year = int(res.group("year"))
        self.month = int(res.group("month"))
        self.day = int(res.group("day"))

    @property
    def values_(self):
        """Get the characteristics of file as a list"""
        return [self.key, self.file_name, self.year, self.month, self.day]


class CollectionPartitioner:
    def __init__(self, bucket: str):
        self.bucket = bucket
        self.client = create_s3_client()

    def get_files_of_collection(self, collection_key: str) -> list:
        """
        list of keys of all the files in the collection folder

        :param collection_key: key of the collection folder
        """

        keys = []
        logging.info("Getting files' keys of the bucket...")
        for file in self.client.list_objects(Bucket=self.bucket, Prefix=collection_key)[
            "Contents"
        ]:
            if not file["Key"].endswith("/"):
                keys.append(file["Key"])

        return keys

    def create_collection_structure(self, collection_key: str) -> pd.DataFrame:
        """
        return a pandas dataframe that summarizes the information of each file in this collection

        :param collection_key: key of the collection in s3
        """

        logging.info("Creating the pandas.dataframe structure for the folder...")
        data = pd.DataFrame(columns=["key", "file_name", "year", "month", "day"])
        files = self.get_files_of_collection(collection_key)
        for file in files:
            data.loc[len(data.index)] = S3Object(file).values_

        logging.info("Folder structure created successfully !")
        return data

    def partition_collection(
        self,
        collection_key: str,
        year: bool,
        month: bool,
        day: bool,
        new_collection_key: str,
    ):
        """
        create a new partitioned collection from an existing collection depending on the passed params

        :param collection_key: existing collection key
        :param year: bool to partition with year
        :param month: bool to partition with month
        :param day: bool to partition with day
        :param new_collection_key: new partitioned collection key
        """

        data = self.create_collection_structure(collection_key)
        partition_parameters = []
        if year:
            partition_parameters.append("year")
        if month:
            partition_parameters.append("month")
        if day:
            partition_parameters.append("day")

        logging.info(f"Partition params are: {partition_parameters}")
        self.partition_data(
            files_data=data,
            columns=partition_parameters,
            base_s3_folder=new_collection_key,
            client=self.client,
        )
        logging.info("Partitioning done successfully !")

    def partition_data(
        self,
        files_data: pd.DataFrame,
        columns: list,
        base_s3_folder: str,
        client: boto3.client,
    ):
        """
        partition the data in the base folder according to the specified columns

        :param files_data: data of files to partition
        :param columns: columns of partitioning
        :param base_s3_folder: base folder
        :param client: aws s3 client
        """

        if len(columns) > 0:
            first_col = columns[0]
            logging.info(f"Partition by {first_col}...")
            partitioned_files = files_data.groupby(first_col, group_keys=True).apply(
                lambda x: x
            )
            for val in files_data[first_col].unique():
                current_partition = partitioned_files.loc[val]

                folder_to_create = f"{base_s3_folder}/{first_col}={val}"
                client.put_object(Bucket=self.bucket, Key=folder_to_create + "/")
                if len(columns) == 1:
                    current_partition = partitioned_files.loc[val]
                    for i in current_partition.index:
                        copy_source = {
                            "Bucket": self.bucket,
                            "Key": current_partition.loc[i]["key"],
                        }
                        client.copy(
                            copy_source,
                            self.bucket,
                            folder_to_create
                            + "/"
                            + current_partition.loc[i]["file_name"],
                        )
                else:
                    self.partition_data(
                        files_data=current_partition,
                        columns=[col for col in columns if col != first_col],
                        base_s3_folder=folder_to_create,
                        client=client,
                    )


@click.command()
@click.option(
    "--collection-key",
    default="test-source",
    prompt="Collection key",
    help="Collection to partition",
    type=str,
)
@click.option("-y", "--year", is_flag=True, help="Partition by year")
@click.option("-m", "--month", is_flag=True, help="Partition by month")
@click.option("-d", "--day", is_flag=True, help="Partition by day")
@click.option(
    "--new-collection-key",
    default="test-result",
    prompt="New collection key",
    help="Partitioned collection",
    type=str,
)
def main(
    collection_key: str, year: bool, month: bool, day: bool, new_collection_key: str
):
    start_time = time.time()
    partitioner = CollectionPartitioner(bucket=BUCKET)
    partitioner.partition_collection(
        collection_key=collection_key,
        year=year,
        month=month,
        day=day,
        new_collection_key=new_collection_key,
    )
    print("--- %s seconds ---" % (time.time() - start_time))


if __name__ == "__main__":
    main()
