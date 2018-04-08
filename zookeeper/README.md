# zookeeper文档

## 变量：

```
ENV tickTime=2000
ENV dataDir=/var/lib/zookeeper/data
ENV dataLogDir=/var/lib/zookeeper/logs
ENV clientPort=2181
ENV initLimit=20
ENV syncLimit=10
ENV maxClientCnxns=60
```

## 单机：

```
useradd -s /sbin/nologin zookeeper -u 1015 && \
chown -R  zookeeper:zookeeper /sunyard/middleware/zookeeper
```
```
docker run -d --restart=always \
--name zookeeper \
--log-driver=json-file --log-opt max-size=100k --log-opt max-file=5 \
-e ZOO_CLUSTER=no \
-p 2181:2181 -p 2888:2888 -p 3888:3888 \
-v /sunyard/middleware/zookeeper:/var/lib/zookeeper  \
docker.sunyard.com:5000/zookeeper:3.4.11
```


## 集群：
```
useradd  -s /sbin/nologin  zookeeper -u 1015 && \
chown -R  zookeeper:zookeeper /sunyard/middleware/zookeeper
```

### middleware1：
```
docker run -d --restart=always \
--name zookeeper \
--log-driver=json-file --log-opt max-size=100k --log-opt max-file=5 \
-e ZOO_CLUSTER=yes \
-p 2181:2181 -p 2888:2888 -p 3888:3888 \
-v /sunyard/middleware/zookeeper:/var/lib/zookeeper  \
docker.sunyard.com:5000/zookeeper:3.4.11  \
zoo3.sunyard.com,zoo2.sunyard.com,zoo1.sunyard.com  3
```

### middleware2：
```
docker run -d --restart=always \
--name zookeeper \
-p 2181:2181 -p 2888:2888 -p 3888:3888 \
-e ZOO_CLUSTER=yes \
--log-driver=json-file --log-opt max-size=100k --log-opt max-file=5 \
-v /sunyard/middleware/zookeeper:/var/lib/zookeeper  \
docker.sunyard.com:5000/zookeeper:3.4.11  \
zoo3.sunyard.com,zoo2.sunyard.com,zoo1.sunyard.com  2
```

### middleware3：
```
docker run -d --restart=always \
--name zookeeper \
-e ZOO_CLUSTER=yes \
--log-driver=json-file --log-opt max-size=100k --log-opt max-file=5 \
-p 2181:2181 -p 2888:2888 -p 3888:3888 \
-v /sunyard/middleware/zookeeper:/var/lib/zookeeper  \
docker.sunyard.com:5000/zookeeper:3.4.11  \
zoo3.sunyard.com,zoo2.sunyard.com,zoo1.sunyard.com  1
```
