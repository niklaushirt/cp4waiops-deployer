#!/bin/bash
echo "*****************************************************************************************************************************"
echo " 🐥 CloudPak for Watson AIOPs - Install AWX"
echo "*****************************************************************************************************************************"
echo "  "
echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Clusterrole binding"
oc create clusterrolebinding awx-default --clusterrole=cluster-admin --serviceaccount=awx:default| sed 's/^/         /'

echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create AWX Operator"
oc apply -f ./tools/09_AWX-Installer/awx/operator-install.yaml| sed 's/^/         /'

echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create AWX Instance"
oc apply -f ./tools/09_AWX-Installer/awx/awx-deploy-cr.yml| sed 's/^/         /'

echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🕦  Wait for AWX pods ready"
while [ `oc get pods -n awx| grep postgres|grep 1/1 | wc -l| tr -d ' '` -lt 1 ]
do
      echo "        AWX pods not ready yet. Waiting 15 seconds"
      sleep 15
done
echo "       ✅  OK: AWX pods ready"

export AWX_ROUTE=$(oc get route -n awx awx -o jsonpath={.spec.host})
export AWX_URL=$(echo "https://$AWX_ROUTE")


echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🕦  Wait for AWX being ready"
while : ; do
      READY=$(curl -s $AWX_URL|grep "Application is not available")
      if [[  $READY  =~ "Application is not available" ]]; then
            echo "        AWX not ready yet. Waiting 15 seconds"
            sleep 30
      else
            break
      fi
done
echo "       ✅  OK: AWX ready"

echo ""
echo ""
echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀 AWX Access"
echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "  "  
echo "        📥 AWX :"
echo ""
echo "            🌏 URL:      $AWX_URL"
echo "            🧑 User:     admin"
echo "            🔐 Password: $(oc -n awx get secret awx-admin-password -o jsonpath='{.data.password}' | base64 --decode && echo)"
echo "  "
echo "  "  

echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""