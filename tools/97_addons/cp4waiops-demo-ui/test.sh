#!/bin/bash

export CONT_VERSION=test

# Create the Image
cd demoui
docker build -t niklaushirt/cp4waiops-demo-ui:$CONT_VERSION .
cd -
docker run -p 8080:8000 --rm -e TOKEN=test niklaushirt/cp4waiops-demo-ui-python:$CONT_VERSION

# Deploy the Image


exit 1

podman machine start

export CONT_VERSION=0.45

# Create the Image
podman buildx build --platform linux/amd64 -t niklaushirt/cp4waiops-demo-ui-python:$CONT_VERSION --load .
docker push niklaushirt/cp4waiops-demo-ui-python:$CONT_VERSION
