###########################################################
# Timeseries builder Section #
###########################################################
FROM redis:6.0.16-alpine3.16 as tsbuilder

ARG TS_VERSION="1.6.13"

RUN echo "cross-build-start-timeseries"

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories

RUN apk update \
	&& apk add git gcc g++ musl-dev make automake libtool vim nano lcov patch \
		autoconf m4 make file openssl-dev bash libffi-dev yaml-dev python3 python3-dev \
	&& ln -s /usr/bin/python3 /usr/bin/python

COPY ./files/alpine-ts-comp.patch /tmp/

RUN git clone https://github.com/RedisTimeSeries/RedisTimeSeries.git /RedisTimeSeries -b v${TS_VERSION} \
	&& cd /RedisTimeSeries \
  && patch -p1 < /tmp/alpine-ts-comp.patch \
	&& git submodule update --init --recursive \
	&& make setup \
	&& make -j3 \
	&& make pack

RUN echo "cross-build-end-ts"
###################################################################

FROM redis:6.0.16-alpine3.16

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories

RUN mkdir -p /etc/redis && chown redis:redis /etc/redis \
	&& mkdir -p /etc/redis/cwd && chown redis:redis /etc/redis/cwd \
	&& mkdir -p /var/lib/redis && chown redis:redis /var/lib/redis \
	&& mkdir -p /lib/redis/plugins/

RUN apk update \
	&& apk add --no-cache libstdc++

COPY ./files/redis-persistent.conf /etc/redis

COPY ./files/docker-entrypoint-aof-alpine.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint-aof-alpine.sh"]

COPY --from=tsbuilder /RedisTimeSeries/bin/*-release/redistimeseries.so /lib/redis/plugins/

EXPOSE 6380
CMD ["redis-server"]
