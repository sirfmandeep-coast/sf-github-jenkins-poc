public with sharing class AccountRelatedRecords {
    public static Set<String> stringLeadReferalStatusFilterSet = new Set<String>{'Converted','Lost'};
    // Added on Nov 27th 2023 to filter only in progress cases CRM-5554
    public static Set<String> stringCaseStatusFilterSet = new Set<String>{'Resolved','Closed'};
    public static Set<String> stringMoneyChatStatusFilterSet = new Set<String>{'Incomplete'};
    @AuraEnabled
    public static Account getRelatedRecordsInfo(String accountId){
        Account acc = [select Id, Name, RecordType.Name,
                                       (select Id, Name, Product__c, RecordType.Name from FinServ__RelatedLeads__r where Status NOT IN: stringLeadReferalStatusFilterSet), 
                                       (select Id, Name,StageName,CloseDate from Opportunities),
                                       (select Id, CaseNumber, RecordTypeImage__c, Status, Owner.Name from Cases where Status NOT IN: stringCaseStatusFilterSet),
                                       (select Id, Name, CreatedDate, Status__c from Money_Chats__r where Status__c IN:stringMoneyChatStatusFilterSet order by CreatedDate DESC),
                                       (select Id, Subject, Type, Owner.Name from Events order by ActivityDate DESC),
                                       (select Id, Owner.Name, ActivityDate, Subject from Tasks order by ActivityDate DESC),
                                       (select Id, Name, Stage__c, Status__c, CreatedDate from Product_Reviews_and_Disclosures__r),
                                       (select Id, Name, Account__c, PRD_Status_Formula__c, CreatedDate, Record_Name_for_Retrieval__c, Product_Review_and_Disclosure__c from Product_Member_Review_Disclosures__r WHERE CreatedDate = LAST_N_DAYS:180 order by PRD_Status_Formula__c, CreatedDate DESC)
                                       from Account where Id =:accountId];
        return acc;
    }

}