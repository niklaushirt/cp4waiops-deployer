  oc apply -f ./tools/97_addons/experimental/rook-ceph/crds.yaml
  oc apply -f ./tools/97_addons/experimental/rook-ceph/common.yaml
  oc apply -f ./tools/97_addons/experimental/rook-ceph/operator-openshift.yaml
  oc apply -f ./tools/97_addons/experimental/rook-ceph/cluster.yaml
  #oc apply -f ./tools/97_addons/experimental/rook-ceph/storageclass-block.yaml
  oc patch storageclass rook-cephfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
  oc apply -f ./tools/97_addons/experimental/rook-ceph/filesystem.yaml
  oc apply -f ./tools/97_addons/experimental/rook-ceph/storageclass-fs.yaml
  oc apply -f ./tools/97_addons/experimental/rook-ceph/cluster.yaml
