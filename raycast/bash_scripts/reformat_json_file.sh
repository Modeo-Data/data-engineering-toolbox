#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Reformat JSON
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.packageName Modeo
# @raycast.description Pretty prints the JSON currently in the clipboard.

source ../../raycast-venv/bin/activate
pbpaste | python3 -m json.tool | pbcopy
echo "Copied to clipboard !"
