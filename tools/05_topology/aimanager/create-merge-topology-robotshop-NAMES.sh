echo "Starting..."
export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
export EVTMGR_NAMESPACE=$(oc get po -A|grep noi-operator |awk '{print$1}')



export EVTMGR_REST_USR=$(oc get secret aiops-topology-asm-credentials -n $WAIOPS_NAMESPACE -o jsonpath='{.data.username}' | base64 --decode)
export EVTMGR_REST_PWD=$(oc get secret aiops-topology-asm-credentials -n $WAIOPS_NAMESPACE -o jsonpath='{.data.password}' | base64 --decode)

oc delete route topology-rest -n $WAIOPS_NAMESPACE 
oc create route passthrough topology-rest -n $WAIOPS_NAMESPACE --insecure-policy="Redirect" --service=aiops-topology-rest-observer --port=https-rest-observer-api

export TOPO_ROUTE="https://"$(oc get route -n $WAIOPS_NAMESPACE topology-rest -o jsonpath={.spec.host})


export LOGIN="$EVTMGR_REST_USR:$EVTMGR_REST_PWD"

echo "Wait 10 seconds"
sleep 10

echo "URL: $TOPO_ROUTE/1.0/rest-observer/rest/resources"
echo "LOGIN: $LOGIN"


#echo curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["web"],"matchTokens": ["web","web-deployment"],"name": "web","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "web-id"}'



# -------------------------------------------------------------------------------------------------------------------------------------------------
# CREATE EDGES
# -------------------------------------------------------------------------------------------------------------------------------------------------
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["web"],"matchTokens": ["web","web-deployment","web-synthetic","web-instana"],"name": "web","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "web-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["shipping"],"matchTokens": ["shipping","shipping-deployment"],"name": "shipping","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "shipping-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["cart"],"matchTokens": ["cart","cart-deployment"],"name": "cart","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "cart-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["user"],"matchTokens": ["user","user-deployment"],"name": "user","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "user-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["catalogue"],"matchTokens": ["catalogue","catalogue-deployment","catalogue-log"],"name": "catalogue","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "catalogue-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["cities"],"matchTokens": ["cities","cities-deployment"],"name": "cities","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "cities-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["redis"],"matchTokens": ["redis","redis-deployment"],"name": "redis","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "redis-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["payment"],"matchTokens": ["payment","payment-deployment"],"name": "payment","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "payment-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["dispatch"],"matchTokens": ["dispatch","dispatch-deployment"],"name": "dispatch","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "dispatch-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["mongodb"],"matchTokens": ["mongodb","mongodb-deployment"],"name": "mongodb","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "mongodb-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["rabbitmq"],"matchTokens": ["rabbitmq","rabbitmq-deployment"],"name": "rabbitmq","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "rabbitmq-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["ratings"],"matchTokens": ["ratings","ratings-deployment","ratings-log","ratings-predictive"],"name": "ratings","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "ratings-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["mysql"],"matchTokens": ["mysql","mysql-deployment","mysql-github","mysql-instana","mysql-security","mysql-predictive","mysql-turbonomic","xxx","xxx","xxx","xxx","xxx","xxx"],"matchTokens": ["mysql","mysql"],"name": "mysql","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "mysql-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["deployment"],"mergeTokens": ["load"],"matchTokens": ["load","load-deployment"],"name": "load","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "load-id"}'
echo "."



curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["server"],"matchTokens": ["paypal"],"name": "paypal.com","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "paypal.com-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["server"],"matchTokens": ["paypal"],"name": "www.paypal.com","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "www.paypal.com-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["volume"],"matchTokens": ["catalogue-db"],"name": "catalogue-db","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "catalogue-db-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{"app": "robotshop","availableReplicas": 1,"createdReplicas": 1,"dataCenter": "demo","desiredReplicas": 1,"entityTypes": ["volume"],"matchTokens": ["user-db"],"name": "user-db","namespace": "robot-shop","readyReplicas": 1,"tags": ["app:robotshop","namespace:robot-shop"],"vertexType": "resource","uniqueId": "user-db-id"}'
echo "."

echo "."



# -------------------------------------------------------------------------------------------------------------------------------------------------
# CREATE LINKS
# -------------------------------------------------------------------------------------------------------------------------------------------------
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "load-id","_toUniqueId": "web-id"}'
echo "."


curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "web-id","_toUniqueId": "shipping-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "web-id","_toUniqueId": "catalogue-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "web-id","_toUniqueId": "cart-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "web-id","_toUniqueId": "payment-id"}'
echo "."

curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "cart-id","_toUniqueId": "catalogue-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "cart-id","_toUniqueId": "redis-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "user-id","_toUniqueId": "redis-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "user-id","_toUniqueId": "mongodb-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "catalogue-id","_toUniqueId": "mongodb-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "ratings-id","_toUniqueId": "mysql-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "catalogue-id","_toUniqueId": "ratings-id"}'
echo "."

curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "shipping-id","_toUniqueId": "cart-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "cart-id","_toUniqueId": "payment-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "payment-id","_toUniqueId": "user-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "payment-id","_toUniqueId": "www.paypal.com-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "payment-id","_toUniqueId": "paypal.com-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "payment-id","_toUniqueId": "rabbitmq-id"}'
echo "."


curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "rabbitmq-id","_toUniqueId": "dispatch-id"}'
echo "."


curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "user-id","_toUniqueId": "user-db-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "catalogue-id","_toUniqueId": "catalogue-db-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "user-db-id","_toUniqueId": "mongodb-id"}'
echo "."
curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/references" --insecure -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H 'JobId: restTopology' -H 'Content-Type: application/json; charset=utf-8' -u $LOGIN -d $'{"_edgeType": "dependsOn","_fromUniqueId": "catalogue-db-id","_toUniqueId": "mongodb-id"}'
echo "."




