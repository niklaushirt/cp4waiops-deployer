#!/bin/bash

export CONT_VERSION=1.0.9

docker login docker.io -u niklaushirt

docker build -t "niklaushirt/turbo-gateway:$CONT_VERSION" .

docker push "niklaushirt/turbo-gateway:1.0.$CONT_VERSION"
oc apply -n default -f ./tools/10_turbonomic/turbo-gateway/create-turbo-gateway.yaml





exit 1




oc -n default set image deployment/turbo-gateway gateway="lucafloris/turbo-gateway:1.0.$1"
echo "1.0.$1" > version.txt