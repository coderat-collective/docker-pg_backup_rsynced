# docker-pg_backup_rsynced

Docker container backing up postgresql databases and syncing them to remote storage location.
The [pg_backup_rotated.sh](https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux) bash script is used to create rotated sql dumps. The syncronisation is done via the [rsync](https://rsync.samba.org/) tool.

Cron is used to run the backups and sync commands. Configure the cron entry and commands in [./data/config/crontab.txt](data/config/crontab.txt)
You can configure the pg_backup_rotated.sh script with environment variables or place you own [pg_backup.config](https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux)
at `/scripts/pg_backup.config`.  To mail the cron output if needed the simple [msmtp](https://github.com/marlam/msmtp-mirror) mta is used.

If you want to use a modified [pg_backup_rotated.sh](https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux) mount you version to `/scripts/pg_backup_rotated.sh`

If you want to just use the [pg_backup_rotated.sh](https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux) bash script you can delete the rsync command from `./data/config/crontab.txt`.

To use rsync you have to mount a known_hosts file and ssh keys to `/root/.ssh/`.
Note if you dont mount a folder as backup storage to `/mnt/backups` and delete the container
all local backups are gone and rsync will sync the deleted state to you remote host.

The basic workflow of this container is inspired by:
* [b3vis/docker-borgmatic](https://github.com/b3vis/docker-borgmatic)
* [martianrock/docker-pg_backup](https://github.com/martianrock/docker-pg_backup)

### Usage
* Create your `.env` file from [sample.env](sample.env). You can configure the
    [pg_backup_rotated.sh](https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux) script, the [msmtp](https://github.com/marlam/msmtp-mirror) used by crontab and the ssh backend for [rsync](https://rsync.samba.org/)
* For further configuration you can mount your config files and scripts. Env vars will still be replaced at container startup:
  * [crontab.txt](data/config/crontab.txt) -> `/mnt/config/crontab.txt`
  * [pg_backup_rotated.sh](data/scripts/pg_backup_rotated.sh) mount you version to `/scripts/pg_backup_rotated.sh`
  * [pb_backup.conf](data/config/pg_backup.conf) -> `/mnt/config/pb_backup.conf`
  * [msmtprc](data/config/msmtprc) at `/mnt/config/msmtprc`
* Start the container with mounted:
  * backup folder `./backups:/mnt/backups`
  * ssh private key `./ssh_private_key:/root/.ssh/id_rsa`
  * known_hosts file `./known_hosts:/root/.ssh/known_hosts`

### Examples
#### Run command
Basic:
```
docker run \
  --detach --name  pg_backup_rsynced\
  -v /srv/web/database-backup/docker-pg_backup_rsynced/data/backups:/mnt/backups \
  -v /srv/web/database-backup/docker-pg_backup_rsynced/data/config:/mnt/config \
  -v /srv/web/database-backup/docker-pg_backup_rsynced/data/.ssh/id_rsa:/root/.ssh/id_rsa \
  -v /srv/web/database-backup/docker-pg_backup_rsynced/data/.ssh/known_hosts:/root/.ssh/known_hosts \
  -e TZ=Europe/Berlin \
  -e POSTGRES_HOSTNAME=web_postgres \
  -e POSTGRES_USER=web_postgres_admin \
  -e POSTGRES_PASSWORD=superS3cretPasswd \
  coderat-collective/docker-pg_backup_rsynced
```
With Mail:
```
docker run \
  --detach --name  pg_backup_rsynced\
  -v /srv/web/database-backup/docker-pg_backup_rsynced/data/backups:/mnt/backups \
  -v /srv/web/database-backup/docker-pg_backup_rsynced/data/config:/mnt/config \
  -v /srv/web/database-backup/docker-pg_backup_rsynced/data/.ssh/id_rsa:/root/.ssh/id_rsa \
  -v /srv/web/database-backup/docker-pg_backup_rsynced/data/.ssh/known_hosts:/root/.ssh/known_hosts \
  -e TZ=Europe/Berlin \
  -e POSTGRES_HOSTNAME=web_postgres \
  -e POSTGRES_USER=web_postgres_admin \
  -e POSTGRES_PASSWORD=superS3cretPasswd \
  -e MAIL_RELAY_HOST=mail.example.com \
  -e MAIL_PORT=587 \
  -e MAIL_FROM=pg_backup_rsynced \
  -e MAIL_USER=backup_log \
  -e MAIL_PASSWORD=yourMailP4ssword \
  coderat-collective/docker-pg_backup_rsynced
```
#### In a compose file
Use [sample.env](sample.env) to create your own `.env` file
```
version: '2'
services:
  web-postgres:
    container_name: web_postgres
    image: postgres:alpine
    env_file: .env
    environment:
      - POSTGRES_DB=web_project_production
    expose:
      - '5432'

  pg_backup_rsynced:
    container_name: pg_backup_rsynced
    image: coderat/docker-pg_backup_rsynced 
    env_file: .env
    volumes:
      - ./data/backups:/mnt/backups            # backup destination
      - ./data/config:/mnt/config              # Directory with config files + crontab.txt
      - ./data/ssh/id_rsa:/root/.ssh/id_rsa
      - ./data/ssh/known_hosts:/root/.ssh/known_hosts
    links:          
      - web-postgres
```

### Environment
- `TZ=Europe/Berlin` - Time zone
- `REMOTE_BACKUP_STORAGE=webbackup@web.example.com:database/` - ssh endpoint for rsync

#### pg_backup
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

#### mail msmtp
- `MAILTO`           - mail address receiving cron output 
- `MAIL_RELAY_HOST`  - mail server used for realying
- `MAIL_PORT`        - port where the relay mail server is accepting connections
- `MAIL_FROM`        - mail from
- `MAIL_USER`        - user name loging in on the relay mail server
- `MAIL_PASSWORD`    - password used for loging in on the relay mail server

### Layout
#### /mnt/backups
Destination for backups created by [pg_backup_rotated.sh](https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux)

#### /mnt/config
Container config files before env var substituation. Config via env vars or mount you custom configs here.
  * [crontab.txt](data/config/crontab.txt)
  * [pg_backup.config](data/config/pg_backup.config)
  * [msmtprc](data/config/msmtprc)

#### /scripts
Generated config files and scripts are placed here. Place your own [pg_backup_rotated.sh](https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux).

#### /root/.ssh/
Mount here your ssh keys and known_host file for ssh connection to your backup storage server.
