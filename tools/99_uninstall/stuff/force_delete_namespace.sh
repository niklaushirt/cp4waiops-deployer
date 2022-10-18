
#!/bin/bash
NS=$1
NS_CHECK=$(oc get ns | grep $NS | awk '{print $1}')
if [[ $NS_CHECK == $NS ]];
then
echo "Namespace $NS will be deleted"
else
echo "No such namespace named $NS"
exit 1
fi
oc delete ns $NS --force=true --grace-period=0 > /dev/null 2>&1 &
echo "Start oc proxy on port 8123"
oc proxy --port=8123 &
PROXY_PID=$!
sleep 1
oc get namespace $NS -o json > /tmp/ns.json
jq 'del(.spec.finalizers[])' /tmp/ns.json > /tmp/new-ns.json
echo "Delete namespace $NS"
sleep 1
curl -k -H "Content-Type: application/json" -X PUT --data-binary @/tmp/new-ns.json http://127.0.0.1:8123/api/v1/namespaces/$NS/finalize > /dev/null 2>&1
rm -rf /tmp/ns.json /tmp/new-ns.json
echo "Namespace $NS deleted"
echo "Stop oc proxy"
kill $PROXY_PID
wait $PROXY_PID 2>/dev/null
sleep 1
echo "oc proxy stopped"
