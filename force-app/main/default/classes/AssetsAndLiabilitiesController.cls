/*******************************************************************************************************************************************************
*   Company         :   Coast Capital Savings Credit Union
*   Class           :   AssetsAndLiabilitiesController
*   Description     :   This Class is used to GET date from FinServ__FinancialAccount__c and GET/SET data from/into FinServ__AssetsAndLiabilities__c
********************************************************************************************************************************************************
*   Author           :  Sudhakar Botta
*   Date Created     :  [2022.SEP.12]
*   History          :  
*       
*   [2022.SEP.12]  sbotta - Initial Version [Created the getCCSManagedAssets/getNonCCSManagedAssets method which fetches the data from the FinServ__FinancialAccount__c].
*   [2022.SEP.14]  sbotta - [Created the getCCSManagedLiabilities/getNonCCSManagedLiabilities method which fetches the data from the FinServ__AssetsAndLiabilities__c].
*   [2022.OCT.03]  sbotta - [Created the insertNonManagedAssetLiability method which inserts and creates new records in FinServ__AssetsAndLiabilities__c].
*   [2022.OCT.06]  sbotta - [Created the deleteAssetOrLiability method which soft deletes a record from FinServ__AssetsAndLiabilities__c making a field Is Deleted selected].
*   [2022.OCT.19]  sbotta - [Created the getTotalLiabilititesAmount/getTotalAssetsAmount method calculates the total mount value from Managed and Non Managed Assets and Liabilities].
*                         
********************************************************************************************************************************************************/
public with sharing class AssetsAndLiabilitiesController {

    public static Decimal assetsSubTotal;
    public static Decimal liabilitiesSubTotal;
    public static Set<String> stringfinAccountStatusFilterSet = new Set<String>{'Closed','Pending.Closure','Expired','Dormant','Inactive'};

    @AuraEnabled
    public static List<FinServ__FinancialAccount__c> getCCSManagedAssets(String AccountId) { 
        
        
        Integer numOfDaysBetweenTodayAndLastModified = 0;
        
        
        List<FinServ__FinancialAccount__c> ccsAssetList = [select Id, Name, FinServ__FinancialAccountSource__c, FinServ__LastTransactionDate__c, FinServ__Status__c, FinServ__FinancialAccountType__c, 
                                                            FinServ__Balance__c, FinServ__RecordTypeName__c, LastModifiedDate, Maturity_Date__c, Plan_Type__c,
                                                            (select Id, Name, Ownership_Percent__c from FinServ__FinancialAccountRoles__r where FinServ__RelatedAccount__c =:AccountId)
                                                            FROM FinServ__FinancialAccount__c
                                                            where 
                                                            Id IN (select FinServ__FinancialAccount__c from FinServ__FinancialAccountRole__c where FinServ__RelatedAccount__c =:AccountId)
                                                            AND
                                                            FinServ__Status__c NOT IN: stringfinAccountStatusFilterSet 
                                                            AND 
                                                            (
                                                                FinServ__RecordTypeName__c = 'General Account' OR
                                                                FinServ__RecordTypeName__c = 'Investment Account' OR 
                                                                (
                                                                    (FinServ__Balance__c >=0 OR FinServ__Balance__c = null) AND
                                                                    //FinServ__TotalCreditLimit__c = Null AND
                                                                    (
                                                                        FinServ__RecordTypeName__c = 'Bank Account' OR 
                                                                        FinServ__RecordTypeName__c = 'Checking Account'
                                                                    )
                                                                )
                                                            )
                                                            ];

        for(FinServ__FinancialAccount__c finAccount : ccsAssetList){
            finAccount.FinServ__FinancialAccountSource__c = 'CCS';
        }
        return ccsAssetList;

    }

    @AuraEnabled
    public static List<FinServ__AssetsAndLiabilities__c> getNonCCSManagedAssets(String AccountId) {
      
                                                            
        List<FinServ__AssetsAndLiabilities__c> nonCCSAssetList = [SELECT Id,Name,FinServ__Amount__c,LastModifiedDate,FinServ__AssetsAndLiabilitiesType__c,
                                                            Sub_Type__c,FinServ__AssetsAndLiabilitiesSource__c, RecordType.Name, Is_Deleted__c, Maturity_Date__c, Primary_Ownership_Percent__c,
                                                            (select Id, Name, Ownership_Percent__c from Asset_Liability_Roles__r where Account__c =:AccountId)
                                                            FROM FinServ__AssetsAndLiabilities__c 
                                                            WHERE Id IN (select Assets_and_Liabilities__c from Asset_Liability_Role__c where Account__c =:AccountId) AND Is_Deleted__c = false AND RecordType.Name = 'CCSNonManagedAsset' 
                                                        ];                                                 
        return nonCCSAssetList;
    }

    @AuraEnabled
    public static List<FinServ__FinancialAccount__c> getCCSManagedLiabilities(String AccountId) {
        Integer numOfDaysBetweenTodayAndLastModified = 0;
        List<FinServ__FinancialAccount__c> ccsLiabilityList = [select Id, Name, FinServ__FinancialAccountSource__c, FinServ__LastTransactionDate__c, FinServ__Status__c, FinServ__FinancialAccountType__c, 
                                                            FinServ__Balance__c, FinServ__RecordTypeName__c, LastModifiedDate, Maturity_Date__c, FinServ__RenewalDate__c, Plan_Type__c,
                                                            (select Id, Name, Ownership_Percent__c from FinServ__FinancialAccountRoles__r where FinServ__RelatedAccount__c =:AccountId)
                                                            FROM FinServ__FinancialAccount__c
                                                            where 
                                                            Id IN (select FinServ__FinancialAccount__c from FinServ__FinancialAccountRole__c where FinServ__RelatedAccount__c =:AccountId)
                                                            AND
                                                            FinServ__Status__c NOT IN: stringfinAccountStatusFilterSet 
                                                            AND 
                                                            (
                                                                FinServ__RecordTypeName__c = 'Credit Card' OR
                                                                FinServ__RecordTypeName__c = 'Loan Account' OR
                                                                FinServ__RecordTypeName__c = 'Mortgage' OR
                                                                (
                                                                    (FinServ__Balance__c < 0 AND FinServ__Balance__c != null) AND
                                                                    //FinServ__TotalCreditLimit__c != Null AND
                                                                    (
                                                                        FinServ__RecordTypeName__c = 'Bank Account' OR 
                                                                        FinServ__RecordTypeName__c = 'Checking Account'
                                                                    )
                                                                )
                                                            )
                                                            ];

                                                            
        
        for(FinServ__FinancialAccount__c finAccount : ccsLiabilityList){
            finAccount.FinServ__FinancialAccountSource__c = 'CCS';
        }
        return ccsLiabilityList;
    }

    @AuraEnabled
    public static List<FinServ__AssetsAndLiabilities__c> getNonCCSManagedLiabilities(String AccountId) {
        
        List<FinServ__AssetsAndLiabilities__c> nonCCSLiabilityList = [SELECT Id,Name,FinServ__Amount__c,LastModifiedDate,FinServ__AssetsAndLiabilitiesType__c,
                                            Sub_Type__c,FinServ__AssetsAndLiabilitiesSource__c, RecordType.Name, Is_Deleted__c, Maturity_Date__c, Primary_Ownership_Percent__c,
                                            (select Id, Name, Ownership_Percent__c from Asset_Liability_Roles__r where Account__c =:AccountId)
                                            FROM FinServ__AssetsAndLiabilities__c 
                                            WHERE Id IN (select Assets_and_Liabilities__c from Asset_Liability_Role__c where Account__c =:AccountId) AND Is_Deleted__c = false AND RecordType.Name = 'CCSNonManagedLiability' 
    ];       
        return nonCCSLiabilityList;
    }

    @AuraEnabled
    public static Boolean deleteAssetOrLiability(Id assetLiabilityId){
        Boolean assetOrLiabilityDeleted =false;
        try{
            List<FinServ__AssetsAndLiabilities__c> nonManagedAssetLiability = [SELECT Id,Is_Deleted__c FROM FinServ__AssetsAndLiabilities__c WHERE Id =:assetLiabilityId LIMIT 1];
            if(nonManagedAssetLiability.size() > 0){
                for(FinServ__AssetsAndLiabilities__c assetOrLiability : nonManagedAssetLiability){
                    assetOrLiability.Is_Deleted__c = true;
                }
            }
            update nonManagedAssetLiability;
            assetOrLiabilityDeleted= true;
        }
        catch(Exception ex){
            System.debug('Exception Occured  :: '+ex.getMessage());
        }
        return assetOrLiabilityDeleted;
    }

    
    @AuraEnabled
    public static Id insertNonManagedAssetLiability(String AccountId, String recTypeId, String Amount, String Source, String Type, String SubType, Date maturityDate){ 
        Boolean insertAsset =false;
        FinServ__AssetsAndLiabilities__c asst = new FinServ__AssetsAndLiabilities__c();
        Asset_Liability_Role__c assetLiabilityRoleRecord = new Asset_Liability_Role__c();
        List<Asset_Liability_Role__c> assetLiabilityRoleList = new List<Asset_Liability_Role__c>();
        try{
            if(SubType != null){
                asst.Name = Source+'-'+Type+'-'+SubType;
            }
            else{
                asst.Name = Source+'-'+Type;
            }

            Account acc = [Select Id, Name from Account where Id =: AccountId];
            String accName = acc.Name;
                
            asst.FinServ__PrimaryOwner__c=AccountId;
            asst.FinServ__Amount__c =Decimal.valueOf(Amount);
            asst.RecordTypeId =recTypeId;
            asst.FinServ__AssetsAndLiabilitiesSource__c = Source;
            asst.FinServ__AssetsAndLiabilitiesType__c = Type;
            asst.Sub_Type__c = SubType;
            if(maturityDate !=null){
                asst.Maturity_Date__c = maturityDate;
            }
            insert asst;

            assetLiabilityRoleRecord.Account__c = AccountId;
            assetLiabilityRoleRecord.Assets_and_Liabilities__c = asst.Id;
            assetLiabilityRoleRecord.Ownership_Percent__c = 100;
            assetLiabilityRoleRecord.Account_Name__c = accName;
            assetLiabilityRoleRecord.Role__c = 'Primary Owner';
            assetLiabilityRoleList.add(assetLiabilityRoleRecord);


            insert assetLiabilityRoleList;
            insertAsset= true;
        }
         catch(Exception ex){
            System.debug('Exception Occured  :: '+ex.getMessage());
        } 
        return asst.Id;
    }
    
    @AuraEnabled 
    public static String fetchRecTypeIdByName(String recTypeName) {

        String nonManagedId =[SELECT Id FROM RecordType WHERE SObjectType='FinServ__AssetsAndLiabilities__c' AND Name=:recTypeName LIMIT 1].Id;
        return nonManagedId;

    }

    //New changes for the ownership page display April 25th 2023
    @AuraEnabled(cacheable=true)
    public static List<Asset_Liability_Role__c> getAssetRoles(String assetId){
        List<Asset_Liability_Role__c> assetRolesList = [SELECT Id, Name, Role__c, Ownership_Percent__c, Account__c, Account_Name__c 
                                                            FROM Asset_Liability_Role__c WHERE Assets_and_Liabilities__c =:assetId];
        return assetRolesList;
        
    }

    @AuraEnabled
    public static List<Asset_Liability_Role__c> getAssetRecordRoles(String assetId){
        List<Asset_Liability_Role__c> assetRolesList = [SELECT Id, Name, Role__c, Ownership_Percent__c, Account__c, Account_Name__c 
                                                            FROM Asset_Liability_Role__c WHERE Assets_and_Liabilities__c =:assetId];
        return assetRolesList;
        
    }
    
    @AuraEnabled
    public static Decimal getTotalAssetsAmount(String AccountId) {
        assetsSubTotal = 0;
        Decimal ccsAssetsTotal = 0;
        Decimal nonCCSAssetsTotal = 0;
        List<FinServ__AssetsAndLiabilities__c> nonCCSAssetList = [SELECT Id, Name, FinServ__Amount__c, (select Ownership_Percent__c from Asset_Liability_Roles__r where Account__c =:AccountId) FROM FinServ__AssetsAndLiabilities__c 
                                                            WHERE Id IN (select Assets_and_Liabilities__c from Asset_Liability_Role__c where Account__c =:AccountId) AND Is_Deleted__c = false AND RecordType.Name = 'CCSNonManagedAsset' 
                                                        ];                       

        for(FinServ__AssetsAndLiabilities__c asset : nonCCSAssetList) {
            //NWS 1.1
            for(Asset_Liability_Role__c assetRole : asset.Asset_Liability_Roles__r) {
                Decimal amountPercentageCalculation = ((assetRole.Ownership_Percent__c/100) * asset.FinServ__Amount__c);
                nonCCSAssetsTotal += amountPercentageCalculation;
            //NWS 1.1
            }
        }                               
        List<FinServ__FinancialAccount__c> ccsAssetList = [select Id, FinServ__Balance__c, 
                                                            (select Id, Name, Ownership_Percent__c from FinServ__FinancialAccountRoles__r where FinServ__RelatedAccount__c =:AccountId)
                                                            FROM FinServ__FinancialAccount__c
                                                            where 
                                                            Id IN (select FinServ__FinancialAccount__c from FinServ__FinancialAccountRole__c where FinServ__RelatedAccount__c =:AccountId)
                                                            AND
                                                            FinServ__Status__c NOT IN: stringfinAccountStatusFilterSet 
                                                            AND 
                                                            (
                                                                FinServ__RecordTypeName__c = 'General Account' OR
                                                                FinServ__RecordTypeName__c = 'Investment Account' OR 
                                                                (
                                                                    (FinServ__Balance__c >=0 OR FinServ__Balance__c = null) AND
                                                                    //FinServ__TotalCreditLimit__c = Null AND
                                                                    (
                                                                        FinServ__RecordTypeName__c = 'Bank Account' OR 
                                                                        FinServ__RecordTypeName__c = 'Checking Account'
                                                                    )
                                                                )
                                                            )
                                                            ];

        for(FinServ__FinancialAccount__c asset : ccsAssetList) {
             //NWS 1.1
             for(FinServ__FinancialAccountRole__c assetRole : asset.FinServ__FinancialAccountRoles__r) {
                if(asset.FinServ__Balance__c != null){}
                    Decimal amountPercentageCalculation = ((assetRole.Ownership_Percent__c/100) * asset.FinServ__Balance__c);
                    ccsAssetsTotal += amountPercentageCalculation;
                }
            //NWS 1.1
        }
        assetsSubTotal = nonCCSAssetsTotal + ccsAssetsTotal;
        return assetsSubTotal;
    }

    @AuraEnabled
    public static Decimal getTotalLiabilititesAmount(String AccountId) {
        liabilitiesSubTotal = 0;
        Decimal ccsliabilitiesTotal = 0;
        Decimal nonCCSliabilitiesTotal = 0;
        List<FinServ__AssetsAndLiabilities__c> nonCCSLiabilityList = [SELECT Id, FinServ__Amount__c, (select Ownership_Percent__c from Asset_Liability_Roles__r where Account__c =:AccountId) FROM FinServ__AssetsAndLiabilities__c 
                                            WHERE Id IN (select Assets_and_Liabilities__c from Asset_Liability_Role__c where Account__c =:AccountId) AND Is_Deleted__c = false AND RecordType.Name = 'CCSNonManagedLiability' 
    ];                                                                       
        for(FinServ__AssetsAndLiabilities__c nonCCSLiability : nonCCSLiabilityList) {
            if(nonCCSLiability.FinServ__Amount__c > 0){
                nonCCSLiability.FinServ__Amount__c = -nonCCSLiability.FinServ__Amount__c;
            }
            //NWS 1.1
            for(Asset_Liability_Role__c liabilityRole : nonCCSLiability.Asset_Liability_Roles__r) {
                Decimal amountPercentageCalculation = ((liabilityRole.Ownership_Percent__c/100) * nonCCSLiability.FinServ__Amount__c);
                nonCCSliabilitiesTotal += amountPercentageCalculation;
            //NWS 1.1
            }
        }                               
        List<FinServ__FinancialAccount__c> ccsLiabilitiesList = [select Id, FinServ__Balance__c,
                                                            (select Id, Name, Ownership_Percent__c from FinServ__FinancialAccountRoles__r where FinServ__RelatedAccount__c =:AccountId)
                                                            FROM FinServ__FinancialAccount__c
                                                            where 
                                                            Id IN (select FinServ__FinancialAccount__c from FinServ__FinancialAccountRole__c where FinServ__RelatedAccount__c =:AccountId)
                                                            AND
                                                            FinServ__Status__c NOT IN: stringfinAccountStatusFilterSet 
                                                            AND 
                                                            (
                                                                FinServ__RecordTypeName__c = 'Credit Card' OR
                                                                FinServ__RecordTypeName__c = 'Loan Account' OR
                                                                FinServ__RecordTypeName__c = 'Mortgage' OR
                                                                (
                                                                    (FinServ__Balance__c < 0 AND FinServ__Balance__c != null) AND
                                                                    //FinServ__TotalCreditLimit__c != Null AND
                                                                    (
                                                                        FinServ__RecordTypeName__c = 'Bank Account' OR 
                                                                        FinServ__RecordTypeName__c = 'Checking Account'
                                                                    )
                                                                )
                                                            )
                                                            ];


        for(FinServ__FinancialAccount__c liability : ccsLiabilitiesList) {
            //NWS 1.1
            for(FinServ__FinancialAccountRole__c liabilityRole : liability.FinServ__FinancialAccountRoles__r) {
                if(liability.FinServ__Balance__c != null){
                    if(liability.FinServ__Balance__c > 0){
                        liability.FinServ__Balance__c = -liability.FinServ__Balance__c;
                    }
                    Decimal amountPercentageCalculation = ((liabilityRole.Ownership_Percent__c/100) * liability.FinServ__Balance__c);
                    ccsliabilitiesTotal += amountPercentageCalculation;
                }
            }
            //NWS 1.1
        }
        liabilitiesSubTotal = nonCCSliabilitiesTotal + ccsliabilitiesTotal;
        return liabilitiesSubTotal;
    }

    //NWS1.1 changes
    @AuraEnabled
    public static Boolean deleteAssetOrLiabilityRole(Id assetLiabilityRoleId){
        Boolean assetOrLiabilityRoleDeleted =false;
        try{
            List<Asset_Liability_Role__c> assetLiabilityRoleRecId = [SELECT Id FROM Asset_Liability_Role__c WHERE Id =:assetLiabilityRoleId LIMIT 1];
            if(assetLiabilityRoleRecId.size() > 0){
                delete assetLiabilityRoleRecId;
                assetOrLiabilityRoleDeleted= true;
            }
            
        }
        catch(Exception ex){
            System.debug('Exception Occured  :: '+ex.getMessage());
        }
        return assetOrLiabilityRoleDeleted;
    }

    @AuraEnabled
    public static string updateCCSAssetOrLiabilityOwnershipPercent(Object data, String accountId){
        List<String> assetIdList = new List<Id>();
        List<FinServ__FinancialAccountRole__c> assetLiabilityRolesToUpdate = new List<FinServ__FinancialAccountRole__c>();

        List<FinServ__FinancialAccount__c> assetOrLiabilityForUpdate = (List<FinServ__FinancialAccount__c>) JSON.deserialize(
                                                                                                                                        JSON.serialize(data),
                                                                                                                                        List<FinServ__FinancialAccount__c>.class
                                                                                                                                  );

        for(FinServ__FinancialAccount__c recIdsToUpdate : assetOrLiabilityForUpdate){
            assetIdList.add(recIdsToUpdate.Id);
        }                                                                                                                                   
        try {
            update assetOrLiabilityForUpdate;
            //NWS1.1
            List<FinServ__FinancialAccount__c> assetOrLiabilityList = [select Id, Name, Primary_Ownership_Percent__c, 
                                                                                    (select Id, Name, Ownership_Percent__c from FinServ__FinancialAccountRoles__r where FinServ__RelatedAccount__c =:accountId)
                                                                                    FROM 
                                                                                    FinServ__FinancialAccount__c
                                                                                    WHERE
                                                                                        Id IN :assetIdList

                                                                                    ];
            for(FinServ__FinancialAccount__c assetLiabilityList: assetOrLiabilityList)  {
                List<FinServ__FinancialAccountRole__c> assetLiabiltyRole = assetLiabilityList.FinServ__FinancialAccountRoles__r;
                for(FinServ__FinancialAccountRole__c roleList : assetLiabiltyRole){
                    roleList.Ownership_Percent__c = assetLiabilityList.Primary_Ownership_Percent__c;
                    assetLiabilityRolesToUpdate.add(roleList);
                }
            }
            update assetLiabilityRolesToUpdate;                                                                                 
            //NWS 1.1
            return 'Success: Asset Or Liability Ownership updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static string updateAssetOrLiability (Object data, String accountId) {

        List<String> assetIdList = new List<Id>();
        List<Asset_Liability_Role__c> assetLiabilityRolesToUpdate = new List<Asset_Liability_Role__c>();

        List<FinServ__AssetsAndLiabilities__c> assetOrLiabilityForUpdate = (List<FinServ__AssetsAndLiabilities__c>) JSON.deserialize(
                                                                                                                                        JSON.serialize(data),
                                                                                                                                        List<FinServ__AssetsAndLiabilities__c>.class
                                                                                                                                  );

        for(FinServ__AssetsAndLiabilities__c recIdsToUpdate : assetOrLiabilityForUpdate){
            assetIdList.add(recIdsToUpdate.Id);
        }                                                                                                                                   
        try {
            update assetOrLiabilityForUpdate;
            //NWS1.1
            List<FinServ__AssetsAndLiabilities__c> assetOrLiabilityList = [select Id, Name, Primary_Ownership_Percent__c, 
                                                                                    (select Id, Name, Ownership_Percent__c from Asset_Liability_Roles__r where Account__c =:accountId)
                                                                                    FROM 
                                                                                        FinServ__AssetsAndLiabilities__c
                                                                                    WHERE
                                                                                        Id IN :assetIdList

                                                                                    ];
            for(FinServ__AssetsAndLiabilities__c assetLiabilityList: assetOrLiabilityList)  {
                List<Asset_Liability_Role__c> assetLiabiltyRole = assetLiabilityList.Asset_Liability_Roles__r;
                for(Asset_Liability_Role__c roleList : assetLiabiltyRole){
                    roleList.Ownership_Percent__c = assetLiabilityList.Primary_Ownership_Percent__c;
                    assetLiabilityRolesToUpdate.add(roleList);
                }
            }
            update assetLiabilityRolesToUpdate;                                                                                 
            //NWS 1.1
            return 'Success: Asset Or Liability Ownership updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
        //return null;
    }
    //NWS1.1 changes
}