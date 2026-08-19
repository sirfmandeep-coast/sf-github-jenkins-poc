public with sharing class OperatingHoursTriggerHandler extends BaseTriggerHandler{
    private List<OperatingHours> newList;
    private List<OperatingHours> oldList;
    private Map<ID, OperatingHours> newMap;
    private Map<ID, OperatingHours> oldMap;
    
    public OperatingHoursTriggerHandler() {
        oldList = (List<OperatingHours>)Trigger.old;
        newList = (List<OperatingHours>)Trigger.new;
        newMap =  (Map<ID, OperatingHours>)Trigger.newMap;
        oldMap = (Map<ID, OperatingHours>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() {
        if(!isBypassed('OperatingHoursTriggerHandler')){
            OperatingHoursLogic.validate(newList, true, false);//6/17/2021 - CRM-3893 update logic by RC
         }
    }
    
    protected override void beforeUpdate() {
        if(!isBypassed('OperatingHoursTriggerHandler')){
            OperatingHoursLogic.validate(newList, false, false);//6/17/2021 - CRM-3893 update logic by RC
        }
    }
    
    protected override void beforeDelete() {
        if(!isBypassed('OperatingHoursTriggerHandler')){
            OperatingHoursLogic.validate(oldList, false, true);//6/17/2021 - CRM-3893 update logic by RC
        }
    }
    
}