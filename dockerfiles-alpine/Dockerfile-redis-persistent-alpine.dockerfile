FROM redis:6.0.10-alpine

RUN mkdir -p /etc/redis && chown redis:redis /etc/redis \
	&& mkdir -p /etc/redis/cwd && chown redis:redis /etc/redis/cwd

COPY ./files/redis-persistent.conf /etc/redis

COPY ./files/docker-entrypoint-aof-alpine.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint-aof-alpine.sh"]

ADD ./files/redistimeseries.Linux-x86_64-musl.1.4.8.tar.gz /lib/redis/plugins/

EXPOSE 6380
CMD ["redis-server"]
