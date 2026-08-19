global class TxnP_DataExport_Admins implements TxnSecurity.PolicyCondition {
    public boolean evaluate(TxnSecurity.Event e) {
        
        // The event data is a Map<String, String>.
        // We need to call the valueOf() method on appropriate data types to use them in our logic.
        Integer numberOfRecords = Integer.valueOf(e.data.get('NumberOfRecords'));
        Long executionTimeMillis = Long.valueOf(e.data.get('ExecutionTime'));
        String entityName = e.data.get('EntityName');
        system.debug(e);
        
        Integer adminRecordsAllowed = integer.valueof([SELECT label from TxnProfile_Settings__mdt where setting_name__c='export_records_admin' and isactive__c=true limit 1].label);
        system.debug(adminRecordsAllowed);

        Integer nonAdminRecordsAllowed = integer.valueof([SELECT label from TxnProfile_Settings__mdt where setting_name__c='export_records_nonadmin' and isActive__c=true limit 1].label);
        system.debug(adminRecordsAllowed);

        User loginUser = [Select profile.name from user where id = :e.UserId];
        system.debug(loginUser.profile.name);
        
        TxnProfile_Settings__mdt[] exceptionProfiles = [SELECT label from TxnProfile_Settings__mdt where setting_name__c='profile' and isactive__c=true and label=:loginUser.profile.name];
        System.debug(exceptionProfiles.size());

        Set<String> userPSets = new Set<String>();
        for(PermissionSetAssignment  pset:[SELECT permissionset.name FROM PermissionSetAssignment WHERE AssigneeId = :loginUser.id])
        {userPsets.add(pset.permissionset.name);}
        System.debug(userPSets.size());
        
        TxnProfile_Settings__mdt[] exceptionPSets = [SELECT label from TxnProfile_Settings__mdt where setting_name__c='permissionset' and isactive__c=true and label IN :userPSets];
        System.debug(exceptionPSets.size());
        
//        if(!loginUser.profile.name.containsIgnoreCase('admin')) return true;
        /* Do not block export for admin users */
        if( ((!exceptionProfiles.isEmpty()) || (!exceptionPSets.isEmpty())) && numberOfRecords > adminRecordsAllowed) return true;
/*        if(!exceptionProfiles.isEmpty() && numberOfRecords > adminRecordsAllowed){
                system.debug('dataexporteventFired');
                return true;
            }
*/        // For everything else don't trigger the policy.
        return false;
    }
}