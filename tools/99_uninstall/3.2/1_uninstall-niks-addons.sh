
export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
export EVTMGR_NAMESPACE=$(oc get po -A|grep noi-operator |awk '{print$1}')


oc project $WAIOPS_NAMESPACE


oc delete eventmanagergateway.ai-manager.watson-aiops.ibm.com --all
oc delete kong.management.ibm.com  --all

echo "Uninstall RobotShop"
oc delete -n robot-shop -f ./ansible/templates/demo_apps/robotshop/load-deployment.yaml
oc delete -f ./ansible/templates/demo_apps/robotshop/robot-all-in-one.yaml -n robot-shop

oc delete clusterrolebinding default-robotinfo1-admin
oc delete clusterrolebinding default-robotinfo2-admin



echo "Delete Custom Routes"
oc delete route  topology-merge -n $WAIOPS_NAMESPACE 
oc delete route  topology-rest -n $WAIOPS_NAMESPACE
oc delete route  topology-manage -n $WAIOPS_NAMESPACE
oc delete route  job-manager -n $WAIOPS_NAMESPACE

echo "Delete OpenLdap"
oc delete -f ./ansible/templates/ldap/install-ldap.j2     

echo "Delete Namespaces"
oc delete ns kubetoy
oc delete ns bookinfo
oc delete ns robot-shop 



oc delete -f ./ansible/templates/xxx/xxx
oc delete -f ./ansible/templates/xxx/xxx
oc delete -f ./ansible/templates/xxx/xxx
oc delete -f ./ansible/templates/xxx/xxx
oc delete -f ./ansible/templates/xxx/xxx
oc delete -f ./ansible/templates/xxx/xxx
oc delete -f ./ansible/templates/xxx/xxx


oc delete -f ./ansible/templates/awx/awx-deploy-cr.yml
oc delete -f ./ansible/templates/awx/operator-install.yaml
oc delete -f ./ansible/templates/waiops-demo-ui/delete-cp4waiops-demo.yaml
oc delete -f ./ansible/templates/waiops-toolbox/create-waiops-toolbox.yaml


oc delete -f ./ansible/templates/runbook_bastion/create-bastion.yaml


oc delete Deployment -n default cp4waiops-installer
oc delete Jobs -n default --all

oc delete -f ./ansible/templates/manageiq/*.yaml

oc delete -n manageiq -f ./ansible/templates/manageiq/
oc delete ns manageiq


oc delete ns $WAIOPS_NAMESPACE
oc delete Subscription -n openshift-operators ibm-common-service-operator-v3-ibm-operator-catalog-openshift-marketplace
oc delete Subscription -n openshift-operators ibm-management-orchestrator

oc delete -f ./ansible/templates/waiops/

oc delete ClusterServiceVersion ibm-management-orchestrator.v2.3.24 -n openshift-operators
oc delete ClusterServiceVersion ibm-common-service-operator.v3.15.0 -n openshift-operators



