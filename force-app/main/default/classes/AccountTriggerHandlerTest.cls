@isTest
public class AccountTriggerHandlerTest {
    
    @isTest
    public static void accountTeamMemberTriggerTest1()
    {
        List<Account> testAccounts = new List<Account>();
        String recTypePerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        List <User> uList = new List<User> ();
        uList = [Select Id From User Where isActive = True And userType = 'Standard' And Id != :UserInfo.getUserId() And Profile.Name = 'CCS Member Facing' Limit 5];
         
        testAccounts.add(new Account(LastName= 'Person Account 0', recordTypeid = recTypePerAccId, OwnerId = uList.get(0).Id));
        insert testAccounts;
        
        List <AccountTeamMember> ATMList1 = new List <AccountTeamMember>();
        ATMList1.add(new AccountTeamMember (UserId = uList.get(0).Id, AccountId = testAccounts.get(0).Id, TeamMemberRole = 'Financial Planner', Source__c = 'CRM' ));
        ATMList1.add(new AccountTeamMember (UserId = uList.get(1).Id, AccountId = testAccounts.get(0).Id, TeamMemberRole = 'Retail RM / MF Advisor', Source__c = 'MDM'));
        insert ATMList1;
        
        Test.startTest();
        //testAccounts.get(0).OwnerId = uList.get(1).Id;
        //update testAccounts;
        
        
     
        List <AccountTeamMember> ATMList2 = new List <AccountTeamMember>();
        ATMList2.add(new AccountTeamMember (UserId = uList.get(2).Id, AccountId = testAccounts.get(0).Id, TeamMemberRole = 'Financial Planner', Source__c = 'MDM' ));
        ATMList2.add(new AccountTeamMember (UserId = uList.get(3).Id, AccountId = testAccounts.get(0).Id, TeamMemberRole = 'Retail RM / MF Advisor', Source__c = 'CRM'));
        insert ATMList2;
        
        Test.stopTest();
        
        
        
        
        
    }
    
     @isTest
    public static void accountTeamMemberTriggerTest2()
    {
        List<Account> testAccounts = new List<Account>();
        String recTypePerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        List <User> uList = new List<User> ();
        uList = [Select Id From User Where isActive = True And userType = 'Standard' And Id != :UserInfo.getUserId() And Profile.Name = 'CCS Member Facing' Limit 5];
         
        testAccounts.add(new Account(LastName= 'Person Account 0', recordTypeid = recTypePerAccId, OwnerId = uList.get(0).Id));
        insert testAccounts;
        
        List <AccountTeamMember> ATMList1 = new List <AccountTeamMember>();
        ATMList1.add(new AccountTeamMember (UserId = uList.get(0).Id, AccountId = testAccounts.get(0).Id, TeamMemberRole = 'Financial Planner', Source__c = 'CRM' ));
        ATMList1.add(new AccountTeamMember (UserId = uList.get(1).Id, AccountId = testAccounts.get(0).Id, TeamMemberRole = 'Retail RM / MF Advisor', Source__c = 'MDM'));
        insert ATMList1;
        
        Test.startTest();
        ATMList1.get(0).TeamMemberRole = 'Retail RM / MF Advisor'; 
        update ATMList1;
        Test.stopTest();
        
        
        
        
        
    }
    
    @isTest
    public static void accountOwnerUpdateTest()
    {
        List<Account> testAccounts = new List<Account>();
        String recTypePerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        List <User> uList = new List<User> ();
        uList = [Select Id From User Where isActive = True And userType = 'Standard' And Id != :UserInfo.getUserId() And Profile.Name = 'CCS Member Facing' Limit 5];
         
        testAccounts.add(new Account(LastName= 'Person Account 0', recordTypeid = recTypePerAccId, OwnerId = uList.get(0).Id));
        insert testAccounts;
        
        List <AccountTeamMember> ATMList1 = new List <AccountTeamMember>();
        ATMList1.add(new AccountTeamMember (UserId = uList.get(0).Id, AccountId = testAccounts.get(0).Id, TeamMemberRole = 'Financial Planner', Source__c = 'CRM' ));
        ATMList1.add(new AccountTeamMember (UserId = uList.get(1).Id, AccountId = testAccounts.get(0).Id, TeamMemberRole = 'Retail RM / MF Advisor', Source__c = 'MDM'));
        insert ATMList1;
        
        Test.startTest();
        testAccounts.get(0).OwnerId = uList.get(1).Id;
        update testAccounts;
 
        
        Test.stopTest();
        
        
        
        
        
    }
    
    
    @isTest
    public static void accountConsentTest()
    {
        List<Account> testAccounts = new List<Account>();
        String recTypePerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        List <User> uList = new List<User> ();
        uList = [Select Id From User Where isActive = True And userType = 'Standard' And Id != :UserInfo.getUserId() And Profile.Name = 'CCS Member Facing' Limit 5];
         
        testAccounts.add(new Account(LastName= 'Person Account 0', T24_Profile_Number__c = '999999989', recordTypeid = recTypePerAccId, OwnerId = uList.get(0).Id));
        insert testAccounts;
        
        
        
        Test.startTest();
        testAccounts.get(0).Consent_to_Electronic_Delivery_of_Docume__c = true;
        update testAccounts;
 
        testAccounts.get(0).Consent_to_General_Email_Communication__c = true;
        update testAccounts;
        
        Test.stopTest();
        
        
        
        
        
    }
    
}