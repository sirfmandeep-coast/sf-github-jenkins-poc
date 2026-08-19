trigger LeadTrigger on Lead  (before update) {
    new LeadTriggerHandler().setMaxLoopCount(1).run();
}