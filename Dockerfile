FROM openjdk:8-jdk-slim

MAINTAINER USU Software AG

RUN \
  apt-get update && \
  apt-get install -y -qq --no-install-recommends wget unzip python openssh-client python-openssl git-core jq curl vim gnupg2 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* 

RUN \
  curl -s https://raw.githubusercontent.com/paulp/sbt-extras/master/sbt > /usr/local/bin/sbt && chmod 0755 /usr/local/bin/sbt && \
  sbt about -sbt-create

# Prepare the image.
ENV DEBIAN_FRONTEND noninteractive

# Install the Google Cloud SDK.
ENV HOME /
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip && unzip google-cloud-sdk.zip && rm google-cloud-sdk.zip
RUN google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --additional-components kubectl alpha beta

RUN mkdir /.ssh
ENV PATH /google-cloud-sdk/bin:$PATH

# Install the docker client.
ENV DOCKERVERSION=18.09.0
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz \
  && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 -C /usr/local/bin docker/docker \
  && rm docker-${DOCKERVERSION}.tgz

# Install node & npm
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt install -y nodejs && npm install -g npm@6.1.0

RUN echo "Europe/Berlin" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

CMD ["/bin/bash"]

ENV HOME /root
WORKDIR /root
