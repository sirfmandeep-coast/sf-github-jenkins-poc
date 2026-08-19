@isTest
public class NextBestActionController_Test {

    
    @isTest
    public static void testNextBestActionControllerMethods() {
        String recTypePerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account accRecPersonAcc = new Account(FirstName = 'Test Person', LastName= 'Account AAC', RecordTypeId = recTypePerAccId);
        insert accRecPersonAcc;

        NBX_Template__c NBXTemplate = new NBX_Template__c (Name = 'Test', Display_Name__c = 'Test', Inbound_Script__c = 'Test', Rank__c = 1);
        insert NBXTemplate;
        
        NextBestAction__c NBA = new NextBestAction__c (NBX_Template_Name__c = 'Test', Rank__c = 1, Opportunity__c = 'Test Description', OpportunityType__c = 'Test Title', MemberName__c = accRecPersonAcc.Id);
        insert NBA;
        List <NextBestAction__c> NBAList =  NextBestActionController.getNextBestActionsByAccountId(accRecPersonAcc.Id);
        NextBestActionController.saveRecord (NBA);
    }


}