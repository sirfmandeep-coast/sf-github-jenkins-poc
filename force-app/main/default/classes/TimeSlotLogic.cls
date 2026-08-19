public with sharing class TimeSlotLogic {

    public static void validate(list<TimeSlot> newList, Boolean isInsert, Boolean isDelete) {
        
        Boolean isAutorized = OperatingHoursLogic.checkIfAutorized();

        if( !isAutorized ) {
            set<Id> operatingHoursIds = new set<Id>();
            for(timeslot ts:newList){
                operatingHoursIds.add(ts.OperatingHoursId);
            }
            Set<Id> territoryBlockedIds = new Set<Id>();
            List<ServiceTerritory> territories = [SELECT Id, OperatingHoursId FROM ServiceTerritory 
                                                WHERE OperatingHoursId IN : operatingHoursIds];
            if( territories.size() > 0 ) {
                //get service territory records
                for(ServiceTerritory tmpTerritory : territories) {
                    territoryBlockedIds.add(tmpTerritory.OperatingHoursId);
                }

                for(timeslot ts:newList){
                    if( territoryBlockedIds.contains(ts.OperatingHoursId)) {
                        ts.addError(Label.Trigger_Error_Message_Time_Slot_Update);
                    }
                }
            } else {
                List<String> managerPublicGroups = System.Label.Manager_Public_Groups.split(',');
                Boolean isManager = UtilityClass.checkUserInPublicGroup(UserInfo.getUserId(), 
                                                                    new Set<String>(managerPublicGroups));
                
                if( !isManager ) {
                    Set<Id> blockedOperatingHoursIds = new Set<Id>();
                    List<ServiceTerritoryMember> members = [SELECT Id, ServiceResourceId, ServiceResource.RelatedRecordId, 
                                                                ServiceResource.RelatedRecord.Name, OperatingHoursId, 
                                                                ServiceTerritoryId
                                                                FROM ServiceTerritoryMember
                                                                WHERE OperatingHoursId in :operatingHoursIds];
                    if ( members.size() > 0 ) {
                        for(ServiceTerritoryMember tmpMember : members) {
                            if( tmpMember.ServiceResource.RelatedRecordId != UserInfo.getUserId() ) {
                                blockedOperatingHoursIds.add(tmpMember.OperatingHoursId);
                            }
                        }

                        for(timeslot ts:newList){
                            if( blockedOperatingHoursIds.contains(ts.OperatingHoursId)) {
                                
                                 if( isInsert && !isDelete ) {
                                    ts.addError(Label.Trigger_Error_Message_Time_Slot_Insert);
                                 }  else if( isDelete && !isInsert ) {
                                    ts.addError(Label.Trigger_Error_Message_Time_Slot_Delete);
                                 } else {
                                   ts.addError(Label.Trigger_Error_Message_Time_Slot_Update); 
                                 }
                            }
                        }

                    }
                }
            }
        } 
    }
}