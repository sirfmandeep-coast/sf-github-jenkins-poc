global class ccsExpireLeads implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query= 'SELECT ID, Name, RecordType.Name, End_Date__c, Status, Lost_Reason__c, Lost_Reason_Other__c, Expired__c FROM Lead WHERE End_Date__c <= TODAY AND RecordType.Name LIKE \'%Lead%\' AND Status NOT IN (\'Lost\', \'Converted\')';
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> scope)
    {
        for(Lead l: scope)
        {
            l.Status = 'Lost';
            l.Lost_Reason__c = 'Closed By System';
            l.Expired__c  = 'TRUE';
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}