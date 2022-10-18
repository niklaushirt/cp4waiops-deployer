## 2.6 Install Event Manager 

![K8s CNI](./pics/install-evtmanager.png)

### 2.6.1 Start Event Manager Installation 

Use Option 🐥`02` in Easy Install to install a base `Event Manager` instance

or run:

```bash
ansible-playbook ./ansible/04_cp4waiops-eventmanager-install.yaml -e CP_ENTITLEMENT_KEY=<REGISTRY_TOKEN> 
```

### 2.6.2 Configure Event Manager 

There are some minimal configurations that you have to do to use the demo system and that are covered by the 🅱️ flow below:

###  🚀 Start here [EventManager Configuration](./CONF_EVENT_MANAGER.md)

<div style="page-break-after: always;"></div>





