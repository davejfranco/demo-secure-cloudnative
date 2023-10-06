#!/bin/sh
# This is dummy script for testing
while true; do
  echo "$(date +'%Y-%m-%d:%H:%M:%S') - I'm agent smith" >> /var/log/agent/smith.log
  sleep 5
done
