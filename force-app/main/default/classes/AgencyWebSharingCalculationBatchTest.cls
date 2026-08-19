@IsTest
public with sharing class AgencyWebSharingCalculationBatchTest {
    @testSetup static void setup() {
        String recTypeBrokerAcctId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        String recTypePersonAcctId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recTypeExternalAgentId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CCS External Agent (Individual) Rep Record Type').getRecordTypeId();
        String recTypeTermDepositFAId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Investment Account').getRecordTypeId();
        

        List <Account> aList = new List <Account> ();
        Account aa = new Account(FirstName = 'Test Person', LastName= 'Account AAC', recordTypeId = recTypePersonAcctId);
        aList.add(aa);
        aa = new Account(Name = 'Test Broker Account', recordTypeId = recTypeBrokerAcctId);
        aList.add(aa);
        aa = new Account(Name = 'Test Broker Account2', recordTypeId = recTypeBrokerAcctId);
        aList.add(aa);
        insert aList;   

        List <Contact> cList = new List <Contact> ();
        Contact cc = new Contact(AccountId = aList.get(1).Id, FirstName = 'Test123', LastName = 'Agent234', Email = 'Test123.Agent234@coastcapitalsavings.com.invalid', phone = '2214324324', recordTypeId = recTypeExternalAgentId, Agency_Role__c = 'Agent Rep No Code');
        cList.add(cc);
        cc = new Contact(AccountId = aList.get(2).Id, FirstName = 'Test234', LastName = 'Agent345', Email = 'Test234.Agent345@coastcapitalsavings.com.invalid', phone = '2214324325', recordTypeId = recTypeExternalAgentId, Agency_Role__c = 'Agent Rep', Rep_Number__c = '2432');
        cList.add(cc);
        insert cList;  
        
        List <FinServ__FinancialAccount__c> FAList = new List <FinServ__FinancialAccount__c> ();
        FinServ__FinancialAccount__c FA1 = new FinServ__FinancialAccount__c (FinServ__FinancialAccountType__c = 'Term Deposit', Name = 'Named FA', FinServ__PrimaryOwner__c = aList.get(0).Id, Broker__c = aList.get(1).Id, recordTypeId = recTypeTermDepositFAId, FinServ__Status__c = 'Active');
        FAList.add(FA1);
        
        FA1 = new FinServ__FinancialAccount__c (FinServ__FinancialAccountType__c = 'Term Deposit', Name = 'Broker FA', FinServ__PrimaryOwner__c = aList.get(1).Id, Broker__c = aList.get(1).Id, recordTypeId = recTypeTermDepositFAId, FinServ__Status__c = 'Active');
        FAList.add(FA1);

        FA1 = new FinServ__FinancialAccount__c (FinServ__FinancialAccountType__c = 'Term Deposit', Name = 'Broker FA', FinServ__PrimaryOwner__c = aList.get(2).Id, recordTypeId = recTypeTermDepositFAId, FinServ__Status__c = 'Active');
        FAList.add(FA1);
        insert FAList;

        List <FinServ__FinancialAccountRole__c> FARList = new List <FinServ__FinancialAccountRole__c> ();
        FinServ__FinancialAccountRole__c FAR1 = new FinServ__FinancialAccountRole__c (FinServ__RelatedAccount__c = aList.get(0).Id, FinServ__FinancialAccount__c = FAList.Get(0).Id, FinServ__Role__c = 'Primary Owner');

        FARList.Add (FAR1);
        FAR1 = new FinServ__FinancialAccountRole__c (FinServ__RelatedAccount__c = aList.get(1).Id, FinServ__FinancialAccount__c = FAList.Get(0).Id, FinServ__Role__c = 'Primary Owner');
        FARList.Add (FAR1);

        FAR1 = new FinServ__FinancialAccountRole__c (FinServ__RelatedAccount__c = aList.get(2).Id, FinServ__FinancialAccount__c = FAList.Get(1).Id, FinServ__Role__c = 'Primary Owner');
        FARList.Add (FAR1);
        insert FARList;
        
        Test.startTest();

        Profile portalProfile = [SELECT Id FROM Profile where Name = 'CCS External Agent'];
        List <User> uList = new List <User> ();
        User user = new User();
        user.ProfileID = portalProfile.Id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'Test123.Agent234@coastcapitalsavings.com.invalid';  
        user.Email = 'Test123.Agent234@coastcapitalsavings.com.invalid';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't123';
        user.IsActive = true; 
        user.contactId = cList.get(0).Id;    
        user.Is_Agency_User__c = true;
        uList.Add (user);
       
        user = new User();
        user.ProfileID = portalProfile.Id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'Test234.Agent345@coastcapitalsavings.com.invalid';  
        user.Email = 'Test234.Agent345@coastcapitalsavings.com.invalid';
        user.CommunityNickname = 'testUser234';
        user.Alias = 't234';
        user.IsActive = true; 
        user.contactId = cList.get(1).Id;    
        user.Is_Agency_User__c = true;

        uList.Add (user);
        insert uList; 

        Test.stopTest();


    }

    static testMethod void myTest() {
    
        Test.StartTest();
        String jobId = System.schedule('AgencyWebSharingSchedulerTest123', '0 0 5, *, *, ?', new AgencyWebSharingScheduler());
        Test.StopTest();
        
    }

    
    static testMethod void myTest2() {
        List <Account> aList = [SELECT Id, Name FROM Account WHERE Name = 'Test Broker Account'];
        List <User> uList = [SELECT Id FROM User where Username = 'Test123.Agent234@coastcapitalsavings.com.invalid'];
        List <AccountShare> ASList = new List <AccountShare>();
        ASList.add( new AccountShare(AccountId = aList.get(0).Id, UserOrGroupId = uList.get(0).Id, AccountAccessLevel = 'Read', OpportunityAccessLevel = 'None', CaseAccessLevel = 'None', RowCause = 'Manual'));
        insert ASList;

        List <FinServ__FinancialAccount__c> FAList = [SELECT Id, Name FROM FinServ__FinancialAccount__c WHERE Name = 'Broker FA'];
        List <FinServ__FinancialAccount__Share> FASList = new List <FinServ__FinancialAccount__Share>();
        FASList.add(new FinServ__FinancialAccount__Share(ParentId = FAList.get(0).Id, UserOrGroupId = uList.get(0).Id, AccessLevel = 'Read', RowCause = 'Manual'));
        insert FASList;

        Test.StartTest();
        AgencyWebSharingCalculationBatch pb = new AgencyWebSharingCalculationBatch ();
        ID batchprocessid = Database.executeBatch(pb);
        Test.StopTest();
        
    }

    
    static testMethod void myTest3() {
        List <Account> aList = [SELECT Id, Name FROM Account WHERE Name = 'Test Broker Account'];
        List <User> uList = [SELECT Id FROM User where Username = 'Test123.Agent234@coastcapitalsavings.com.invalid'];
        List <AccountShare> ASList = new List <AccountShare>();
        ASList.add( new AccountShare(AccountId = aList.get(0).Id, UserOrGroupId = uList.get(0).Id, AccountAccessLevel = 'Read', OpportunityAccessLevel = 'None', CaseAccessLevel = 'None', RowCause = 'Manual'));
        insert ASList;

        Test.StartTest();
        AgencyWebDeleteAccountShareBatch pb = new AgencyWebDeleteAccountShareBatch ();
        ID batchprocessid = Database.executeBatch(pb);
        Test.StopTest();
        
    }

    
    static testMethod void myTest4() {

        List <FinServ__FinancialAccount__c> FAList = [SELECT Id, Name FROM FinServ__FinancialAccount__c WHERE Name = 'Broker FA'];
        List <User> uList = [SELECT Id FROM User where Username = 'Test123.Agent234@coastcapitalsavings.com.invalid'];

        List <FinServ__FinancialAccount__Share> FASList = new List <FinServ__FinancialAccount__Share>();
        FASList.add(new FinServ__FinancialAccount__Share(ParentId = FAList.get(0).Id, UserOrGroupId = uList.get(0).Id, AccessLevel = 'Read', RowCause = 'Manual'));
        insert FASList;
        Test.StartTest();
        AgencyWebDeleteFAShareBatch pb = new AgencyWebDeleteFAShareBatch ();
        ID batchprocessid = Database.executeBatch(pb);
        Test.StopTest();
        
    }
}