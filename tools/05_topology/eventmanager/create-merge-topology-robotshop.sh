echo "Starting..."
WAIOPS_PARAMETER=$(cat ./00_config_cp4waiops.yaml|grep EVTMGR_NAMESPACE:)
EVTMGR_NAMESPACE=${WAIOPS_PARAMETER##*:}
EVTMGR_NAMESPACE=$(echo $EVTMGR_NAMESPACE|tr -d '[:space:]')


CLUSTER_ROUTE=$(oc get routes console -n openshift-console | tail -n 1 2>&1 ) 
CLUSTER_FQDN=$( echo $CLUSTER_ROUTE | awk '{print $2}')
CLUSTER_NAME=${CLUSTER_FQDN##*console.}


export EVTMGR_REST_USR=$(oc get secret evtmanager-topology-asm-credentials -n $EVTMGR_NAMESPACE -o jsonpath='{.data.username}' | base64 --decode)
export EVTMGR_REST_PWD=$(oc get secret evtmanager-topology-asm-credentials -n $EVTMGR_NAMESPACE -o jsonpath='{.data.password}' | base64 --decode)
export LOGIN="$EVTMGR_REST_USR:$EVTMGR_REST_PWD"

oc delete route topology-rest -n $EVTMGR_NAMESPACE 
oc create route passthrough topology-rest -n $EVTMGR_NAMESPACE --insecure-policy="Redirect" --service=evtmanager-topology-rest-observer --port=https-rest-observer-api

echo "Wait 10 seconds"
sleep 10

echo "URL: https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources"
echo "LOGIN: $LOGIN"



#echo curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["web"],"matchTokens": ["web","web-deployment"],"name": "web","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "web-id"}'



# -------------------------------------------------------------------------------------------------------------------------------------------------
# CREATE EDGES
# -------------------------------------------------------------------------------------------------------------------------------------------------
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["web"],"matchTokens": ["web-deployment","web-synthetic","web-instana"],"name": "web","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "web-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["shipping"],"matchTokens": ["shipping-deployment"],"name": "shipping","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "shipping-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["cart"],"matchTokens": ["cart-deployment"],"name": "cart","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "cart-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["user"],"matchTokens": ["user-deployment"],"name": "user","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "user-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["catalogue"],"matchTokens": ["catalogue-deployment","catalogue-log"],"name": "catalogue","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "catalogue-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["cities"],"matchTokens": ["cities-deployment"],"name": "cities","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "cities-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["redis"],"matchTokens": ["redis-deployment"],"name": "redis","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "redis-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["payment"],"matchTokens": ["payment-deployment"],"name": "payment","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "payment-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["dispatch"],"matchTokens": ["dispatch-deployment"],"name": "dispatch","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "dispatch-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["mongodb"],"matchTokens": ["mongodb-deployment"],"name": "mongodb","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "mongodb-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["rabbitmq"],"matchTokens": ["rabbitmq-deployment"],"name": "rabbitmq","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "rabbitmq-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["ratings"],"matchTokens": ["ratings-deployment","ratings-log","ratings-predictive"],"name": "ratings","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "ratings-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["mysql"],"matchTokens": ["mysql-deployment","mysql-github","mysql-instana","mysql-security","mysql-predictive","mysql-turbonomic","xxx","xxx","xxx","xxx","xxx","xxx"],"matchTokens": ["mysql","mysql"],"name": "mysql","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "mysql-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["load"],"matchTokens": ["load-deployment"],"name": "load","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "load-id"}'
echo "."



curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["server"],"matchTokens": ["paypal"],"name": "paypal.com","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "paypal.com-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["server"],"matchTokens": ["paypal"],"name": "www.paypal.com","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "www.paypal.com-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["volume"],"matchTokens": ["catalogue-db"],"name": "catalogue-db","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "catalogue-db-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["volume"],"matchTokens": ["user-db"],"name": "user-db","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "user-db-id"}'
echo "."

echo "."



# -------------------------------------------------------------------------------------------------------------------------------------------------
# CREATE LINKS
# -------------------------------------------------------------------------------------------------------------------------------------------------
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "load-id","_toUniqueId": "web-id"}'
echo "."


curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "web-id","_toUniqueId": "shipping-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "web-id","_toUniqueId": "catalogue-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "web-id","_toUniqueId": "cart-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "web-id","_toUniqueId": "payment-id"}'
echo "."

curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "cart-id","_toUniqueId": "catalogue-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "cart-id","_toUniqueId": "redis-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "user-id","_toUniqueId": "redis-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "user-id","_toUniqueId": "mongodb-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "catalogue-id","_toUniqueId": "mongodb-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "ratings-id","_toUniqueId": "mysql-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "catalogue-id","_toUniqueId": "ratings-id"}'
echo "."

curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "shipping-id","_toUniqueId": "cart-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "cart-id","_toUniqueId": "payment-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "payment-id","_toUniqueId": "user-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "payment-id","_toUniqueId": "www.paypal.com-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "payment-id","_toUniqueId": "paypal.com-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "payment-id","_toUniqueId": "rabbitmq-id"}'
echo "."


curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "rabbitmq-id","_toUniqueId": "dispatch-id"}'
echo "."


curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "user-id","_toUniqueId": "user-db-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "catalogue-id","_toUniqueId": "catalogue-db-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "user-db-id","_toUniqueId": "mongodb-id"}'
echo "."
curl -X "POST" "https://topology-rest-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "catalogue-db-id","_toUniqueId": "mongodb-id"}'
echo "."




