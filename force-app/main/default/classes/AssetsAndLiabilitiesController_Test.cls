/*******************************************************************************************************************************************************
*   Company         :   Coast Capital Savings Credit Union
*   Class           :   AssetsAndLiabilitiesController_Test
*   Description     :   This Class is used to perform the Unit testing on the AssetsAndLiabilitiesController class.
********************************************************************************************************************************************************
*   Author           :  Sudhakar Botta
*   Date Created     :  [2023.JAN.30]
*   History          :  
*       
*   [2023.JAN.30]  sbotta - Initial Version [Test class for the AssetsAndLiabilitiesController ].
*                         
********************************************************************************************************************************************************/

@isTest
public class AssetsAndLiabilitiesController_Test {
    
    @isTest
    public static void testAssetAndLiabilitiesControllerController() {
        
        String recTypePerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recTypeFinAccountAssetId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Investment Account').getRecordTypeId();
        String recTypeFinAccountLiabilityId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Mortgage').getRecordTypeId();
        String recTypeFinAssetLiability_AssetId = AssetsAndLiabilitiesController.fetchRecTypeIdByName('CCSNonManagedAsset');
        String recTypeFinAssetLiability_LiabilityId = AssetsAndLiabilitiesController.fetchRecTypeIdByName('CCSNonManagedLiability');

       String moneyChatOwnerId = UserInfo.getUserId(); 

        Account accRecPersonAcc = new Account(FirstName = 'Test Person', LastName= 'Account AAC', RecordTypeId = recTypePerAccId, DMC_Invited_By__c = moneyChatOwnerId);
        insert accRecPersonAcc;

        //Creatign 2 fiancial account records
        List<FinServ__FinancialAccount__c> finAccountList = new List<FinServ__FinancialAccount__c>();
        FinServ__FinancialAccount__c ccsManagedAsset = new FinServ__FinancialAccount__c(
                                                                                            Name = 'Test CCS Asset', FinServ__FinancialAccountSource__c = 'CCS',
                                                                                            FinServ__FinancialAccountType__c = 'Term Deposit', 
                                                                                            RecordTypeId = recTypeFinAccountAssetId,
                                                                                            FinServ__Status__c = 'Active',
                                                                                            FinServ__PrimaryOwner__c = accRecPersonAcc.Id

                                                                                        );

        FinServ__FinancialAccount__c ccsManagedLiability = new FinServ__FinancialAccount__c(
                                                                                            Name = 'Test CCS Liability', FinServ__FinancialAccountSource__c = 'CCS',
                                                                                            FinServ__FinancialAccountType__c = 'Mortgage', 
                                                                                            RecordTypeId = recTypeFinAccountLiabilityId,
                                                                                            FinServ__Status__c = 'Active',
                                                                                            FinServ__PrimaryOwner__c = accRecPersonAcc.Id

                                                                                        );
        
        finAccountList.add(ccsManagedAsset);
        finAccountList.add(ccsManagedLiability);
        insert finAccountList;

        
        //Creating Finserv Asset Liabilities record top test the deleteAssetOrLiability 
        
        FinServ__AssetsAndLiabilities__c ccsNonManagedAsset = new FinServ__AssetsAndLiabilities__c(
                                                                                            Name = 'Test CCS Non Managed Asset', FinServ__Amount__c = 10000.50,
                                                                                            FinServ__AssetsAndLiabilitiesType__c = 'Accounts', 
                                                                                            Sub_Type__c = 'Chequing',
                                                                                            FinServ__AssetsAndLiabilitiesSource__c = 'BMO',
                                                                                            RecordTypeId = recTypeFinAssetLiability_AssetId,
                                                                                            FinServ__PrimaryOwner__c = accRecPersonAcc.Id

                                                                                        );
        insert ccsNonManagedAsset;

        Id assetNonMangedRecord = AssetsAndLiabilitiesController.insertNonManagedAssetLiability(accRecPersonAcc.Id, recTypeFinAssetLiability_AssetId, '10000.50', 'BMO', 'Accounts', 'Chequing', System.today() );
        Id liabilityNonMangedRecord = AssetsAndLiabilitiesController.insertNonManagedAssetLiability(accRecPersonAcc.Id, recTypeFinAssetLiability_LiabilityId, '-10000.50', 'BMO', 'Expense', 'Alimony', System.today() ); 
        List<FinServ__FinancialAccount__c> ccsAssetList = AssetsAndLiabilitiesController.getCCSManagedAssets(accRecPersonAcc.Id);
        List<FinServ__FinancialAccount__c> ccsLiabilityList = AssetsAndLiabilitiesController.getCCSManagedLiabilities(accRecPersonAcc.Id);
        List<FinServ__AssetsAndLiabilities__c> nonCCSAssetList = AssetsAndLiabilitiesController.getNonCCSManagedAssets(accRecPersonAcc.Id);
        List<FinServ__AssetsAndLiabilities__c> nonCCSLiabilityList = AssetsAndLiabilitiesController.getNonCCSManagedLiabilities(accRecPersonAcc.Id);
        Boolean isnonCCSAssetRecDeleted = AssetsAndLiabilitiesController.deleteAssetOrLiability(ccsNonManagedAsset.Id);
        //Decimal totalAssetsAmount = AssetsAndLiabilitiesController.getTotalAssetsAmount(accRecPersonAcc.Id);
        //Decimal totalLiabilitiesAmount = AssetsAndLiabilitiesController.getTotalLiabilititesAmount(accRecPersonAcc.Id);


        //System.assertEquals(true, assetNonMangedRecord);
        //System.assertEquals(true, liabilityNonMangedRecord);
        System.assertEquals(1, ccsAssetList.size());
        System.assertEquals(1, ccsLiabilityList.size());
        System.assertEquals(1, nonCCSAssetList.size());
        System.assertEquals(0, nonCCSLiabilityList.size());
        System.assertNotEquals(null, recTypeFinAssetLiability_AssetId);
        //System.assertEquals(10000.50, totalAssetsAmount);
        //System.assertEquals(-10000.50, totalLiabilitiesAmount);
        System.assertEquals(true, isnonCCSAssetRecDeleted );
     }
}