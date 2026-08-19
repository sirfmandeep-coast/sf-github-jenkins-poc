public without sharing class AccountMergeSync {
    
    private static String PDRating='';
    private static String LGDRating='';
    private static String GroupRiskRating='';
    private static String BRR_ScoreCard='';
    private static Boolean ConsenttoEDD = false;
    private static Boolean ConsentToEmail = false;
    private static Id masterRecord;
    
    public static void populateMasterAccounts (Set <Id> masterAccountIdSet, Map <Id, Id> accountIdMap, Map <Id, String> accountOFI) {

        Map <Id, String> accountPRRating = new Map <Id, String>();
        Map <Id, String> accountLGDRating = new Map <Id, String>();
        Map <Id, String> accountGroupRiskRating = new Map <Id, String>();
        Map <Id, String> accountBRRScorecardUsed= new Map <Id, String>();
        Map <Id, Boolean> accountConsentEDD= new Map <Id, Boolean>();
        Map <Id, Boolean> accountConsentEmail= new Map <Id, Boolean>();
 
        List<AccountHistory> accHistoryValues = new List<AccountHistory> ();

        if(Test.isRunningTest()){ 
           
            accHistoryValues.add(new AccountHistory(AccountId = new List<Id> (masterAccountIdSet).get(0),  Field = 'PD_Rating__c'));
            accHistoryValues.add(new AccountHistory(AccountId = new List<Id> (masterAccountIdSet).get(0),  Field = 'LGD_Rating__c'));
            accHistoryValues.add(new AccountHistory(AccountId = new List<Id> (masterAccountIdSet).get(0),  Field = 'Group_Risk_Rating__c'));
            accHistoryValues.add(new AccountHistory(AccountId = new List<Id> (masterAccountIdSet).get(0),  Field = 'BRR_Scorecard_Used__c'));
            accHistoryValues.add(new AccountHistory(AccountId = new List<Id> (masterAccountIdSet).get(0),  Field = 'Consent_to_Electronic_Delivery_of_Docume__c'));
            accHistoryValues.add(new AccountHistory(AccountId = new List<Id> (masterAccountIdSet).get(0),  Field = 'Consent_to_General_Email_Communication__c'));
        }
        else {
 
            accHistoryValues = [SELECT Id,NewValue,CreatedDate,Field,AccountId FROM AccountHistory
                        where AccountId IN :accountIdMap.keyset()
                                        AND Field IN ('PD_Rating__c', 'LGD_Rating__c', 'Group_Risk_Rating__c', 'BRR_Scorecard_Used__c', 'Consent_to_Electronic_Delivery_of_Docume__c', 'Consent_to_General_Email_Communication__c')
                                        ORDER BY CREATEDDATE DESC 
                                        ALL ROWS];
        }

        for ( AccountHistory accHistory : accHistoryValues ){
            if (accHistory.Field == 'PD_Rating__c' && accountIdMap.get(accHistory.AccountId)!= null && accountPRRating.get(accountIdMap.get(accHistory.AccountId)) == null) {
                if( accHistory.NewValue != null ) {
                    accountPRRating.put (accountIdMap.get(accHistory.AccountId), accHistory.NewValue.toString());
                }
                else {
                    accountPRRating.put (accountIdMap.get(accHistory.AccountId), '');
                }
            }

            if (accHistory.Field == 'LGD_Rating__c' && accountIdMap.get(accHistory.AccountId)!= null && accountLGDRating.get(accountIdMap.get(accHistory.AccountId)) == null) {
                if( accHistory.NewValue != null ) {
                    accountLGDRating.put (accountIdMap.get(accHistory.AccountId), accHistory.NewValue.toString());
                }
                else {
                    accountLGDRating.put (accountIdMap.get(accHistory.AccountId), '');
                }
            }

            if (accHistory.Field == 'Group_Risk_Rating__c' && accountIdMap.get(accHistory.AccountId)!= null && accountGroupRiskRating.get(accountIdMap.get(accHistory.AccountId)) == null) {
                if( accHistory.NewValue != null ) {
                    accountGroupRiskRating.put (accountIdMap.get(accHistory.AccountId), accHistory.NewValue.toString());
                }
                else {
                    accountGroupRiskRating.put (accountIdMap.get(accHistory.AccountId), '');
                }
            }

            if (accHistory.Field == 'BRR_Scorecard_Used__c' && accountIdMap.get(accHistory.AccountId)!= null && accountBRRScorecardUsed.get(accountIdMap.get(accHistory.AccountId)) == null) {
                if( accHistory.NewValue != null ) {
                    accountBRRScorecardUsed.put (accountIdMap.get(accHistory.AccountId), accHistory.NewValue.toString());
                }
                else {
                    accountBRRScorecardUsed.put (accountIdMap.get(accHistory.AccountId), '');
                }
            }

            if (accHistory.Field == 'Consent_to_Electronic_Delivery_of_Docume__c' && accountIdMap.get(accHistory.AccountId)!= null && accountConsentEDD.get(accountIdMap.get(accHistory.AccountId)) == null) {
                if( accHistory.NewValue != null ) {
                    if ( accHistory.NewValue.toString() == 'true')
                        accountConsentEDD.put (accountIdMap.get(accHistory.AccountId), true);
                    else
                        accountConsentEDD.put (accountIdMap.get(accHistory.AccountId), false);        
                }
                else {
                    accountConsentEDD.put (accountIdMap.get(accHistory.AccountId), false);
                }
            }
            
            if (accHistory.Field == 'Consent_to_General_Email_Communication__c' && accountIdMap.get(accHistory.AccountId)!= null && accountConsentEmail.get(accountIdMap.get(accHistory.AccountId)) == null) {
                if( accHistory.NewValue != null ) {
                    if ( accHistory.NewValue.toString() == 'true')
                        accountConsentEmail.put (accountIdMap.get(accHistory.AccountId), true);
                    else
                        accountConsentEmail.put (accountIdMap.get(accHistory.AccountId), false);        
                }
                else {
                    accountConsentEmail.put (accountIdMap.get(accHistory.AccountId), false);
                }
            }
        }
        insertTracking (masterAccountIdSet, accountPRRating, accountLGDRating, accountGroupRiskRating, accountBRRScorecardUsed, accountConsentEDD, accountConsentEmail, accountOFI);
        updateMasterAccount (masterAccountIdSet, accountPRRating, accountLGDRating, accountGroupRiskRating, accountBRRScorecardUsed, accountConsentEDD, accountConsentEmail, accountOFI);
    }

    public static void insertTracking (Set <Id> masterAccountIdSet, Map <Id, String> accountPRRating, Map <Id, String> accountLGDRating, Map <Id, String> accountGroupRiskRating, Map <Id, String> accountBRRScorecardUsed, Map <Id, Boolean> accountConsentEDD, Map <Id, Boolean> accountConsentEmail, Map <Id, String> accountOFI){
        List <Merge_Account_Tracking__c> MATlist = new List <Merge_Account_Tracking__c> ();
        for (Id recordId : accountPRRating.keySet())
        {
            MATlist.Add (New Merge_Account_Tracking__c(AccountId__c = recordId, Field_Name__c = 'PD_Rating__c', Field_Value__c = accountPRRating.get(recordId)));
        }

        for (Id recordId : accountLGDRating.keySet())
        {
            MATlist.Add (New Merge_Account_Tracking__c(AccountId__c = recordId, Field_Name__c = 'LGD_Rating__c', Field_Value__c = accountLGDRating.get(recordId)));
        }

        for (Id recordId : accountGroupRiskRating.keySet())
        {
            MATlist.Add (New Merge_Account_Tracking__c(AccountId__c = recordId, Field_Name__c = 'Group_Risk_Rating__c', Field_Value__c = accountGroupRiskRating.get(recordId)));
        }

        for (Id recordId : accountBRRScorecardUsed.keySet())
        {
            MATlist.Add (New Merge_Account_Tracking__c(AccountId__c = recordId, Field_Name__c = 'BRR_Scorecard_Used__c', Field_Value__c = accountBRRScorecardUsed.get(recordId)));
        }

        for (Id recordId : accountConsentEDD.keySet())
        {
            MATlist.Add (New Merge_Account_Tracking__c(AccountId__c = recordId, Field_Name__c = 'Consent_to_Electronic_Delivery_of_Docume__c', Field_Value__c = String.ValueOf(accountConsentEDD.get(recordId))));
        }

        for (Id recordId : accountConsentEmail.keySet())
        {
            MATlist.Add (New Merge_Account_Tracking__c(AccountId__c = recordId, Field_Name__c = 'Consent_to_General_Email_Communication__c', Field_Value__c = String.ValueOf(accountConsentEmail.get(recordId))));
        }

        for (Id recordId : accountOFI.keySet())
        {
            MATlist.Add (New Merge_Account_Tracking__c(AccountId__c = recordId, Field_Name__c = 'Other_Financial_Institution__c', Field_Value__c = accountOFI.get(recordId)));
        }

        insert MATlist;
    }
    
    @future
    public static void updateMasterAccount (Set <Id> masterAccountIdSet, Map <Id, String> accountPRRating, Map <Id, String> accountLGDRating, Map <Id, String> accountGroupRiskRating, Map <Id, String> accountBRRScorecardUsed, Map <Id, Boolean> accountConsentEDD, Map <Id, Boolean> accountConsentEmail, Map <Id, String> accountOFI){
        List <Account> accountList = [SELECT Id, PD_Rating__c, LGD_Rating__c, Group_Risk_Rating__c, BRR_Scorecard_Used__c, Consent_to_Electronic_Delivery_of_Docume__c, Consent_to_General_Email_Communication__c, Other_Financial_Institution__c FROM Account WHERE Id IN :masterAccountIdSet];
        For (Account aRecord : accountList) {
            If (accountPRRating.get(aRecord.Id) != null && aRecord.PD_Rating__c !=  accountPRRating.get(aRecord.Id))
            {
                aRecord.PD_Rating__c = accountPRRating.get(aRecord.Id);
            }

            If (accountLGDRating.get(aRecord.Id) != null && aRecord.LGD_Rating__c !=  accountLGDRating.get(aRecord.Id))
            {
                aRecord.LGD_Rating__c = accountLGDRating.get(aRecord.Id);
            }

            If (accountGroupRiskRating.get(aRecord.Id) != null && aRecord.Group_Risk_Rating__c != accountGroupRiskRating.get(aRecord.Id))
            {
                aRecord.Group_Risk_Rating__c = accountGroupRiskRating.get(aRecord.Id);
            }

            If (accountBRRScorecardUsed.get(aRecord.Id) != null && aRecord.BRR_Scorecard_Used__c != accountBRRScorecardUsed.get(aRecord.Id))
            {
                aRecord.BRR_Scorecard_Used__c = accountBRRScorecardUsed.get(aRecord.Id);
            }

            If (accountConsentEDD.get(aRecord.Id) != null && aRecord.Consent_to_Electronic_Delivery_of_Docume__c != accountConsentEDD.get(aRecord.Id))
            {
                aRecord.Consent_to_Electronic_Delivery_of_Docume__c = accountConsentEDD.get(aRecord.Id);
            }

            If (accountConsentEmail.get(aRecord.Id) != null && aRecord.Consent_to_General_Email_Communication__c != accountConsentEmail.get(aRecord.Id))
            {
                aRecord.Consent_to_General_Email_Communication__c = accountConsentEmail.get(aRecord.Id);
            }  
            
            If (accountOFI.get(aRecord.Id) != null && aRecord.Other_Financial_Institution__c != accountOFI.get(aRecord.Id))
            {
                aRecord.Other_Financial_Institution__c = accountOFI.get(aRecord.Id);
            }    
        }
        update accountList;
    }

    @future
    public static void getSync( Id masterRecordId ){
        system.debug('BundasLiga');
        //system.debug(mergeAccounts);
       // system.debug(masterRecordIds);
        Set<Id> queryAccounts = new Set<Id>();
        List<AccountHistory> accHistoryFields = new List<AccountHistory> ();

        if(Test.isRunningTest()){ 
           
            accHistoryFields.add(new AccountHistory(AccountId = masterRecordId,  Field = 'PD_Rating__c'));
            accHistoryFields.add(new AccountHistory(AccountId = masterRecordId,  Field = 'LGD_Rating__c'));
            accHistoryFields.add(new AccountHistory(AccountId = masterRecordId,  Field = 'Group_Risk_Rating__c'));
            accHistoryFields.add(new AccountHistory(AccountId = masterRecordId,  Field = 'BRR_Scorecard_Used__c'));
            accHistoryFields.add(new AccountHistory(AccountId = masterRecordId,  Field = 'Consent_to_Electronic_Delivery_of_Docume__c'));
            accHistoryFields.add(new AccountHistory(AccountId = masterRecordId,  Field = 'Consent_to_General_Email_Communication__c'));
        }
        else {
      /* for (Account acc : mergeAccounts){
           // acc.Id or acc.MasterRecordId IN ( masterRecordIds ) ;
           // then put that acc.Id >> In queryAccounts SET
            if ( masterRecordIds.contains(acc.Id) || masterRecordIds.contains(acc.MasterRecordId )){
                queryAccounts.add( acc.Id );
            }
            system.debug(queryAccounts);
            
        }*/
        // find all account history records where accountid = mergeaccounts and field = pd rating based on order by created date desc 
            accHistoryFields = [Select Id,NewValue,CreatedDate,Field,AccountId from AccountHistory
                                                 where AccountId IN : [Select Id from Account where (Id =: masterRecordId OR MasterRecordId =: masterRecordId) ALL ROWS ]
                                                 AND (Field =: 'PD_Rating__c' OR Field =: 'LGD_Rating__c' OR Field =: 'Group_Risk_Rating__c' OR Field =: 'BRR_Scorecard_Used__c' OR Field =: 'Consent_to_Electronic_Delivery_of_Docume__c' OR Field =: 'Consent_to_General_Email_Communication__c')
                                                 order by createddate desc
                                                 ALL ROWS];
        }
        Boolean setPDRating = false;
        Boolean setLGDRating = false;
        Boolean setGroupRiskRating = false;
        Boolean setBRR_ScoreCard = false;
        Boolean setConsenttoEDD = false;
        Boolean setConsentToEmail = false;
        
        for ( AccountHistory accHistory : accHistoryFields ){
            if( accHistory.Field == 'PD_Rating__c' && setPDRating == false ){
                if( accHistory.NewValue != null )
                PDRating = accHistory.NewValue.toString();
                else
                PDRating = '';
                
                setPDRating = true;
            }
            if(accHistory.Field == 'LGD_Rating__c' && setLGDRating == false  ){
                if( accHistory.NewValue != null )
                LGDRating = accHistory.NewValue.toString();
                else
                LGDRating = '';
                
                setLGDRating = true;
            }
            if(accHistory.Field == 'Group_Risk_Rating__c' && setGroupRiskRating == false  ){
                if( accHistory.NewValue != null )
                GroupRiskRating = accHistory.NewValue.toString();
                else
                GroupRiskRating = '';
                
                setGroupRiskRating = true;
            }
            if(accHistory.Field == 'BRR_Scorecard_Used__c' && setBRR_ScoreCard == false  ){
                if( accHistory.NewValue != null )
                BRR_ScoreCard = accHistory.NewValue.toString();
                else
                BRR_ScoreCard = '';
                
                setBRR_ScoreCard = true;
            }
            if(accHistory.Field == 'Consent_to_Electronic_Delivery_of_Docume__c' && setConsenttoEDD == false  ){
                if( accHistory.NewValue != null ){
                string consentEDD = accHistory.NewValue.toString();
                    if ( consentEDD == 'true')
                        ConsenttoEDD = true;
                    else
                        ConsenttoEDD = false;
                }
                else
                ConsenttoEDD = false;
                
                setConsenttoEDD = true;
            }
            if(accHistory.Field == 'Consent_to_General_Email_Communication__c' && setConsentToEmail == false  ){
                if( accHistory.NewValue != null ){
                string consentEmail = accHistory.NewValue.toString();
                    if ( consentEmail == 'true')
                        ConsentToEmail = true;
                    else
                        ConsentToEmail = false;
                }
                else
                ConsentToEmail = false;
                
                setConsentToEmail = true;
            }
            
        }
        // List<AccountHistory> accHistoryField2 = [Select Id,NewValue,CreatedDate,AccountId from AccountHistory where AccountId IN : mergeAccounts AND Field =: 'LGD_Rating__c' order by createddate desc LIMIT 1 ALL ROWS];
        // List<AccountHistory> accHistoryField3 = [Select Id,NewValue,CreatedDate,AccountId from AccountHistory where AccountId IN : mergeAccounts AND Field =: 'Group_Risk_Rating__c' order by createddate desc LIMIT 1 ALL ROWS];
        // List<AccountHistory> accHistoryField4 = [Select Id,NewValue,CreatedDate,AccountId from AccountHistory where AccountId IN : mergeAccounts AND Field =: 'BRR_Scorecard_Used__c' order by createddate desc LIMIT 1 ALL ROWS];
        // List<AccountHistory> accHistoryField5 = [Select Id,NewValue,CreatedDate,AccountId from AccountHistory where AccountId IN : mergeAccounts AND Field =: 'Consent_to_Electronic_Delivery_of_Docume__c' order by createddate desc LIMIT 1 ALL ROWS];
        // List<AccountHistory> accHistoryField6 = [Select Id,NewValue,CreatedDate,AccountId from AccountHistory where AccountId IN : mergeAccounts AND Field =: 'Consent_to_General_Email_Communication__c' order by createddate desc LIMIT 1 ALL ROWS];
        system.debug(accHistoryFields);
        system.debug(accHistoryFields.size());
        /*
        if( accHistoryField1[0].NewValue != null )
        PDRating = accHistoryField1[0].NewValue.toString();
        if( accHistoryField2[0].NewValue != null )
        LGDRating = accHistoryField2[0].NewValue.toString();
        if( accHistoryField3[0].NewValue != null )
        GroupRiskRating = accHistoryField3[0].NewValue.toString();
        if( accHistoryField4[0].NewValue != null )
        BRR_ScoreCard = accHistoryField4[0].NewValue.toString();
        
        if( accHistoryField5[0].NewValue != null ){
        String strConsenttoEDD = accHistoryField5[0].NewValue.toString();
            if (strConsenttoEDD == 'true')
            ConsenttoEDD = true;
            else if (strConsenttoEDD == 'false')
            ConsenttoEDD = false;   
        }
        if( accHistoryField6[0].NewValue != null ){
        String strConsentToEmail = accHistoryField6[0].NewValue.toString();
            if (strConsentToEmail == 'true')
            ConsentToEmail = true;
            else if (strConsentToEmail == 'false')
            ConsentToEmail = false;  
        }
        */
        
        masterRecord = masterRecordId;
        accUpdate( PDRating, LGDRating, GroupRiskRating, BRR_ScoreCard, ConsenttoEDD, ConsentToEmail, masterRecord );
        
    }
    
 
    public static void accUpdate ( String PDRating, String LGDRating, String GroupRiskRating, String BRR_ScoreCard, Boolean ConsenttoEDD, Boolean ConsentToEmail, Id  masterRecord ){
        // update the new value on Account record where Id = masterrecord
        Account accUpdate = [Select Id,PD_Rating__c,LGD_Rating__c,Group_Risk_Rating__c,BRR_Scorecard_Used__c from Account where Id=: masterRecord LIMIT 1];
        accUpdate.PD_Rating__c = PDRating;
        accUpdate.LGD_Rating__c = LGDRating;
        accUpdate.Group_Risk_Rating__c = GroupRiskRating;
        accUpdate.BRR_Scorecard_Used__c = BRR_ScoreCard;
        accUpdate.Consent_to_Electronic_Delivery_of_Docume__c = ConsenttoEDD;
        accUpdate.Consent_to_General_Email_Communication__c = ConsentToEmail;
      
        update accUpdate;
       
    }        
    

}