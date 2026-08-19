/**
*  UserDeactivationBatchScheduler.cls
*  By Rong Bin, CCS
*  Created Date: 20 Oct 2022
*  Description:  CRM-4786: User Deactivation Automation 
*/

global class UserDeactivationBatchScheduler implements Schedulable {
    global void execute (SchedulableContext sc) {
        List <CRM_User_Deactivation_Configuration__mdt> configList = [SELECT MasterLabel, DeveloperName, Deactivation_Period__c, Email_Warning_Period__c, Exemption_Profile_List__c, Notification_Only__c, Target_Profile_List__c FROM CRM_User_Deactivation_Configuration__mdt ];
        
        if(Test.isRunningTest()){
            configList.Add (new CRM_User_Deactivation_Configuration__mdt (MasterLabel = 'Test', DeveloperName = 'Test', Deactivation_Period__c = 180, Email_Warning_Period__c = 173, Exemption_Profile_List__c = '\'System Adminstrator\'', Target_Profile_List__c = '\'CCS Internal\'', Notification_Only__c = True));
        }

        If (!configList.isEmpty()){
            UserDeactivationBatch pb = new UserDeactivationBatch (configList[0].Email_Warning_Period__c.intValue(), configList[0].Deactivation_Period__c.intValue(), configList[0].Exemption_Profile_List__c, configList[0].Target_Profile_List__c, configList[0].Notification_Only__c);
            Id batchJobId = Database.executeBatch(pb, 50);
        }
    }
}