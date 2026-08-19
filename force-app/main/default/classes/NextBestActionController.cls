public with sharing class NextBestActionController {
    @AuraEnabled
    public static List<NextBestAction__c> getNextBestActionsByAccountId(Id accountId){
        return [SELECT Id, Name, MemberName__c, LastModifiedDate, Opportunity__c, OpportunityType__c, ProductCode__c, Rank__c, Outcome_Action_Flow__c, Contextual_Detail__c, NBX_Template__r.Inbound_Script__c, NBX_Template__r.Display_Name__c, CreatedDate
                    FROM NextBestAction__c WHERE MemberName__c = :accountId AND Outcome__c = '' AND NBX_Template__c != '' ORDER BY Rank__c ASC NULLS LAST, LastModifiedDate DESC ];

    }

    @AuraEnabled
    public static void saveRecord (NextBestAction__c recordToUpdate){ 
        update recordToUpdate; 
    }
}