echo "***************************************************************************************************************************************************"
echo " 🚀  Clean for GIT Push"
echo "***************************************************************************************************************************************************"


export gitCommitMessage=$(date +%Y%m%d-%H%M)

echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🗄️  Make local copy ../ARCHIVE/cloud-pak-deployer-$gitCommitMessage"
echo "--------------------------------------------------------------------------------------------------------------------------------"

mkdir -p ../ARCHIVE/cloud-pak-deployer-$gitCommitMessage

cp -r ../cloud-pak-deployer/* ../ARCHIVE/cloud-pak-deployer-$gitCommitMessage
cp .gitignore ../ARCHIVE/cloud-pak-deployer-$gitCommitMessage
 

rm -r ../cloud-pak-deployer/automation-roles/50-install-cloud-pak/cp4waiops/
cp -r ./ansible/roles/ ../cloud-pak-deployer/automation-roles/50-install-cloud-pak/cp4waiops/

cd ../cloud-pak-deployer/automation-roles/50-install-cloud-pak/cp4waiops/

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

rm -f ./install_*.log* 
rm -f ./LOGINS* 

cd -
cd ../cloud-pak-deployer/

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

cd -

