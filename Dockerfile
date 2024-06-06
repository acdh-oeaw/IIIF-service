FROM ghcr.io/acdh-oeaw/iipsrv/iipsrv as builder
COPY uv /app/uv
COPY mirador /app/mirador
USER root
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN apk update && \
     apk add --no-cache \
     nodejs npm && \
     npm install -g corepack &&\
     corepack prepare pnpm@8.15.4 --activate &&\
     cd /app/uv && pnpm install &&\
     cd /app/mirador && pnpm install && pnpm run build


FROM alpine:3.20

# inspired by https://github.com/m4rcu5nl/docker-lighttpd-alpine
LABEL maintainer="Omar Siam <omar.siam@oeaw.ac.at>" \
      version="1.1.0"

# Install packages
RUN apk update && \
    apk add --no-cache \
    lighttpd \
    lighttpd-mod_webdav \
    lighttpd-mod_auth \
    apache2-utils\
    openssl \
    curl && \
    rm -rf /var/cache/apk/* &&\
    mkdir -p /mnt/data/upload &&\
    chown -R lighttpd:www-data /mnt/data &&\
    chmod g+w -R /mnt/data &&\
    sed -i s/100:101/100:82/ /etc/passwd
# change the primary group of lighttpd to www-data
COPY --from=builder /versions /
COPY --from=builder /app/uv/node_modules/universalviewer/dist /var/www/htdocs/uv
COPY --from=builder /app/mirador/dist /var/www/htdocs/dist
COPY config/lighttpd/*.sh /
COPY config/lighttpd/*.conf /etc/lighttpd/
COPY htdocs/ /var/www/htdocs/
WORKDIR /var/www
EXPOSE 8080
# user lighttpd, kubernetes checks non-root with numbers
USER 100

# Make configuration path and webroot a volume
VOLUME /etc/lighttpd/
VOLUME /var/www/
# for upload
# deleting files with gvfs is impossible: https://gitlab.gnome.org/GNOME/gvfs/-/issues/545
# alternative: use cadaver
VOLUME /mnt/data

ENV IIPSRV=localhost\
    NODESRV=localhost\
    HTTPD_ERROR_LOGFILE=/dev/fd/3\
    HTTPD_ACCESS_LOGFILE=/dev/fd/3\
    LOGIDSITE=0\
    DEFAULT_COLLECTION=default

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD [ "/usr/bin/wget", "localhost:8080/", "-O", "-", "--spider", "-q" ]

CMD ["/bin/sh", "/run_lighttpd.sh"]