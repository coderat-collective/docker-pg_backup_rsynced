FROM postgres:alpine
MAINTAINER coderat-collective

COPY entry.sh /entry.sh

VOLUME /mnt/backups

CMD ["/entry.sh"]
