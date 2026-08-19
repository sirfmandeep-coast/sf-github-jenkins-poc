trigger TimeSlotTrigger on TimeSlot (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {
		//call the handler
		new TimeSlotTriggerHandler().run();
}