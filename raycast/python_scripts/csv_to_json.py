import pandas as pd
import sys

# Read the csv data from input
df = pd.read_csv(sys.stdin, sep=";")
json_data = df.to_json()
# Print the result
print(json_data)

