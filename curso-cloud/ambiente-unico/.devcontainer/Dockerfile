FROM ubuntu:23.04

## UTILITARIOS
ENV DEBIAN_FRONTEND noninteractive
ENV KUBECTL_VERSION 1.25.13-00
ENV TERRAFORM_VERSION_DEFAULT 1.5.3

# PYTHON + JAVA 17 + Maven + utils
RUN apt update && \
    apt install -y --no-install-recommends apt-transport-https ca-certificates software-properties-common gcc python3 python3-distutils gnupg iproute2 \
    python3-pip python3-apt python-is-python3 curl git zip unzip jq awscli maven openjdk-17-jdk htop ssh dnsutils iputils-ping vim lsb-release hey
    
# KUBECTL
RUN curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get install kubectl=$KUBECTL_VERSION -y

# HELM 3 (OPCIONAL)
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

# NVM (node version manager) OPCIONAL
RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash && \
    . ~/.bashrc && \
    nvm install 18 && \
    nvm use 18 && \
    nvm alias default 18

## TERRAFORM (TFEnv) OPCIONAL
RUN git clone https://github.com/tfutils/tfenv.git ~/.tfenv && \
    echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile && \
    . ~/.bash_profile && \
    ln -s ~/.tfenv/bin/* /usr/local/bin && \
    tfenv --version && \
    tfenv install $TERRAFORM_VERSION_DEFAULT && \
    tfenv use $TERRAFORM_VERSION_DEFAULT

# Install Docker CE CLI
RUN curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
    && echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y docker-ce-cli

# Install Docker Compose
RUN LATEST_COMPOSE_VERSION=$(curl -sSL "https://api.github.com/repos/docker/compose/releases/latest" | grep -o -P '(?<="tag_name": ").+(?=")') \
    && curl -sSL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# AZURE
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# GCLOUD
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update && apt-get install google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin

# K3D - CLUSTER LOCAL k8s
RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# ROOT USERS
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && echo "$SNIPPET" >> "/root/.bashrc"

ENV TZ=America/Lima
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# OPCIONAL
ENV PATH "$HOME/.tfenv/bin:$HOME/bin:$PATH"

RUN aws --version && \
    kubectl version --client && \
    helm version --client && \
    python --version && \
    terraform --version

RUN apt-get clean && rm -rf /tmp/* /var/tmp/*