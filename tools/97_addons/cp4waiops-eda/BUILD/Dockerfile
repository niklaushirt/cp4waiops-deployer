FROM ubuntu:22.10

ARG DEBIAN_FRONTEND=noninteractive

ENV DockerHOME=/home/app

RUN mkdir -p $DockerHOME
WORKDIR $DockerHOME
RUN mkdir -p $DockerHOME/repo

RUN apt-get update && apt-get install -y \
  openssh-server \
  ansible \
  kafkacat \
  python3-pip \
  npm \
  jq \
  curl \
  nano \
  unzip \
  && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip
RUN pip install -Iv 'resolvelib<0.6.0'
RUN pip install aiohttp

RUN ansible-galaxy collection install ansible.eda
RUN ansible-playbook -i localhost, -c local ansible.eda.install_rulebook_cli --ask-become-pass

# Install Openshift Client
RUN wget https://github.com/okd-project/okd/releases/download/4.11.0-0.okd-2022-08-20-022919/openshift-client-linux-4.11.0-0.okd-2022-08-20-022919.tar.gz -O oc.tar.gz && tar xfvz oc.tar.gz && mv oc /usr/local/bin && mv kubectl /usr/local/bin/ && rm oc.tar.gz

COPY * ./
COPY ./rulebooks ./rulebooks
COPY ./playbooks ./playbooks
COPY ./inventories ./inventories

RUN chmod +x startup.sh

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/
ENV REPO_URL=https://github.com/niklaushirt/cp4waiops-eda.git

ENTRYPOINT /home/app/startup.sh

