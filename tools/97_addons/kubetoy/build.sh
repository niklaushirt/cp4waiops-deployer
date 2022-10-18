#!/bin/bash

export CONT_VERSION=0.2

# Create the Image
docker buildx build --platform linux/amd64 -t niklaushirt/kubetoy:$CONT_VERSION --load .
docker push niklaushirt/kubetoy:$CONT_VERSION

helm install --create-namespace --namespace instana-autotrace-webhook instana-autotrace-webhook \
  --repo https://agents.instana.io/helm instana-autotrace-webhook \
  --set webhook.imagePullCredentials.password=qUMhYJxjSv6uZh2SyqTEn