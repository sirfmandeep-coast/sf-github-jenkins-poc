global class AgencyWebUserDeactivationBatchScheduler implements Schedulable {
    global void execute (SchedulableContext sc) {
        List <CRM_User_Deactivation_Configuration__mdt> configList = [SELECT MasterLabel, DeveloperName, Deactivation_Period__c, Email_Warning_Period__c, Exemption_Profile_List__c, Notification_Only__c, Target_Profile_List__c FROM CRM_User_Deactivation_Configuration__mdt WHERE DeveloperName = 'AgencyWeb' ];
        
        if(Test.isRunningTest()){
            configList.Add (new CRM_User_Deactivation_Configuration__mdt (MasterLabel = 'Test', DeveloperName = 'Test', Deactivation_Period__c = 90, Email_Warning_Period__c = 75, Exemption_Profile_List__c = null, Target_Profile_List__c = '\'CCS External Agent\'', Notification_Only__c = False));
        }

        If (!configList.isEmpty()){
            AgencyWebUserDeactivationBatch pb = new AgencyWebUserDeactivationBatch (configList[0].Email_Warning_Period__c.intValue(), configList[0].Deactivation_Period__c.intValue(), configList[0].Exemption_Profile_List__c, configList[0].Target_Profile_List__c, configList[0].Notification_Only__c);
            Id batchJobId = Database.executeBatch(pb, 200);
        }
    }
}