FROM registry.access.redhat.com/ubi8/ubi-minimal:8.4
# FROM redhat/ubi8/ubi-minimal:8.4

LABEL maintainer="TychoDev <cloud.ops@tychodev.com>"

ENV PULUMI_VERSION=v3.13.2
ENV PULUMI_URL=https://get.pulumi.com/releases/sdk/pulumi-${PULUMI_VERSION}-linux-x64.tar.gz

# MicroDNF is recommended over YUM for Building Container Images
# https://www.redhat.com/en/blog/introducing-red-hat-enterprise-linux-atomic-base-image

RUN microdnf update -y \
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

RUN pulumi version

