#!/bin/bash

# https://stackoverflow.com/a/18216122
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# https://askubuntu.com/a/719157
cp set-inotify-limits.service /etc/systemd/system/set-inotify-limits.service
systemctl daemon-reload
systemctl enable /etc/systemd/system/set-inotify-limits.service

