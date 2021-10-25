FROM redis:6.0.16-alpine

ARG TS_VERSION="1.4.10"
ARG DOWN_URL="https://packages.smartme.io/repository/arancino-download/redistimeseries/musl"

RUN mkdir -p /etc/redis && chown redis:redis /etc/redis \
	&& mkdir -p /etc/redis/cwd && chown redis:redis /etc/redis/cwd \
	&& mkdir -p /var/lib/redis && chown redis:redis /var/lib/redis \
	&& mkdir -p /lib/redis/plugins/

COPY ./files/redis-persistent.conf /etc/redis

COPY ./files/docker-entrypoint-aof-alpine.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint-aof-alpine.sh"]

# ADD ./files/redistimeseries.Linux-x86_64-musl.1.6.0.tar.gz /lib/redis/plugins/

RUN wget ${DOWN_URL}/redistimeseries.Linux-$(uname -m).${TS_VERSION}-musl.zip -P /tmp \
	&& cd /tmp \
	&& unzip redistimeseries.Linux-$(uname -m).${TS_VERSION}-musl.zip -d /lib/redis/plugins/ \
	&& rm -rf /tmp/*

EXPOSE 6380
CMD ["redis-server"]
