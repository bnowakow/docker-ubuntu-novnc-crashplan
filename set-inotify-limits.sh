#!/bin/bash

# ask for password in the begning so it would be "cached" later
sudo ls
echo

# https://unix.stackexchange.com/questions/444998/how-to-set-and-understand-fs-notify-max-user-watches
# https://www.ibm.com/docs/en/aspera-on-demand/3.9?topic=line-configuring-linux-many-watch-folders

max_user_watches=2147483647; # max value
max_user_watches=524288; # IBM
max_user_watches=1048576; # https://askubuntu.com/a/1377649
max_user_watches=3276800; # https://www.reddit.com/r/jellyfin/comments/ntis6u/inotify_limit_in_docker_container/h0suyxm/
max_user_watches=10485760; # https://coder.com/docs/coder/latest/guides/troubleshooting/inotify-watch-limits
echo "prev           "`cat /proc/sys/fs/inotify/max_user_watches`
echo "trying to set  $max_user_watches"
sudo bash -c "echo $max_user_watches > /proc/sys/fs/inotify/max_user_watches"
echo "set            "`cat /proc/sys/fs/inotify/max_user_watches`

echo

max_user_instances=12345024;
max_user_instances=1024; # IBM
max_user_instances=1048576; # https://askubuntu.com/a/1377649
echo "prev          "`cat /proc/sys/fs/inotify/max_user_instances`
echo "trying to set  $max_user_instances"
sudo bash -c "echo $max_user_instances > /proc/sys/fs/inotify/max_user_instances"
echo "set            "`cat /proc/sys/fs/inotify/max_user_instances`

echo

file_max=9223372036854775807; # default when truenas boots
file_max=2097152; # IBM
echo "prev          "`cat /proc/sys/fs/file-max`
echo "trying to set  $file_max"
sudo bash -c "echo $file_max > /proc/sys/fs/file-max"
echo "set            "`cat /proc/sys/fs/file-max`

echo 

max_queued_events=1000000; # https://stackoverflow.com/a/62501929
echo "prev           "`cat /proc/sys/fs/inotify/max_queued_events`
echo "trying to set  $max_queued_events"
sudo bash -c "echo $max_queued_events > /proc/sys/fs/inotify/max_queued_events"
echo "set            "`cat /proc/sys/fs/inotify/max_queued_events`

