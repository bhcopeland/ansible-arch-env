#!/usr/bin/env sh

#export rclone_jobber="$HOME/GitHub/ans/backup/rclone_jobber"
export rclone_jobber="/home/ben/GitHub/ansible-arch-env/backup/rclone_jobber"

rclone_jobber=$rclone_jobber

source="$HOME"
dest="gstorage:/backup/desktop"
move_old_files_to="dated_files"
options="--filter-from=filter_rules --checksum -P --transfers=20 --checkers 20"
monitoring_URL=""

$rclone_jobber/rclone_jobber.sh "$source" "$dest" "$move_old_files_to" "$options" "$(basename $0)" "$monitoring_URL"
