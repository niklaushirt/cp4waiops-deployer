
INSTALL_POD=$(oc get po -n default|grep install|awk '{print$1}')
FILE_PATH="/cp4waiops-deployer/install_AIManager.log"

oc cp -n default ${INSTALL_POD}:/cp4waiops-deployer/install_AIManager.log ./install_AIManager.log 
oc cp -n default ${INSTALL_POD}:/cp4waiops-deployer/install_AIManagerDemoContent.log ./install_AIManagerDemoContent.log 
oc cp -n default ${INSTALL_POD}:/cp4waiops-deployer/install_EventManager.log ./install_EventManager.log 
oc cp -n default ${INSTALL_POD}:/cp4waiops-deployer/install_InfrastructureManagement.log ./install_InfrastructureManagement.log 
oc cp -n default ${INSTALL_POD}:/cp4waiops-deployer/install_ELK.log ./install_ELK.log 
oc cp -n default ${INSTALL_POD}:/cp4waiops-deployer/install_Turbonomic.log ./install_Turbonomic.log 

oc logs -n default -f $INSTALL_POD > install.log
