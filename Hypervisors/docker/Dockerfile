FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    unzip \
    openssh-client \
    software-properties-common \
    python3-pip \
    python3-cryptography \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main" > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update && apt-get install -y terraform

RUN pip3 install --no-cache-dir --break-system-packages --ignore-installed \
    ansible \
    ansible-runner \
    azure-cli \
    azure-mgmt-resource \
    azure-mgmt-compute \
    azure-identity \
    kubernetes

USER ubuntu
WORKDIR /actions-runner

RUN curl -o actions-runner-linux-x64-2.317.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-x64-2.317.0.tar.gz \
    && tar xzf ./actions-runner-linux-x64-2.317.0.tar.gz \
    && rm actions-runner-linux-x64-2.317.0.tar.gz

RUN ansible-galaxy collection install ansible.posix \
    && ansible-galaxy collection install azure.azcollection

COPY --chown=ubuntu:ubuntu entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]