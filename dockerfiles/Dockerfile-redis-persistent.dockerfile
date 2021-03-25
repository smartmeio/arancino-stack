FROM redis:6.0.10-buster

COPY ./files/redis-persistent.conf /etc/redis

EXPOSE 6380