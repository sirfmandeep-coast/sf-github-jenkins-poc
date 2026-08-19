/*
   * @description      :This class helps update Task_License_Type__c field on historical tasks 
   * @author           :Mandeep Singh
   * @last modified on :1st April 2026
   * @last modified by :Mandeep Singh
   * Modification Log
   * Ver    Date            Author         Jira
   * 1.0    1st Apr 2026   Mandeep Singh    CRM-5945
*/
global with sharing class TaskLicenseTypeUpdateBatch implements Database.Batchable<sObject>{
   Integer processed = 0;
   Integer updated = 0;
   Date startDate ;
   Date endDate;
   global TaskLicenseTypeUpdateBatch (Date startDate, Date endDate){
	this.startDate = startDate;
	this.endDate = endDate;
   }
  
global Database.QueryLocator start(Database.BatchableContext bc) {

        // Build DateTime bounds (inclusive start, exclusive end+1 day)
        DateTime startDt;
        DateTime endExclusiveDt;

        if (startDate != null && endDate != null) {
            startDt        = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
            endExclusiveDt = DateTime.newInstance(endDate.addDays(1), Time.newInstance(0, 0, 0, 0));

            // ALL ROWS must be last
            return Database.getQueryLocator([
                SELECT Id, Task_License_Type__c, CreatedById
                FROM Task
                WHERE CreatedDate >= :startDt
                  AND CreatedDate <  :endExclusiveDt
                  AND Task_License_Type__c = null
                  AND Isdeleted = False
                ALL ROWS
            ]);
        }

        return Database.getQueryLocator([
            SELECT Id, Task_License_Type__c, CreatedById
            FROM Task
            WHERE Task_License_Type__c = null
        ]);
    }


   global void execute(Database.BatchableContext bc, List<Task> scope)
   {
        
        
        Set<Id> creatorIds = new Set<Id>();
        processed += scope.size();

        if(scope!=null && !scope.isEmpty())
        {
            //Collect CreatedById
            
            for(Task t:scope)
            {
                if(t.CreatedById!=null)
                creatorIds.add(t.CreatedById);
            }
        }
            
        // Query creators once
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
        
        List<Task> toUpdate = new List<Task>();

        for(Task t:scope)
            {
                User u = usersById.get(t.CreatedById);

                if(u.MF_Licensed_User__c && !u.IIROC_Licensed__c)
                {
                    t.Task_License_Type__c = 'Mutual Fund';
                }
                else if (!u.MF_Licensed_User__c && u.IIROC_Licensed__c)
                {
                    t.Task_License_Type__c = 'IIROC';
                }
                else {
                    t.Task_License_Type__c = 'Unlicensed';
                }

                toUpdate.add(t);
            }
           
        if (!toUpdate.isEmpty()) {
            //update toUpdate;
            List<Database.SaveResult> results = Database.update(toUpdate, false);
            updated += toUpdate.size();
        }

        

   }
   global void finish(Database.BatchableContext bc)
    {
          System.debug('TaskLicenseTypeUpdateBatch completed. Processed=' + processed + ', Updated=' + updated);
    }
}