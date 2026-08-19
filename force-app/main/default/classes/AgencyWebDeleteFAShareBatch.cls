global class AgencyWebDeleteFAShareBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    global AgencyWebDeleteFAShareBatch() {

    }

    global Database.querylocator start(Database.BatchableContext BC){  
        //String query = ' select Id, Broker__c, Rep_Number__c, (select Id, FinServ__RelatedAccount__c from FinServ__FinancialAccountRoles__r where FinServ__Role__c in (\'Primary Owner\', \'Joint Owner\')) from FinServ__FinancialAccount__c where Broker__c != \'\' and Broker__r.RecordType_Name__c = \'Broker\' and FinServ__FinancialAccountType__c = \'Term Deposit\' '; 
        String query = 'SELECT Id, parentId, UserOrGroupId from FinServ__FinancialAccount__Share where UserOrGroupId in (SELECT Id FROM User Where Profile.Name = \'CCS External Agent\' AND Is_Agency_User__c = True) and RowCause = \'Manual\' ';
        
        System.Debug('AgencyWebDeleteFAShareBatch.Query ' + query);
        Database.querylocator qList = Database.getQueryLocator(query);
        System.Debug('AgencyWebDeleteFAShareBatch.start - Getting query locator: ' + qList);
        return qList;
    }

    // execute method
    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
        List<FinServ__FinancialAccount__Share> financialAccountShareList = (List<FinServ__FinancialAccount__Share>) scope;
        delete financialAccountShareList;
    }

    global void finish(Database.BatchableContext BC){ 
        AgencyWebSharingCalculationBatch pb = new AgencyWebSharingCalculationBatch ();
        Id batchJobId = Database.executeBatch(pb, 200);
        System.Debug(Logginglevel.DEBUG,'AgencyWebDeleteFAShareBatch.finish ');
 
    }
}