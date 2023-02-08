
oc create ns rook-ceph
oc apply -f common.yaml
oc apply -f crds.yaml
oc apply -f operator-openshift.yaml

while true
do
    notready=$(oc -n rook-ceph get pods| grep '0/' |grep -v "Completed"|grep -c "")
    if [[ $notready -lt 1 ]] then
        break
    fi
    echo " 🟠 Not ready"
    sleep 15
done


oc apply -f rocks-cluster.yaml

oc apply -f pool.yaml

oc apply -f storageclass.yaml
oc apply -f filesystem.yaml
oc apply -f storageclass-fs.yaml

oc patch storageclass rook-cephfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'


oc get secret rook-ceph-dashboard-password -n rook-ceph -o jsonpath='{ .data.password }' | base64 --decode


while true
do
    notready=$(oc -n rook-ceph get pods| grep '0/' |grep -v "Completed"|grep -c "")
    ready=$(oc -n rook-ceph get pods| grep -v '0/' |grep -v "Completed"|grep -c "")
    if [[ $ready -gt 40 ]] then
        break
    fi
    echo " 🟠 Not ready $ready"
    sleep 15
done

