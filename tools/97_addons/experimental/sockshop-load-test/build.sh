#!/bin/bash

export CONT_VERSION=0.1

# Create the Image
docker buildx build --platform linux/amd64 -t quay.io/niklaushirt/sockshop-load:$CONT_VERSION --load .
docker push quay.io/niklaushirt/sockshop-load:$CONT_VERSION
