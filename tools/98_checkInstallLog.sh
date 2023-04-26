num_failed=$(cat /tmp/ansible.log|grep "failed=[1-9]"|wc -l)
if [ $num_failed -gt 0 ];
then
echo "ERROR in Logs"
echo ""
echo "*****************************************************************************************************************************"
echo " ❌ FATAL ERROR: Please check the Installation Logs"
echo "*****************************************************************************************************************************"

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
EOF
else
echo ""
echo "*****************************************************************************************************************************"
echo " ✅ DONE"
echo "*****************************************************************************************************************************"
fi
