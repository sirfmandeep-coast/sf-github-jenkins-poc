/**
*  UserDeactivationBatchTest.cls
*  By Rong Bin, CCS
*  Created Date: 20 Oct 2022
*  Description:  CRM-4786: User Deactivation Automation 
*/

@IsTest
public with sharing class UserDeactivationBatchTest {

    // testmethod
    static testMethod void myTest() {
    
        List <User> updateList = new List <User>();
    
        Profile p = [SELECT Id FROM Profile WHERE Name = 'CCS Internal' Limit 1 ];
        
        List <User> users = [SELECT Id, IsActive, Email, ProfileId, Name, Username, CreatedDate, LastLoginDate, Profile.Name, Last_Deactivation_Email_Sent_Date__c FROM User WHERE IsActive = False AND UserType = 'Standard' AND Email like '%coastcapitalsavings.com%' AND  LastLoginDate = null LIMIT 10]; 
        
        Integer i = 0;
        for (user uu : users) {
            uu.IsActive = True; 
            uu.ProfileId = p.Id;
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
        String exemptionProfiles = '\'System Administrator\',\'CCS Exec\',\'CCS Service Account\',\'CCS NICE Service User\',\'CCS nCino Service Account\'';
        String targetProfiles = '\'CCS Internal\'';
        UserDeactivationBatch pb = new UserDeactivationBatch (173, 180, exemptionProfiles, targetProfiles, False);
        Boolean sandbox = pb.isSandbox();
        ID batchprocessid = Database.executeBatch(pb);
        Test.StopTest();
        
    }

    static testMethod void myTest2() {
    
        Test.StartTest();
        String jobId = System.schedule('UserDeactivationBatchScheduler', '0 0 5, *, *, ?', new UserDeactivationBatchScheduler());
        Test.StopTest();
        
    }
}