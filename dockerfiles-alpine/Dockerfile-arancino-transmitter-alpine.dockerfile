################################
# Arancino Transmitter Section #
################################
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

# Arancino is run with user `me`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $ARANCINO_HOME \
  && mkdir -p /etc/systemd/system/ \
  && chown ${uid}:${gid} $ARANCINO_HOME \
  && addgroup -g ${gid} ${group} \
  && adduser -h "$ARANCINO_HOME" -u ${uid} -G ${group} -s /bin/bash -D ${user} \
  && echo me:arancino | chpasswd \
  && echo root:arancino | chpasswd

# installing arancino
RUN wget -qO- https://bootstrap.pypa.io/pip/get-pip.py | python3

COPY ./files/pip.conf /etc/pip.conf

COPY ./files/systemctl-template.sh /usr/bin/systemctl

RUN chmod +x /usr/bin/systemctl

RUN pip3 install -v --no-cache-dir redistimeseries==1.4.5 \
    arancino-transmitter==1.0.0-test.3

COPY ./files/transmitter.cfg.yml /etc/arancino/config/transmitter.cfg.yml
COPY ./files/transmitter.cfg.dev.yml /etc/arancino/config/transmitter.cfg.dev.yml
COPY ./files/transmitter.flow.test.cfg.yml /etc/arancino/config/transmitter.flow.test.cfg.yml

# Arancino home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $ARANCINO_HOME

# EXPOSE 1475
EXPOSE 6379
EXPOSE 6380
