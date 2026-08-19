trigger AccountMergeTrigger on Account (after delete) {

    List<Account> listAccountBackup = new List<Account>();
    Set<Id> masterRecordIds = new Set<Id>();
    Map <Id, Id> accountIdMap = new Map <Id, Id>();
    Map <Id, String> accountIdOFI = new Map <Id, String>();
    

    for(Account acct : trigger.old) {
        if( String.isNotBlank( acct.MasterRecordId ) ) { 
            accountIdMap.put (acct.Id, acct.MasterRecordId);
            if (accountIdMap.get(acct.MasterRecordId) == null) {
                accountIdMap.put(acct.MasterRecordId, acct.MasterRecordId);
            }
            if (!masterRecordIds.contains(acct.MasterRecordId)) {
                masterRecordIds.add( acct.MasterRecordId );
            }
            //MBM-113
            if (String.isNotBlank(acct.Other_Financial_Institution__c)) {
                if (accountIdOFI.get(acct.MasterRecordId) == null) {
                    accountIdOFI.put(acct.MasterRecordId, acct.Other_Financial_Institution__c);
                }
            }
        }         
    }

    AccountMergeSync.populateMasterAccounts(masterRecordIds, accountIdMap, accountIdOFI);
    /*
    system.debug('yea'+ masterRecordIds);
    for (Id masterRecordId : masterRecordIds){
        AccountMergeSync.getSync( masterRecordId );
    }
    */
  /*  listAccountBackup = [Select Id,MasterRecordId from Account where (Id IN: masterRecordIds OR MasterRecordId IN: masterRecordIds) ALL ROWS ]; 
    system.debug('yea'+ masterRecordIds);
    system.debug(listAccountBackup.size());
    system.debug(listAccountBackup);
    if(listAccountBackup.size() > 0) {
        AccountMergeSync.getSync( listAccountBackup, masterRecordIds );
    } */
    
    
}