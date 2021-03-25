FROM redis:6.0.10-buster

COPY ./files/redis-volatile.conf /etc/redis