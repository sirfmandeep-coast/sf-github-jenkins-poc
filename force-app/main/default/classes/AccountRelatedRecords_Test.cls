@isTest
public class AccountRelatedRecords_Test {

    @isTest
    public static void getAccountRelatedRecords() {
        
        String recTypeIndividualId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CCS Individual Lead').getRecordTypeId();
        String recTypePerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account accRec = new Account(Name = 'Test Account AAC');
        insert accRec;

        String moneyChatOwnerId = UserInfo.getUserId(); 

        Account accRecPersonAcc = new Account(FirstName = 'Test Person', LastName= 'Account AAC', RecordTypeId = recTypePerAccId, DMC_Invited_By__c = moneyChatOwnerId);
        insert accRecPersonAcc;

        Lead leadRec = new Lead(FinServ__RelatedAccount__c = accRecPersonAcc.Id, Status = 'New', RecordTypeId = recTypeIndividualId);

        Date opptyCloseDate = Date.newInstance(2021,12,31);
        Opportunity opptyRec = new Opportunity(Name = 'Test Oppty AAC', AccountId = accRecPersonAcc.Id, StageName = 'Consent' , CloseDate = opptyCloseDate);
        insert opptyRec;

        Case caseRec = new Case(AccountId = accRecPersonAcc.Id);
        insert caseRec;

        
        MoneyChat__c moneyChatRec = new MoneyChat__c(Member__c = accRecPersonAcc.Id, DMC_ID__c = '87878787');
        insert moneyChatRec;

        Datetime activityDateTime = Datetime.newInstance(2022, 5, 11);
        Event eveRec = new Event(WhatId = accRecPersonAcc.Id, DurationInMinutes = 60, ActivityDateTime = activityDateTime);
        insert eveRec;

        Task taskRec = new Task(WhatId = accRecPersonAcc.Id, Subject = 'Test Subject AAC', Status = 'Not Started');
        insert taskRec;

        Account acc = AccountRelatedRecords.getRelatedRecordsInfo(accRecPersonAcc.Id);

        System.assertNotEquals(null, acc.FinServ__RelatedLeads__r);
        System.assertNotEquals(null, acc.Opportunities);
        System.assertNotEquals(null, acc.Cases);
        System.assertNotEquals(null, acc.Money_Chats__r);
        System.assertNotEquals(null, acc.Events);
        System.assertNotEquals(null, acc.Tasks);
     }
}