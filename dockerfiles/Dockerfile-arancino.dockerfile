FROM python:3.7.12-slim-buster

# defining user 'me'
ARG user=me
ARG group=me
ARG uid=1000
ARG gid=1000
ARG ARANCINO_HOME=/home/me

ENV TZ 'Europe/Rome'

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $ARANCINO_HOME \
  && chown ${uid}:${gid} $ARANCINO_HOME \
  && groupadd -g ${gid} ${group} \
  && useradd -d "$ARANCINO_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user} \
  && echo me:arancino | chpasswd \
  && echo root:arancino | chpasswd

# getting 'me' sudoer permissions
RUN echo "me ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        gnupg apt-transport-https  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && :

# adding arancino repository
COPY ./files/arancino-os-public.key /tmp

RUN : \
    && echo "deb https://packages.smartme.io/repository/arancino-os-buster/ buster main" >> /etc/apt/sources.list.d/arancino.list \
    && apt-key add /tmp/arancino-os-public.key

RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        vim wget nano curl arduinostm32load \
        build-essential nano telnet net-tools  \
        systemd systemd-sysv bash-completion apt-utils \
        openocd avrdude dfu-util-stm32 bossa-cli \
        ca-certificates ca-cacert libssl-dev libyaml-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && :

RUN wget -qO- https://bootstrap.pypa.io/pip/get-pip.py | python3

COPY ./files/pip.conf /etc/pip.conf

RUN pip3 install -v --no-cache-dir arancino==2.5.0-test.7 adafruit-nrfutil

COPY ./files/arancino.cfg.yml /etc/arancino/config/arancino.cfg.yml
COPY ./files/arancino.dev.cfg.yml /etc/arancino/config/arancino.dev.cfg.yml

# copying upload tool scripts
COPY ./files/run-arancino-bossac.sh /usr/bin/run-arancino-bossac
COPY ./files/run-arancino-arduinoSTM32load.sh /usr/bin/run-arancino-arduinoSTM32load
COPY ./files/run-arancino-adafruit-nrfutil.sh /usr/bin/run-arancino-adafruit-nrfutil
COPY ./files/run-arancino-rp2040load.sh /usr/bin/run-arancino-rp2040load
COPY ./files/run-arancino-uf2conv.sh /usr/bin/run-arancino-uf2conv
COPY ./files/uf2conv.py /usr/bin/uf2conv.py
RUN chmod +x /usr/bin/run-arancino-*
RUN chmod +x /usr/bin/uf2conv.py

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $ARANCINO_HOME

# USER ${user}

WORKDIR $ARANCINO_HOME

EXPOSE 1475
EXPOSE 6379
EXPOSE 6380