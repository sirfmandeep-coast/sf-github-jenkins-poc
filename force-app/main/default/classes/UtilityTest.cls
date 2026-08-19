/*
    Created By: Anh Phan
    Created Date: 03-Jan-2019
    Purpose: This is a test utility class for test data creation.
    -------------------------------------------------------------------------------------------------
    Modified By:
    Modified Date:
    Purpose:

*/

@isTest
public class UtilityTest {
    
    public static Account createAccount(String accName) {
        
        Account accountRec = new Account(
        
            Name = accName
        );
        
        return accountRec;
    }//End of createAccount
    
    public static Case createCase(String cOrigin) {
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Case caseRec = new Case(
        
            Status = 'New',
            Origin = cOrigin,
            AccountId = acc.Id
        );
        
        return caseRec;
    }//End of createCase
    
    public static User createUser(String uName, String pName) {
        
        User userRec = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name =:pName].Id,
             LastName = uName,
             Email = 'test@abc.com',
             Username = 'test@abc.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        
        return userRec;
        
    }//End of createUser

}//End of UtilityTest