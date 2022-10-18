  oc delete -f ./ansible/templates/rook-ceph/crds.yaml
  oc delete -f ./ansible/templates/rook-ceph/common.yaml
  oc delete -f ./ansible/templates/rook-ceph/operator-openshift.yaml
  oc delete -f ./ansible/templates/rook-ceph/cluster.yaml
  #oc delete -f ./ansible/templates/rook-ceph/storageclass-block.yaml
  oc patch storageclass rook-cephfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
  oc delete -f ./ansible/templates/rook-ceph/filesystem.yaml
  oc delete -f ./ansible/templates/rook-ceph/storageclass-fs.yaml
  oc delete -f ./ansible/templates/rook-ceph/cluster.yaml






  #oc delete -f ./ansible/templates/rook-ceph/storageclass-block.yaml
  oc patch storageclass rook-cephfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
  oc delete -f ./ansible/templates/rook-ceph/filesystem.yaml
  oc delete -f ./ansible/templates/rook-ceph/storageclass-fs.yaml
  oc delete -f ./ansible/templates/rook-ceph/cluster.yaml
  oc delete -f ./ansible/templates/rook-ceph/operator-openshift.yaml
  oc delete -f ./ansible/templates/rook-ceph/crds.yaml
  oc delete -f ./ansible/templates/rook-ceph/lvm-installation.yml
  oc delete -f ./ansible/templates/rook-ceph/common.yaml



  