FROM python:3.7.12-slim-buster

ARG user=me
ARG group=me
ARG uid=1000
ARG gid=1000
ARG ARANCINO_HOME=/home/me

ENV NODE_VERSION 10.24.1

ENV TZ 'Europe/Rome'
ENV CRYPTOGRAPHY_DONT_BUILD_RUST 1

# installing base packages
RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        vim wget nano curl build-essential curl tzdata \
        sudo net-tools telnet procps coreutils psmisc \
        systemd systemd-sysv bash-completion apt-utils \
        dsniff git ntpdate lsof screen libffi-dev libyaml-dev \
        git subversion psutils nginx dialog libssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && :

RUN echo $TZ > /etc/timezone \
    && rm -f /etc/localtime \
    && ln -nfs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

# installing node.js according to container arch
RUN if [ $(dpkg --print-architecture) = "amd64" ]; then \
			export nodearch=x64; \
		elif [ $(dpkg --print-architecture) = "armhf" ]; then \
			export nodearch=armv7l; \
		elif [ $(dpkg --print-architecture) = "arm64" ]; then \
			export nodearch=arm64; \
		fi \
	&& wget https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${nodearch}.tar.gz -P /tmp \
	&& tar xvf /tmp/node-v${NODE_VERSION}-linux-${nodearch}.tar.gz --strip-components=1 -C /usr \
	&& npm install -g npm@7 \
	&& npm config set loglevel http \
	&& npm config set unsafe-perm true \
	&& npm install -g --unsafe @mdslab/wstun@1.1.0 && npm cache --force clean \
	&& rm -rf /tmp/node-v${NODE_VERSION}-linux-${nodearch}.tar.gz

# setting up nginx
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

# getting me sudoer permissions
RUN echo "me ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# installing pip3
RUN wget -qO- https://bootstrap.pypa.io/pip/get-pip.py | python3
COPY ./files/pip.conf /etc/pip.conf

# adding piwheels to /etc/pip.conf if architecture is armhf
# RUN if [ $(dpkg --print-architecture) = "armhf" ]; then \
# 		echo -e "\n                 https://www.piwheels.org/simple" >> /etc/pip.conf;fi \
# 	&& sed -i '/^$/d' /etc/pip.conf \
# 	&& sed -i 's/-e//g' /etc/pip.conf \
# 	&& cat /etc/pip.conf

# installing lightning-rod
RUN pip3 install -v --no-cache-dir acme==0.31 certbot==0.31 \
		certbot-nginx==0.31 pyOpenSSL==21.0.0 cryptography==3.4.8 \
		iotronic-lightningrod==0.5.0 \
	&& ln -sf /usr/local/bin/certbot /usr/bin/certbot \
	&& ln -sf /usr/local/bin/python3 /usr/bin/python3
COPY ./files/lr_install.py /usr/local/bin/lr_install
RUN chmod +x /usr/local/bin/lr_install && lr_install

# installing lightning-rod executable
COPY ./files/lightning-rod.py /usr/local/bin/lightning-rod
RUN chmod +x /usr/local/bin/lightning-rod

COPY ./files/startLR.sh /usr/local/bin/startLR
RUN chmod +x /usr/local/bin/startLR

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $ARANCINO_HOME

# USER ${user}

# WORKDIR $ARANCINO_HOME

EXPOSE 1474