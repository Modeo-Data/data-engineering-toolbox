import sys


old_sep = sys.argv[1]
new_sep = sys.argv[2]

# Read data
data = sys.stdin.read()

new_data = data.replace(old_sep, new_sep)
print(new_data)
