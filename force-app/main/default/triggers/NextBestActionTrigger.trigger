trigger NextBestActionTrigger on NextBestAction__c (before insert, before update) {
 
    String userName = UserInfo.getName();
    if(userName == 'Service-IICS CRM' )
    {
        new NextBestActionTriggerHandler().setMaxLoopCount(400).run();
        system.debug('inhere');
    }
    else{
        new NextBestActionTriggerHandler().setMaxLoopCount(1).run();
        system.debug('notinhere');
    }
	
}