#!/bin/bash

# Upgrade procedures
TEST_U=`cat /etc/iotronic/iotronic.conf  | grep autobahn`

if [ "$TEST_U" = "" ]; then
	cp /usr/lib/python3.7/site-packages/iotronic_lightningrod/etc/iotronic/iotronic.conf /etc/iotronic/iotronic.conf
	echo "iotronic configuration updated."
else
	echo "Already updated."
fi

# Start the first process
mkdir -b /run/nginx
/usr/sbin/nginx
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start NGINX: $status"
  exit $status
fi

# Start the second process
/usr/bin/lightning-rod
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Lightning-rod: $status"
  exit $status
fi

while sleep 60; do
  ps aux |grep nginx |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep lightning-rod |grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done