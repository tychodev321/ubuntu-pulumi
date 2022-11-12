FROM registry.access.redhat.com/ubi9/ubi-minimal:9.0.0
# FROM redhat/ubi9/ubi-minimal:9.0.0

LABEL maintainer=""

ENV PULUMI_VERSION=v3.34.1
ENV PULUMI_URL=https://get.pulumi.com/releases/sdk/pulumi-${PULUMI_VERSION}-linux-x64.tar.gz

ENV AWSCLI_VERSION=2.7.7
ENV AWSCLI_URL=https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip

ENV KUBECTL_VERSION=v1.24.1
ENV KUBECTL_URL=https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ENV KUBECTL_CHECKSUM_URL=https://dl.k8s.io/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256

ENV PYTHON_VERSION=3 \
    PATH=$HOME/.local/bin/:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    PIP_NO_CACHE_DIR=off

ENV NODEJS_VERSION=16.14.0 \
    NPM_VERSION=8.3.1 \
    YARN_VERSION=1.22.19 \
    PATH=$HOME/.local/bin/:$PATH \
    npm_config_loglevel=warn \
    npm_config_unsafe_perm=true

# MicroDNF is recommended over YUM for Building Container Images
# https://www.redhat.com/en/blog/introducing-red-hat-enterprise-linux-atomic-base-image

# Install Generics Tools
RUN microdnf update -y \
    && microdnf install -y tar \
    && microdnf install -y gzip \
    && microdnf install -y wget \
    && microdnf install -y unzip \
    && microdnf clean all \
    && rm -rf /var/cache/* /var/log/dnf* /var/log/yum.*

# Install Python 3
# microdnf install -y python${PYTHON_VERSION}-devel
RUN microdnf update -y \
    && microdnf install -y python${PYTHON_VERSION} \
    && microdnf install -y python${PYTHON_VERSION}-pip \
    && microdnf clean all \
    && rm -rf /var/cache/* /var/log/dnf* /var/log/yum.*

# Make sure to upgrade pip3
RUN pip3 install --upgrade pip && pip3 install poetry

# Install Node and NPM
RUN microdnf update -y \
    && microdnf install -y nodejs \
    && microdnf install -y npm \
    && microdnf clean all \
    && rm -rf /var/cache/* /var/log/dnf* /var/log/yum.*

RUN npm install --global yarn@${YARN_VERSION} \
    && npm config set prefix /usr/local

# Download and install Pulumi
RUN wget ${PULUMI_URL} \
	&& tar -xzvf pulumi-${PULUMI_VERSION}-linux-x64.tar.gz \
    && rm pulumi-${PULUMI_VERSION}-linux-x64.tar.gz \
	&& cp pulumi/* /usr/bin \
	&& rm -rf pulumi

# Download and install AWS CLI
RUN curl ${AWSCLI_URL} -o "awscliv2.zip" \ 
    && unzip awscliv2.zip \
    && ./aws/install -i /usr/local -b /usr/local/bin -u \
    && rm  -rf awscliv2.zip awscliv2

# Download and install Kubectl
RUN curl -LO "${KUBECTL_URL}" \
    && curl -LO "${KUBECTL_CHECKSUM_URL}" \
    && echo "$(<kubectl.sha256) kubectl" | sha256sum --check \
    && chmod +x kubectl \
    && mv ./kubectl /usr/bin/kubectl

RUN echo "Pulumi Version - $(pulumi version)" \
    && echo "AWS CLI Version - $(aws --version)" \
    && echo "Kubectl Version - $(kubectl version --client)" \
    && echo "NodeJS Version - $(node --version)" \ 
    && echo "NPM Version - $(npm --version)" \ 
    && echo "YARN Version - $(yarn --version)" \ 
    && echo "Python Version - $(python3 --version)" \
    && echo "PIP Version - $(pip3 --version)"

# USER 1001

CMD ["echo", "This is a 'Purpose Built Image', It is not meant to be ran directly"]
