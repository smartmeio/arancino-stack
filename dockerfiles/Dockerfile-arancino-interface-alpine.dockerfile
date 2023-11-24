FROM alpine:3.14.2

RUN : \
    && apk update \
    && apk add vim wget nano curl python3 python3-dev linux-pam \
       gcc musl-dev linux-headers procps coreutils bash shadow \
       sudo net-tools libffi libffi-dev openssl openssl-dev sed \
       libusb libusb-dev libftdi1 libftdi1-dev avrdude openocd \
       g++ make libressl-dev libc-dev musl-dev build-base \
       bsd-compat-headers bash-completion cmake py3-gunicorn git\
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

RUN wget -qO- https://bootstrap.pypa.io/pip/get-pip.py | python3

COPY ./files/pip.conf /etc/pip.conf

WORKDIR $ARANCINO_HOME

RUN git clone --branch all_in_one https://dev:dgmbTsmZxoohWzc7dnAq@git.smartme.io/smartme.io/arancino/arancino-services/arancino-interface.git 

#COPY arancino-interface $ARANCINO_HOME
WORKDIR $ARANCINO_HOME/arancino-interface

RUN mkdir -p log

#PATCH 
#RUN sed -i 's/localhost/redis-persistent-arancino/g' arancino_panel/modules/system/submodules/workprogram/config/config.py
RUN sed -i "s/arancino_rest_host = '127.0.0.1'/arancino_rest_host = 'arancino'/g" arancino_panel/modules/system/submodules/ports/config/config.py
RUN sed -i "s/bcrypt==4.0.1/bcrypt<4.0.0/g" requirements.txt

#RUN pip install --upgrade pip
RUN pip3 install -r requirements.txt \
  && python3 setup.py install

COPY ./files/interface.cfg.yml /etc/arancino/config/arancino.cfg.yml

