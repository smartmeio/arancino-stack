FROM redis:6.0.10-alpine

RUN mkdir -p /etc/redis && chown redis:redis /etc/redis \
	&& mkdir -p /etc/redis/cwd && chown redis:redis /etc/redis/cwd \
	&& mkdir -p /var/lib/redis && chown redis:redis /var/lib/redis

ADD ./files/redistimeseries.Linux-x86_64-musl.1.4.8.tar.gz /lib/redis/plugins/

COPY ./files/redis-volatile.conf /etc/redis
