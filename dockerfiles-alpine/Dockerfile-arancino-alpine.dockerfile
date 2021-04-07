FROM alpine:3.10.8

RUN : \
    && apk update \
    && apk add vim wget nano curl python3 python3-dev rust linux-pam \
        gcc musl-dev linux-headers procps coreutils cargo bash \
        sudo net-tools libffi libffi-dev openssl openssl-dev sed \
    && :

RUN wget -qO- https://bootstrap.pypa.io/pip/get-pip.py | python3

COPY ./files/pip.conf /etc/pip.conf

RUN pip3 install -v arancino==2.3.0

COPY ./files/arancino.prod.cfg /etc/arancino/config/arancino.prod.cfg
COPY ./files/arancino.dev.cfg /etc/arancino/config/arancino.dev.cfg

EXPOSE 1475
EXPOSE 6379
EXPOSE 6380
