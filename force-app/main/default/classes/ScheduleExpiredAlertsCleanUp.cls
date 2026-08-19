/**
	 * ExpiredAlertsCleanupBatchCleanUp
	 * @description      :This class helps schedule the ExpiredAlertsCleanupBatch class. Note: The test class for this has been included in the test class for ExpiredAlertsCleanupBatch
	 * @author           :Mandeep Sigh
	 * @last modified on :28 Aug 2025
	 * @last modified by :Mandeep Singh
	 * Modification Log
	 * Ver    Date            Author			Jira
	 * 1.0    28 Aug 2025   Mandeep Singh		CRM-4528
	 */
public with sharing class ScheduleExpiredAlertsCleanUp implements Schedulable{
    public void execute(SchedulableContext SC)
	{
		ExpiredAlertsCleanupBatch batchJob = new ExpiredAlertsCleanupBatch();
        Database.executeBatch(batchJob, 200);
	}

}