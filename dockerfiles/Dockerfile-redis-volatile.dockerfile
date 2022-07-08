###########################################################
# Timeseries builder Section #
###########################################################
FROM redis:6.0.16-buster as tsbuilder

ARG TS_VERSION="1.6.13"

RUN echo "cross-build-start-timeseries"

RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        vim wget nano curl bash-completion git zip unzip tar ca-certificates build-essential \
        libssl-dev libssl-dev autoconf m4 libtool libtool-bin libyaml-dev python-all \
        python-all-dev python3-all python3-all-dev libffi-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && :

RUN : \
    && git clone https://github.com/RedisTimeSeries/RedisTimeSeries.git /RedisTimeSeries -b v${TS_VERSION} \
  	&& cd /RedisTimeSeries \
  	&& git submodule update --init --recursive \
    && sed -i /getgcc/d system-setup.py \
  	&& make setup \
  	&& make -j3 \
  	&& make pack \
    && :

RUN echo "cross-build-end-ts"
###################################################################

FROM redis:6.0.16-buster

RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        vim wget nano curl bash-completion apt-utils zip unzip tar \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && :

RUN mkdir -p /etc/redis && chown redis:redis /etc/redis \
	&& mkdir -p /etc/redis/cwd && chown redis:redis /etc/redis/cwd \
	&& mkdir -p /var/lib/redis && chown redis:redis /var/lib/redis \
	&& mkdir -p /lib/redis/plugins/

COPY --from=tsbuilder /RedisTimeSeries/bin/*-release/redistimeseries.so /lib/redis/plugins/

COPY ./files/redis-volatile.conf /etc/redis