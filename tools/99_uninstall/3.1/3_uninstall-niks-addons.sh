. ./tools/99_uninstall/3.1/0_uninstall-cp4waiops-props.sh


echo "Uninstall Kubetoy"
oc delete -n kubetoy -f ./ansible/templates/demo_apps/kubetoy/kubetoy_all_in_one.yaml

echo "Uninstall RobotShop"
oc delete -n robot-shop -f ./ansible/templates/demo_apps/robotshop/load-deployment.yaml
oc delete -f ./ansible/templates/demo_apps/robotshop/robot-all-in-one.yaml -n robot-shop

oc delete clusterrolebinding default-robotinfo1-admin
oc delete clusterrolebinding default-robotinfo2-admin

echo "Uninstall Bookinfo"
oc delete -n bookinfo -f ./demo_install/bookinfo/bookinfo.yaml
oc delete -n default -f ./demo_install/bookinfo/bookinfo-create-load.yaml


echo "Delete Custom Routes"
oc delete route  topology-merge -n $AIOPS_PROJECT 
oc delete route  topology-rest -n $AIOPS_PROJECT
oc delete route  topology-manage -n $AIOPS_PROJECT
oc delete route  job-manager -n $AIOPS_PROJECT

echo "Delete OpenLdap"
helm delete -n default openldap         

echo "Delete Namespaces"
oc delete ns kubetoy
oc delete ns bookinfo
oc delete ns robot-shop 