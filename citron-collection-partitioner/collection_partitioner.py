import pandas as pd
import logging as log
import re

import boto3
from botocore.exceptions import NoCredentialsError


class CollectionPartitioner:
    def __init__(self, bucket: str):
        self.bucket = bucket

    @staticmethod
    def init_sts_client():
        """Init client for AWS S3"""
        try:
            s3_client = boto3.client("sts")
        except NoCredentialsError:
            log.error("Credentials are missing or incorrect")
            raise
        return s3_client

    def get_files_of_collection(self, collection_key: str) -> list:
        """

        :param collection_key: key of the collection folder
        :return: list of keys of all the files in the collection folder
        """

        keys = []

        sts_client= CollectionPartitioner.init_sts_client()
        assumed_role_object = sts_client.assume_role(
            RoleArn="arn:aws:iam::585762237892:role/gads-citron-modeo",
            RoleSessionName="AssumeRoleSession1",
        )
        credentials = assumed_role_object["Credentials"]
        s3_client = boto3.client(
            "s3",
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
        )

        for file in s3_client.list_objects(Bucket=self.bucket, Prefix= collection_key)["Contents"]:
            if not file["Key"].endswith('/'):
                keys.append(file["Key"])

        sts_client.close()
        s3_client.close()
        return keys

    @staticmethod
    def get_file_infos(key: str) -> dict:
        """

        :param key: key of the file stored in s3
        :return: dict containing the information of the file: key, year, month, day
        """

        res= re.search(r"^.*year=(?P<year>\d+)/month=(?P<month>\d+)/day=(?P<day>\d+)/(?P<file_name>.*)$",key)
        file_infos={
            "key": key,
            "file_name":res.group('file_name'),
            "year":int(res.group('year')),
            "month":int(res.group('month')),
            "day":int(res.group('day')),
        }
        return file_infos

    def create_collection_structure(self, collection_key: str) -> pd.DataFrame:
        """

        :param collection_key: key of the collection in s3
        :return: return a pandas dataframe that summarizes the information of each file in this collection
        """
        data= pd.DataFrame(columns=["key","file_name","year","month","day"])
        files= self.get_files_of_collection(collection_key)
        for file in files:
            data.loc[len(data.index)]= list(CollectionPartitioner.get_file_infos(file).values())

        return data

    def partition_collection(self, collection_key:str, year:bool, month:bool,day:bool,new_collection_key:str):
        """

        :param collection_key: existing collection key
        :param year: bool to partition with year
        :param month: bool to partition with month
        :param day: bool to partition with day
        :param new_collection_key: new partitioned collection key
        :return: create a new partitioned collection from an existing collection depending on the passed params
        """

        data= self.create_collection_structure(collection_key)
        partition_parameters=[]
        if year: partition_parameters.append('year')
        if month: partition_parameters.append('month')
        if day: partition_parameters.append('day')

        aws_client = self.init_sts_client()

        assumed_role_object = aws_client.assume_role(
            RoleArn="arn:aws:iam::585762237892:role/gads-citron-modeo",
            RoleSessionName="AssumeRoleSession1",
        )

        credentials = assumed_role_object["Credentials"]

        s3_client = boto3.client(
            "s3",
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
        )

        self.partition_data(
            files_data=data,
            columns=partition_parameters,
            base_s3_folder=new_collection_key,
            client=s3_client
        )

    def partition_data(self, files_data:pd.DataFrame,columns:list,base_s3_folder:str,client: boto3.client):
        """
        partition the data in the base folder according to the specified columns

        :param files_data: data of files to partition
        :param columns: columns of partitioning
        :param base_s3_folder: base folder
        :param client: aws s3 client
        """

        if len(columns)>0:
            first_col= columns[0]
            partitioned_files= files_data.groupby(first_col,group_keys=True).apply(
                lambda x:x
            )
            for val in files_data[first_col].unique():
                current_partition = partitioned_files.loc[val]

                folder_to_create=f"{base_s3_folder}/{first_col}={val}"
                client.put_object(
                    Bucket=self.bucket, Key=folder_to_create+"/"
                )
                if len(columns)==1:
                    current_partition= partitioned_files.loc[val]
                    for i in current_partition.index:
                        copy_source={
                            "Bucket":self.bucket,
                            "Key": current_partition.loc[i]['key']
                        }
                        client.copy(copy_source,self.bucket,folder_to_create+"/"+current_partition.loc[i]['file_name'])
                else:
                    self.partition_data(
                        files_data=current_partition,
                        columns=[col for col in columns if col != first_col],
                        base_s3_folder=folder_to_create,
                        client=client
                    )