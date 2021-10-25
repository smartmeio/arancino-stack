FROM redis:6.0.16-buster

RUN mkdir -p /etc/redis && chown redis:redis /etc/redis \
	&& mkdir -p /etc/redis/cwd && chown redis:redis /etc/redis/cwd \
	&& mkdir -p /var/lib/redis && chown redis:redis /var/lib/redis

ADD ./files/redistimeseries.Linux-x86_64.1.6.0.zip /lib/redis/plugins/

COPY ./files/redis-volatile.conf /etc/redis