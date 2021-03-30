FROM python:3.7-buster

ARG user=me
ARG group=me
ARG uid=1000
ARG gid=1000
ARG ARANCINO_HOME=/home/me

RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        software-properties-common vim wget nano curl python3-dev python3-distutils \
        python3-distro python3-distro-info build-essential \
        certbot python3-certbot-nginx sudo net-tools telnet procps coreutils \
        systemd systemd-sysv bash-completion apt-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && :

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
    /lib/systemd/system/systemd-update-utmp*

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
# VOLUME $ARANCINO_HOME

RUN wget -qO- https://bootstrap.pypa.io/pip/get-pip.py | python3

COPY ./files/pip.conf /etc/pip.conf

RUN pip3 install -v --no-cache-dir iotronic-lightningrod==0.4.17

COPY ./files/lr_install_systemd.py /usr/local/bin/lr_install
RUN chmod +x /usr/local/bin/lr_install && lr_install 

COPY ./files/lightning-rod.py /usr/local/bin/lightning-rod
RUN chmod +x /usr/local/bin/lightning-rod

COPY ./files/lightning-rod.service /etc/systemd/system

VOLUME [ "/sys/fs/cgroup" ]

# USER ${user}

# WORKDIR $ARANCINO_HOME

EXPOSE 1474

CMD ["/lib/systemd/systemd"]