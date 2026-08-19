global class ccsExpireLeadsScheduler implements Schedulable {
    
    global void execute(SchedulableContext ctx){
      ccsExpireLeads batch = new ccsExpireLeads();
      if(!Test.isRunningTest()){
          Database.executebatch(batch, 200);
      }
    }
}