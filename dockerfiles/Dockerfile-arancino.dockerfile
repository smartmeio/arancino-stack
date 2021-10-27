FROM python:3.7-buster

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

# adding arancino repository
COPY files/arancino-os-public.key /tmp

RUN : \
    && echo "deb https://packages.smartme.io/repository/arancino-os-buster/ buster main" >> /etc/apt/sources.list.d/arancino.list \
    && apt-key add /tmp/arancino-os-public.key

RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        software-properties-common vim wget nano curl python3-dev python3-distutils \
        python3-distro python3-distro-info build-essential vim nano telnet net-tools \
        systemd systemd-sysv bash-completion apt-utils bossa-cli python3-pkg-resources \
        python3-adafruit-nrfutil openocd avrdude dfu-util-stm32 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && :

RUN wget -qO- https://bootstrap.pypa.io/pip/get-pip.py | python3

COPY ./files/pip.conf /etc/pip.conf

RUN pip3 install -v arancino==2.3.0

COPY ./files/arancino.prod.cfg /etc/arancino/config/arancino.prod.cfg
COPY ./files/arancino.dev.cfg /etc/arancino/config/arancino.dev.cfg

COPY ./files/run-arancino-bossac.sh /usr/bin/run-arancino-bossac
RUN chmod +x /usr/bin/run-arancino-bossac

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $ARANCINO_HOME

# USER ${user}

WORKDIR $ARANCINO_HOME

EXPOSE 1475
EXPOSE 6379
EXPOSE 6380