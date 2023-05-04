
INSTALL_POD=$(oc get po -n cp4waiops-installer|grep install|awk '{print$1}')
FILE_PATH="/cp4waiops-deployer/install_CP4WAIOps.log"

oc cp -n cp4waiops-installer ${INSTALL_POD}:/cp4waiops-deployer/install_CP4WAIOps.log ./install_CP4WAIOps.log 
oc cp -n cp4waiops-installer ${INSTALL_POD}:/cp4waiops-deployer/install_CP4WAIOpsDemoContent.log ./install_CP4WAIOpsDemoContent.log 
oc cp -n cp4waiops-installer ${INSTALL_POD}:/cp4waiops-deployer/install_EventManager.log ./install_EventManager.log 
oc cp -n cp4waiops-installer ${INSTALL_POD}:/cp4waiops-deployer/install_InfrastructureManagement.log ./install_InfrastructureManagement.log 
oc cp -n cp4waiops-installer ${INSTALL_POD}:/cp4waiops-deployer/install_ELK.log ./install_ELK.log 
oc cp -n cp4waiops-installer ${INSTALL_POD}:/cp4waiops-deployer/install_Turbonomic.log ./install_Turbonomic.log 

oc logs -n cp4waiops-installer -f $INSTALL_POD > install.log
