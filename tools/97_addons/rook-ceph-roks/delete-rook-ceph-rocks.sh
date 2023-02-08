oc patch storageclass rook-cephfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

oc delete -f storageclass-fs.yaml
oc delete -f filesystem.yaml
oc delete -f storageclass.yaml
oc delete -f pool.yaml
oc delete -f rocks-cluster.yaml
oc delete -f operator-openshift.yaml
oc delete -f crds.yaml
oc delete -f common.yaml



oc get secret rook-ceph-dashboard-password -n rook-ceph -o jsonpath='{ .data.password }' | base64 --decode
