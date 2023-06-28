oc delete pod  -n cp4waiops --ignore-not-found $(oc get po -n cp4waiops|grep spark|awk '{print$1}') --force --grace-period=0
oc delete pod  -n cp4waiops --ignore-not-found $(oc get po -n cp4waiops|grep metric|awk '{print$1}') --force --grace-period=0
