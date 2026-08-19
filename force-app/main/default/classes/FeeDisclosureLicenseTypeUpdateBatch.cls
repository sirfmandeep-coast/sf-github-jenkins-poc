/*
   * @description      :This class helps update Creator_License_Type__c field on historical Investment Compliance records 
   * @author           :Mandeep Singh
   * @last modified on :8th April 2026
   * @last modified by :Mandeep Singh
   * Modification Log
   * Ver    Date            Author         Jira
   * 1.0    8th Apr 2026   Mandeep Singh    CRM-5945
*/
global with sharing class FeeDisclosureLicenseTypeUpdateBatch implements Database.Batchable<sObject>{
   Integer processed = 0;
   Integer updated = 0;
    global Database.QueryLocator start(Database.BatchableContext bc)
    {

            String query = 'SELECT id,Creator_License_Type__c,CreatedById from Fee_Disclosure__c where Creator_License_Type__c = null';

            return Database.getQueryLocator(query);

    }
    global void execute(Database.BatchableContext bc, List<Fee_Disclosure__c> scope)
    {
        Set<Id> creatorIds = new Set<Id>();
        processed += scope.size();

        if(scope!=null && !scope.isEmpty())
        {
            //Collect CreatedById
            
            for(Fee_Disclosure__c t:scope)
            {
                if(t.CreatedById!=null)
                creatorIds.add(t.CreatedById);
            }
        }

        Map<Id, User> usersById = new Map<Id, User>();
        if (!creatorIds.isEmpty()) {
            usersById = new Map<Id, User>([
                SELECT Id,
                       MF_Licensed_User__c,
                       IIROC_Licensed__c
                FROM User
                WHERE Id IN :creatorIds
            ]);
        }
        List<Fee_Disclosure__c> toUpdate = new List<Fee_Disclosure__c>();
        for(Fee_Disclosure__c t:scope)
            {
                User u = usersById.get(t.CreatedById);

                if(u.MF_Licensed_User__c && !u.IIROC_Licensed__c)
                {
                    t.Creator_License_Type__c = 'Mutual Fund';
                }
                else if (!u.MF_Licensed_User__c && u.IIROC_Licensed__c)
                {
                    t.Creator_License_Type__c = 'IIROC';
                }
                else {
                    t.Creator_License_Type__c = 'Unlicensed';
                }

                toUpdate.add(t);
            }
         if (!toUpdate.isEmpty()) {
            update toUpdate;
            updated += toUpdate.size();
        }
    }

    global void finish(Database.BatchableContext bc)
    {
          System.debug('FeeDisclosureLicenseTypeUpdateBatch completed. Processed=' + processed + ', Updated=' + updated);
    }

}