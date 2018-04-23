FROM java:openjdk-8-jre


RUN groupadd -r zookeeper -g 1015 && useradd -r -g zookeeper zookeeper -u 1015

RUN apt-get update; \
    apt-get install -y wget tar  --no-install-recommends; \
    rm -rf /var/lib/apt/lists/*

#time
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# The used ZooKeeper version can also be supplied like this with the build command like this:
# --build-arg BIN_VERSION=zookeeper-3.4.8
ARG BIN_VERSION=zookeeper-3.4.11

WORKDIR /usr/share/zookeeper


# Install and set everything up
RUN mkdir -p /var/lib/zookeeper/data  && \
	chown -R zookeeper:zookeeper  /var/lib/zookeeper  
RUN \
   wget -q -N http://mirror.bit.edu.cn/apache/zookeeper/$BIN_VERSION/$BIN_VERSION.tar.gz \
&& tar --strip-components=1 -C /usr/share/zookeeper -xvf ${BIN_VERSION}.tar.gz \
&& rm $BIN_VERSION.tar.gz \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
&& chown -R zookeeper:zookeeper /usr/share/zookeeper

# default parameters for config file:
ENV tickTime=2000
ENV dataDir=/var/lib/zookeeper/data
ENV clientPort=2181
ENV initLimit=20
ENV syncLimit=10
ENV maxClientCnxns=60
ENV ZOO_CLUSTER=no
ENV purgeInterval=24
ENV snapRetainCount=24



# add startup script
ADD entrypoint.sh entrypoint.sh

RUN chmod +x entrypoint.sh

VOLUME [ "/var/lib/zookeeper" ]

EXPOSE 2181 2888 3888

ENTRYPOINT ["/usr/share/zookeeper/entrypoint.sh"]

