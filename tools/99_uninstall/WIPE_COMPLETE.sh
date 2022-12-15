oc delete csv --all -n ibm-common-services 
oc delete subscription --all -n ibm-common-services  

oc delete csv --all -n cp4waiops 
oc delete subscription --all -n cp4waiops 

oc delete ns ibm-common-services 
oc delete ns cp4waiops