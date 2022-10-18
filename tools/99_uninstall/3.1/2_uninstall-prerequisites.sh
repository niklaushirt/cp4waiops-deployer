. ./tools/99_uninstall/3.1/0_uninstall-cp4waiops-props.sh

echo "Uninstall Strimzi Operator"
oc delete -f ./ansible/templates/strimzi/strimzi-subscription.yaml
oc delete csv strimzi-cluster-operator.v0.19.0 -n openshift-operators


echo "Uninstall Knative Operator"

oc delete -n knative-eventing -f ./ansible/templates/knative/knative-eventing.yaml
oc delete -n knative-serving -f ../ansible/templates/knative/knative-serving.yaml

oc delete --namespace=openshift-serverless -f ./ansible/templates/knative/knative-subscription.yaml

oc delete csv serverless-operator.v1.13.0 -n openshift-serverless


#oc delete ns knative-serving
#oc delete ns knative-eventing
#oc delete ns openshift-serverless


echo "Uninstall IBM Operator"
oc delete -n openshift-operators -f ./ansible/templates/waiops/sub-ibm-aiops-orchestrator.yaml


oc delete -f ./ansible/templates/waiops/cat-ibm-operator.yaml
oc delete -f ./ansible/templates/waiops/cat-ibm-aiops.yaml
oc delete -f ./ansible/templates/waiops/cat-ibm-common-services.yaml

echo ""
echo ""
echo "-------------------------------------------------------------------------------------------------------------------------"
echo "Remaining CSVs"
echo "-------------------------------------------------------------------------------------------------------------------------"
oc get csv -A