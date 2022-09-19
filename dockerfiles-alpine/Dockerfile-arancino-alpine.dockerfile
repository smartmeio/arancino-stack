###########################################################
# arduinoSTM32load and rp2040load tools gobuilder Section #
###########################################################
FROM golang:1.17.3-alpine3.14 as gobuilder

RUN echo "cross-build-start-golang"

RUN apk update \
	&& apk add git make vim nano

RUN git clone https://github.com/artynet/arduino101load.git /arduinoSTM32load \
	&& cd /arduinoSTM32load \
	&& go build -o arduinoSTM32load

RUN git clone https://github.com/arduino/rp2040tools.git -b 1.0.3 /rp2040tools \
	&& cd /rp2040tools \
	&& go build -o rp2040load

RUN echo "cross-build-end-golang"

################################
# Upload tools builder Section #
################################
FROM alpine:3.14.2 as builder

RUN echo "cross-build-start"

RUN : \
	&& apk update \
	&& apk add vim wget nano curl git bash gcc g++ make \
	   autoconf m4 gettext libtool automake libusb libusb-dev \
	   gcc g++ make openssl libressl-dev musl-dev build-base \
	   bsd-compat-headers libc-dev bash-completion cmake \
	&& :

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

# build elf2uf2
RUN git clone https://github.com/raspberrypi/pico-sdk.git -b 1.3.0 pico-sdk \
	&& cd /pico-sdk/tools/elf2uf2 \
	&& mkdir build \
	&& cd build/ && cmake ../ \
	&& make \
	&& cd /

# build picotool
RUN git clone https://github.com/raspberrypi/picotool.git -b 1.1.0 picotool \
	&& cd /picotool \
	&& mkdir build \
	&& cd build/ && cmake -DPICO_SDK_PATH=/pico-sdk ../ \
	&& make \
	&& cd /

RUN echo "cross-build-end"

####################
# Arancino Section #
####################
FROM alpine:3.14.2

RUN : \
    && apk update \
    && apk add vim wget nano curl python3 python3-dev linux-pam \
       gcc musl-dev linux-headers procps coreutils bash shadow \
       sudo net-tools libffi libffi-dev openssl openssl-dev sed \
       libusb libusb-dev libftdi1 libftdi1-dev avrdude openocd \
       g++ make libressl-dev libc-dev musl-dev build-base \
       bsd-compat-headers bash-completion cmake \
    && :

ARG user=me
ARG group=me
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG ARANCINO_HOME=/home/me

ENV ARANCINO_HOME $ARANCINO_HOME
ENV PYTHON_PIP_VERSION 22.2.2

# Arancino is run with user `me`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $ARANCINO_HOME \
  && chown ${uid}:${gid} $ARANCINO_HOME \
  && addgroup -g ${gid} ${group} \
  && adduser -h "$ARANCINO_HOME" -u ${uid} -G ${group} -s /bin/bash -D ${user} \
  && echo me:arancino | chpasswd \
  && echo root:arancino | chpasswd

# arduinoSTM32load copy from gobuilder
ENV BINDIR /usr/bin/
COPY --from=gobuilder /arduinoSTM32load/arduinoSTM32load "$BINDIR"

# rp2040load copy from gobuilder
COPY --from=gobuilder /rp2040tools/rp2040load "$BINDIR"

# bossac copy from builder
COPY --from=builder /BOSSA/bin/bossac "$BINDIR"

# dfu-util-stm32 copy from builder
COPY --from=builder /dfu-util/src/dfu-* "$BINDIR"

# elf2uf2 copy from builder
COPY --from=builder /pico-sdk/tools/elf2uf2/build/elf2uf2 "$BINDIR"

# picotool copy from builder
COPY --from=builder /picotool/build/picotool "$BINDIR"

# installing arancino
RUN wget -qO- https://bootstrap.pypa.io/pip/get-pip.py "pip==$PYTHON_PIP_VERSION" | python3

COPY ./files/pip.conf /etc/pip.conf

RUN pip3 install -v -U pip \
	&& pip3 install -v --no-cache-dir arancino==2.5.1 adafruit-nrfutil

COPY ./files/arancino.cfg.yml /etc/arancino/config/arancino.cfg.yml
COPY ./files/arancino.dev.cfg.yml /etc/arancino/config/arancino.dev.cfg.yml

# copying upload tool scripts
COPY ./files/uf2conv.py /usr/bin/uf2conv.py

COPY ./files/run-arancino-bossac.sh /usr/bin/run-arancino-bossac
COPY ./files/run-arancino-arduinoSTM32load.sh /usr/bin/run-arancino-arduinoSTM32load
COPY ./files/run-arancino-adafruit-nrfutil.sh /usr/bin/run-arancino-adafruit-nrfutil
COPY ./files/run-arancino-rp2040load.sh /usr/bin/run-arancino-rp2040load
COPY ./files/run-arancino-uf2conv.sh /usr/bin/run-arancino-uf2conv
RUN chmod +x /usr/bin/run-arancino-*

# Arancino home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $ARANCINO_HOME

EXPOSE 1475
EXPOSE 6379
EXPOSE 6380
