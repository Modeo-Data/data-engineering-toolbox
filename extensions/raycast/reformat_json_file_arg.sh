#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Prettify JSON
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 💻

# Documentation:
# @raycast.description Prettify the the JSON file argument.



cat $1 | python -m json.tool


