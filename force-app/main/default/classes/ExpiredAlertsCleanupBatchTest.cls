/**
	 * ExpiredAlertsCleanupBatch
	 * @description      :This is a test class for ExpiredAlertsCleanupBatch
	 * @author           :Mandeep Sigh
	 * @lastmodified on :27 Aug 2025
	 * @lastmodified by :Mandeep Singh
	 * Modification Log
	 * Ver    Date            Author			Jira
	 * 1.0    27 Aug 2025   Mandeep Singh		CRM-4528
	 */
@isTest
public with sharing class ExpiredAlertsCleanupBatchTest {
    

    @isTest
    public static void alertExpiryBatchTest()
    {
        List <Account> testAccounts = new List <Account>();
        

        testAccounts.add(new Account(
            FirstName = 'Test',
            LastName = 'Account1',
            RecordTypeId = '0120h0000007zAlAAI'));
        insert testAccounts;
      
        List <FinServ__Alert__c> testAlerts = new List<FinServ__Alert__c>();
        for(Integer i=0; i<100;i++)
        {
        testAlerts.add(new FinServ__Alert__c(
            FinServ__Message__c = 'Test Alert: '+i,
            ExpiryDate__c =  Date.today().addDays(-1),
            FinServ__Active__c = true,
            FinServ__Account__c = testAccounts[0].Id,
            FINSERV__MESSAGEDESCRIPTION__C = 'Dormant account: 10110009022823',
            FINSERV__SEVERITY__C = 'Warning'
            ));
            i++;
        }
        insert testAlerts;
       
        Test.startTest();
        List<FinServ__Alert__c> allTestAlerts = [SELECT Id, ExpiryDate__c, FinServ__Active__c
                                    From FinServ__Alert__c WHERE FinServ__Account__c =: testAccounts[0].Id];
        ExpiredAlertsCleanupBatch expireAlert = new ExpiredAlertsCleanupBatch();
        Database.executeBatch(expireAlert,200);
        Test.stopTest();
		
        List<FinServ__Alert__c> updatedAlerts = [SELECT Id, ExpiryDate__c, FinServ__Active__c
                                    From FinServ__Alert__c WHERE FinServ__Account__c =: testAccounts[0].Id];
        if(updatedAlerts!=null){
            for (FinServ__Alert__c alert : updatedAlerts) {
                System.assertEquals(false, alert.FinServ__Active__c, 'Alert should be deactivated');
            }
        }
        
    }
    
   @isTest
    public static void scheduleExpiredAlertsCleanUpTest()
    {
		// Create test data
        FinServ__Alert__c alert = new FinServ__Alert__c(FinServ__Message__c = 'Scheduled Alert', FinServ__Active__c = true, ExpiryDate__c = Date.today().addDays(-1));
        insert alert;

        // Schedule the job
        String cronExp = '0 0 5, *, *, ?'; // Arbitrary future date
        Test.startTest();
        String jobId = System.schedule('TestExpiredAlertsJob', cronExp, new ScheduleExpiredAlertsCleanUp());
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Scheduled job should return a job ID');
    } 
}