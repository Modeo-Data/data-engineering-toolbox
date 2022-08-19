#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title CSV to JSON
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 {"type": "text", "optional": true}
# @raycast.packageName Modeo

# Documentation:
# @raycast.author aguinilydia
# @raycast.authorURL https://github.com/aguinilydia
# @raycast.description Convert the CSV file into JSON.

pbpaste | python -c 'import pandas;import sys;df=pandas.read_csv(sys.stdin,sep=";");print(df.to_json())'| pbcopy
echo "Copied to clipboard !"
