#!/bin/bash

wait_for_redis() {
  timeout=$1

  start_time=$(date +%s)
  elapsed_time=0
  while true; do
    loading=$(docker exec redis-aof-startup-time-test-redis-1 redis-cli INFO | grep "^loading" | awk -F: '{print $2}' | tr -d '\r')
    if [ "$loading" == "0" ]; then
      break
    fi

    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))

    if [ $elapsed_time -ge $timeout ]; then
      echo "Timed out waiting for redis"
      exit 1
    fi

    sleep 1
  done
  echo "Redis started in $elapsed_time seconds"
}

# Default values arguments
KEYS=2000000

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -k|--keys)
      KEYS="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown option: $key"
      exit 1
      ;;
  esac
done

echo "Starting redis containers..."
docker-compose up -d --build

echo "Waiting for redis instances to be ready..."
wait_for_redis 180

mkdir -p logs

echo "Generating AOF"
docker exec redis-aof-startup-time-test-redis-1 redis-cli EVAL "$(cat populate-redis.lua)" 0 $KEYS 1024
docker exec redis-aof-startup-time-test-redis-1 redis-cli INFO memory | grep used_memory_human

echo "Flushing AOF before restarting Redis"
docker exec redis-aof-startup-time-test-redis-1 redis-cli BGREWRITEAOF

while true; do
  aof_rewrite_in_progress=$(docker exec redis-aof-startup-time-test-redis-1 redis-cli INFO | grep aof_rewrite_in_progress | awk -F: '{print $2}' | tr -d '\r')
  if [ "$aof_rewrite_in_progress" == "0" ]; then
    break
  fi
  sleep 1
done

echo "Restarting redis"
docker-compose restart redis

echo "Measuring startup time..."
wait_for_redis 180
docker exec redis-aof-startup-time-test-redis-1 redis-cli INFO memory | grep used_memory_human

echo "Stopping Redis containers..."
docker-compose down

echo "Cleaning up files..."
rm -rf /mnt/f/redis-load-testing/data/large/
