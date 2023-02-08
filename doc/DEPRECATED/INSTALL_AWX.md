---------------------------------------------------------------
# 17 AWX
---------------------------------------------------------------

## 17.1 Installing AWX

Use Option 🐥`23` in Easy Install to install a `AWX ` instance

![K8s CNI](./pics/install-evtmanager_awx.png)


## 17.2 Manually installing AWX


You can easily install AWX (OpenSource Ansible Tower) into the same cluster as CP4WAIOPS.

1. Launch

	```bash
	ansible-playbook ./ansible/23_addons-install-awx.yaml	
	```
	
2. Wait for the pods to come up
3. You can get the URLs and access credentials by launching:

	```bash
	./tools/20_get_logins.sh > my_credentials.txt
	```



<div style="page-break-after: always;"></div>
