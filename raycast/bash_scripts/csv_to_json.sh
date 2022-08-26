#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title CSV to JSON
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Modeo

# Documentation:
# @raycast.author aguinilydia
# @raycast.authorURL https://github.com/aguinilydia
# @raycast.description Convert the CSV file into JSON.

source ../venv/bin/activate
pbpaste | python3 '../python_scripts/csv_to_json.py'| pbcopy
echo "Copied to clipboard !"
