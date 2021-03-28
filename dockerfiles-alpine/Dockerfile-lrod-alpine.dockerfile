FROM alpine:3.13.3

ARG user=me
ARG group=me
ARG uid=1000
ARG gid=1000
ARG ARANCINO_HOME=/home/me

RUN : \
    && apk update \
    && apk add vim wget nano curl python3 python3-dev rust linux-pam \
        gcc musl-dev linux-headers procps coreutils cargo bash nginx \
        sudo net-tools libffi libffi-dev openssl openssl-dev sed \
    && :

RUN : \
    && sed -i 's/# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 64;/g' /etc/nginx/nginx.conf \
    && sed -i "s|listen 80 default_server;|listen 50000 default_server;|g" /usr/share/nginx/http-default_server.conf \
    && sed -i "s|80 default_server;|50000 default_server;|g" /usr/share/nginx/http-default_server.conf \
    && :

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $ARANCINO_HOME \
  && addgroup -g ${gid} -S ${group} \
  && adduser -h "$ARANCINO_HOME" -S -u ${uid} -G ${group} -s /bin/ash ${user} \
  && passwd me -d arancino \
  && passwd root -d arancino

# getting artik sudoer permissions
RUN echo "me ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $ARANCINO_HOME

RUN wget -qO- https://bootstrap.pypa.io/pip/get-pip.py | python3

COPY ./files/pip.conf /etc/pip.conf

RUN pip3 install -v --no-cache-dir certbot==0.31 certbot-nginx==0.31 \
  cryptography==2.6.1 iotronic-lightningrod==0.4.17

COPY ./files/lr_install.py /usr/local/bin/lr_install

RUN chmod +x /usr/local/bin/lr_install && lr_install

# USER ${user}

# WORKDIR $ARANCINO_HOME

EXPOSE 1474