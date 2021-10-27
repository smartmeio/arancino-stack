################################
# Upload tools builder Section #
################################
FROM alpine:3.10.9 as builder

RUN echo "cross-build-start"

RUN : \
	&& apk update \
	&& apk add vim wget nano curl git bash gcc g++ make \
		autoconf m4 gettext libtool automake libusb libusb-dev \
	&& :

# build openocd
RUN apk --no-cache add --virtual runtime-dependencies \
      libusb \
      libftdi1 \
  && apk --no-cache add --virtual build-dependencies \
      git \
      build-base \
      libusb-dev \
      libftdi1-dev \
      automake \
      autoconf \
      libtool \
	&& git clone --depth 1 git://repo.or.cz/openocd.git -b v0.11.0 openocd \
    && cd /openocd \
    && ./bootstrap \
    && ./configure \
    && make -j3 \
		&& cd /

# build dfu-util-stm32
RUN git clone https://github.com/artynet/dfu-util-official.git -b smartme-stm32 dfu-util \
	&& cd /dfu-util \
	&& ./autogen.sh \
	&& ./configure \
	&& make -j3 \
	&& cd /

# build bossac 
RUN git clone https://github.com/artynet/BOSSA.git -b arduino-alpine \
	&& cd /BOSSA \
	&& make bin/bossac \
	&& cd /

RUN echo "cross-build-end"

####################
# Arancino Section #
####################
FROM alpine:3.10.9

RUN : \
    && apk update \
    && apk add vim wget nano curl python3 python3-dev linux-pam \
        gcc musl-dev linux-headers procps coreutils bash shadow \
        sudo net-tools libffi libffi-dev openssl openssl-dev sed \
				libusb libusb-dev libftdi1 libftdi1-dev \
    && :

ARG user=me
ARG group=me
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG ARANCINO_HOME=/home/me

ENV ARANCINO_HOME $ARANCINO_HOME

# Arancino is run with user `me`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $ARANCINO_HOME \
  && chown ${uid}:${gid} $ARANCINO_HOME \
  && addgroup -g ${gid} ${group} \
  && adduser -h "$ARANCINO_HOME" -u ${uid} -G ${group} -s /bin/bash -D ${user} \
	&& echo me:arancino | chpasswd \
  && echo root:arancino | chpasswd

# bossac copy from builder
ENV BINDIR /usr/bin/
COPY --from=builder /BOSSA/bin/bossac "$BINDIR"

# openocd copy from builder
COPY --from=builder /openocd/src/openocd "$BINDIR"

# dfu-util-stm32 copy from builder
COPY --from=builder /dfu-util/src/dfu-* "$BINDIR"

# installing arancino
RUN wget -qO- https://bootstrap.pypa.io/pip/get-pip.py | python3

COPY ./files/pip.conf /etc/pip.conf

RUN pip3 install -v arancino==2.3.0 adafruit-nrfutil

COPY ./files/arancino.prod.cfg /etc/arancino/config/arancino.prod.cfg
COPY ./files/arancino.dev.cfg /etc/arancino/config/arancino.dev.cfg

# copying upload script
COPY ./files/run-arancino-bossac.sh /usr/bin/run-arancino-bossac
RUN chmod +x /usr/bin/run-arancino-bossac

# Arancino home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $ARANCINO_HOME

EXPOSE 1475
EXPOSE 6379
EXPOSE 6380
