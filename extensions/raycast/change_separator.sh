#!/bin/bash


# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title change separator
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.argument1 { "type": "text", "placeholder": "Old_separator" }
# @raycast.argument2 { "type": "text", "placeholder": "new_separator" }
# @raycast.icon 🤖
# @raycast.packageName Modeo

# Documentation:
# @raycast.author aguinilydia
# @raycast.authorURL https://github.com/aguinilydia
# @raycast.description Replace old_separator to new_separator in data currently in the clipboard


source ../venv/bin/activate

pbpaste| python3 './python_scripts/replace_separator.py' $1 $2 | pbcopy
echo "Copied to clipboard !"

