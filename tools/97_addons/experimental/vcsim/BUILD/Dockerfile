FROM ubuntu:22.10

ARG DEBIAN_FRONTEND=noninteractive



USER root

RUN apt-get update && apt-get install -y \
  wget \
  && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/vmware/govmomi/releases/download/v0.30.4/vcsim_Linux_x86_64.tar.gz && tar -xvzf vcsim_Linux_x86_64.tar.gz && mv vcsim /usr/local/bin
RUN wget https://github.com/vmware/govmomi/releases/download/v0.30.4/govc_Linux_x86_64.tar.gz && tar -xvzf govc_Linux_x86_64.tar.gz && mv govc /usr/local/bin

RUN groupadd -r appuser -g 433 && \
    useradd -u 431 -r -g appuser -s /sbin/nologin -c "Local user" appuser


WORKDIR /vcsim

RUN mkdir vcsim-demo
COPY vcsim-demo/* ./vcsim-demo
COPY startup.sh ./startup.sh

RUN chmod +x ./startup.sh
RUN chown -R appuser:appuser /vcsim
RUN mkdir -p /.govmomi/sessions
RUN chown -R appuser:appuser /.govmomi


#USER appuser

# Expose application port

EXPOSE 8989

# Set entrypoint to application with container defaults
ENTRYPOINT ./startup.sh
# ENTRYPOINT [ "vcsim" ]
# CMD ["-l", "0.0.0.0:8989","-load=vcsim-demo","-tls=false"]