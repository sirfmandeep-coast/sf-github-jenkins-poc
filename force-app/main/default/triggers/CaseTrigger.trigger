/*
Created By: Anh Phan
Created Date: 01-Jan-2019
Purpose: This class is a helper class for CaseTrigger.
-------------------------------------------------------------------------------------------------
Modified By:
Modified Date:
Purpose:

*/

trigger CaseTrigger on Case (before insert, before update, after insert, after update) {

    if(trigger.isAfter){
        
        if(trigger.isInsert) {
            
            //place holder
            
        }//End of if(trigger.isInsert)
        
        if(trigger.isUpdate) {
            
            CaseTriggerHelper.checkOwnerShipChange(trigger.newmap, trigger.oldmap);
            
        }//End of if(trigger.isInsert)
        
    }//End of if(trigger.isAfter)
    
}//End of CaseTrigger