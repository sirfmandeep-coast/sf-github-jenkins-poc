@isTest
public class PracticeManagementControllerTest {

    
    @isTest
    public static void testPracticeManagementControllerMethod() {
        String recTypePerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        List <Account> aaList = new List <Account>();
        aaList.add (new Account(FirstName = 'Test Person', LastName= 'Account AAC', Classification__c = 'AA', Last_Account_Team_Review__c = Date.Today(), Last_Account_Team_Interaction__c = Date.Today(), RecordTypeId = recTypePerAccId));
        aaList.add (new Account(FirstName = 'Test Person', LastName= 'Account AAC', RecordTypeId = recTypePerAccId));
        insert aaList;
        
        List <AccountTeamMember> ATMList = new List <AccountTeamMember>();
        ATMList.add(new AccountTeamMember (UserId = UserInfo.getUserId(), AccountId = aaList.get(0).Id, TeamMemberRole = 'Financial Planner' ));
        ATMList.add(new AccountTeamMember (UserId = UserInfo.getUserId(), AccountId = aaList.get(1).Id, TeamMemberRole = 'Financial Planner' ));
        insert ATMList;

        PracticeManagementController.getAccounts(UserInfo.getUserId(), 'AA', 'Completed', 'Completed', 'True', UserInfo.getUserId());
        PracticeManagementController.getAccounts(UserInfo.getUserId(), 'Unclassified', '', '', 'True', UserInfo.getUserId());
        PracticeManagementController.updateAccounts (aaList);
    }


}