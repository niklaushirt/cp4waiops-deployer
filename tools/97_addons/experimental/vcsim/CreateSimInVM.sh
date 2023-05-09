wget https://github.com/vmware/govmomi/releases/download/v0.30.4/vcsim_Linux_x86_64.tar.gz 
tar -xvzf vcsim_Linux_x86_64.tar.gz 
sudo mv vcsim /usr/local/bin
wget https://github.com/vmware/govmomi/releases/download/v0.30.4/govc_Linux_x86_64.tar.gz
tar -xvzf govc_Linux_x86_64.tar.gz
sudo mv govc /usr/local/bin

vcsim -l 0.0.0.0:8989 -dc 4 -folder 5 -ds 10 -pod 5 -nsx 4 -pool 10 -app 5 -username=administrator -password=P4ssw0rd -api-version=6.7 
vcsim -l 0.0.0.0:8989 -dc 2 -folder 2 -ds 2 -pod 2 -nsx 1 -pool 2 -app 1 -username=administrator -password=P4ssw0rd -api-version=6.7 

https://91.121.172.228:8989


vcsim -l 0.0.0.0:8989 -dc 0 -api-version=6.7 -username=administrator -password=P4ssw0rd

sleep 60


export GOVC_INSECURE=true
export GOVC_URL=https://administrator:P4ssw0rd@91.121.172.228:8989/sdk

govc datacenter.create DemoDC
govc cluster.create -dc=DemoDC DemoCluster
govc cluster.add -dc=DemoDC -hostname DemoHost_1 -username user -password pass -noverify
govc cluster.add -dc=DemoDC -hostname DemoHost_2 -username user -password pass -noverify
govc cluster.add -dc=DemoDC -hostname DemoHost_3 -username user -password pass -noverify
govc datastore.create -dc=DemoDC -type local -name DemoDataStore_1 -path /tmp /DemoDC/host/DemoCluster
govc datastore.create -dc=DemoDC -type local -name DemoDataStore_2 -path /tmp /DemoDC/host/DemoCluster
govc datastore.create -dc=DemoDC -type local -name DemoDataStore_3 -path /tmp /DemoDC/host/DemoCluster
govc datastore.create -dc=DemoDC -type local -name DemoDataStore_4 -path /tmp /DemoDC/host/DemoCluster
govc vm.create -dc=DemoDC -ds DemoDataStore_1 -cluster DemoCluster DemoVM1
govc vm.create -dc=DemoDC -ds DemoDataStore_2 -cluster DemoCluster DemoVM2
govc vm.create -dc=DemoDC -ds DemoDataStore_3 -cluster DemoCluster DemoVM3
govc vm.create -dc=DemoDC -ds DemoDataStore_4 -cluster DemoCluster DemoVM4
govc vm.create -dc=DemoDC -ds DemoDataStore_1 -cluster DemoCluster DemoVM5
govc vm.create -dc=DemoDC -ds DemoDataStore_2 -cluster DemoCluster DemoVM6
govc vm.create -dc=DemoDC -ds DemoDataStore_3 -cluster DemoCluster DemoVM7
govc vm.create -dc=DemoDC -ds DemoDataStore_4 -cluster DemoCluster DemoVM8
govc vm.create -dc=DemoDC -ds DemoDataStore_1 -cluster DemoCluster RobotShop_mysql
govc vm.create -dc=DemoDC -ds DemoDataStore_2 -cluster DemoCluster RobotShop_payment
govc vm.create -dc=DemoDC -ds DemoDataStore_3 -cluster DemoCluster DemoVM8
govc vm.create -dc=DemoDC -ds DemoDataStore_4 -cluster DemoCluster DemoVM8
govc find -l



https://administrator%40hirt.us:M4g4dino!@hirt.us
https%3A%2F%2Fadministrator%40hirt.us:M4g4dino!%40hirt.us


export GOVC_URL=https://administrator%40hirt.us:M4g4dino%21@hirt.us
govc about


export GOVC_URL="https://administrator%40hirt.us:M4g4dino%21@192.168.10.99"

govc object.save
vcsim -l 0.0.0.0:8989 -api-version=6.7 -username=administrator -password=P4ssw0rd -load=vcsim-192.168.10.99


❯ govc find -l
Folder                       /
Datacenter                   /TinyDatacenter
Datacenter                   /HirtDatacenter
Folder                       /HirtDatacenter/vm
Folder                       /HirtDatacenter/host
Folder                       /HirtDatacenter/datastore
Folder                       /HirtDatacenter/network
Network                      /HirtDatacenter/network/VM Network
Datastore                    /HirtDatacenter/datastore/datastore1
Datastore                    /HirtDatacenter/datastore/Data2
Datastore                    /HirtDatacenter/datastore/Data1
ComputeResource              /HirtDatacenter/host/192.168.10.88
ResourcePool                 /HirtDatacenter/host/192.168.10.88/Resources
HostSystem                   /HirtDatacenter/host/192.168.10.88/192.168.10.88
Folder                       /HirtDatacenter/vm/SYSTEM
Folder                       /HirtDatacenter/vm/TEMPLATES
Folder                       /TinyDatacenter/vm
Folder                       /TinyDatacenter/host
Folder                       /TinyDatacenter/datastore
Folder                       /TinyDatacenter/network
Network                      /TinyDatacenter/network/VM Network
Network                      /TinyDatacenter/network/Management Network
DistributedVirtualPortgroup  /TinyDatacenter/network/DSwitch 1-Management Network
DistributedVirtualPortgroup  /TinyDatacenter/network/DSwitch 1-DVUplinks-1021
DistributedVirtualPortgroup  /TinyDatacenter/network/DSwitch 1-VM Network
DistributedVirtualSwitch     /TinyDatacenter/network/DSwitch 1
Datastore                    /TinyDatacenter/datastore/datastore2
Datastore                    /TinyDatacenter/datastore/datastore1
ClusterComputeResource       /TinyDatacenter/host/TinyCluster
ResourcePool                 /TinyDatacenter/host/TinyCluster/Resources
HostSystem                   /TinyDatacenter/host/TinyCluster/192.168.10.87
HostSystem                   /TinyDatacenter/host/TinyCluster/192.168.10.86
Folder                       /TinyDatacenter/vm/Discovered virtual machine
Folder                       /TinyDatacenter/vm/vCLS
VirtualMachine               /HirtDatacenter/vm/robot-shop-backend
VirtualMachine               /HirtDatacenter/vm/demo1
VirtualMachine               /HirtDatacenter/vm/demo2
VirtualMachine               /HirtDatacenter/vm/robot-shop-mysql
VirtualMachine               /HirtDatacenter/vm/SYSTEM/VMware vCenter Server
VirtualMachine               /HirtDatacenter/vm/TEMPLATES/ubuntutemplate
VirtualMachine               /TinyDatacenter/vm/demo3
VirtualMachine               /TinyDatacenter/vm/vCLS/vCLS-72810bb2-abfc-47a8-9740-d79353ef139a
VirtualMachine               /TinyDatacenter/vm/ubuntutemplate
VirtualMachine               /TinyDatacenter/vm/vCLS/vCLS-f6d81ea3-2419-4cad-997b-4c566a0da209
❯ govc about

FullName:     VMware vCenter Server 7.0.3 build-18700403
Name:         VMware vCenter Server
Vendor:       VMware, Inc.
Version:      7.0.3
Build:        18700403
OS type:      linux-x64
API type:     VirtualCenter
API version:  7.0.3.0
Product ID:   vpx
UUID:         8a972364-3515-4f7a-b38c-91bc7b19ffb4