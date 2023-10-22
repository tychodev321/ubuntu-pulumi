# https://hub.docker.com/_/ubuntu
FROM ubuntu:22.04

LABEL maintainer=""

ENV PULUMI_VERSION=3.86.0
ENV PULUMI_URL=https://get.pulumi.com/releases/sdk/pulumi-v${PULUMI_VERSION}-linux-x64.tar.gz

ENV AWSCLI_VERSION=2.9.1
ENV AWSCLI_URL=https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip

ENV KUBECTL_VERSION=1.25.4
ENV KUBECTL_URL=https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ENV KUBECTL_CHECKSUM_URL=https://dl.k8s.io/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256

ENV PYTHON_VERSION=3.10.10 \
    PATH=$HOME/.local/bin/:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    PIP_NO_CACHE_DIR=off \
    POETRY_VERSION=1.2.2 \
    PULUMI_EXPERIMENTAL=true

ENV NODEJS_VERSION=18.0.0 \
    NPM_VERSION=10.1.0 \
    YARN_VERSION=1.22.19 \
    PATH=$HOME/.local/bin/:$PATH \
    npm_config_loglevel=warn \
    npm_config_unsafe_perm=true

# Install Base Tools
RUN apt update -y && apt upgrade -y \
    && apt install -y unzip \
    && apt install -y gzip \
    && apt install -y tar \
    && apt install -y wget \
    && apt install -y curl \
    && apt install -y git \
    && apt install -y sudo \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install Python
RUN apt update -y && apt upgrade -y \
    && apt install -y python3-pip \
    && apt install -y python3-venv \
    && apt install -y python3-setuptools \
    && apt install -y python-is-python3 \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/*

# Configure Python
ENV PATH=/root/.local/bin:$PATH

# Install pipx and poetry
RUN python -m pip install --user pipx \
    && python -m pipx ensurepath --force \
    && pipx install poetry==${POETRY_VERSION}

# Install Node and NPM
RUN apt update -y && apt upgrade -y \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - \
    && apt install -y nodejs \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/*

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
    # && echo "$(<kubectl.sha256) kubectl" | sha256sum --check \
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
    && echo "kubectl version: $(kubectl version --client)"

# USER 1001

CMD ["echo", "This is a 'Purpose Built Image', It is not meant to be ran directly"]
