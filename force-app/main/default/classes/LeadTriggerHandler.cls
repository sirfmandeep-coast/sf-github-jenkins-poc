public class LeadTriggerHandler extends TriggerHandler {
    private List<Lead> newRecords;
    private List<Lead> oldRecords;
    private Map<Id, Lead> newRecordsMap;
    private Map<Id, Lead> oldRecordsMap;

    public LeadTriggerHandler (){
        super('LeadTriggerHandler');
        this.newRecords = Trigger.new;
        this.oldRecords = Trigger.old;
        this.newRecordsMap = (Map<Id, Lead>) Trigger.newMap;
        this.oldRecordsMap = (Map<Id, Lead>) Trigger.oldMap;
    }

    public override void beforeUpdate() {
        NBXMultiChannelHelper.syncFromLeadUpdate (this.newRecords, this.oldRecordsMap);       
    }
    
}