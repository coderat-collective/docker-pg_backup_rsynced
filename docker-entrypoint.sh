#!/bin/bash
# Import your cron file

envsubst < /mnt/config/crontab.txt > /root/crontab.txt
/usr/bin/crontab /root/crontab.txt

# Convert Docker Environment vars to vars needed by pg_backup_rotated.sh

envsubst < /mnt/config/pg_backup.config > /root/pg_backup.config

# Run the command instruction
exec "$@"
