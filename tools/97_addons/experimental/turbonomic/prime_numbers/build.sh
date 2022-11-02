#!/bin/bash

export CONT_VERSION=0.2

# Create the Image
docker buildx build --platform linux/amd64 -t niklaushirt/prime_numbers:$CONT_VERSION --load .
docker push niklaushirt/prime_numbers:$CONT_VERSION
