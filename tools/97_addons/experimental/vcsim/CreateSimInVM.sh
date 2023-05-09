wget https://github.com/vmware/govmomi/releases/download/v0.30.4/vcsim_Linux_x86_64.tar.gz 
tar -xvzf vcsim_Linux_x86_64.tar.gz 
sudo mv vcsim /usr/local/bin
wget https://github.com/vmware/govmomi/releases/download/v0.30.4/govc_Linux_x86_64.tar.gz
tar -xvzf govc_Linux_x86_64.tar.gz
sudo mv govc /usr/local/bin

vcsim -l 0.0.0.0:8989 -dc 4 -folder 5 -ds 10 -pod 5 -nsx 4 -pool 10 -app 5 -username=administrator -password=P4ssw0rd -api-version=6.7 
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