#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Reformat JSON file
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.packageName Modeo
# @raycast.description Pretty prints the JSON currently in the clipboard.

pbpaste | python3 -m json.tool
