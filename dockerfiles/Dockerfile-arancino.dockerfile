FROM python:3.7-buster

RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        software-properties-common vim wget nano curl python3-dev python3-distutils \
        python3-distro python3-distro-info build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && :

RUN wget -qO- https://bootstrap.pypa.io/pip/get-pip.py | python3

COPY ./files/pip.conf /etc/pip.conf

RUN pip3 install -v arancino==2.2.0

COPY ./files/arancino.cfg /etc/arancino/config/arancino.cfg

EXPOSE 1475
EXPOSE 6379
EXPOSE 6380