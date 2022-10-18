FROM ubuntu:21.10

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  git \
  wget \
  jq \
  curl \
  && rm -rf /var/lib/apt/lists/*

# Install Openshift Client
RUN wget https://github.com/openshift/okd/releases/download/4.9.0-0.okd-2022-01-14-230113/openshift-client-linux-4.9.0-0.okd-2022-01-14-230113.tar.gz && tar xfvz openshift-client-linux-4.9.0-0.okd-2022-01-14-230113.tar.gz && mv oc /usr/local/bin && mv kubectl /usr/local/bin/ && rm openshift-client-linux-4.9.0-0.okd-2022-01-14-230113.tar.gz


WORKDIR /cp4waiops


COPY startup.sh /cp4waiops/startup.sh
RUN chmod +x /cp4waiops/startup.sh

ENTRYPOINT /cp4waiops/startup.sh
