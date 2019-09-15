#!/bin/bash
# Import your cron file
/usr/bin/crontab /mnt/config/crontab.txt

# Convert Docker Environment vars to vars needed by pg_backup_rotated.sh
/scripts/config_gen.sh

# Run the command instruction
exec "$@"
