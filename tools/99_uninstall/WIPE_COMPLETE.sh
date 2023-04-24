echo "*****************************************************************************************************************************"
echo " ✅ WIPE REMAINING WAIOPS STUFF"
echo "*****************************************************************************************************************************"
echo ""
echo "  ⏳ INSTALLATION START TIMESTAMP: $(date)"
echo ""

echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete CS CSV"
oc delete csv --all -n ibm-common-services 
oc delete subscription --all -n ibm-common-services  

$echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete WAIOPS CSV"
oc delete csv --all -n cp4waiops 
oc delete subscription --all -n cp4waiops 


echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete Stuff"
oc delete pods -n ibm-common-services --all
oc delete pods -n cp4waiops --all
oc delete csv --all -n ibm-common-services
oc delete subscription --all -n ibm-common-services
oc delete csv --all -n cp4waiops
oc delete subscription --all -n cp4waiops
oc delete deployment -n cp4waiops --all
oc delete deployment -n ibm-common-services --all
oc delete ss -n ibm-common-services --all
oc delete statefulset -n ibm-common-services --all
oc delete statefulset -n cp4waiops --all
oc delete jobs -n cp4waiops --all
oc delete jobs -n ibm-common-services --all
oc delete cm -n cp4waiops --all
oc delete cm -n ibm-common-services --all
oc delete secret -n cp4waiops --all
oc delete secret -n ibm-common-services --all
oc delete pvc -n cp4waiops --all
oc delete pvc -n ibm-common-services --all
oc delete cm -n cp4waiops --all
oc delete cm -n ibm-common-services --all

echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete OPERANDREQUESTS"
oc delete operandrequests.operator.ibm.com -n cp4waiops --all --force --grace-period=0 &
oc delete operandrequests.operator.ibm.com -n ibm-common-services --all --force --grace-period=0 &

kubectl patch operandrequests.operator.ibm.com -n cp4waiops iaf-core-operator  -p '{"metadata":{"finalizers":null}}' --type=merge          
kubectl patch operandrequests.operator.ibm.com -n cp4waiops iaf-eventprocessing-operator  -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch operandrequests.operator.ibm.com -n cp4waiops iaf-operator  -p '{"metadata":{"finalizers":null}}' --type=merge               
kubectl patch operandrequests.operator.ibm.com -n cp4waiops ibm-elastic-operator -p '{"metadata":{"finalizers":null}}' --type=merge       


echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete KAFKA Claims"
oc delete kafkaclaims.shim.bedrock.ibm.com -n cp4waiops --all
oc delete kafkaclaims.shim.bedrock.ibm.com -n ibm-common-services --all

echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete OIDC Clients"
oc delete clients.oidc.security.ibm.com -n cp4waiops --all --force --grace-period=0
oc delete clients.oidc.security.ibm.com -n ibm-common-services --all

echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete ConfigMaps"
oc delete cm -n cp4waiops --all
oc delete cm -n ibm-common-services --all
oc delete cm -n cp4waiops --all
oc delete cm -n ibm-common-services --all
oc delete cm -n cp4waiops --all
oc delete cm -n ibm-common-services --all


echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete Namespace sock-shop"
oc delete ns sock-shop &
echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete Namespace robot-shop"
oc delete ns robot-shop &
echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete Namespace awx"
oc delete ns awx &
echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete awx.ansible.com CustomResourceDefinition"
oc delete CustomResourceDefinition $(oc get CustomResourceDefinition| grep awx.ansible.com|awk '{print$1}') --ignore-not-found


echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete Namespace cp4waiops-demo-ui"
oc delete ns cp4waiops-demo-ui &
echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete Namespace cp4waiops-tools"
oc delete ns cp4waiops-tools &
echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete Namespace openldap"
oc delete ns openldap &


echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete namespacescopes"
oc delete namespacescopes.operator.ibm.com -n ibm-common-services --all &
echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete operandbindinfos"
oc delete operandbindinfos.operator.ibm.com -n ibm-common-services --all &

kubectl patch namespacescope.operator.ibm.com -n ibm-common-services common-service  -p '{"metadata":{"finalizers":null}}' --type=merge          
kubectl patch namespacescope.operator.ibm.com -n ibm-common-services nss-managedby-odlm  -p '{"metadata":{"finalizers":null}}' --type=merge          
kubectl patch namespacescope.operator.ibm.com -n ibm-common-services nss-odlm-scope  -p '{"metadata":{"finalizers":null}}' --type=merge          
kubectl patch namespacescope.operator.ibm.com -n ibm-common-services odlm-scope-managedby-odlm  -p '{"metadata":{"finalizers":null}}' --type=merge          
kubectl patch operandbindinfo.operator.ibm.com -n ibm-common-services ibm-licensing-bindinfo  -p '{"metadata":{"finalizers":null}}' --type=merge          



echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete Namespace ibm-common-services "
oc delete ns ibm-common-services &
echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete Namespace cp4waiops"
oc delete ns cp4waiops &


echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete *.ibm.com CustomResourceDefinition"
oc delete CustomResourceDefinition $(oc get CustomResourceDefinition| grep .ibm.com|awk '{print$1}') --ignore-not-found

