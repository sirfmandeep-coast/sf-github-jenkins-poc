global class NBXMultiChannelExpiringNBXBatchScheduler implements Schedulable {
/**
*  NBXMultiChannelExpiringNBXBatchScheduler.cls
*  By Rong Bin, CCS
*  Created Date: 01 Jun 2024
*  Description:  For NBX Multi Channel Epic
*/
    global void execute (SchedulableContext sc) {
        
        NBXMultiChannelExpiringNBXBatch pb = new NBXMultiChannelExpiringNBXBatch();
        Id batchJobId = Database.executeBatch(pb, 200);

    }
}