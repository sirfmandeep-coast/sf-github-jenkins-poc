global class AgencyWebSharingCalculationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    global AgencyWebSharingCalculationBatch() {

    }

    global Database.querylocator start(Database.BatchableContext BC){  
        //String query = ' select Id, Broker__c, Rep_Number__c, (select Id, FinServ__RelatedAccount__c from FinServ__FinancialAccountRoles__r where FinServ__Role__c in (\'Primary Owner\', \'Joint Owner\')) from FinServ__FinancialAccount__c where Broker__c != \'\' and Broker__r.RecordType_Name__c = \'Broker\' and FinServ__FinancialAccountType__c = \'Term Deposit\' '; 
        String query = ' select Id, FinServ__RelatedAccount__c, FinServ__RelatedAccount__r.RecordType_Name__c, FinServ__FinancialAccount__c, FinServ__FinancialAccount__r.Broker__c, FinServ__FinancialAccount__r.Rep_Number__c, FinServ__Role__c  from FinServ__FinancialAccountRole__c where FinServ__Role__c in (\'Primary Owner\', \'Joint Owner\') AND  FinServ__FinancialAccount__r.Broker__c != \'\' and FinServ__FinancialAccount__r.Broker__r.RecordType_Name__c = \'Broker\' and FinServ__FinancialAccount__r.FinServ__FinancialAccountType__c = \'Term Deposit\' Order By FinServ__FinancialAccount__r.Broker__c, FinServ__FinancialAccount__c, FinServ__RelatedAccount__r.RecordType_Name__c, FinServ__RelatedAccount__c ';
        System.Debug('AgencyWebSharingCalculationBatch.Query ' + query);
        Database.querylocator qList = Database.getQueryLocator(query);
        System.Debug('AgencyWebSharingCalculationBatch.start - Getting query locator: ' + qList);
        return qList;
    }

    // execute method
    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
        List<FinServ__FinancialAccountRole__c> financialAccountRoleList = (List<FinServ__FinancialAccountRole__c>) scope;  
        List<User> agencyUserList = new List<User>();
        Set <Id> brokerIdSet = new Set <Id> ();
        Set <Id> accountIdSet = new Set <Id> ();
        Set <Id> userIdSet = new Set<Id> ();
        Set <Id> financialAccountIdSet = new Set<Id> ();
        Set <Id> financialAccountIdSetPrimaryRole = new Set<Id> ();
        Map <String, AccountShare> accountShareMap = new Map <String, AccountShare>();
        Map <String, FinServ__FinancialAccount__Share> financialAccountShareMap = new Map <String, FinServ__FinancialAccount__Share>();
        String agentRepNumber = '';

        for(FinServ__FinancialAccountRole__c financialAccountRole:financialAccountRoleList){ 

            if (!brokerIdSet.contains (financialAccountRole.FinServ__FinancialAccount__r.Broker__c))
            {
                brokerIdSet.add(financialAccountRole.FinServ__FinancialAccount__r.Broker__c);
            }
            if (financialAccountRole.FinServ__RelatedAccount__r.RecordType_Name__c == 'Broker') 
            {
                if (!brokerIdSet.contains (financialAccountRole.FinServ__RelatedAccount__c))
                {
                    brokerIdSet.add(financialAccountRole.FinServ__RelatedAccount__c);
                }
            }
        }

        agencyUserList = [SELECT Id, ContactId, Contact.Agency_Role__c, Contact.Rep_Number__c, Contact.AccountId FROM User WHERE Contact.AccountId IN :brokerIdSet AND (Contact.Agency_Role__c != 'Agent Rep' OR Contact.Rep_Number__c != '') AND Profile.Name = 'CCS External Agent' AND Is_Agency_User__c = True AND isActive = True];
        for (FinServ__FinancialAccountRole__c financialAccountRole:financialAccountRoleList)
        {
            //if (!financialAccountIdSetPrimaryRole.contains(financialAccountRole.FinServ__FinancialAccount__c)) {
                for (User agencyUser: agencyUserList){
                    if (!String.isBlank(agencyUser.Contact.Rep_Number__c))
                    {
                        agentRepNumber = ',' + agencyUser.Contact.Rep_Number__c + ',';
                    }
                    else 
                    {
                        agentRepNumber = ',';
                    }
                    
                    if (
                    ( 
                       /* 
                       (//non-broker, for example: nominee
                        agencyUser.Contact.AccountId == financialAccountRole.FinServ__FinancialAccount__r.Broker__c 
                        && 
                        financialAccountRole.FinServ__RelatedAccount__r.RecordType_Name__c != 'Broker')
                    || 
                        (//broker
                        agencyUser.Contact.AccountId == financialAccountRole.FinServ__RelatedAccount__c
                        &&
                        financialAccountRole.FinServ__RelatedAccount__r.RecordType_Name__c == 'Broker')
                        */
                        
                        (// for direct broker
                        agencyUser.Contact.AccountId == financialAccountRole.FinServ__FinancialAccount__r.Broker__c 
                        )
                    || 
                        (// for owner is broker
                        agencyUser.Contact.AccountId == financialAccountRole.FinServ__RelatedAccount__c
                        &&
                        financialAccountRole.FinServ__RelatedAccount__r.RecordType_Name__c == 'Broker')
                    ) 
                    && (
                        (agencyUser.Contact.Agency_Role__c == 'Agent Rep' && (!String.isBlank(financialAccountRole.FinServ__FinancialAccount__r.Rep_Number__c) && agentRepNumber.contains(',' + financialAccountRole.FinServ__FinancialAccount__r.Rep_Number__c +',')))
                        ||
                        (!String.isBlank(agencyUser.Contact.Agency_Role__c) && agencyUser.Contact.Agency_Role__c != 'Agent Rep')
                    ))
                    {
                        if (!accountIdSet.contains(financialAccountRole.FinServ__RelatedAccount__c))
                        {
                            accountIdSet.add(financialAccountRole.FinServ__RelatedAccount__c);
                        }
                        
                        if (!userIdSet.contains(agencyUser.Id))
                        {
                            userIdSet.add(agencyUser.Id);
                        }
                        
                        if (accountShareMap.get(financialAccountRole.FinServ__RelatedAccount__c + '-' + agencyUser.Id) == null)
                        {     
                            accountShareMap.put(financialAccountRole.FinServ__RelatedAccount__c + '-' + agencyUser.Id, new AccountShare(AccountId = financialAccountRole.FinServ__RelatedAccount__c, UserOrGroupId = agencyUser.Id, AccountAccessLevel = 'Read', OpportunityAccessLevel = 'None', CaseAccessLevel = 'None', RowCause = 'Manual'));
                        }
                        
                        if (!financialAccountIdSet.contains(financialAccountRole.FinServ__FinancialAccount__c))
                        {
                            financialAccountIdSet.add(financialAccountRole.FinServ__FinancialAccount__c);
                        }
                        
                        if (financialAccountShareMap.get(financialAccountRole.FinServ__FinancialAccount__c + '-' + agencyUser.Id) == null)
                        {
                            financialAccountShareMap.put (financialAccountRole.FinServ__FinancialAccount__c + '-' + agencyUser.Id, new FinServ__FinancialAccount__Share(ParentId = financialAccountRole.FinServ__FinancialAccount__c, UserOrGroupId = agencyUser.Id, AccessLevel = 'Read', RowCause = 'Manual'));
                        }
                    }
                }
            //}

            /*
            if ((financialAccountRole.FinServ__RelatedAccount__r.RecordType_Name__c == 'Broker' || financialAccountRole.FinServ__RelatedAccount__r.RecordType_Name__c == 'Business') 
            && financialAccountRole.FinServ__Role__c == 'Primary Owner') 
            {
                if (!financialAccountIdSetPrimaryRole.contains(financialAccountRole.FinServ__FinancialAccount__c))
                {
                    financialAccountIdSetPrimaryRole.add(financialAccountRole.FinServ__FinancialAccount__c);
                }
            }
            */
        }

        
        for (AccountShare existingAccountShare:[SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :accountIdSet AND UserOrGroupId IN :userIdSet AND RowCause = 'Manual'])
        {
            if (accountShareMap.get(existingAccountShare.AccountId + '-' + existingAccountShare.USerOrGroupId) != null)
            {
                accountShareMap.remove (existingAccountShare.AccountId + '-' + existingAccountShare.USerOrGroupId);
            }
        }

        for (FinServ__FinancialAccount__Share existingFinancialAccountShare:[SELECT Id, ParentId, UserOrGroupId FROM FinServ__FinancialAccount__Share WHERE ParentId IN :financialAccountIdSet AND UserOrGroupId IN :userIdSet AND RowCause = 'Manual'])
        {
            if (financialAccountShareMap.get(existingFinancialAccountShare.ParentId + '-' + existingFinancialAccountShare.USerOrGroupId) != null)
            {
                financialAccountShareMap.remove (existingFinancialAccountShare.ParentId + '-' + existingFinancialAccountShare.USerOrGroupId);
            }
        }
        
        insert accountShareMap.values();
        insert financialAccountShareMap.values();

    }

    global void finish(Database.BatchableContext BC){ 
        System.Debug(Logginglevel.DEBUG,'AgencyWebSharingCalculationBatch.finish ');
 
    }
}