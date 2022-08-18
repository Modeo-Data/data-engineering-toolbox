#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Prettify JSON
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 💻

# Documentation:
# @raycast.description Pretty prints the JSON currently in the clipboard.



pbpaste | python -m json.tool

