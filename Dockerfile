FROM redis

ARG CONFIG_FILE
COPY ${CONFIG_FILE} /usr/local/etc/redis/redis.conf
CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
