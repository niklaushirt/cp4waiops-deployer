FROM ubuntu:21.10

ARG DEBIAN_FRONTEND=noninteractive

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

# Install Openshift Client
RUN wget https://github.com/openshift/okd/releases/download/4.9.0-0.okd-2022-01-14-230113/openshift-client-linux-4.9.0-0.okd-2022-01-14-230113.tar.gz && tar xfvz openshift-client-linux-4.9.0-0.okd-2022-01-14-230113.tar.gz && mv oc /usr/local/bin && mv kubectl /usr/local/bin/ && rm openshift-client-linux-4.9.0-0.okd-2022-01-14-230113.tar.gz

# Init SSH
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh/ && echo $SSH_KEY > /root/.ssh/authorized_keys && touch /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys

# Install cloudctl
RUN curl -L https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-linux-amd64.tar.gz -o cloudctl-linux-amd64.tar.gz && tar xfvz cloudctl-linux-amd64.tar.gz && mv cloudctl-linux-amd64 /usr/local/bin/cloudctl && rm cloudctl-linux-amd64.tar.gz


# Install stuff
RUN ansible-galaxy collection install community.kubernetes:1.2.1
RUN npm install elasticdump -g
RUN pip install slack-cleaner2


# Install k9s
RUN wget https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz && tar xfzv k9s_Linux_x86_64.tar.gz && mv k9s /usr/local/bin && rm LICENSE && rm README.md && rm k9s_Linux_x86_64.tar.gz



COPY startup.sh /cp4waiops/startup.sh
RUN chmod +x /cp4waiops/startup.sh

ENTRYPOINT /cp4waiops/startup.sh
