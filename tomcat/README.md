```
docker run -d --restart=always \
--name tomcat \
--log-driver=json-file --log-opt max-size=100k --log-opt max-file=5 \
-e TOMCAT_HTTP_PORT_NUMBER=8090 \
-e NAMI_LOG_LEVEL=trace \
-e JAVA_OPTS="-Dfile.encoding=UTF-8 -server -Xms2048m -Xmx2048m  \
-XX:NewSize=512m  -XX:MaxNewSize=512m -XX:MetaspaceSize=512m  -XX:MaxMetaspaceSize=512m  \
-XX:MaxTenuringThreshold=10 -XX:NewRatio=2 -XX:+DisableExplicitGC"  \
-p 8090:8090  \
-v /sunyard/tomcat/log:/opt/bitnami/tomcat/logs \
-v /sunyard/tomcat/data:/bitnami \
docker.sunyard.com:5000/tomcat:8.5.35 
```
