#!/bin/bash

export CONT_VERSION=1.4


# Build Production AMD64
docker buildx build --platform linux/amd64 -t niklaushirt/cp4waiops-installer:$CONT_VERSION --load .
docker push niklaushirt/cp4waiops-installer:$CONT_VERSION




# Local Test Mac
docker build -t niklaushirt/cp4waiops-installer:arm$CONT_VERSION .
#sudo docker push cp4waiops-install:arm$CONT_VERSION
docker run -p 8080:8080 niklaushirt/cp4waiops-installer:arm$CONT_VERSION
