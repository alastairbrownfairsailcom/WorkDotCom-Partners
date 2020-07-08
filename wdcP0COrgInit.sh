#!/bin/bash

function get_user_choice_yesno() {
    printf "$1"
    while :; do
        read response
        case "$response" in
            y|Y) return 0;;
            n|N) return 1;;
            *) printf "Invalid response." ;;
        esac
    done
}

DURATION='7'
while getopts ":hu:d:" option
do
    case $option in
        h) usage;;
        u) scratch_org_user_alias=${OPTARG};;
        d) DURATION=${OPTARG};;
        *) usage;;
    esac
done

echo Scratch Org alias is $scratch_org_user_alias

if echo $GIT_CLONE_METHOD | grep -iqF SSH
then
    GIT_USE_SSH=true
elif echo $GIT_CLONE_METHOD | grep -iqF HTTPS
then
    unset GIT_USE_SSH
fi

if [ -z scratch_org_user_alias ]; then
    read -p "What scratch org alias do you want to use: " scratch_org_user_alias
fi

#create scratch org
sfdx force:org:create -f config/project-scratch-def.json  -a "$scratch_org_user_alias" -s -d $DURATION

#Command Center managed package
sfdx force:package:install -p 04t5w000005dcR9 -w 50 -u "$scratch_org_user_alias"

#Command Center un-managed package
sfdx force:package:install -p 04t5w000005au3o -w 50 -u "$scratch_org_user_alias"

#Install un-managed packages from Appiphony for their sample Building Management App
# https://github.com/appiphony/building-management-app
#sfdx force:package:install -p 04t5w000004Lpu3 -w 50 -u "$scratch_org_user_alias"
#sfdx force:package:install -p 04t4S000000hXF3 -w 50 -u "$scratch_org_user_alias"

#Perm sets have some fields from managed package so package needs to be installed first

#Source code has a permission set with workplace license
#This will auto assign Workplace license to the user
sfdx force:source:push -u "$scratch_org_user_alias"

#For deploy to non-scratch org
#sfdx force:source:deploy -m ApexClass,CustomObject,LightningComponentBundle,CustomField,StaticResource,SecuritySettings,ApexTrigger,CustomApplication,ContentAsset,FlexiPage,CustomTab,CustomObject -u "$scratch_org_user_alias"

#Perm sets have some fields from managed package so package needs to be installed first
sfdx force:user:permset:assign -n Workplace_Command_Center_Standard_PermSet_Admin_Full_Access_Cloned -u "$scratch_org_user_alias"

#Permission Sets
#Workplace Admin
sfdx force:user:permset:assign -n b2w_Admin -u "$scratch_org_user_alias"
#Workplace Global Operations
sfdx force:user:permset:assign -n b2w_GlobalOperations -u "$scratch_org_user_alias"
#Workplace Operations
sfdx force:user:permset:assign -n b2w_Operations -u "$scratch_org_user_alias"

#All AddOn Permission Sets
sfdx force:user:permset:assign -n b2w_OperationsExecutiveAddOn -u "$scratch_org_user_alias"
sfdx force:user:permset:assign -n b2w_Workplace_Operations_Addon -u "$scratch_org_user_alias"
sfdx force:user:permset:assign -n b2w_Workplace_Command_Center_Access -u "$scratch_org_user_alias"
sfdx force:user:permset:assign -n b2w_AdminAddOn -u "$scratch_org_user_alias"
sfdx force:user:permset:assign -n b2w_GlobalOperationsExecutiveAddOn -u "$scratch_org_user_alias"
sfdx force:user:permset:assign -n b2w_GlobalOperationsAddOn -u "$scratch_org_user_alias"

#Custom Permission set to grant access to Location.Status__c that is in managed package
sfdx force:user:permset:assign -n Workplace_Command_Center_Location_Admin -u "$scratch_org_user_alias"

#Appiphony app permission set
#sfdx force:user:permset:assign -n  Command_Center_Appiphony_App_Admin -u "$scratch_org_user_alias"

#Location.Status__c is NOT included in this data set
#sfdx force:data:tree:import -p ./testdata/InternalOrganizationUnit-Employee-EmployeeCrisisAssessment-plan.json -u "$scratch_org_user_alias"

#sfdx force:apex:execute -f ./dx-utils/apex-scripts/updateLocationVisitorAddressId.apex -u "$scratch_org_user_alias"

#Post install file from Appiphony app
#sfdx force:apex:execute -f ./dx-utils/apex-scripts/convertData.apex -u "$scratch_org_user_alias"

#Extra steps like resetting password for scartch org (if needed)
#sfdx force:apex:execute -f ./dx-utils/apex-scripts/demo-setup.apex -u "$scratch_org_user_alias"

#sfdx force:org:open -u "$scratch_org_user_alias"