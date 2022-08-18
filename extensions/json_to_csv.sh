#!/bin/bash


# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title JSON to CSV
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 {"type": "text", "placeholder": "inline", "optional": true}
# @raycast.packageName Modeo

# Documentation:
# @raycast.author aguinilydia
# @raycast.authorURL https://github.com/aguinilydia
# @raycast.description Convert the JSON currently in the clipboard on csv.

json=$1
cat $json | jq -r '.[]| join(";")'
echo "Copied to clipboard !"