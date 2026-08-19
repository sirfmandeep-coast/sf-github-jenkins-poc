/**
	 * ExpiredAlertsCleanupBatch
	 * @description      :This class helps mark expired alerts as inactive
	 * @author           :Mandeep Sigh
	 * @last modified on :27 Aug 2025
	 * @last modified by :Mandeep Singh
	 * Modification Log
	 * Ver    Date            Author			Jira
	 * 1.0    27 Aug 2025   Mandeep Singh		CRM-4528
	 */
public with sharing class ExpiredAlertsCleanupBatch implements Database.Batchable<SObject>{

        
    	public Database.QueryLocator start(Database.BatchableContext BC)
		{
			String query = 'SELECT id from FinServ__Alert__c where FinServ__Active__c = true AND ExpiryDate__c < TODAY';

			return Database.getQueryLocator(query);
		}
        public void execute(Database.BatchableContext BC, List<FinServ__Alert__c> expiredAlerts)
        {
            if(!expiredAlerts.isEmpty())
            {
                for(FinServ__Alert__c  expiredAlert: expiredAlerts )
                {
                    expiredAlert.FinServ__Active__c = false;
                }
				
                try {
					update expiredAlerts; 
                } 
        		catch (DmlException e) {
                    System.debug('Error executing DML: ' + e.getMessage());

                }
                
            }

        }
	    public void finish(Database.BatchableContext BC)
	    {   
	    }


}