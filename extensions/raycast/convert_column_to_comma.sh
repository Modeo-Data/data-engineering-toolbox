#!/bin/bash


# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Converts column to comma separated.
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Modeo

# Documentation:
# @raycast.author aguinilydia
# @raycast.authorURL https://github.com/aguinilydia
# @raycast.description Converts column to comma separated.


pbpaste| gsed ':a;N;$!ba;$s/\n/,/g' | pbcopy
