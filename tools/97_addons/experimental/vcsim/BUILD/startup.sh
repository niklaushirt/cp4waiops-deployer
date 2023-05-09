echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "       ________  __  ___     ___    ________       "
echo "      /  _/ __ )/  |/  /    /   |  /  _/ __ \____  _____"
echo "      / // __  / /|_/ /    / /| |  / // / / / __ \/ ___/"
echo "    _/ // /_/ / /  / /    / ___ |_/ // /_/ / /_/ (__  ) "
echo "   /___/_____/_/  /_/    /_/  |_/___/\____/ .___/____/  "
echo "                                         /_/"
echo ""
echo "*****************************************************************************************************************************"
echo " 🐥 CloudPak for Watson AIOPs - vCenter Simulator"
echo "*****************************************************************************************************************************"
echo "  "
echo ""
echo ""


vcsim -l 0.0.0.0:8989 -dc 10 -folder 10 -ds 20 -pod 10 -nsx 20 -pool 20 -app 10 -tls=false &
#export GOVC_URL=http://user:pass@10.130.5.55:8989/sdk

export GOVC_URL=http://$SIM_USER:$SIM_PASS@0.0.0.0:8989/sdk

sleep 120

govc find -l

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



echo "*****************************************************************************************************************************"
echo " ✅ DONE"
echo "*****************************************************************************************************************************"

while true
do
    sleep 60000                           
done
