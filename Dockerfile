FROM registry.access.redhat.com/ubi9/ubi-minimal:9.0.0
# FROM redhat/ubi9/ubi-minimal:9.0.0

LABEL maintainer=""

ENV PULUMI_VERSION=3.48.0
ENV PULUMI_URL=https://get.pulumi.com/releases/sdk/pulumi-v${PULUMI_VERSION}-linux-x64.tar.gz

ENV AWSCLI_VERSION=2.9.1
ENV AWSCLI_URL=https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip

ENV KUBECTL_VERSION=1.25.4
ENV KUBECTL_URL=https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ENV KUBECTL_CHECKSUM_URL=https://dl.k8s.io/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256

ENV PYTHON_VERSION=3 \
    PATH=$HOME/.local/bin/:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    PIP_NO_CACHE_DIR=off \
    POETRY_VERSION=1.2.2

ENV NODEJS_VERSION=16.14.0 \
    NPM_VERSION=8.3.1 \
    YARN_VERSION=1.22.19 \
    PATH=$HOME/.local/bin/:$PATH \
    npm_config_loglevel=warn \
    npm_config_unsafe_perm=true

# MicroDNF is recommended over YUM for Building Container Images
# https://www.redhat.com/en/blog/introducing-red-hat-enterprise-linux-atomic-base-image

# Install Tools
RUN microdnf update -y \
    && microdnf install -y tar \
    && microdnf install -y gzip \
    && microdnf install -y wget \
    && microdnf install -y unzip \
    && microdnf install -y git \
    && microdnf clean all \
    && rm -rf /var/cache/* /var/log/dnf* /var/log/yum.*

# Install the latest version of Python
RUN microdnf update -y \
    && microdnf install -y python${PYTHON_VERSION} \
    && microdnf install -y python${PYTHON_VERSION}-devel \
    && microdnf install -y python${PYTHON_VERSION}-setuptools \
    && microdnf install -y python${PYTHON_VERSION}-pip \
    && microdnf clean all \
    && rm -rf /var/cache/* /var/log/dnf* /var/log/yum.*

# Configure Python
ENV PATH=/root/.local/bin:$PATH

# Install pipx and poetry
RUN python -m pip install --user pipx \
    && python -m pipx ensurepath --force \
    && pipx install poetry==${POETRY_VERSION}

# Install Node and NPM
RUN microdnf update -y \
    && microdnf install -y nodejs \
    && microdnf install -y npm \
    && microdnf clean all \
    && rm -rf /var/cache/* /var/log/dnf* /var/log/yum.*

# Install Yarn
RUN npm install --global yarn@${YARN_VERSION} \
    && npm config set prefix /usr/local

# Download and install Pulumi
RUN wget ${PULUMI_URL} \
	&& tar -xzvf pulumi-v${PULUMI_VERSION}-linux-x64.tar.gz \
    && rm pulumi-v${PULUMI_VERSION}-linux-x64.tar.gz \
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

RUN echo "pulumi version: $(pulumi version)" \
    && echo "aws-cli version: $(aws --version)" \
    && echo "nodejs version: $(node --version)" \ 
    && echo "npm version: $(npm --version)" \ 
    && echo "yarn version: $(yarn --version)" \ 
    && echo "python version: $(python --version)" \
    && echo "pip version: $(python -m pip --version)" \
    && echo "poetry about: $(poetry about)" \
    && echo "wget version: $(wget --version | head -n 1)" \
    && echo "unzip version: $(unzip -v | head -n 1)" \
    && echo "tar version: $(tar --version | head -n 1)" \
    && echo "gzip version: $(gzip --version | head -n 1)" \
    && echo "git version: $(git --version)" \
    && echo "kubectl version: $(kubectl version --client)" \
    && microdnf repolist

# USER 1001

CMD ["echo", "This is a 'Purpose Built Image', It is not meant to be ran directly"]
