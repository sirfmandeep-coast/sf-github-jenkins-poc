public with sharing class OperatingHoursLogic {

    public static void validate(list<OperatingHours> newList, Boolean isInsert, Boolean isDelete) {
        
        Boolean isAutorized = checkIfAutorized();

        if( !isAutorized ) {
            List<String> managerPublicGroups = System.Label.Manager_Public_Groups.split(',');
            Boolean isManager = UtilityClass.checkUserInPublicGroup(UserInfo.getUserId(), 
                                                                new Set<String>(managerPublicGroups));
            if( isInsert && !isDelete ) {
                if(!isManager) {
                    //If the currnet user is not a manager, then the creation should not be allowed
                    for(OperatingHours ts:newList){
                        ts.addError(Label.Trigger_Error_Message_Operating_hours_Insert);
                    } 
                }
            } else if( isDelete && !isInsert ) {
                //If the currnet user is not a manager, then the creation should not be allowed
                if(!isManager) {
                    for(OperatingHours ts:newList){
                        ts.addError(Label.Trigger_Error_Message_Operating_hours_Delete);
                    }
                }
            } else {
                //If the current user is not a Manager, he/she should be only allowed to update his/her own time slot
                if( !isManager ) {
                    set<Id> operatingHoursIds = new set<Id>();
                    set<Id> blockedOperatingHoursIds = new set<Id>();

                    for(OperatingHours ts:newList){
                        operatingHoursIds.add(ts.Id);
                    }

                    //get service territory member records
                    for(ServiceTerritoryMember tmpMember : [SELECT Id, ServiceResourceId, ServiceResource.RelatedRecordId, 
                                                            ServiceResource.RelatedRecord.Name, OperatingHoursId, 
                                                            ServiceTerritoryId
                                                            FROM ServiceTerritoryMember
                                                            WHERE OperatingHoursId in :operatingHoursIds]) {
                        if( tmpMember.ServiceResource.RelatedRecordId != UserInfo.getUserId() ) {
                            blockedOperatingHoursIds.add(tmpMember.OperatingHoursId);
                        }
                    }


                    for(OperatingHours ts:newList){
                        if( blockedOperatingHoursIds.contains(ts.Id)) {
                            ts.addError(Label.Trigger_Error_Message_Operating_hours_Update);
                        }
                    }
                }
            }
        }
        
    }
    
    public static boolean checkIfAutorized(){
        
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        List<Operating_Hours_authorized_profiles__mdt> profiles = [
            SELECT MasterLabel 
            FROM Operating_Hours_authorized_profiles__mdt
        ];

        for(Operating_Hours_authorized_profiles__mdt pro:profiles){
            if(pro.MasterLabel==profileName){
                return true;
            }
        }
        
        return false;
    }
}