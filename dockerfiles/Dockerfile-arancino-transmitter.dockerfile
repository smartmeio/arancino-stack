FROM python:3.11-slim-bookworm

# defining user 'me'
ARG user=me
ARG group=me
ARG uid=1000
ARG gid=1000
ARG ARANCINO_HOME=/home/me

ENV TZ 'Europe/Rome'

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

RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git \
    nano   \
     #    vim wget nano curl arduinostm32load \
     #    build-essential nano telnet net-tools  \
     #    systemd systemd-sysv bash-completion apt-utils \
     #    openocd avrdude dfu-util-stm32 bossa-cli \
     #    ca-certificates ca-cacert libssl-dev libyaml-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && :

COPY ./files/pip.conf /etc/pip.conf

RUN pip3 install -v -U pip \
	&& pip3 install -v --no-cache-dir arancino-transmitter==1.0.1

COPY ./files/transmitter.cfg.yml /etc/arancino/config/transmitter.cfg.yml

#CMD [ "arancino-transmitter" ]