oc delete NOI -n cp4waiops-evtmgr evtmanager
oc delete pvc -n cp4waiops-evtmgr --all
oc delete Subscription -n cp4waiops-evtmgr noi-operator
oc delete ClusterServiceVersion -n cp4waiops-evtmgr noi.v1.6.0
oc delete OperatorGroup -n cp4waiops-evtmgr noi-operator-group
oc delete ns cp4waiops-evtmgr &


oc delete job  -n default --ignore-not-found $(oc get job -n default|awk '{print$1}')

oc delete ns openldap &
oc delete ns awx &
oc delete ns cp4waiops-demo-ui &
oc delete ns robot-shop &


oc delete Xl -n turbonomic xl-release
oc delete ns turbonomic &
