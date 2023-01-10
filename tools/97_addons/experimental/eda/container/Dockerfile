FROM ubuntu:22.10

ARG DEBIAN_FRONTEND=noninteractive

ENV DockerHOME=/home/app

# set work directory
RUN mkdir -p $DockerHOME

# where your code lives
WORKDIR $DockerHOME

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


# install dependencies
RUN pip install --upgrade pip

RUN pip install -Iv 'resolvelib<0.6.0'
RUN pip install aiohttp

RUN ansible-galaxy collection install ansible.eda
RUN ansible-playbook -i localhost, -c local ansible.eda.install_rulebook_cli --ask-become-pass

COPY * ./
COPY ./rulebooks ./rulebooks
COPY ./playbooks ./playbooks

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/

CMD ansible-rulebook --rulebook ./rulebooks/default-rulebook.yaml -i inventory.yaml --verbose

