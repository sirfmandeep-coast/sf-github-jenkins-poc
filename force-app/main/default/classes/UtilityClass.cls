public without sharing class UtilityClass {
    

    public static Boolean checkUserInPublicGroup(String userId, Set<String> publicGroupNames) {
    	///Get RoleIds in a set of public groups
		Set<Id> roleIdsInGroups = new Set<Id>();
		Boolean isGroupMember = false;
		User usr = [SELECT UserRoleId  FROM User WHERE Id =: userId];
		
		Map<String, Group> mainGroups = new Map<String,Group>([SELECT Id
															FROM Group
															WHERE DeveloperName IN :publicGroupNames]);
		Set<String> allGroupIds = getSubPublicGroups(mainGroups.keySet());
		//Check all sub public group to fetch the role id
		for(Group gr : [SELECT relatedId, Name FROM Group 
						WHERE Id IN : allGroupIds ]){
			//if role Id is matched as user's role Id
			//mark this user as a manager
			if( usr.UserRoleId != null && gr.relatedId == usr.UserRoleId ) {
				isGroupMember = true;
				break;
			}
		}
		
		return isGroupMember;
    }

    //Method to loop all sub public groups to get gorup Id
    private static Set<String> getSubPublicGroups(Set<String> groupIds) {
    	Set<String> allGroupIds = new Set<String>();
    	Set<String> innerGroupIds = new Set<String>();
    	String groupType = Schema.SObjectType.Group.getKeyPrefix();
    	for (GroupMember m : [SELECT UserOrGroupId 
    						FROM GroupMember 
    						WHERE GroupId In :groupIds]) {
			if (((String)m.UserOrGroupId).startsWith(groupType) ) {
				innerGroupIds.add(m.UserOrGroupId);
			}

			allGroupIds.addAll(innerGroupIds);
		}

		if (innerGroupIds.size() > 0) {
			allGroupIds.addAll(getSubPublicGroups(innerGroupIds));
		}
		
		return allGroupIds;
    }
}