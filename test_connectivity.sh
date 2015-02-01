#!/bin/bash

# script for testing port connectivity
# uses netcat: nc -z -w 10 -v host port
#
# usage:
# 1. populate 'servers' array with host/port values
#      see example below
# 2. execute script

declare -A servers
#servers["localhost"]="localhost 80"

for server in "${!servers[@]}"; do
	echo "testing connectivity to: $server (${servers["$server"]})";
	nc -z -w 10 -v ${servers["$server"]};
	echo "";
done
