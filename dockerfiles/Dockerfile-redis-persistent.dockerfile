FROM redis:6.0.16-buster

RUN mkdir -p /etc/redis && chown redis:redis /etc/redis \
	&& mkdir -p /etc/redis/cwd && chown redis:redis /etc/redis/cwd

COPY ./files/redis-persistent.conf /etc/redis

COPY ./files/docker-entrypoint-aof.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint-aof.sh"]

ADD ./files/redistimeseries.Linux-x86_64.1.6.0.zip /lib/redis/plugins/

EXPOSE 6380
CMD ["redis-server"]