FROM openjdk:8u111-jdk

MAINTAINER USU Software AG

RUN \
  curl -s https://raw.githubusercontent.com/paulp/sbt-extras/master/sbt > /usr/local/bin/sbt && chmod 0755 /usr/local/bin/sbt && \
  sbt about -sbt-create

WORKDIR /root
