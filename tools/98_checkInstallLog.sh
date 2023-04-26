num_failed=$(cat /tmp/ansible.log|grep "failed=[1-9]"|wc -l)
if [ $num_failed -gt 0 ];
then
echo "ERROR in Logs"
echo ""
echo "*****************************************************************************************************************************"
echo " ❌ FATAL ERROR: Please check the Installation Logs"
echo "*****************************************************************************************************************************"
OPENSHIFT_ROUTE=$(oc get route -n openshift-console console -o jsonpath={.spec.host})
INSTALL_POD=$(oc get po -n cp4waiops-installer -l app=cp4waiops-installer --no-headers|grep "1/1"|awk '{print$1}')


oc delete ConsoleNotification --all
cat <<EOF | oc apply -f -
apiVersion: console.openshift.io/v1
kind: ConsoleNotification
metadata:
    name: cp4waiops-notification-main
spec:
    backgroundColor: '#9a0000'
    color: '#fff'
    location: "BannerTop"
    text: "❌ FATAL ERROR: Please check the Installation Logs"
    link:
        href: "https://$OPENSHIFT_ROUTE/k8s/ns/cp4waiops-installer/pods/$INSTALL_POD/logs"
        text: Open Logs

EOF
else
echo ""
echo "*****************************************************************************************************************************"
echo " ✅ DONE"
echo "*****************************************************************************************************************************"
fi








