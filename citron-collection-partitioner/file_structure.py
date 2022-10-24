import logging
import re


class FileStructure:
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
