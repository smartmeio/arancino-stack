FROM smartmeio/alpine:3.14.2-openrc

ARG user=me
ARG group=me
ARG uid=1000
ARG gid=1000
ARG ARANCINO_HOME=/home/me
ENV CRYPTOGRAPHY_DONT_BUILD_RUST 1

RUN : \
    && apk update \
    && apk add vim wget nano curl python3 python3-dev linux-pam \
        gcc musl-dev linux-headers procps coreutils bash nginx \
        sudo net-tools libffi libffi-dev openssl openssl-dev sed \
        nodejs nodejs-dev nodejs-doc npm openrc nginx-mod-http-geoip2 \
		nginx-mod-http-dav-ext nginx-mod-mail nginx-openrc screen \
		nginx-mod-http-echo nginx-mod-http-image-filter nginx-mod-http-geoip \
		nginx-mod-stream nginx-mod-http-xslt-filter nginx-vim \
		nginx-mod-http-upstream-fair nginx-mod-stream-geoip git \
    && :

# wstun setup
RUN : \
    && npm config set loglevel http \
    && npm config set unsafe-perm true \
    && npm install -g --unsafe @mdslab/wstun@1.1.0 \
    && npm cache --force clean \
	&& ln -s /usr/local/bin/wstun /usr/bin/wstun \
    && :

# nginx setup
RUN : \
    && sed -i 's/# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 64;/g' /etc/nginx/nginx.conf \
    && sed -i "s|listen 80 default_server;|listen 50000 default_server;|g" /usr/share/nginx/http-default_server.conf \
    && sed -i "s|80 default_server;|50000 default_server;|g" /usr/share/nginx/http-default_server.conf \
	&& mkdir -p /etc/nginx/conf.d/ \
	&& mkdir -p /etc/nginx/sites-available/ \
	&& mkdir -p /etc/nginx/sites-enabled/ \
    && :

COPY ./files/nginx-alpine-default.conf /etc/nginx/nginx.conf
COPY ./files/nginx-sites-default.conf /etc/nginx/sites-available/default

RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

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
  acme==0.31 cryptography==3.4.8 pyOpenSSL==21.0.0 iotronic-lightningrod==0.5.0

COPY ./files/lr_install.py /usr/local/bin/lr_install

RUN chmod +x /usr/local/bin/lr_install && lr_install

COPY ./files/startLR-alpine.sh /usr/local/bin/startLR
RUN chmod +x /usr/local/bin/startLR

COPY files/lrod-alpine.service /etc/init.d/lrod
RUN chmod +x /etc/init.d/lrod \
  && rc-update add lrod

# USER ${user}

# WORKDIR $ARANCINO_HOME

EXPOSE 1474
