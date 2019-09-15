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
  -v /srv/web/database-backup/docker-pg_backup_rsynced/data/scripts/:/mnt/config/ \
  -v /srv/web/database-backup/docker-pg_backup_rsynced/data/.ssh:/root/.ssh \
  -e TZ=Europe/Berlin \
  coderat-collective/docker-pg_backup_rsynced
```
#### In a compose file


### Environment
- Time zone, e.g. `TZ="Europe/Berlin"'`.

### Layout
#### /mnt/backups
Destination for backup creation.

#### /mnt/config
Container config files like [crontab.txt](data/config/crontab.txt] live here.

#### /mnt/scripts
Place for pg_backup.sh script and pg_config. Defaults are already in the contaier.

#### /root/.ssh/
Mount here your ssh keys and known_host file for ssh connection to your backup storage server.
