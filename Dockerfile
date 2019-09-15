FROM postgres:alpine
MAINTAINER coderat-collective

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY docker-cmd.sh /docker-cmd.sh
COPY data/scripts /scripts

VOLUME /mnt/backups

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/docker-cmd.sh"]
