# mysql 文档

```
useradd -s /sbin/nologin mysql -u 1010  && \
mkdir -p /sunyard/mysql/conf  /sunyard/mysql/data && \
chown -R mysql:mysql  /sunyard/mysql    
```
将`my.cnf`  复制到`/sunyard/mysql/conf`文件下

```
docker run -d --restart=always  \
--name mysql \
--log-driver=json-file --log-opt max-size=100k --log-opt max-file=5 \
-v /sunyard/mysql/conf:/etc/mysql  \
-v /sunyard/mysql/data:/var/lib/mysql \
-v /etc/localtime:/etc/localtime \
-e MYSQL_ROOT_PASSWORD=Sunyard88 \
-p 3306:3306 \
docker.sunyard.com:5000/mysql:5.6
```
