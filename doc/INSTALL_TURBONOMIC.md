-----------------------------------------------------------------------------------
# 13 Installing Turbonomic
---------------------------------------------------------------

## 13.1 Installing Turbonomic

Use Option 🐥`21` in Easy Install to install a `Turbonomic` instance

## 13.2 Manually Installing Turbonomic

Only do this if you don't want to use 🐥 Easy Install


You can install Turbonomic into the same cluster as CP4WAIOPS.

**❗ You need a license in order to use Turbonomic.**

1. Launch

	```bash
	ansible-playbook ./ansible/10_cp4waiops-turbonomic-install.yaml
	```
2. Wait for the pods to come up
3. Open Turbonomic
4. Enter the license
5. Add the default target (local Kubernetes cluster is already instrumented with `kubeturbo`)

It can take several hours for the Supply Chain to populate, so be patient.

<div style="page-break-after: always;"></div>
