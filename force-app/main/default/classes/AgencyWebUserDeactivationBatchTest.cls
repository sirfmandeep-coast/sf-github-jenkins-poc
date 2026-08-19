/**
*  AgencyWebUserDeactivationBatchTest.cls
*  By Rong Bin, CCS
*  Created Date: 3 Jan 2024
*  Description:  AGENCY-212: Disable User if Password Not Changed at 90 Days 
*/

@IsTest
public with sharing class AgencyWebUserDeactivationBatchTest {

    // testmethod
    static testMethod void myTest() {
    
        List <User> updateList = new List <User>();
    
        //Profile p = [SELECT Id FROM Profile WHERE Name = 'CCS Internal' Limit 1 ];
        
        List <User> users = [SELECT Id, IsActive, Email, ProfileId, Name, Username, CreatedDate, LastLoginDate, Profile.Name, LastPasswordChangeDate, Last_Deactivation_Email_Sent_Date__c FROM User WHERE UserType = 'PowerCustomerSuccess' AND isActive = True LIMIT 10]; 
        
        Integer i = 0;
        for (user uu : users) {
            //uu.IsActive = True; 
            if (math.mod(i,2) == 0)
            {
                uu.Last_Deactivation_Email_Sent_Date__c = null;
            }
            else 
            {
                uu.Last_Deactivation_Email_Sent_Date__c = Datetime.Now().addDays(-10);
            }
            updatelist.Add(uu);
            i++;
        }
        update updatelist;
             
        Test.StartTest();
        String exemptionProfiles = '';
        String targetProfiles = '\'CCS External Agent\'';
        AgencyWebUserDeactivationBatch pb = new AgencyWebUserDeactivationBatch (3, 4, exemptionProfiles, targetProfiles, False);
        Boolean sandbox = pb.isSandbox();
        ID batchprocessid = Database.executeBatch(pb);
        Test.StopTest();
        
    }

    static testMethod void myTest2() {
    
        Test.StartTest();
        String jobId = System.schedule('AgencyWebUserDeactivationBatchSchedulerTest', '0 0 5, *, *, ?', new AgencyWebUserDeactivationBatchScheduler());
        Test.StopTest();
        
    }
}