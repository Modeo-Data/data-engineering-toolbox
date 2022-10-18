from collection_partitioner import CollectionPartitioner


cp= CollectionPartitioner(bucket="gads-citron-mongo-export-stage")
cp.partition_collection(
    collection_key="test-source",
    month=True,
    year=False,
    day=False,
    new_collection_key="test-result"
)