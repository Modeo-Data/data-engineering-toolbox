#!/bin/bash


# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title JSON to CSV
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Modeo

# Documentation:
# @raycast.author aguinilydia
# @raycast.authorURL https://github.com/aguinilydia
# @raycast.description Convert the JSON currently in the clipboard on csv.


pbpaste | jq -r '.[]| join(";")' | pbcopy
echo "Copied to clipboard !"
