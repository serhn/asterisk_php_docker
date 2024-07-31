FROM alpine:3.20.2 

ENV LANG=C.UTF-8
ENV LC_ALL C.UTF-8

RUN set -e \
&& apk add --update --quiet \
         asterisk \
         asterisk-chan-dongle \
         asterisk-sample-config >/dev/null \
         php php-curl php-pdo_sqlite php-json \
&& asterisk -U asterisk &>/dev/null \
&& sleep 5s \
&& [ "$(asterisk -rx "core show channeltypes" | grep PJSIP)" != "" ] && : \
     || rm -rf /usr/lib/asterisk/modules/*pj* \
&& pkill -9 ast \
&& sleep 1s \
&& truncate -s 0 \
     /var/log/asterisk/messages \
     /var/log/asterisk/queue_log || : \
&& mkdir -p /var/spool/asterisk/fax \
&& chown -R asterisk: /var/spool/asterisk \
&& rm -rf /var/run/asterisk/* \
          /var/cache/apk/* \
          /tmp/* \
          /var/tmp/*

RUN mkdir www
RUN echo "<?php phpinfo();" > www/index.php 

EXPOSE 5060/udp 5060/tcp 8888/tcp
VOLUME /var/lib/asterisk/sounds /var/lib/asterisk/keys /var/lib/asterisk/phoneprov /var/spool/asterisk /var/log/asterisk



ADD docker-entrypoint.sh /docker-entrypoint.sh



ENTRYPOINT ["/docker-entrypoint.sh"]
