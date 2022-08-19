#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title System CPU and MEM
# @raycast.mode inline
# @raycast.packageName Dashboard

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 {"type": "text", "placeholder": "inline", "optional": true}
# @raycast.packageName Modeo

# Documentation:
# @raycast.author aguinilydia
# @raycast.authorURL https://github.com/aguinilydia
# @raycast.description

total=$(ps -A -o %cpu,%mem | awk '{ cpu += $1; mem += $2} END {print "sys_cpu  "  cpu"% sys_mem   "mem"%"}')

echo $total