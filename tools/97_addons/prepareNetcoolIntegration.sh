export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
export EVTMGR_NAMESPACE=$(oc get po -A|grep noi-operator |awk '{print$1}')
export EVTMGR_INSTANCE=evtmanager

echo "WAIOPS_NAMESPACE: $WAIOPS_NAMESPACE"
echo "EVTMGR_NAMESPACE: $EVTMGR_NAMESPACE"
echo "EVTMGR_INSTANCE:  $EVTMGR_INSTANCE"

oc create -f - <<EOF
kind: Service
apiVersion: v1
metadata:
  name: $EVTMGR_INSTANCE-objserv-agg-primary
  namespace: $WAIOPS_NAMESPACE
spec:
  type: ExternalName
  externalName: $EVTMGR_INSTANCE-objserv-agg-primary.$EVTMGR_NAMESPACE.svc.cluster.local
  ports:
  - port: 4101
    name: primary-iduc-port
---
kind: Service
apiVersion: v1
metadata:
  name: $EVTMGR_INSTANCE-objserv-agg-backup
  namespace: $WAIOPS_NAMESPACE
spec:
  type: ExternalName
  externalName: $EVTMGR_INSTANCE-objserv-agg-backup.$EVTMGR_NAMESPACE.svc.cluster.local
  ports:
  - port: 4101
    name: backup-iduc-port
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress
  namespace: $EVTMGR_NAMESPACE
spec:
  policyTypes:
  - Ingress
  podSelector:
    matchLabels:
      release: $EVTMGR_INSTANCE
  ingress:
  - from:
    - namespaceSelector: {}
    - podSelector: {}
EOF




export OMNIBUS_ROOT_PASSWORD=$(oc get secret $EVTMGR_INSTANCE-omni-secret -n $EVTMGR_NAMESPACE -o jsonpath='{.data.OMNIBUS_ROOT_PASSWORD}' | base64 --decode)
echo ""
echo ""
echo "🚀 Create Netcool Integration with:"
echo ""
echo "  👩‍💻 Admin username: root"
echo "  🔐 Admin password: $OMNIBUS_ROOT_PASSWORD"
echo ""
echo "  📥 Primary ObjectServer"
echo "    🌏 Hostname:       $EVTMGR_INSTANCE-objserv-agg-primary.cp4waiops-evtmgr.svc.cluster.local"
echo "    🚪 Port:           4100"
echo ""
echo "  📥 Backup ObjectServer (optional)"
echo "    🌏 Hostname:       $EVTMGR_INSTANCE-objserv-agg-backup.cp4waiops-evtmgr.svc.cluster.local"
echo "    🚪 Port:           4100"
echo ""
echo ""

echo ""
echo ""
echo "🚀 Execute the following at the Objectserver prompt (one by one)"
echo "   You can ignore the: 'Warning: Failed to find tar in the following directories : /bin /usr/bin'"
echo ""
echo "  alter table alerts.status ADD COLUMN AIOpsAlertId VARCHAR(64);"
echo "  go"
echo "  alter table alerts.status ADD COLUMN AIOpsState VARCHAR(16);"
echo "  go"
echo "  alter table alerts.status ADD COLUMN BSMIdentity varchar(40);"
echo "  go"
echo "  exit"
echo ""

oc exec -n $EVTMGR_NAMESPACE -it $EVTMGR_INSTANCE-ncoprimary-0 -- /opt/IBM/tivoli/netcool/omnibus/bin/nco_sql -user root -password $OMNIBUS_ROOT_PASSWORD -server AGG_P

