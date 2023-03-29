PROBE_HOSTNAME=$(oc get route turbonomic-probe-mb-webhook -o jsonpath='{.spec.host}')
PROBE_URI=$(oc get route turbonomic-probe-mb-webhook -o jsonpath='{.spec.path}')
PROBE_WEBHOOK_URL=https://$PROBE_HOSTNAME$PROBE_URI
echo "$PROBE_WEBHOOK_URL"

## WEBHOOK PROBE TEST
curl -X "POST" "$PROBE_WEBHOOK_URL" \
     -H 'Content-Type: text/plain; charset=utf-8' \
     -H 'Cookie: 8a3ca3e7036a020dcf1e98075251e2b8=6b0d31808967c487642156d942be194f' \
     -u 'administrator:P4ssw0rd!' \
     -d $'{
    "uuid": "637746351351293",
    "displayName": "MANUAL",
    "actionImpactID": 637746351351293,
    "marketID": 777777,
    "createTime": "2023-01-08T15:19:03Z",
    "actionType": "RESIZE",
    "actionState": "READY",
    "actionMode": "MANUAL",
    "details": "Resize VCPU Limit for Workload Controller catalogue",
    "importance": 0.0,
    "target": {
        "uuid": "74795006515724",
        "displayName": "catalogue",
        "className": "WorkloadController",
        "environmentType": "HYBRID",
        "discoveredBy": {
            "uuid": "74795006106224",
            "displayName": "Kubernetes-Turbonomic",
            "type": "Kubernetes",
            "readonly": false
        },
        "vendorIds": {
            "Kubernetes-Turbonomic": "7ffdff91-8317-457c-8680-350e2033f99a"
        },
        "state": "ACTIVE",
        "aspects": {
            "containerPlatformContextAspect": {
                "namespace": "robot-shop",
                "containerPlatformCluster": "Kubernetes-Turbonomic",
                "namespaceEntity": {
                    "uuid": "74795006518315",
                    "displayName": "robot-shop",
                    "className": "Namespace"
                },
                "containerClusterEntity": {
                    "uuid": "74795006518760",
                    "displayName": "Kubernetes-Turbonomic",
                    "className": "ContainerPlatformCluster"
                },
                "type": "ContainerPlatformContextAspectApiDTO"
            }
        },
        "tags": {
            "app": ["robot-shop"],
            "service": ["catalogue"],
            "version": ["v1"]
        }
    },
    "currentEntity": {
        "uuid": "74795006515724",
        "displayName": "catalogue",
        "className": "WorkloadController",
        "environmentType": "HYBRID",
        "discoveredBy": {
            "uuid": "74795006106224",
            "displayName": "Kubernetes-Turbonomic",
            "type": "Kubernetes",
            "readonly": false
        },
        "vendorIds": {
            "Kubernetes-Turbonomic": "7ffdff91-8317-457c-8680-350e2033f99a"
        },
        "state": "ACTIVE",
        "tags": {
            "app": ["robot-shop"],
            "service": ["catalogue"],
            "version": ["v1"]
        }
    },
    "newEntity": {
        "uuid": "74795006515724",
        "displayName": "catalogue",
        "className": "WorkloadController",
        "environmentType": "HYBRID",
        "discoveredBy": {
            "uuid": "74795006106224",
            "displayName": "Kubernetes-Turbonomic",
            "type": "Kubernetes",
            "readonly": false
        },
        "vendorIds": {
            "Kubernetes-Turbonomic": "7ffdff91-8317-457c-8680-350e2033f99a"
        },
        "state": "ACTIVE",
        "tags": {
            "app": ["robot-shop"],
            "service": ["catalogue"],
            "version": ["v1"]
        }
    },
    "risk": {
        "subCategory": "Performance Assurance",
        "description": "VCPU Throttling Congestion in Container Spec catalogue",
        "severity": "CRITICAL",
        "importance": 0.0
    },
    "compoundActions": [{
        "displayName": "MANUAL",
        "actionType": "RESIZE",
        "actionState": "READY",
        "actionMode": "MANUAL",
        "details": "VCPU Congestion in catalogue",
        "target": {
            "uuid": "74795006516059",
            "displayName": "catalogue",
            "className": "ContainerSpec",
            "environmentType": "HYBRID",
            "discoveredBy": {
                "uuid": "74795006106224",
                "displayName": "Kubernetes-Turbonomic",
                "type": "Kubernetes",
                "readonly": false
            },
            "vendorIds": {
                "Kubernetes-Turbonomic": "7ffdff91-8317-457c-8680-350e2033f99a/catalogue"
            },
            "state": "ACTIVE",
            "tags": {
                "app": ["robot-shop"],
                "service": ["catalogue"],
                "version": ["v1"]
            }
        },
        "currentValue": "200.0",
        "newValue": "300.0",
        "valueUnits": "mCores",
        "resizeAttribute": "CAPACITY",
        "risk": {
            "importance": 0.0,
            "reasonCommodity": "VCPU",
            "reasonCommodities": ["VCPU"]
        }
    }],
    "actionID": 637746351351293
}
'
