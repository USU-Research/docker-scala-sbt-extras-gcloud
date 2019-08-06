FROM openjdk:8-jdk-slim

MAINTAINER USU Software AG

RUN echo "deb http://deb.debian.org/debian stretch-backports main" >> /etc/apt/sources.list

RUN \
  apt-get update && \
  apt-get install -y -qq --no-install-recommends wget unzip python openssh-client python-openssl git-core jq curl vim gnupg2 procps zip && \
  apt-get install -y -t stretch-backports golang-go && \
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

ENV HELM_ARCHIVE=helm-v2.14.3-linux-amd64.tar.gz \
    HELM_DIR=linux-amd64 \
    FAAS_CLI_VERSION=0.8.5

RUN curl -LsO https://storage.googleapis.com/kubernetes-helm/$HELM_ARCHIVE && tar -zxvf $HELM_ARCHIVE && cp $HELM_DIR/* /usr/local/bin

RUN curl -LsO https://github.com/openfaas/faas-cli/releases/download/${FAAS_CLI_VERSION}/faas-cli && chmod +x faas-cli && cp faas-cli /usr/local/bin

RUN wget -q -O /usr/local/bin/kind https://github.com/kubernetes-sigs/kind/releases/download/0.2.1/kind-linux-amd64
RUN chmod +x /usr/local/bin/kind

# Install node & npm
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt install -y nodejs && npm install -g npm@6.1.0

RUN curl -LsO https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && chmod +x jq-linux64 && mv jq-linux64 /usr/local/bin/jq

RUN echo "Europe/Berlin" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

CMD ["/bin/bash"]

ENV HOME /root
WORKDIR /root
