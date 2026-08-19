@isTest
public class  NBXMultiChannelHelperTest {
   
    @testsetup
    public static void makeData(){
        
        List<Account> testAccounts = new List<Account>();
        String recTypePerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
         
        testAccounts.add(new Account(LastName= 'Person Account 0', recordTypeid = recTypePerAccId));
        insert testAccounts;
      
        List<NBX_Template__c> testNBXTemplateList = new List<NBX_Template__c> ();
        testNBXTemplateList.add (new NBX_Template__c(Name='Test', Display_Name__c = 'Test', Inbound_Script__c = 'Test', Rank__c = 1));
        insert testNBXTemplateList;
        
        List<NextBestAction__c> testNBXList = new List<NextBestAction__c> ();
        testNBXList.add (new NextBestAction__c(NBX_Template_Name__c = 'Test', MemberName__c = testAccounts[0].Id, SourceSystemID__c = '1111232343', Outcome__c = '', Expiration_Date__c = Date.Today() - 30));
        testNBXList.add (new NextBestAction__c(NBX_Template_Name__c = 'Test', MemberName__c = testAccounts[0].Id, SourceSystemID__c = '1111232344', Outcome__c = '', Expiration_Date__c = Date.Today() - 30));
        testNBXList.add (new NextBestAction__c(NBX_Template_Name__c = 'Test', MemberName__c = testAccounts[0].Id, SourceSystemID__c = '1111232345', Outcome__c = '', Expiration_Date__c = Date.Today() - 30));
        testNBXList.add (new NextBestAction__c(NBX_Template_Name__c = 'Test', MemberName__c = testAccounts[0].Id, SourceSystemID__c = '1111232346', Outcome__c = '', Expiration_Date__c = Date.Today() - 30));
        testNBXList.add (new NextBestAction__c(NBX_Template_Name__c = 'Dummy', MemberName__c = testAccounts[0].Id, SourceSystemID__c = '1111232347', Outcome__c = '', Expiration_Date__c = Date.Today() - 30));
        insert testNBXList;
        
        List<Lead> testLeadList = new List<Lead>();
        String recTypeLeadId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CCS Individual Lead').getRecordTypeId();
         
        testLeadList.add(new Lead(FirstName = 'test', LastName= 'Lead 0', recordTypeid = recTypeLeadId, NBX_External_Id__c = '1111232343', isActioned__c = true, FinServ__RelatedAccount__c =  testAccounts[0].Id, Phone = '3354354343', email = '3354354343@test3354354343.test.invalid' ));
        testLeadList.add(new Lead(FirstName = 'test', LastName= 'Lead 1', recordTypeid = recTypeLeadId, NBX_External_Id__c = '1111232344', isActioned__c = true, FinServ__RelatedAccount__c =  testAccounts[0].Id, Phone = '3354354344', email = '3354354344@test3354354343.test.invalid' ));
        testLeadList.add(new Lead(FirstName = 'test', LastName= 'Lead 2', recordTypeid = recTypeLeadId, NBX_External_Id__c = '1111232345', isActioned__c = true, FinServ__RelatedAccount__c =  testAccounts[0].Id, Phone = '3354354345', email = '3354354345@test3354354343.test.invalid' ));
        testLeadList.add(new Lead(FirstName = 'test', LastName= 'Lead 2', recordTypeid = recTypeLeadId, NBX_External_Id__c = '1111232346', isActioned__c = true, FinServ__RelatedAccount__c =  testAccounts[0].Id, Phone = '3354354346', email = '3354354346@test3354354343.test.invalid' ));
        insert testLeadList;
        
        
        
    }
    
    @isTest
    public static void actionNBXTest()
    {
        List<NextBestAction__c> testNBXList = [SELECT Id, Outcome__c, NBX_Template_Name__c FROM NextBestAction__c];
        testNBXList[0].Outcome__c = 'Interested';
        testNBXList[1].Outcome__c = 'Not Interested';
        testNBXList[2].Outcome__c = 'Expired';
        testNBXList[3].Outcome__c = 'Not Applicable';
        testNBXList[4].NBX_Template_Name__c = 'Test';
        update testNBXList;
    }
    
    @isTest
    public static void actionLeadTest()
    {
        List<Lead> testLeadList = [SELECT Id, Status, Lost_Reason__c, Expired__c, FinServ__RelatedAccount__c FROM Lead];
        testLeadList[0].Status = 'Lost';
        testLeadList[0].Lost_Reason__c = 'Not Interested';
        testLeadList[1].Status = 'Lost';
        testLeadList[1].Lost_Reason__c = 'Closed By System';
        testLeadList[1].Expired__c = 'True';
        List<Database.LeadConvert> leadConvertList=new List<Database.LeadConvert>();
        Database.LeadConvert leadConvert = new Database.LeadConvert();
        leadConvert.setLeadId(testLeadList[2].Id);
        leadConvert.setConvertedStatus('Converted'); 
        leadConvert.setAccountId(testLeadList[2].FinServ__RelatedAccount__c);
        leadConvert.setDoNotCreateOpportunity(true);
         
        leadConvertList.add(leadConvert);
        update testLeadList;
        test.startTest();
        List<Database.LeadConvertResult> lcr=Database.convertLead(leadConvertList);
        test.stopTest();
        
    }
    
    @isTest
    public static void expireNBXTest()
    {
        NBXMultiChannelExpiringNBXBatch pb = new NBXMultiChannelExpiringNBXBatch  ();
        ID batchprocessid = Database.executeBatch(pb);
        
    }
    
     @isTest
     Public static void expireNBXScheduler() {
    
        Test.StartTest();
        String jobId = System.schedule('MultiChannelExpiringNBXSchedulerTest123', '0 0 5, *, *, ?', new NBXMultiChannelExpiringNBXBatchScheduler ());
        Test.StopTest();
        
    }
    
}