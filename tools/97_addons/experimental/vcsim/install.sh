https://github.com/vmware/govmomi/blob/main/govc/README.md

wget "https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz"
tar -xvzf govc_Darwin_arm64.tar.gz
sudo mv govc /usr/local/bin



wget -O vcsim.tar.gz https://github.com/vmware/govmomi/releases/latest/download/vcsim_$(uname -s)_$(uname -m).tar.gz
tar -xvzf vcsim.tar.gz
sudo mv vcsim /usr/local/bin




# ignore self-signed certificate warnings
export GOVC_INSECURE=true

# use default credentials and local port-forwarding address
$ export GOVC_URL=https://user:pass@127.0.0.1:8989/sdk

govc find -l
# list vcsim inventory
$ govc ls
/DC0/vm
/DC0/host
/DC0/datastore
/DC0/network



govc events -f
govc vm.power -off /DC0/vm/DC0_C0_RP0_VM1



vcsim  -l 0.0.0.0:8989 -dc 0 -tls=false

vcsim -l 0.0.0.0:8989 -dc 10 -folder 10 -ds 20 -pod 10 -nsx 20 -pool 20 -app 10 -tls=false

vcsim -l 0.0.0.0:8989  -tls=false -load=vcsim-192.168.10.99

vcsim -l 0.0.0.0:8989 -load=vcsim-192.168.10.99



govc tree -k


govc datacenter.create DemoDC
govc cluster.create DemoCluster
govc cluster.add -hostname DemoHost_1 -username user -password pass -noverify
govc cluster.add -hostname DemoHost_2 -username user -password pass -noverify
govc cluster.add -hostname DemoHost_3 -username user -password pass -noverify
govc datastore.create -type local -name DemoDataStore_1 -path /tmp /DemoDC/host/DemoCluster
govc datastore.create -type local -name DemoDataStore_2 -path /tmp /DemoDC/host/DemoCluster
govc datastore.create -type local -name DemoDataStore_3 -path /tmp /DemoDC/host/DemoCluster
govc datastore.create -type local -name DemoDataStore_4 -path /tmp /DemoDC/host/DemoCluster
govc vm.create -ds DemoDataStore_1 -cluster DemoCluster DemoVM1
govc vm.create -ds DemoDataStore_2 -cluster DemoCluster DemoVM2
govc vm.create -ds DemoDataStore_3 -cluster DemoCluster DemoVM3
govc vm.create -ds DemoDataStore_4 -cluster DemoCluster DemoVM4
govc vm.create -ds DemoDataStore_1 -cluster DemoCluster DemoVM5
govc vm.create -ds DemoDataStore_2 -cluster DemoCluster DemoVM6
govc vm.create -ds DemoDataStore_3 -cluster DemoCluster DemoVM7
govc vm.create -ds DemoDataStore_4 -cluster DemoCluster DemoVM8
govc vm.create -ds DemoDataStore_1 -cluster DemoCluster RobotShop_mysql
govc vm.create -ds DemoDataStore_2 -cluster DemoCluster RobotShop_payment
govc vm.create -ds DemoDataStore_3 -cluster DemoCluster DemoVM8
govc vm.create -ds DemoDataStore_4 -cluster DemoCluster DemoVM8
govc find -l

govc object.save


Folder                  /
Datacenter              /godc
Folder                  /godc/vm
VirtualMachine          /godc/vm/govm1
Folder                  /godc/host
ClusterComputeResource  /godc/host/gocluster
HostSystem              /godc/host/gocluster/gohost1
ResourcePool            /godc/host/gocluster/Resources
Folder                  /godc/datastore
Datastore               /godc/datastore/gostore
Folder                  /godc/network
Network                 /godc/network/VM Network

govc ls


govc find -l

/demodc/host/democluster

# extract govc binary to /usr/local/bin
# note: the "tar" command must run with root permissions
curl -L -o - "https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz" | tar -C /usr/local/bin -xvzf - govc


vcsim -dc 2 -folder 1 -ds 4 -pod 1 -nsx 2 -pool 2 -app 1