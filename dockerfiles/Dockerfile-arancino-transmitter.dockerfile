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
        vim wget nano curl build-essential nano telnet net-tools  \
        systemd systemd-sysv bash-completion apt-utils \
        ca-certificates ca-cacert libssl-dev libyaml-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && :

RUN wget -qO- https://bootstrap.pypa.io/pip/get-pip.py | python3

COPY ./files/pip.conf /etc/pip.conf

RUN pip3 install -v --no-cache-dir redistimeseries==1.4.5 \
    arancino-transmitter==1.0.0-test.3

COPY ./files/transmitter.cfg.yml /etc/arancino/config/transmitter.cfg.yml
COPY ./files/transmitter.cfg.dev.yml /etc/arancino/config/transmitter.cfg.dev.yml

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $ARANCINO_HOME

# USER ${user}

WORKDIR $ARANCINO_HOME

# EXPOSE 1475
EXPOSE 6379
EXPOSE 6380