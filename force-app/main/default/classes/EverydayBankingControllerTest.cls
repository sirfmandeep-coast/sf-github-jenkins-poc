@isTest
public class EverydayBankingControllerTest {
    @isTest static void testGetFinancialAccountNumber() {
        String recTypePerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recTypeFinAccountAssetId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Investment Account').getRecordTypeId();
        String recTypeFinAccountLiabilityId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Mortgage').getRecordTypeId();

        String moneyChatOwnerId = UserInfo.getUserId(); 

        Account accRecPersonAcc = new Account(FirstName = 'Test Person', LastName= 'Account AAC', RecordTypeId = recTypePerAccId, DMC_Invited_By__c = moneyChatOwnerId);
        insert accRecPersonAcc;

        FinServ__FinancialAccount__c FA = new FinServ__FinancialAccount__c(
                                                                                            Name = 'Test CCS Asset', FinServ__FinancialAccountSource__c = 'CCS',
                                                                                            FinServ__FinancialAccountType__c = 'Term Deposit', 
                                                                                            RecordTypeId = recTypeFinAccountAssetId,
                                                                                            FinServ__Status__c = 'Active',
                                                                                            FinServ__PrimaryOwner__c = accRecPersonAcc.Id

                                                                                        );
        insert FA;
        EverydayBankingController.getFinanicalAccount (FA.Id);
    }

    @isTest static void testGetLoyaltyProductsByProfileId200() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockEverydayBankingResponseGenerator('profile', 200));
        
        string returnMsg = EverydayBankingController.getLoyaltyProductsByProfileId('11111');
        
    }

    @isTest static void testGetLoyaltyProductsByProfileId400() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockEverydayBankingResponseGenerator('profile', 400));
        
        try{
            string returnMsg = EverydayBankingController.getLoyaltyProductsByProfileId('11111');
            system.assert(false, 'Should have thrown an exception');
        }catch(Exception e){
           
        }
        
        
    }

    @isTest static void testGetLoyaltyProductsByProfileId500() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockEverydayBankingResponseGenerator('profile', 500));
        
        try{
            string returnMsg = EverydayBankingController.getLoyaltyProductsByProfileId('11111');
            system.assert(false, 'Should have thrown an exception');
        }catch(Exception e){
           
        }
        
        
    }

    @isTest static void testGetLoyaltyProductsByAccountNumber200() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockEverydayBankingResponseGenerator('account', 200));
        
        string returnMsg = EverydayBankingController.getLoyaltyProductsByAccountNumber('11111');
        
    }

    @isTest static void testGetLoyaltyProductsByAccountNumber400() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockEverydayBankingResponseGenerator('account', 400));
        try {
            string returnMsg = EverydayBankingController.getLoyaltyProductsByAccountNumber('11111');
            system.assert(false, 'Should have thrown an exception');
        }catch(Exception e){
           
        }
    }

    @isTest static void testGetLoyaltyProductsByAccountNumber500() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockEverydayBankingResponseGenerator('account', 500));
        try {
            string returnMsg = EverydayBankingController.getLoyaltyProductsByAccountNumber('11111');
            system.assert(false, 'Should have thrown an exception');
        }catch(Exception e){
           
        }
    }
}