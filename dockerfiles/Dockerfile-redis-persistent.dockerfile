FROM redis:6.0.10-buster

RUN mkdir -p /etc/redis && chown redis:redis /etc/redis \
	&& mkdir -p /etc/redis/cwd && chown redis:redis /etc/redis/cwd

COPY ./files/redis-persistent.conf /etc/redis

COPY ./files/docker-entrypoint-aof.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint-aof.sh"]

EXPOSE 6380
CMD ["redis-server"]