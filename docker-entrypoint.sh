#!/bin/bash
# Import your cron file

envsubst < /mnt/config/crontab.txt > /scripts/crontab.txt
/usr/bin/crontab /scripts/crontab.txt

# Convert Docker Environment vars to vars needed by pg_backup_rotated.sh

envsubst < /mnt/config/pg_backup.config > /scripts/pg_backup.config

# Run the command instruction
exec "$@"
