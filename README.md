# docker-pg_backup_rsynced

Docker container backing up postgresql databases and syncing them to remote storage location.
The [pg_backup bash script](https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux) is used to create rotated sql dumps. The syncronisation is done via the [rsync](https://rsync.samba.org/) tool.

It uses cron to run the backups at a time you can configure in `./data/config/crontab.txt`.

The basic workflow of this container is inspired by:
* [b3vis/docker-borgmatic](https://github.com/b3vis/docker-borgmatic)
* [martianrock/docker-pg_backup](https://github.com/martianrock/docker-pg_backup)

### Usage
* Edit the [crontab.txt](data/config/crontab.txt] to adjust the timing of the backup and sync command.
* Edit backup script. Mount the script
* Add ssh keys and knwon hosts

### Examples
#### Run command
```
docker run \
  --detach --name  pg_backup_rsynced\
  -v /srv/web/database-backup/docker-pg_backup_rsynced/data/backups:/mnt/backups \
  -v /srv/web/database-backup/docker-pg_backup_rsynced/data/config:/mnt/config \
  -v /srv/web/database-backup/docker-pg_backup_rsynced/data/scripts/:/mnt/scripts/ \
  -v /srv/web/database-backup/docker-pg_backup_rsynced/data/.ssh:/root/.ssh \
  -e TZ=Europe/Berlin \
  -e POSTGRES_HOSTNAME=web_postgres \
  -e POSTGRES_USER=web_postgres_admin \
  -e POSTGRES_PASSWORD=superS3cretPasswd \
  coderat-collective/docker-pg_backup_rsynced
```
#### In a compose file


### Environment
- `TZ=Europe/Berlin` - Time zone
- `MAILTO`           - mail address receiving cron output 

- `POSTGRES_HOSTNAME`      - database container or ip/hostname of databaseserver
- `POSTGRES_USER`          - user to connect as ('postgres' by default)
- `POSTGRES_PASSWORD`      - password of POSTGRES_USER
- `POSTGRES_PASSWORD_FILE` - location of file containing password of POSTGRES_USER (can be /run/secrets/SECRETNAME if you put password in SECRETNAME)
- `WEEKS_TO_KEEP`          - how many weeks to keep weekly backups (default 5)
- `DAYS_TO_KEEP`           - number of days to keep daily backups (default 7)
- `DAY_OF_WEEK_TO_KEEP`    - which day to take the weekly backup from (1-7 = Monday-Sunday, default 5-Friday)
- `ENABLE_GLOBALS_BACKUPS` - will produce gzipped sql file containing the cluster globals, like users and passwords, if set to "yes" (default)
- `ENABLE_PLAIN_BACKUPS`   - will produce a gzipped plain-format backup if set to "yes" (default)
- `ENABLE_CUSTOM_BACKUPS`  - will produce a custom-format backup if set to "yes" (default)
- `SCHEMA_ONLY_LIST`       - List of strings to match against in database name, separated by space or comma, for which we only wish to keep a backup of the schema, not the data. Any database names which contain any of these values will be considered candidates. (e.g. "system_log" will match "dev_system_log_2010-01"). Default is empty list.

### Layout
#### /mnt/backups
Destination for backups created by `pg_backup_rotated.sh`

#### /mnt/config
Container config files like [crontab.txt](data/config/crontab.txt] live here.

#### /mnt/scripts
Scripts used for backing up the database. If you want to place your own `pg_backup_rotated.sh` watch out to not overwrite the other scripts.

#### /root/.ssh/
Mount here your ssh keys and known_host file for ssh connection to your backup storage server.
