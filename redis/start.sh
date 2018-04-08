#!/bin/bash
/redis/src/redis-server /redis.conf
tail -f /opt/redis/logs/redis.log
