FROM postgres:alpine
MAINTAINER coderat-collective

RUN apk upgrade --no-cache \
    && apk add --no-cache \
    curl \
    openssh \
    rsync

# Install envsubst
RUN curl -L https://github.com/a8m/envsubst/releases/download/v1.1.0/envsubst-`uname -s`-`uname -m` -o /usr/local/bin/envsubst
RUN chmod +x /usr/local/bin/envsubst

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY docker-cmd.sh /docker-cmd.sh
COPY data/scripts /scripts

VOLUME /mnt/backups

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/docker-cmd.sh"]
