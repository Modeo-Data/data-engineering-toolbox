import os
import logging as log
from dotenv import load_dotenv

import boto3
from botocore.exceptions import NoCredentialsError

load_dotenv()
CITRON_ROLE_ARN = os.getenv("CITRON_ROLE_ARN")


def create_sts_client():
    """Init sts client for AWS"""
    try:
        sts_client = boto3.client("sts")
    except NoCredentialsError:
        log.error("Credentials are missing or incorrect")
        raise

    log.info("STS client created !")
    return sts_client


def create_s3_client():
    """Create S3 aws client"""
    sts_client = create_sts_client()
    if sts_client is not None:
        assumed_role_object = sts_client.assume_role(
            RoleArn=CITRON_ROLE_ARN,
            RoleSessionName="AssumeRoleSession1",
        )
        credentials = assumed_role_object["Credentials"]
        s3_client = boto3.client(
            "s3",
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
        )
        log.info("S3 client created !")
        return s3_client
    else:
        return None
