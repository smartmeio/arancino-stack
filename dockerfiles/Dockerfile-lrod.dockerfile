FROM python:3.7-buster

RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        software-properties-common vim wget nano curl python3-dev python3-distutils \
        python3-distro python3-distro-info build-essential \
        certbot python3-certbot-nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && :

RUN : \
    && sed -i 's/# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 64;/g' /etc/nginx/nginx.conf \
    && sed -i "s|listen 80 default_server;|listen 50000 default_server;|g" /etc/nginx/sites-available/default \
    && sed -i "s|80 default_server;|50000 default_server;|g" /etc/nginx/sites-available/default \
    && :

RUN wget -qO- https://bootstrap.pypa.io/pip/get-pip.py | python3

COPY ./files/pip.conf /etc/pip.conf

RUN pip3 install -v --no-cache-dir iotronic-lightningrod==0.4.17

COPY ./files/lr_install.py /usr/local/bin/lr_install

RUN chmod +x /usr/local/bin/lr_install && lr_install

EXPOSE 1474