#!/bin/bash


# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title single to double quotes
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Modeo

# Documentation:
# @raycast.author aguinilydia
# @raycast.authorURL https://github.com/aguinilydia


source ../../raycast-venv/bin/activate

pbpaste| python3 '../python_scripts/double_to_single_quotes.py' | pbcopy
echo "Copied to clipboard !"
