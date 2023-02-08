---------------------------------------------------------------
# 16 ServiceMesh
---------------------------------------------------------------

## 16.1 Installing ServiceMesh

Use Option 🐥`24` in Easy Install to install a `ServiceMesh ` instance

## 16.2 Manually installing ServiceMesh

You can easily install ServiceMesh/Istio into the same cluster as CP4WAIOPS.

This will instrument the RobotShop Application at the same time.

1. Launch

	```bash
	ansible-playbook ./ansible/29_addons-install-servicemesh.yaml	
	```
	
2. Wait for the pods to come up
3. You can get the different URLs (RobotShop, Kibana, Grafana, Jaeger) by launching:

	```bash
	./tools/20_get_logins.sh > my_credentials.txt
	```


<div style="page-break-after: always;"></div>
