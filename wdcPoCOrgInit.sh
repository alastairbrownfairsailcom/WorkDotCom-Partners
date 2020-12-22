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

function usage() {
    echo "Usage: $0 [-u] [-d] [-n] [-h]"
    echo "Options:"
    echo "-u <alias for scratch org>"
    echo "-d <duration of scratch org> [defaults to 7]"
    echo "-n <namespace> [defaults to no namespace]"
    echo "-h help"
    exit 1
}


DURATION='7'
NAMESPACE=
update_namespace="n"
namespaceParam=" --nonamespace"
CONFIG_OVERRIDES=


while getopts ":hu:d:n:" option
do
    case $option in
        h) usage;;
        u) scratch_org_user_alias=${OPTARG};;
        d) DURATION=${OPTARG};;
        n) NAMESPACE=${OPTARG};;
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

if [ -z NAMESPACE ]; then
    echo no namespace
else
    echo using namespace $NAMESPACE
    update_namespace="y"
    namespaceParam=""
    CONFIG_OVERRIDES="namespace="$NAMESPACE
fi


#create scratch org
sfdx force:org:create -f config/project-scratch-def.json  -a "$scratch_org_user_alias" -s -d $DURATION $namespaceParam $CONFIG_OVERRIDES

#Command Center managed package
#v5.3
#Get new version from http://work.force.com/workplacecommandcenter
sfdx force:package:install -p 04t5w000005CqbhAAC -w 50 -u "$scratch_org_user_alias"

#Command Center un-managed package
#Get new version from http://work.force.com/employeewellnesssurveysamples
#v3.1
sfdx force:package:install -p 04t5w000005dhbI -w 50 -u "$scratch_org_user_alias"






#Install un-managed packages from Appiphony for their sample Building Management App
# https://github.com/appiphony/building-management-app
#sfdx force:package:install -p 04t5w000004Lpu3 -w 50 -u "$scratch_org_user_alias"
#sfdx force:package:install -p 04t4S000000hXF3 -w 50 -u "$scratch_org_user_alias"

#Perm sets have some fields from managed package so package needs to be installed first

#Source code has a permission set with workplace license
#This will auto assign Workplace license to the user
sfdx force:source:push -u "$scratch_org_user_alias" -u "$scratch_org_user_alias"

#For deploy to non-scratch org
#sfdx force:source:deploy -m ApexClass,CustomObject,LightningComponentBundle,CustomField,StaticResource,SecuritySettings,ApexTrigger,CustomApplication,ContentAsset,FlexiPage,CustomTab,CustomObject -u "$scratch_org_user_alias"

#Perm sets have some fields from managed package so package needs to be installed first
sfdx force:user:permset:assign -n Workplace_Command_Center_Standard_PermSet_Admin_Full_Access_Cloned -u "$scratch_org_user_alias"

#Custom Permission set to grant access to Location.Status__c that is in managed package
sfdx force:user:permset:assign -n Workplace_Command_Center_Admin_Custom -u "$scratch_org_user_alias"

#Permission Sets
#Workplace Admin
sfdx force:user:permset:assign -n b2w_Admin -u "$scratch_org_user_alias"
#Workplace Global Operations Executive
sfdx force:user:permset:assign -n b2w_OperationsExecutive -u "$scratch_org_user_alias"
#Workplace Operations
sfdx force:user:permset:assign -n b2w_Operations -u "$scratch_org_user_alias"

#All AddOn Permission Sets
#sfdx force:user:permset:assign -n b2w_OperationsExecutiveAddOn -u "$scratch_org_user_alias"
#sfdx force:user:permset:assign -n b2w_Workplace_Operations_Addon -u "$scratch_org_user_alias"
#sfdx force:user:permset:assign -n b2w_Workplace_Command_Center_Access -u "$scratch_org_user_alias"
#sfdx force:user:permset:assign -n b2w_AdminAddOn -u "$scratch_org_user_alias"
#sfdx force:user:permset:assign -n b2w_GlobalOperationsExecutiveAddOn -u "$scratch_org_user_alias"
#sfdx force:user:permset:assign -n b2w_GlobalOperationsAddOn -u "$scratch_org_user_alias"

#sfdx force:org:open -u "$scratch_org_user_alias"