#!/bin/bash


# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Converts Open new private window.
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Modeo

# Documentation:
# @raycast.author aguinilydia
# @raycast.authorURL https://github.com/aguinilydia
# @raycast.description Open new private window.

browser="Brave Browser"
URL=$(osascript -e "$browser")

open -a "$browser" -n --args --incognito --new-window "$URL"
