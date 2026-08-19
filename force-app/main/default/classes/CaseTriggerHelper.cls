/*
Created By: Anh Phan
Created Date: 01-Jan-2019
Purpose: This class is a helper class for CaseTrigger.
-------------------------------------------------------------------------------------------------
Modified By:
Modified Date:
Purpose:

*/

public class CaseTriggerHelper {

    private final static string READONLY = 'ReadOnly';
    
    public static void checkOwnerShipChange(Map<Id, Case> caseNewMap, Map<Id, Case> caseOldMap) {
        
        List<Case> caseOwnerChangeList = new List<Case>();
        
        List<CaseTeamMember> insertCaseTeamMemberList = new List<CaseTeamMember>();
        
        for(Case cse: caseNewMap.values()) {
            
            if(caseOldMap <> NULL && cse.OwnerId <> caseOldMap.get(cse.id).OwnerId) {
                
                caseOwnerChangeList.add(caseOldMap.get(cse.id));
                
            }//End of if(cont.OwnerId <> contactOldMap.get(cont.id).OwnerId)
            
        }//End of for(Contact cont: contactNewMap)
        
        if(caseOwnerChangeList <> NULL && !caseOwnerChangeList.isEmpty()) {
            
            insertCaseTeamMemberList = createCaseTeam(caseOwnerChangeList);
        }//End of if(caseOwnerChangeList <> NULL && !caseOwnerChangeList.isEmpty())
        
        if(insertCaseTeamMemberList <> NULL && !insertCaseTeamMemberList.isEmpty()) {
            
            system.debug('Case Team Member : '+insertCaseTeamMemberList);
            
            Database.insert(insertCaseTeamMemberList,false);
            
        }//End of if(insertCaseTeamMemberList <> NULL && !insertCaseTeamMemberList.isEmpty())
        
    }//End of checkOwnerShipChange
    
    
    public static List<CaseTeamMember> createCaseTeam(List<Case> caseList) {
        
        List<CaseTeamMember> caseTeamMemberList = new List<CaseTeamMember>();
        
        if(caseList <> NULL && !caseList.isEmpty()) {
            
            List<CaseTeamRole> caseTeamRoleList = [select Id, Name from CaseTeamRole where Name = :READONLY limit 1];
            
            for(Case cs: caseList) {
                
                CaseTeamMember caseTeamMemRec = new CaseTeamMember(
                    ParentId = cs.id,
                    MemberId = cs.OwnerId,
                    TeamRoleId = caseTeamRoleList[0].id <> NULL ? caseTeamRoleList[0].id : NULL
                    
                );
                caseTeamMemberList.add(caseTeamMemRec);
            }//End of for(Case cs: caseList)
            
            
        }//End of if(caseList <> NULL && !caseList.isEmpty())
        
        return caseTeamMemberList;
        
    }//End of createCaseTeam
    
}//End of CaseTriggerHelper