trigger OperatingHoursTrigger on OperatingHours (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {
		//call the handler
		new OperatingHoursTriggerHandler().run();
}