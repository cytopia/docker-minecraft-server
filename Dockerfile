ARG JAVA_VERSION=14
# -------------------------------------------------------------------------------------------------
# Builder Docker image
# -------------------------------------------------------------------------------------------------
FROM openjdk:${JAVA_VERSION}-alpine as builder
ARG SERVER_VERSION=1.14

###
### Install Server
###
RUN set -eux \
	&& apk add --no-cache curl \
	&& curl -L -o /usr/local/bin/server-${SERVER_VERSION}.jar \
		'https://launcher.mojang.com/v1/objects/f1a0073671057f01aa843443fef34330281333ce/server.jar'

###
### Create startup script
###
RUN set -eux \
	&& ( \
		echo '#!/bin/sh'; \
		echo; \
		echo 'echo "eula=${ACCEPT_EULA}" > "/data/eula.txt"'; \
		echo; \
		echo 'if [ ! -f "/data/server.properties" ]; then '; \
		echo '    echo "online-mode=false" > "/data/server.properties"'; \
		echo 'fi'; \
		echo; \
		echo 'exec java -Xmx${JAVA_XMX} -jar /usr/local/bin/server-${SERVER_VERSION}.jar --port ${PORT} nogui'; \
	) > /docker-start.sh \
	&& chmod +x /docker-start.sh


# -------------------------------------------------------------------------------------------------
# Final Docker image
# -------------------------------------------------------------------------------------------------
FROM openjdk:${JAVA_VERSION}-alpine as production
ARG SERVER_VERSION=1.14

###
### Copy from builder
###
COPY --from=builder /usr/local/bin/server-${SERVER_VERSION}.jar /usr/local/bin/server-${SERVER_VERSION}.jar
COPY --from=builder /docker-start.sh /docker-start.sh

###
### Server default settings
###
ENV SERVER_VERSION=${SERVER_VERSION}
ENV PORT=25565
ENV JAVA_XMX=4096M

###
### Persistant data
###
VOLUME ["/data"]

###
### Startup
###
WORKDIR /data
CMD ["/docker-start.sh"]
