#!/bin/bash

# Update port on first run
sleep 10 # give transmission time to start
PORT=`cat /portforward/port.txt`
echo "Update port forward to: $PORT"
transmission-remote http://localhost:9091/transmission -n $TRUSER:$TRPASSWD -p $PORT

inotifywait -q -m -e close_write /portforward/port.txt |
while read -r filename event; do
  PORT=`cat /portforward/port.txt`
  echo "Update port forward to: $PORT"
  transmission-remote -n $TRUSER:$TRPASSWD -p $PORT
done
