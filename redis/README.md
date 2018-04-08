# redis 文档
 

## redis 密码    `Sunyard88`
## redis日志路径

`/sunyard/middleware/redis/6379/data   /sunyard/middleware/redis/6379/redis.log`

`/sunyard/middleware/redis/6380/data   /sunyard/middleware/redis/6380/redis.log`

### redis集群模式
```
useradd -s /sbin/nologin redis -u 1020 &&\
 chown -R redis:redis /sunyard/middleware/redis
```
``` 
docker run -d  --restart=always \
--name redis_master \
--sysctl net.core.somaxconn=10240 \
--log-driver=json-file --log-opt max-size=100k --log-opt max-file=5 \
-e REDIS_PASSWORD=Sunyard88 \
-e REDIS_PORT=6379 \
-e REDIS_CLUSTER=yes \
--network=host  \
-v /sunyard/middleware/redis/6379:/data/redis \
docker.sunyard.com:5000/redis:3.2.11
```
```
docker run -d  --restart=always \
--name redis_slave \
--sysctl net.core.somaxconn=10240 \
--log-driver=json-file --log-opt max-size=100k --log-opt max-file=5 \
-e REDIS_PASSWORD=Sunyard88 \
-e REDIS_PORT=6380 \
-e REDIS_CLUSTER=yes \
--network=host  \
-v /sunyard/middleware/redis/6380:/data/redis \
docker.sunyard.com:5000/redis:3.2.11
```

#### 全部启动后，middleware1 手动执行
`docker exec -it redis_master bash `   进入容器
`redis-trib create --replicas 1 10.0.1.131:6379 10.0.1.132:6379 10.0.1.133:6379  10.0.1.131:6380 10.0.1.132:6380 10.0.1.133:6380`  必须以ip形式创建，如填写域名报错！
`redis-trib check 10.0.1.131:6379`    \\检查集群
`redis-cli -h 10.0.1.131 -p 6379 -c -a Sunyard88` \\进入集群
`CLUSTER NODES`    \\查看集群
`CLUSTER info`        \\查看集群


### redis单机模式：
```
useradd -s /sbin/nologin redis -u 1020 &&\
 mkdir -p /sunyard/middleware/redis/6379 && \
 chown -R redis:redis /sunyard/middleware/redis
```
```
docker run -d  --restart=always \
--name redis \
--sysctl net.core.somaxconn=10240 \
--log-driver=json-file --log-opt max-size=100k --log-opt max-file=5 \
-e REDIS_PASSWORD=Sunyard88 \
-e REDIS_PORT=6379 \
-e REDIS_CLUSTER=no \
-p 6379:6379 \
-v /sunyard/middleware/redis/6379:/data/redis \
docker.sunyard.com:5000/redis:3.2.11
```