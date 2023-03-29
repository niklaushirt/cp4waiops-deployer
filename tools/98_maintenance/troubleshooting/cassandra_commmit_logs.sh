
oc debug -n instana-datastores $(oc get po -n instana-datastores|grep cassandra|awk '{print$1}')  

oc rsh -n instana-datastores $(oc get po -n instana-datastores|grep cassandra|awk '{print$1}')  


cd /mnt/data/commitlog
rm-f *

oc delete pod -n instana-datastores $(oc get po -n instana-datastores|grep cassandra|awk '{print$1}')  
