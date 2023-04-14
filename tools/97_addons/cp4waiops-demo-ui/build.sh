#!/bin/bash

export CONT_VERSION=1.20

# Create the Image
docker buildx build --platform linux/amd64 -t niklaushirt/cp4waiops-demo-ui:$CONT_VERSION --load .
docker push niklaushirt/cp4waiops-demo-ui:$CONT_VERSION


# Run the Image

docker build -t niklaushirt/cp4waiops-demo-ui-python:$CONT_VERSION  .

docker run -p 8080:8000 -e TOKEN=test niklaushirt/cp4waiops-demo-ui-python:$CONT_VERSION

# Deploy the Image
oc apply -n default -f create-cp4mcm-event-gateway.yaml





exit 1


export CONT_VERSION=0.97

# Create the Image
docker build -t niklaushirt/cp4waiops-demo-ui:$CONT_VERSION .

podman login docker.io -u niklaushirt   
podman build -t niklaushirt/cp4waiops-demo-ui:$CONT_VERSION .
podman push ^niklaushirt/cp4waiops-demo-ui:$CONT_VERSION



podman machine start

export CONT_VERSION=0.45

# Create the Image
podman buildx build --platform linux/amd64 -t niklaushirt/cp4waiops-demo-ui-python:$CONT_VERSION --load .
docker push niklaushirt/cp4waiops-demo-ui-python:$CONT_VERSION
