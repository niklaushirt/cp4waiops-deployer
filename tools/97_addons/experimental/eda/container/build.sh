#!/bin/bash

export CONT_VERSION=2.0

# Build Production AMD64
docker buildx build --platform linux/amd64 -t niklaushirt/cp4waiops-tools:$CONT_VERSION --load .




docker push niklaushirt/cp4waiops-tools:$CONT_VERSION


export CONT_VERSION=2.0
docker build -t niklaushirt/eda-container:$CONT_VERSION .
docker push niklaushirt/eda-container:$CONT_VERSION





docker build -t test:0.1 .
docker run -ti --rm -p 5000:5000 test:0.1 /bin/bash
ansible-rulebook --rulebook ./rulebooks/default-rulebook.yaml -i inventory.yaml --verbose



