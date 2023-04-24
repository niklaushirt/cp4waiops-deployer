
INSTALL_POD=$(oc get po -n cp4waiops-installation|grep install|awk '{print$1}')
oc logs -n cp4waiops-installation -f $INSTALL_POD