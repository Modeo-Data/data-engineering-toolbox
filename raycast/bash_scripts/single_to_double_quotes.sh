#!/bin/bash


# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title double to signle quotes
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Modeo

# Documentation:
# @raycast.author aguinilydia
# @raycast.authorURL https://github.com/aguinilydia


source ../venv/bin/activate

pbpaste| python3 '../python_scripts/single_to_double_quotes.py' | pbcopy
echo "Copied to clipboard !"
