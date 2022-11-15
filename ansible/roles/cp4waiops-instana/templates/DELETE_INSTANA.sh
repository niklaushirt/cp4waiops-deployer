#!/bin/bash

oc delete agents.instana.io -n instana-agent instana-agent
oc delete subscription -n openshift-operators instana-agent
oc delete ns instana-agent

  #delete instana based on flag
oc -n instana-units delete unit --all
oc delete ns instana-units 
oc -n instana-core delete core --all 
oc delete ns instana-core 
oc delete ns instana-datastores

#If the `instana-core` project gets stuck deleting, it's probably waiting on the `Core` resource which still has a finalizer on it. You can remove that with the below command

#oc -n instana-core patch core instana-core -p '{"metadata":{"finalizers":null}}' --type=merge
#oc -n instana-units patch unit aiops-dev -p '{"metadata":{"finalizers":null}}' --type=merge
#oc -n instana-units patch unit aiops-prod  -p '{"metadata":{"finalizers":null}}' --type=merge
oc project instana-operator
kubectl instana operator template --output-dir=instana-operator-resources
oc -n instana-operator delete -f ./instana-operator-resources/ --namespace=instana-operator
oc delete ns instana-operator
rm -rf ./instana-operator-resources
echo "Instana removed from OpenShift successfully!"
exit 0;
