#!/bin/bash
# Import your cron file
/usr/bin/crontab /mnt/config/crontab.txt
# Start cron
/usr/sbin/crond -f -L /dev/stdout
