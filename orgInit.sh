sfdx force:org:create -f config/project-scratch-def.json  -a WDCScratchOrg -s

sfdx force:source:push

sfdx force:user:permset:assign -n Workplace_Command_Center_Standard_PermSet_Admin_Full_Access_Cloned

#Command Center managed package
sfdx force:package:install -p 04t5w000004iyOd -k astrolovescodey -w 50

#Command Center un-managed package
sfdx force:package:install -p 04t5w000005Is02 -k astrolovescodey -w 50

#Location.Status__c is NOT included in this data set
sfdx force:data:tree:import -p ./testdata/InternalOrganizationUnit-Employee-EmployeeCrisisAssessment-plan.json

sfdx force:apex:execute -f ./dx-utils/apex-scripts/updateLocationVisitorAddressId.apex

sfdx force:org:open 