public class NBXMultiChannelHelper {
    static Boolean isExecuting = false;

    public static void syncLead (Map <String, String> syncRecordStatusMap ) {
        List <Lead> leadList = [SELECT Id, NBX_External_Id__c, Status, Lost_Reason__c, Lost_Reason_Other__c, Lost_Date__c, Expired__c, FinServ__RelatedAccount__c, Actioned_By_Source__c FROM Lead WHERE NBX_External_Id__c IN :syncRecordStatusMap.keySet() AND Status NOT IN ('Converted', 'Lost') AND RecordType.Name LIKE '%Lead%' ];
        
        For (Lead ll:leadList){
            if (syncRecordStatusMap.get(ll.NBX_External_Id__c) == 'Interested' ) {

                ll.Status = 'Lost';
                ll.Actioned_By_Source__c = 'Inbound';
                ll.Lost_Reason__c = 'Closed By System';
                ll.Lost_Reason_Other__c = 'Actioned as Interested in another channel';
                ll.Lost_Date__c = Date.Today();      
            }
            else if (syncRecordStatusMap.get(ll.NBX_External_Id__c) == 'Not Interested' ) {
                ll.Status = 'Lost';
                ll.Actioned_By_Source__c = 'Inbound';
                ll.Lost_Reason__c = 'Closed By System';
                ll.Lost_Reason_Other__c = 'Actioned as Not Interested in another channel';
                ll.Lost_Date__c = Date.Today();
            }
            else if (syncRecordStatusMap.get(ll.NBX_External_Id__c) == 'Expired') {
                ll.Status = 'Lost';
                ll.Actioned_By_Source__c = 'CRM';
                ll.Lost_Reason__c = 'Closed By System';
                ll.Lost_Reason_Other__c = 'Expired';
                ll.Expired__c = 'True';
                ll.Lost_Date__c = Date.Today();
            }
            else if (syncRecordStatusMap.get(ll.NBX_External_Id__c) == 'Not Applicable') {
                ll.Status = 'Lost';
                ll.Actioned_By_Source__c = 'NBX';
                ll.Lost_Reason__c = 'Closed By System';
                ll.Lost_Reason_Other__c = 'Not Applicable';
                ll.Lost_Date__c = Date.Today();
            }
        }
        
        update leadList;       
    
    }
    
    
    public static void syncNBX (Map <String, String> syncRecordStatusMap ) {
        List <NextBestAction__c> NBXList = [SELECT Id, SourceSystemId__c, Outcome__c, isActive__c, Actioned_By_Source__c, Actioned_Date__c, Actioned_Date_Time__c FROM NextBestAction__c WHERE SourceSystemId__c IN :syncRecordStatusMap.keySet() AND Outcome__c = '' ];
        for (NextBestAction__c NBX : NBXList){
            NBX.Outcome__c = syncRecordStatusMap.get(NBX.SourceSystemId__c);
            NBX.isActive__c = false;
            NBX.Actioned_Date__c = Date.Today();
            NBX.Actioned_Date_Time__c = Datetime.Now();
            if  (NBX.Outcome__c == 'Expired') {
                NBX.Actioned_By_Source__c = 'System';
            }
            else {
                NBX.Actioned_By_Source__c = 'Outbound';
            }
        }
        update NBXList;
    }
    
    public static void syncFromNBXUpdate (List<NextBestAction__c> newRecords, Map <Id, NextBestAction__c> oldRecordsMap) {
        Map<String, String> syncToRecords = new Map<String, String>();
        if (isExecuting == false) {
            isExecuting = true;
            for(NextBestAction__c nextBestAction : newRecords) {        
                 NextBestAction__c oldNBA = oldRecordsMap.get(nextBestAction.Id);
                 If (oldNBA != null && !String.isBlank(nextBestAction.Outcome__c) && nextBestAction.Outcome__c != oldNBA.Outcome__c && !String.isBlank(nextBestAction.SourceSystemId__c) && (nextBestAction.Outcome__c == 'Interested' || nextBestAction.Outcome__c == 'Not Interested' || nextBestAction.Outcome__c == 'Expired' || nextBestAction.Outcome__c == 'Not Applicable')) {
                     nextBestAction.isActive__c = false;
                     if (nextBestAction.Outcome__c == 'Interested' || nextBestAction.Outcome__c == 'Not Interested')
                     {
                         nextBestAction.Actioned_By_Source__c = 'Inbound';
                     }
                     else if (nextBestAction.Outcome__c == 'Expired' || nextBestAction.Outcome__c == 'Not Applicable')
                     {
                         nextBestAction.Actioned_By_Source__c = 'System';
                     }
                     syncToRecords.put (nextBestAction.SourceSystemId__c, nextBestAction.Outcome__c);
                 }
            }
            
            if (syncToRecords.size() > 0 ) {
                syncLead(syncToRecords);
            }
            isExecuting = false;
        }
    }
    
    public static void popluateNBXTemplate (List<NextBestAction__c> newRecords) {
        
        Map<String, String> syncToRecords = new Map<String, String>();
        Map<String, String> NBXToNBXTemplate = new Map<String, String>();
        Map<String, NextBestAction__c> syncNBXTrigger = new Map<String, NextBestAction__c>();
        List<NBX_Template__c> NBXTList = new List<NBX_Template__c>();
        
        for (NextBestAction__c nextBestAction : newRecords) {
            
            if (!String.isBlank(nextBestAction.NBX_Template_Name__c))
            {
                syncNBXTrigger.put (nextBestAction.SourceSystemId__c, nextBestAction);    
                NBXToNBXTemplate.put (nextBestAction.SourceSystemId__c, nextBestAction.NBX_Template_Name__c);
            }
            
        }
        
        NBXTList = [SELECT Id, Inbound_Script__c, Rank__c, Name FROM NBX_Template__c WHERE Name IN :NBXToNBXTemplate.values()];
        for (NBX_Template__c NBXT: NBXTList)
        {
             for (String sourceSystemId:NBXToNBXTemplate.keySet()){
                 If (NBXToNBXTemplate.get(sourceSystemId) == NBXT.Name){
                     syncNBXTrigger.get(sourceSystemId).NBX_Template__c = NBXT.Id;
                     //syncNBXTrigger.get(sourceSystemId).Opportunity__c = NBXT.Inbound_Script__c;
                     if (syncNBXTrigger.get(sourceSystemId).Rank__c == null){
                         syncNBXTrigger.get(sourceSystemId).Rank__c = NBXT.Rank__c;
                     }
                 }
             }    
        }
         
    }
    
    public static void syncFromLeadUpdate (List<Lead> newRecords, Map <Id, Lead> oldRecordsMap) {
        Map<String, String> syncToRecords = new Map<String, String>();
        if (isExecuting == false) {
            isExecuting = true;
            for(Lead ll: newRecords) {        
                 Lead oldLead = oldRecordsMap.get(ll.Id);
                 If (oldLead != null && !String.isBlank(ll.Status) && !String.isBlank(ll.NBX_External_Id__c) && ll.Status!= oldLead.Status && (ll.Status == 'Converted' || ll.Status == 'Lost')) {
                     ll.Actioned_By_Source__c = 'Outbound';
                     if (ll.Status == 'Converted'){
                         syncToRecords.put (ll.NBX_External_Id__c, 'Interested');
        
                     }
                     else if (ll.Status == 'Lost' && ll.Expired__c  == 'True' &&  ll.Lost_Reason__c == 'Closed By System') {
                         syncToRecords.put (ll.NBX_External_Id__c, 'Expired');
                     
                     }
                     else if (ll.Status == 'Lost') {
                         syncToRecords.put (ll.NBX_External_Id__c, 'Not Interested');
                     }
                 }
            }
            
            if (syncToRecords.size() > 0 ) {
                syncNBX (syncToRecords);
            }
            isExecuting = false;
        }
    }
    
}