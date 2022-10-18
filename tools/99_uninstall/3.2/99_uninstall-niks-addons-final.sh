
export WAIOPS_NAMESPACE=$(oc get ns|grep aiops |awk '{print$1}')


oc project $WAIOPS_NAMESPACE



oc delete ns $WAIOPS_NAMESPACE
oc delete Subscription -n openshift-operators ibm-common-service-operator-v3-ibm-operator-catalog-openshift-marketplace
oc delete Subscription -n openshift-operators ibm-management-orchestrator

oc delete -f ./ansible/templates/waiops/

oc delete ClusterServiceVersion ibm-management-orchestrator.v2.3.24 -n openshift-operators
oc delete ClusterServiceVersion ibm-common-service-operator.v3.15.0 -n openshift-operators



