FROM redis:6.0.16-buster

ARG TS_VERSION="1.6.0"
ARG DOWN_URL="https://packages.smartme.io/repository/arancino-download/redistimeseries/glibc"

RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        software-properties-common vim wget nano curl bash-completion apt-utils \
				zip unzip tar \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && :

RUN mkdir -p /etc/redis && chown redis:redis /etc/redis \
	&& mkdir -p /etc/redis/cwd && chown redis:redis /etc/redis/cwd \
	&& mkdir -p /var/lib/redis && chown redis:redis /var/lib/redis \
	&& mkdir -p /lib/redis/plugins/

COPY ./files/redis-persistent.conf /etc/redis

COPY ./files/docker-entrypoint-aof.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint-aof.sh"]

# ADD ./files/redistimeseries.Linux-x86_64.1.6.0.zip /lib/redis/plugins/

RUN wget ${DOWN_URL}/redistimeseries.Linux-$(uname -m).${TS_VERSION}.zip -P /tmp \
	&& cd /tmp \
	&& unzip redistimeseries.Linux-$(uname -m).${TS_VERSION}.zip -d /lib/redis/plugins/ \
	&& rm -rf /tmp/*


EXPOSE 6380
CMD ["redis-server"]