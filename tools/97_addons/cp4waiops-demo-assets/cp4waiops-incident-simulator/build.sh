#!/bin/bash

export CONT_VERSION=1.0

# Create the Image
docker buildx build --platform linux/amd64 -t quay.io/niklaushirt/cp4waiops-incident-simulator:$CONT_VERSION --load .
docker push quay.io/niklaushirt/cp4waiops-incident-simulator:$CONT_VERSION

# Run the Image

docker build -t niklaushirt/cp4waiops-incident-simulator:$CONT_VERSION  .

docker run -p 8080:8000 -e TOKEN=test niklaushirt/cp4waiops-incident-simulator:$CONT_VERSION

# Deploy the Image
oc apply -n default -f create-cp4mcm-event-gateway.yaml





exit 1

