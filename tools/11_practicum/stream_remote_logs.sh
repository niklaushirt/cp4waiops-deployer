
INSTALL_POD=$(oc get po -n default|grep install|awk '{print$1}')
oc logs -n default -f $INSTALL_POD