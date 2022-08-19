#!/bin/bash


# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Create an archive for file or directory
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Modeo

# Documentation:
# @raycast.author aguinilydia
# @raycast.authorURL https://github.com/aguinilydia
# @raycast.description Create an archive for file or directory

# $1 archive name, $2 the file or directory to archive

tar -zcvf $1 $2
