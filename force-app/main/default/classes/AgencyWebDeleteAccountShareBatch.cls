global class AgencyWebDeleteAccountShareBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    global AgencyWebDeleteAccountShareBatch() {

    }

    global Database.querylocator start(Database.BatchableContext BC){  
        //String query = ' select Id, Broker__c, Rep_Number__c, (select Id, FinServ__RelatedAccount__c from FinServ__FinancialAccountRoles__r where FinServ__Role__c in (\'Primary Owner\', \'Joint Owner\')) from FinServ__FinancialAccount__c where Broker__c != \'\' and Broker__r.RecordType_Name__c = \'Broker\' and FinServ__FinancialAccountType__c = \'Term Deposit\' '; 
        
        String query = 'SELECT Id, accountId, UserOrGroupId from AccountShare where UserOrGroupId in (SELECT Id FROM User Where Profile.Name = \'CCS External Agent\' AND Is_Agency_User__c = True) and RowCause = \'Manual\' ';
        
        System.Debug('AgencyWebDeleteAccountShareBatch.Query ' + query);
        Database.querylocator qList = Database.getQueryLocator(query);
        System.Debug('AgencyWebDeleteAccountShareBatch.start - Getting query locator: ' + qList);
        return qList;
    }

    // execute method
    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
        List<AccountShare> accountShareList = (List<AccountShare>) scope;
        delete accountShareList;
    }

    global void finish(Database.BatchableContext BC){ 
        AgencyWebDeleteFAShareBatch pb = new AgencyWebDeleteFAShareBatch ();
        Id batchJobId = Database.executeBatch(pb, 200);
        System.Debug(Logginglevel.DEBUG,'AgencyWebDeleteAccountShareBatch.finish ');
 
    }
}