FROM python:3.7-buster

ARG user=me
ARG group=me
ARG uid=1000
ARG gid=1000
ARG ARANCINO_HOME=/home/me

ENV TZ 'Europe/Rome'

RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        software-properties-common vim wget nano curl python3-dev python3-distutils \
        python3-distro python3-distro-info python3-psutil build-essential \
        certbot python3-certbot-nginx sudo net-tools telnet procps coreutils \
        systemd systemd-sysv bash-completion apt-utils nodejs npm tzdata \
        dsniff git ntpdate lsof gdb screen libffi-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && :

RUN echo $TZ > /etc/timezone \
    && rm -f /etc/localtime \
    && ln -nfs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

RUN npm install -g --unsafe @mdslab/wstun@1.0.11 && npm cache --force clean

RUN : \
    && sed -i 's/# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 64;/g' /etc/nginx/nginx.conf \
    && sed -i "s|listen 80 default_server;|listen 50000 default_server;|g" /etc/nginx/sites-available/default \
    && sed -i "s|80 default_server;|50000 default_server;|g" /etc/nginx/sites-available/default \
    && :

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $ARANCINO_HOME \
  && chown ${uid}:${gid} $ARANCINO_HOME \
  && groupadd -g ${gid} ${group} \
  && useradd -d "$ARANCINO_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user} \
  && echo me:arancino | chpasswd \
  && echo root:arancino | chpasswd

# getting artik sudoer permissions
RUN echo "me ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $ARANCINO_HOME

RUN wget -qO- https://bootstrap.pypa.io/pip/get-pip.py | python3

COPY ./files/pip.conf /etc/pip.conf

RUN pip3 install -v --no-cache-dir iotronic-lightningrod==0.4.17

COPY ./files/lr_install.py /usr/local/bin/lr_install

RUN chmod +x /usr/local/bin/lr_install && lr_install

# USER ${user}

# WORKDIR $ARANCINO_HOME

EXPOSE 1474