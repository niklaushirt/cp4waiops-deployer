
export WAIOPS_NAMESPACE=$(oc get po -A|grep iaf-operator-controller-manager |awk '{print$1}')
export EVTMGR_NAMESPACE=$(oc get po -A|grep noi-operator |awk '{print$1}')


echo "**************************************************************************************************************"
echo "AI MANAGER NAMESPACE: $WAIOPS_NAMESPACE"
echo "**************************************************************************************************************"
oc project $WAIOPS_NAMESPACE


echo "**************************************************************************************************************"
echo "Uninstall RobotShop"
echo "**************************************************************************************************************"
oc delete -n robot-shop -f ./ansible/templates/demo_apps/robotshop/load-deployment.yaml
oc delete -f ./ansible/templates/demo_apps/robotshop/robot-all-in-one.yaml -n robot-shop

oc delete clusterrolebinding default-robotinfo1-admin
oc delete clusterrolebinding default-robotinfo2-admin


echo "**************************************************************************************************************"
echo "Delete Custom Routes"
echo "**************************************************************************************************************"
oc delete route  topology-merge -n $WAIOPS_NAMESPACE 
oc delete route  topology-rest -n $WAIOPS_NAMESPACE
oc delete route  topology-manage -n $WAIOPS_NAMESPACE
oc delete route  job-manager -n $WAIOPS_NAMESPACE


echo "**************************************************************************************************************"
echo "Delete OpenLdap"
echo "**************************************************************************************************************"
oc delete -f ./ansible/templates/ldap/install-ldap.j2     


echo "**************************************************************************************************************"
echo "Delete Namespaces"
echo "**************************************************************************************************************"
oc delete ns robot-shop 

echo "**************************************************************************************************************"
echo "Delete AWX"
echo "**************************************************************************************************************"
oc delete -f ./ansible/templates/awx/awx-deploy-cr.yml
oc delete -f ./ansible/templates/awx/operator-install.yaml
oc delete -f ./ansible/templates/waiops-demo-ui/delete-cp4waiops-demo.yaml
oc delete -f ./ansible/templates/waiops-toolbox/create-waiops-toolbox.yaml



echo "**************************************************************************************************************"
echo "Delete Bastion"
echo "**************************************************************************************************************"
oc delete -f ./ansible/templates/runbook_bastion/create-bastion.yaml


echo "**************************************************************************************************************"
echo "Delete Stuff"
echo "**************************************************************************************************************"
oc delete Deployment -n default cp4waiops-installer
oc delete Jobs -n default --all

exit 0

oc delete eventmanagergateway.ai-manager.watson-aiops.ibm.com --all
oc delete kong.management.ibm.com  --all

