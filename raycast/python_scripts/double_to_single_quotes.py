import sys

# Read data
data = sys.stdin.read()

new_data = data.replace('"', "\'")
print(new_data)
