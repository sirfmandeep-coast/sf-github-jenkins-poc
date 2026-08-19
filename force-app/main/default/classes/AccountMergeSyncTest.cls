@isTest

public class AccountMergeSyncTest {
    @isTest static void testAccountMerge() {
        String recTypePerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        String moneyChatOwnerId = UserInfo.getUserId(); 

        List <Account> aList = new List <Account> ();
        Account accRecMasterPersonAcc = new Account(FirstName = 'Test Person', LastName= 'Account Master AAC',  
                            RecordTypeId = recTypePerAccId, DMC_Invited_By__c = moneyChatOwnerId, PD_Rating__c = '', LGD_Rating__c = '', 
                            Group_Risk_Rating__c = '', BRR_Scorecard_Used__c = '', Consent_to_Electronic_Delivery_of_Docume__c = false, 
                            Consent_to_General_Email_Communication__c = true);

        aList.add(accRecMasterPersonAcc);

        Account accRecMergedPersonAcc = new Account(FirstName = 'Test Person', LastName= 'Account Merged AAC',  
                            RecordTypeId = recTypePerAccId, DMC_Invited_By__c = moneyChatOwnerId, PD_Rating__c = '', LGD_Rating__c = '', 
                            Group_Risk_Rating__c = '', BRR_Scorecard_Used__c = '', Consent_to_Electronic_Delivery_of_Docume__c = false, 
                            Consent_to_General_Email_Communication__c = true, Other_Financial_Institution__c = 'Motus');
        aList.add(accRecMergedPersonAcc);
        
        insert aList;

        Account aaMaster =  new Account (Id = aList.get(0).Id);
        aList.get(0).PD_Rating__c = '1';
        aList.get(0).LGD_Rating__c = 'A';
        aList.get(0).Group_Risk_Rating__c = '1';
        aList.get(0).BRR_Scorecard_Used__c = 'Income Producing';
        aList.get(0).Consent_to_Electronic_Delivery_of_Docume__c = true;
        aList.get(0).Consent_to_General_Email_Communication__c = true;
  
        update aList;

        Database.merge(aaMaster, aList.get(1).Id);

        AccountMergeSync.getSync (aaMaster.Id);
    }
}