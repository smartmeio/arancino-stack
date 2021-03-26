FROM redis:6.0.10-buster

RUN mkdir -p /etc/redis && chown redis:redis /etc/redis \
	&& mkdir -p /etc/redis/cwd && chown redis:redis /etc/redis/cwd

COPY ./files/redis-persistent.conf /etc/redis

EXPOSE 6380