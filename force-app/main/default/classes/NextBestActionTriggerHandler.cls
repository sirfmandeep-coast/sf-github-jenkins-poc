public class NextBestActionTriggerHandler extends TriggerHandler {
    private List<NextBestAction__c> newRecords;
    private List<NextBestAction__c> oldRecords;
    private Map<Id, NextBestAction__c> newRecordsMap;
    private Map<Id, NextBestAction__c> oldRecordsMap;

    public NextBestActionTriggerHandler (){
        super('NextBestActionTriggerHandler');
        this.newRecords = Trigger.new;
        this.oldRecords = Trigger.old;
        this.newRecordsMap = (Map<Id, NextBestAction__c>) Trigger.newMap;
        this.oldRecordsMap = (Map<Id, NextBestAction__c>) Trigger.oldMap;
    }

    public override void beforeUpdate() {
    
        for(NextBestAction__c nextBestAction : this.newRecords) {        
                 NextBestAction__c oldNBA = oldRecordsMap.get(nextBestAction.Id);
                 If (oldNBA != null && !String.isBlank(nextBestAction.NBX_Template_Name__c) && nextBestAction.NBX_Template_Name__c != oldNBA.NBX_Template_Name__c) {
                     NBXMultiChannelHelper.popluateNBXTemplate (this.newRecords); 
                 }
            }
        NBXMultiChannelHelper.syncFromNBXUpdate (this.newRecords, this.oldRecordsMap);
    }

    public override void beforeInsert() {
        NBXMultiChannelHelper.popluateNBXTemplate (this.newRecords);            
    }
    
}