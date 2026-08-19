global class NBXMultiChannelExpiringNBXBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    global NBXMultiChannelExpiringNBXBatch () {

    }

    global Database.querylocator start(Database.BatchableContext BC){  
        String query = ' SELECT Id, Outcome__c FROM NextBestAction__c WHERE Outcome__c = \'\' AND Expiration_Date__c < TODAY ';
        
        System.Debug('NBXMultiChannelExpiringNBXBatch.Query ' + query);
        Database.querylocator qList = Database.getQueryLocator(query);
        System.Debug('NBXMultiChannelExpiringNBXBatch.start - Getting query locator: ' + qList);
        return qList;
    }

    // execute method
    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
        List<NextBestAction__c> NBXList = (List<NextBestAction__c>) scope;
        For (NextBestAction__c NBX : NBXList)
        {
            NBX.Outcome__c = 'Expired';
            NBX.Actioned_By_Source__c = 'System';
            NBX.isActive__c = false;
        }
        update NBXList;
    }

    global void finish(Database.BatchableContext BC){ 
        /*
        NBXMultiChannelExpiringNBXMarketingBatch pb = new NBXMultiChannelExpiringNBXMarketingBatch ();
        Id batchJobId = Database.executeBatch(pb, 200);
        System.Debug(Logginglevel.DEBUG,'NBXMultiChannelExpiringNBXBatch.finish ');
        */
    }
}