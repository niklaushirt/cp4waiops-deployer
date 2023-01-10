#!/bin/bash
export DEPLOY_DIR=tools/deploy
export CONT_VERSION=0.1
export _ui_image="niklaushirt/eda-frontend:${CONT_VERSION}"
export _api_image="niklaushirt/eda-server:${CONT_VERSION}"

echo $_api_image
echo $_ui_image

# Build and Push Frontend
docker buildx build . --platform linux/amd64 -t $_ui_image --load -f tools/docker/nginx/Dockerfile
docker push $_ui_image

# Build and Push Server
docker buildx build . --platform linux/amd64 -t $_api_image --load -f tools/docker/Dockerfile
docker push $_api_image



# Create Deployment YAML Manifest

mkdir ${DEPLOY_DIR}/temp/

cd "${DEPLOY_DIR}"/eda-server
kustomize edit set image "eda-server=${_api_image}"
cd -

cd "${DEPLOY_DIR}"/eda-frontend
kustomize edit set image "eda-frontend=${_ui_image}"
cd -

kustomize build "${DEPLOY_DIR}" -o ${DEPLOY_DIR}/temp/


export eda_server_pod_name=$(kubectl get pod -n eda -l app=eda-server -o jsonpath="{.items[0].metadata.name}")
kubectl exec "${eda_server_pod_name}" -- scripts/adduser.py -S --password "${password}" "${user}"



You can now login to the UI at http://localhost:8080/eda/.
API docs can be accessed at:

http://localhost:8080/api/docs
http://localhost:8080/api/openapi.json





# Build and Push Frontend
docker build . -t $_ui_image -f tools/docker/nginx/Dockerfile
docker push $_ui_image

# Build and Push Server
docker build . -t $_api_image -f tools/docker/Dockerfile
docker push $_api_image





build-frontend() {
  local _image="eda-frontend:${1}"

  log-info "minikube image build . -t ${_image} -f tools/docker/nginx/Dockerfile"
  minikube image build . -t "${_image}" -f tools/docker/nginx/Dockerfile
}

build-server() {
  local _image="eda-server:${1}"

  log-info "minikube image build . -t ${_image} -f tools/docker/Dockerfile"
  minikube image build . -t "${_image}" -f tools/docker/Dockerfile
}



# Run the Image

docker build -t niklaushirt/cp4waiops-demo-bot:$CONT_VERSION  .

docker run -p 8080:8000 -e TOKEN=test niklaushirt/cp4waiops-demo-bot:$CONT_VERSION

# Deploy the Image
oc apply -n default -f create-cp4mcm-event-gateway.yaml





exit 1

