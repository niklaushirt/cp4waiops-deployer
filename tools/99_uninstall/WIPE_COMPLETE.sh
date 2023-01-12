oc delete csv --all -n ibm-common-services 
oc delete subscription --all -n ibm-common-services  

oc delete csv --all -n cp4waiops 
oc delete subscription --all -n cp4waiops 



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


oc delete operandrequests.operator.ibm.com -n cp4waiops --all
oc delete operandrequests.operator.ibm.com -n ibm-common-services --all

oc delete kafkaclaims.shim.bedrock.ibm.com -n cp4waiops --all
oc delete kafkaclaims.shim.bedrock.ibm.com -n ibm-common-services --all
oc delete clients.oidc.security.ibm.com -n cp4waiops --all --force --grace-period=0
oc delete clients.oidc.security.ibm.com -n ibm-common-services --all
oc delete cm -n cp4waiops --all
oc delete cm -n ibm-common-services --all
oc delete cm -n cp4waiops --all
oc delete cm -n ibm-common-services --all
oc delete cm -n cp4waiops --all
oc delete cm -n ibm-common-services --all

operandrequests.operator.ibm.com


oc delete ns ibm-common-services 
oc delete ns cp4waiops


