num_failed=$(cat /tmp/ansible.log|grep "failed=[1-9]"|wc -l)
if [ $num_failed -gt 0 ];
then
echo "ERROR in Logs"
echo ""
echo "*****************************************************************************************************************************"
echo " ❌ FATAL ERROR: Please check the Installation Logs"
echo "*****************************************************************************************************************************"
OPENSHIFT_ROUTE=$(oc get route -n openshift-console console -o jsonpath={.spec.host})
INSTALL_POD=$(oc get po -n cp4waiops-installer -l app=cp4waiops-installer --no-headers|grep "Running"|awk '{print$1}')


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
oc delete ConsoleNotification --all>/dev/null 2>/dev/null
export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
export appURL=$(oc get routes -n $WAIOPS_NAMESPACE-demo-ui $WAIOPS_NAMESPACE-demo-ui  -o jsonpath="{['spec']['host']}")|| true
export DEMO_PWD=$(oc get cm -n $WAIOPS_NAMESPACE-demo-ui cp4waiops-demo-ui-config -o jsonpath='{.data.TOKEN}')
cat <<EOF | oc apply -f -
apiVersion: console.openshift.io/v1
kind: ConsoleNotification
metadata:
    name: cp4waiops-notification-main
spec:
    backgroundColor: '#009a00'
    color: '#fff'
    link:
        href: "https://$appURL"
        text: DemoUI
    location: BannerTop
    text: "✅ CP4WAIOPS is installed in this cluster. 🚀 Access the DemoUI with Access Token '$DEMO_PWD' here:"
EOF

echo ""
echo " ✅ CP4WAIOPS is installed in this cluster."


echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🔎 Check Installation Consitency"
./91_check_install_short.sh
echo ""
echo ""
echo ""
echo ""



# num_failed=$(cat /tmp/ansible.log|grep "error"|wc -l)
# if [ $num_failed -gt 0 ];
# then
# OPENSHIFT_ROUTE=$(oc get route -n openshift-console console -o jsonpath={.spec.host})
# INSTALL_POD=$(oc get po -n cp4waiops-installer -l app=cp4waiops-installer --no-headers|grep "Running"|awk '{print$1}')

# cat <<EOF | oc apply -f -
# apiVersion: console.openshift.io/v1
# kind: ConsoleNotification
# metadata:
#     name: cp4waiops-notification-log
# spec:
#     backgroundColor: '#ffd500'
#     color: '#000'
#     location: "BannerTop"
#     text: "❗ There were some non-critical errors: Please check the Installation Logs"
#     link:
#         href: "https://$OPENSHIFT_ROUTE/k8s/ns/cp4waiops-installer/pods/$INSTALL_POD/logs"
#         text: Open Logs
# EOF
# fi
fi









