FROM maven:3.6.0-jdk-8-slim AS build-stage
COPY . /project
WORKDIR /project/
#ENV http_proxy http://10.193.85.155:3129
#ENV https_proxy http://10.193.85.155:3129
###以下追加
###COPY settings.xml /usr/share/maven/conf/settings.xml
###ここまで
RUN mvn clean install 

FROM open-liberty:full

# Config
COPY --chown=1001:0 --from=build-stage src/main/liberty/config/server.xml /config/server.xml
COPY --chown=1001:0 --from=build-stage src/main/liberty/config/server.env /config/server.env
COPY --chown=1001:0 --from=build-stage src/main/liberty/config/jvm.options /config/jvm.options

# App
COPY --chown=1001:0 --from=build-stage target/acmeair-mainservice-java-5.0.war /config/apps/

# Logging vars
ENV LOGGING_FORMAT=simple
ENV ACCESS_LOGGING_ENABLED=false
ENV TRACE_SPEC=*=info

# Build SCC?
ARG CREATE_OPENJ9_SCC=true
ENV OPENJ9_SCC=${CREATE_OPENJ9_SCC}

RUN configure.sh
