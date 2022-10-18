echo "***************************************************************************************************************************************************"
echo " 🚀  Clean for GIT Push"
echo "***************************************************************************************************************************************************"


export gitCommitMessage=$(date +%Y%m%d-%H%M)

echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🗄️  Make local copy ../ARCHIVE/aiops-ansible-$gitCommitMessage"
echo "--------------------------------------------------------------------------------------------------------------------------------"

mkdir -p ../ARCHIVE/aiops-ansible-next-$gitCommitMessage

cp -r * ../ARCHIVE/aiops-ansible-next-$gitCommitMessage
cp .gitignore ../ARCHIVE/aiops-ansible-next-$gitCommitMessage
 

echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Find File Copies"
echo "--------------------------------------------------------------------------------------------------------------------------------"
find . -name '*copy*' -type f | grep -v DO_NOT_DELIVER
find . -name '*test*' -type f | grep -v DO_NOT_DELIVER
find . -name '*tmp*' -type f | grep -v DO_NOT_DELIVER


echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Deleting large and sensitive files"
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "      ❎  Deleting DS_Store"
find . -name '.DS_Store' -type f -delete
echo "      ❎  Deleting Certificate Files"
find . -name 'cert.*' -type f -delete
echo "      ❎  Deleting Certificate Authority Files"
find . -name 'ca.*' -type f -delete
echo "      ❎  Deleting TLS Secrets"
find . -name 'openshift-tls-secret*' -type f -delete
echo "      ❎  Deleting JSON Log Files Kafka"
find . -name '*.json' -type f -size +1000000k -delete
echo "      ❎  Deleting JSON Log Files Elastic"
find . -name '*-logtrain.json' -type f -size +10000k -delete
echo "      ❎  Deleting Conflict Files"
find . -name '*2021_Conflict*' -type f -delete
echo "      ❎  Deleting node_modules"
find . -name 'node_modules' -type d  -exec rm -rf {} \;
echo "      ❎  Deleting files > 250MB"
find . -type f -size +250M -delete
echo "      ❎  Remove Downloaded Training Data"
rm -r -f ./tools/02_training/TRAINING_FILES
echo "      ❎  Remove Pull Secrets"
rm pull-secret-backup.yaml>/dev/null 2>/dev/null
rm temp-ibm-entitlement-key.yaml>/dev/null 2>/dev/null
rm temp-pull-secret.yaml>/dev/null 2>/dev/null


echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Remove Keys"
echo "--------------------------------------------------------------------------------------------------------------------------------"
cp ./tools/98_reset/templates/13_reset-slack.sh ./tools/98_reset/13_reset-slack.sh
cp ./tools/98_reset/templates/14_reset-slack-changerisk.sh ./tools/98_reset/14_reset-slack-changerisk.sh
cp ./tools/98_reset/templates/incident_robotshop-noi.sh ./tools/01_demo/incident_robotshop-noi.sh
mkdir -p ./DO_NOT_DELIVER/LOGINS
mkdir -p ./DO_NOT_DELIVER/LOGS/LOGS-$gitCommitMessage
mv -f ./LOGINS.txt ./DO_NOT_DELIVER/LOGINS/LOGINS-$gitCommitMessage.txt
mv -f ./install_*.log ./DO_NOT_DELIVER/LOGS/LOGS-$gitCommitMessage/
mv -f ./install_*.log* ./DO_NOT_DELIVER/LOGS/LOGS-$gitCommitMessage/
mv -f ./install*.log* ./DO_NOT_DELIVER/LOGS/LOGS-$gitCommitMessage/

rm -f ./install_*.log* 
rm -f ./LOGINS* 



echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Remove Training Files"
echo "--------------------------------------------------------------------------------------------------------------------------------"
rm -fr ./tools/02_training/TRAINING_FILES


echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Remove Temp Files"
echo "--------------------------------------------------------------------------------------------------------------------------------"
rm -f ./reset/tmp_connection.json
rm -f ./reset/test.json
rm -f ./demo/external-tls-secret.yaml
rm -f ./demo/iaf-system-backup.yaml
rm -f ./external-tls-secret.yaml
rm -f ./iaf-system-backup.yaml

export actBranch=$(git branch | tr -d '* ')
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Update Branch to $actBranch"
echo "--------------------------------------------------------------------------------------------------------------------------------"



read -p " ❗❓ do you want to check-in the GitHub branch $actBranch with message $gitCommitMessage? [y,N] " DO_COMM
if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
    echo "   ✅ Ok, committing..."
    git add . && git commit -m $gitCommitMessage 
else
    echo "    ⚠️  Skipping"
fi

read -p " ❗❓ Does this look OK? [y,N] " DO_COMM
if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
    echo "   ✅ Ok, checking in..."
    git push
else
    echo "    ⚠️  Skipping"
fi



