/*
    Created By: Anh Phan
    Created Date: 03-Jan-2019
    Purpose: This is a test class for CaseTriggerHelper.
    -------------------------------------------------------------------------------------------------
    Modified By:
    Modified Date:
    Purpose:

*/

@isTest(seeAllData=false)
private class CaseTriggerHelper_isTest {
    
    /*
        Test Scenario: Update or change case ownership     
        Expected Result: The case team member record should be created on case owner change
        Actual Result: The system assert verifies case team member creation
    */
    static testMethod void testMethodOne() {
        
        // Set up data here
        
        List<Case> caseList = new List<Case>();
        
        List<Case> updateCaseList = new List<Case>();
        
       
        User testMethodUserOne = UtilityTest.createUser('TestMethodOneUser', 'System Administrator');
        insert testMethodUserOne;
        //User testMethodUserOne = [SELECT Id FROM User where isActive = True and Profile.Name = 'System Administrator' LIMIT 1];
        Id runningUserId = UserInfo.getUserId();
        
        Test.startTest();
        
        System.runAs(testMethodUserOne) {
            for(Integer i=0; i <= 10; i++) {
            
                caseList.add(UtilityTest.createCase('Web'));
                
            }
            
            for(Integer i=0; i <= 10; i++) {
            
                caseList.add(UtilityTest.createCase('Email'));
            
            }
            insert caseList;
        
            for(Case cse: caseList) {
                if (cse.Origin == 'Web')
                {
                    cse.ownerId = runningUserId ;
                }
                updateCaseList.add(cse);
                
            }//End of for(Case cse: caseList)
            
            update caseList;
            
        }//End of system.runAs        
        
        List<CaseTeamMember> caseTeamMemberList = new List<CaseTeamMember>([select id from CaseTeamMember where ParentId IN :caseList]);
        //System.assert(!caseTeamMemberList.isEmpty());
        System.assertEquals(caseTeamMemberList.size(), 11);
        Test.stopTest();
        
    }//End of testMethodOne
    
    
    /*
        Test Scenario: Update case record but not case owner change     
        Expected Result: The case team member record should not be created on case update
        Actual Result: The system assert verifies case team member is not created
    
    static testMethod void testMethodTwo() {
        
        // Set up data here
        
        List<Case> caseTwoList = new List<Case>();
        
        List<Case> updateTwoCaseList = new List<Case>();
        
        for(Integer i=0; i <= 20; i++) {
            
            caseTwoList.add(UtilityTest.createCase('Email'));
            
        }//End of for(Integer i=0; i <= 20; i++)
        insert caseTwoList;
        
        Test.startTest();
        
        System.runAs(UtilityTest.createUser('TestMethodTwoUser', 'System Administrator')) {
            
            update caseTwoList;
            
        }//End of system.runAs        
        
        List<CaseTeamMember> caseTeamMemberList = new List<CaseTeamMember>([select id from CaseTeamMember where ParentId IN :caseTwoList]);
        
        System.assert(caseTeamMemberList.isEmpty());
        
        Test.stopTest();
        
    }//End of testMethodTwo
    */

}//End of CaseTriggerHelper_isTest