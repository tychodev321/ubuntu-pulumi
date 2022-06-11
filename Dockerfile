FROM registry.access.redhat.com/ubi9/ubi-minimal:9.0.0
# FROM redhat/ubi9/ubi-minimal:9.0.0

LABEL maintainer=""

ENV PULUMI_VERSION=v3.33.2
ENV PULUMI_URL=https://get.pulumi.com/releases/sdk/pulumi-${PULUMI_VERSION}-linux-x64.tar.gz
ENV PYTHON_VERSION=3 \
    PATH=$HOME/.local/bin/:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    PIP_NO_CACHE_DIR=off

# MicroDNF is recommended over YUM for Building Container Images
# https://www.redhat.com/en/blog/introducing-red-hat-enterprise-linux-atomic-base-image

RUN microdnf update -y \
    && microdnf install -y python${PYTHON_VERSION} \
    && microdnf install -y python${PYTHON_VERSION}-pip \
    && microdnf install -y tar \
    && microdnf install -y gzip \
    && microdnf install -y wget \
    && microdnf clean all \
    && rm -rf /var/cache/* /var/log/dnf* /var/log/yum.*

# Download and install Pulumi
RUN wget ${PULUMI_URL} \
	&& tar -xzvf pulumi-${PULUMI_VERSION}-linux-x64.tar.gz \
    && rm pulumi-${PULUMI_VERSION}-linux-x64.tar.gz \
	&& cp pulumi/* /usr/bin \
	&& rm -rf pulumi

RUN pulumi version && python3 --version && pip3 --version

# USER 1001

CMD ["echo", "This is a 'Purpose Built Image', It is not meant to be ran directly"]
