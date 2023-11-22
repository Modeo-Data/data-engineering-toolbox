import pandas as pd
import json
import sys

# Read the json on input
data = sys.stdin.read()
# Loads the json
json_data = json.loads(data)
json_normalized = pd.json_normalize(json_data)
# Convert on cvs
csv_data = json_normalized.to_csv(sep=';', index=False)
# Print the result
print(csv_data)
