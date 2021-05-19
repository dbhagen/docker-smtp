FROM alpine:3.13
ARG VERSION=4.94.2-r0

LABEL org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.url="https://github.com/dbhagen/docker-smtp-relay" \
      org.opencontainers.image.licenses=MIT \
      org.opencontainers.image.authors="Daniel B. Hagen <daniel.b.hagen+oss@gmail.com>" \
      org.opencontainers.image.vendor="Daniel B. Hagen"

ENV RELAY_FROM_HOSTS=10.0.0.0/8:172.16.0.0/12:192.168.0.0/16 \
    DKIM_KEY_SIZE=1024 \
    DKIM_SELECTOR=dkim \
    DKIM_SIGN_HEADERS=Date:From:To:Subject:Message-ID \
    IGNORE_SMTP_LINE_LENGTH_LIMIT=1

RUN apk add --no-cache exim=$VERSION openssl bash \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apk/* \
    && mkdir -p /dkim /ssl /var/log/exim /usr/lib/exim /var/spool/exim \
    && ln -s /dev/stdout /var/log/exim/mainlog \
    && ln -s /dev/stdout /var/log/exim/main \
    && ln -s /dev/stderr /var/log/exim/panic \
    && ln -s /dev/stderr /var/log/exim/reject

COPY ./entrypoint.sh /usr/sbin/
#COPY ./harden.sh /usr/sbin/
COPY ./exim.conf /etc/exim/exim.conf

RUN chmod a+x /usr/sbin/entrypoint.sh \
    && chown -R root:root /etc/exim \
    && chmod -R 0644 /etc/exim

#    chmod a+x /usr/sbin/harden.sh && \

#RUN /usr/sbin/harden.sh

VOLUME ["/dkim", "/ssl"]
#USER exim

EXPOSE 2025 2465 2587
ENTRYPOINT ["/usr/sbin/entrypoint.sh"]
CMD ["-bdf", "-q15m", "-v"]
