#!/bin/sh
random_pw=$(tr -dc _A-Z-a-z-0-9 < /dev/urandom | head -c${1:-16})
echo -n ${UPLOAD_PASSWD:-$random_pw} > /mnt/data/uploadpasswd
echo Upload passwd is $(cat /mnt/data/uploadpasswd)
# current WORKDIR is /var/www
cd /mnt/data
cat uploadpasswd | htpasswd -ic uploadpasswd upload
cd /var/www
. /versions
exec 3>&1
exec /usr/sbin/lighttpd -D -f /etc/lighttpd/lighttpd.conf