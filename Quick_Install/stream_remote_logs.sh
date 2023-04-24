
INSTALL_POD=$(oc get po -n cp4waiops-installer|grep install|awk '{print$1}')
oc logs -n cp4waiops-installer -f $INSTALL_POD