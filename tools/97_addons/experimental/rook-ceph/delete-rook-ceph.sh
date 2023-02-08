  #oc delete -f ./tools/97_addons/experimental/rook-ceph/storageclass-block.yaml
  oc patch storageclass rook-cephfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
  oc delete -f ./tools/97_addons/experimental/rook-ceph/filesystem.yaml
  oc delete -f ./tools/97_addons/experimental/rook-ceph/storageclass-fs.yaml
  oc delete -f ./tools/97_addons/experimental/rook-ceph/cluster.yaml
  oc delete -f ./tools/97_addons/experimental/rook-ceph/operator-openshift.yaml
  oc delete -f ./tools/97_addons/experimental/rook-ceph/crds.yaml
  oc delete -f ./tools/97_addons/experimental/rook-ceph/lvm-installation.yml
  oc delete -f ./tools/97_addons/experimental/rook-ceph/common.yaml
