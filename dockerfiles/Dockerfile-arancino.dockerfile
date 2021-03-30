FROM python:3.7-buster

RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        software-properties-common vim wget nano curl python3-dev python3-distutils \
        python3-distro python3-distro-info build-essential vim nano telnet net-tools \
        systemd systemd-sysv bash-completion apt-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && :

RUN wget -qO- https://bootstrap.pypa.io/pip/get-pip.py | python3

COPY ./files/pip.conf /etc/pip.conf

RUN pip3 install -v arancino==2.3.0-test.2

COPY ./files/arancino.prod.cfg /etc/arancino/config/arancino.prod.cfg
COPY ./files/arancino.dev.cfg /etc/arancino/config/arancino.dev.cfg

EXPOSE 1475
EXPOSE 6379
EXPOSE 6380