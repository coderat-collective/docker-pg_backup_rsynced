FROM postgres:alpine
MAINTAINER coderat-collective

RUN apk update && apk upgrade

# Setup Mail
RUN apk add --no-cache \
    msmtp \
    openssl \
    ca-certificates
RUN ln -sf /usr/bin/msmtp /usr/sbin/sendmail


RUN apk add --no-cache \
    curl \
    openssh \
    rsync

# Install latest envsubst from github
RUN curl -s https://api.github.com/repos/a8m/envsubst/releases/latest | grep "browser_download_url.*Linux" | cut -d : -f 2,3 | tr -d \" | xargs curl -s -L  -o /usr/local/bin/envsubst
RUN chmod +x /usr/local/bin/envsubst

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY docker-cmd.sh /docker-cmd.sh
COPY data/scripts /scripts
COPY data/config /mnt/config

VOLUME /mnt/backups

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/docker-cmd.sh"]
