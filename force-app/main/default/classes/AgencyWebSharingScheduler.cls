global class AgencyWebSharingScheduler implements Schedulable {
/**
*  AgencyWebSharingScheduler.cls
*  By Rong Bin, CCS
*  Created Date: 01 Jun 2023
*  Description:  For Agency Web Sharing function
*/
    global void execute (SchedulableContext sc) {
        
        AgencyWebDeleteAccountShareBatch pb = new AgencyWebDeleteAccountShareBatch ();
        Id batchJobId = Database.executeBatch(pb, 200);

    }
}