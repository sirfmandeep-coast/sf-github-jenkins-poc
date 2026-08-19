public with sharing class TimeSlotTriggerHandler extends BaseTriggerHandler{
    private List<TimeSlot> newList;
    private List<TimeSlot> oldList;
    private Map<ID, TimeSlot> newMap;
    private Map<ID, TimeSlot> oldMap;
    
    public TimeSlotTriggerHandler() {
        oldList = (List<TimeSlot>)Trigger.old;
        newList = (List<TimeSlot>)Trigger.new;
        newMap =  (Map<ID, TimeSlot>)Trigger.newMap;
        oldMap = (Map<ID, TimeSlot>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() {
        if(!isBypassed('TimeSlotTriggerHandler')){
            TimeSlotLogic.validate(newList, true, false); //6/17/2021 - CRM-3893 update logic by RC
        }
    }
    
    protected override void beforeUpdate() {
        if(!isBypassed('TimeSlotTriggerHandler')){
            TimeSlotLogic.validate(newList, false, false);//6/17/2021 - CRM-3893 update logic by RC
        }
    }
    
    protected override void beforeDelete() {
        if(!isBypassed('TimeSlotTriggerHandler')){
            TimeSlotLogic.validate(oldList, false, true);//6/17/2021 - CRM-3893 update logic by RC
         }
    }
}