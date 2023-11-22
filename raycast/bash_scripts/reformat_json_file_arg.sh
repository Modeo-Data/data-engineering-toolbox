#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Reformat JSON
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.argument1 { "type": "text", "placeholder": "file_path" }
# @raycast.icon 💻
# @raycast.packageName Modeo
# Documentation:
# @raycast.description Reformat the JSON file argument.


source ../../raycast-venv/bin/activate
cat $1 | python -m json.tool| pbcopy
echo "Copied to clipboard !"
