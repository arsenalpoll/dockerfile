FROM bitnami/minideb-extras:jessie-r23

COPY sources.list /etc/apt/sources.list
#time
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone
RUN groupadd -r tomcat -g 1005 && useradd -r -g tomcat tomcat -u 1005
# Install required system packages and dependencies
RUN bitnami-pkg install java-1.8.161-0 --checksum eb289afc43eda33d5920294460dc256f6543318506ca5a540bba9073412cfd06
RUN bitnami-pkg unpack tomcat-8.5.27-0 --checksum e716675e5349b337dbe80944cbdb3dbb6af09af78cca90bd63c546a0b1cd390b
RUN ln -sf /opt/bitnami/tomcat/data /app

COPY app-entrypoint.sh  /app-entrypoint.sh
COPY tomcat-inputs.json /tomcat-inputs.json
RUN chmod +x /app-entrypoint.sh
ENV BITNAMI_APP_NAME="tomcat" \
    BITNAMI_IMAGE_VERSION="8.5.27-r0" \
    JAVA_OPTS="-Djava.awt.headless=true -XX:+UseG1GC -Dfile.encoding=UTF-8" \
    PATH="/opt/bitnami/java/bin:/opt/bitnami/tomcat/bin:$PATH" \
    TOMCAT_AJP_PORT_NUMBER="8009" \
    TOMCAT_ALLOW_REMOTE_MANAGEMENT="0" \
    TOMCAT_HTTP_PORT_NUMBER="8080" \
    TOMCAT_PASSWORD="" \
    TOMCAT_SHUTDOWN_PORT_NUMBER="8005" \
    TOMCAT_USERNAME="user"

EXPOSE 8080
VOLUME ["/opt/bitnami/tomcat/logs"]

ENTRYPOINT ["/app-entrypoint.sh"]
CMD ["nami","start","--foreground","tomcat"]
