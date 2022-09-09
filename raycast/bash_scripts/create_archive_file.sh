#!/bin/bash


# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title archive file
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.argument1 { "type": "text", "placeholder": "archive_name" }
# @raycast.argument1 { "type": "text", "placeholder": "file_to_archive" }
# @raycast.icon 🤖
# @raycast.packageName Modeo

# Documentation:
# @raycast.author aguinilydia
# @raycast.authorURL https://github.com/aguinilydia
# @raycast.description Create an archive for file or directory

# $1 archive name, $2 the file or directory to archive
source ../../raycast-venv/bin/activate

tar -zcvf $1 $2
