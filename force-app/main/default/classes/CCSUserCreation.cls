/**
*  CCSUserCreation.cls
*  @description CCSUserCreation -  Class to create users in TRN31/Lower Enviornments.
*  @author Jujhar Singh, CCS
*  @date Created on 13 Jun 2022
*/
@RestResource(urlMapping= '/UserCreation/*')
global without sharing class CCSUserCreation {


    private static final String EXISTING_RECORD = 'The User already exists with ';
    private static final String WRONG_RECORD = 'The User ';
    private static final String WRONG_RECORD2 = ' doesnt exist in the CCS Org. Please send another record or talk to an System Administrator. ';    
    private static final String NO_ROLE_EXISTS = ' Specified Role doesnt exists in Target Org, User is not created ';
    // Holds the success message
    private static final String SUCCESS_MESSAGE_WITHNOPERMSETS = 'User Record successfully created but permission sets were not assigned.'; 
    private static final String SUCCESS_MESSAGE_WITHPERMSETS = 'User Record successfully created and permission sets assigned.';    

    /*
   @HttpGet
   global static List<User> userrecord (){

    return [SELECT Id from User LIMIT 10];
   } */

/**
    * Retrieve User information to help the create the right record into Salesforce
    * @author Jujhar Singh, CCS
    * @param [pushUserFields] the object that represents the payload of the API.
    * @return [ResponseWrapper] the object that represents the response of the API.
    * @date  11-Jun-2022
    */
    @HttpPost
    global static ResponseWrapper userRecordInfo( RequestWrapper pushUserFields ) {

        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        System.debug(d.getSandboxName());
        // User Query to check for existing record with Username ? 
        String usernameCheck = pushUserFields.username + d.getSandboxName();
        
        /*
        List<User> userList = [SELECT Id from User where Username =: usernameCheck];

        if ( ! userList.isEmpty() )
        {
            return new ResponseWrapper( EXISTING_RECORD +  pushUserFields.username );
        }
        */
        
        User u = new User();
        u.FirstName = pushUserFields.fname;
        u.LastName = pushUserFields.lname;
        u.ProfileId = getProfileID( pushUserFields.profile );
        u.UserName = pushUserFields.username + '.' + d.getSandboxName() ;
        u.Email = pushUserFields.email + '.invalid';
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.timezonesidkey = 'America/Los_Angeles';
        u.emailencodingkey = 'UTF-8';
        u.alias = pushUserFields.fname.substring( 0, 1) + pushUserFields.lname.substring( 0, 3);
        u.FederationIdentifier = pushUserFields.fedId;
        u.UserPermissionsSupportUser = pushUserFields.serviceCloudUser; // Service Cloud User flag
        u.UserPermissionsInteractionUser = pushUserFields.flowUser; // Flow User flag
        if (pushUserFields.callCenter != '') {
            u.CallCenterId = getCallCenterId ( pushUserFields.callCenter );
        }
        u.MF_Licensed_User__c = pushUserFields.mfLicensesUser;
        String roleId = getRoleId( pushUserFields.role );
        if( roleId == 'noRoleFound')
        {
            return new ResponseWrapper( NO_ROLE_EXISTS );
        }
        else {
            u.UserRoleId = roleId;
        }

         // Attempt to insert the record.
        //Database.SaveResult uRecord = Database.insert( u, false );
        
        Database.upsertResult uRecord = Database.upsert(u, User.Username, false);

        // If the record is successfully inserted.
        if( uRecord.isSuccess() ) {
        Boolean assignPermSet = assignPermSet( pushUserFields.permissionSets, uRecord.getId() );
        if( assignPermSet == true ){
        return new ResponseWrapper( uRecord.getId(), SUCCESS_MESSAGE_WITHPERMSETS );    
        }
        else if ( assignPermSet == false ){
        return new ResponseWrapper( uRecord.getId(), SUCCESS_MESSAGE_WITHNOPERMSETS );      
        }

        } else {
        for( Database.error err : uRecord.getErrors() ) {
            return new ResponseWrapper( err.getMessage() );     
        }
        }

        // If the API was processed without returning a valid User Record, return an error message.
        return new ResponseWrapper( WRONG_RECORD +  pushUserFields.fname + ',' + pushUserFields.lname + WRONG_RECORD2 );

    }


    public static Id getProfileID( String profile ){

        Id profileId = [SELECT Id from Profile where Name =: profile].Id;
        return profileId;
    }

    public static String getRoleId( String role ){

        List<UserRole> userRole = [SELECT Id from UserRole where Name =: role];
        if( userRole.size() > 0){
            return userRole[0].Id;
        }
        return 'noRoleFound';
    }

    public static Id getCallCenterId( String callCenter ){

        Id callCtrId = [SELECT Id from CallCenter where Name =: callCenter].Id;
        return callCtrId;
    }
    public static Boolean assignPermSet( List<String> permissionSets , String userId ){
        // Bulkify the Insert
        // SELECT to use List instead of Id and check for size and then Insert
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        List<Database.SaveResult> insertResults = new List<Database.SaveResult>();
        
        Set<String> permissionSetName = new Set<String> ();
        permissionSetName.addAll(permissionSets);

        for (PermissionSetAssignment PSA:[SELECT Id, AssigneeId, PermissionSet.Name FROM permissionSetAssignment WHERE AssigneeId =:userId AND PermissionSet.Name IN :permissionSetName])
        {
            if (permissionSetName.contains(PSA.PermissionSet.Name))
            {
                permissionSetName.remove(PSA.PermissionSet.Name);
            }
        }

        for (PermissionSet PS:[SELECT Id, Name from PermissionSet where Name =: permissionSetName])
        {
            psaList.Add(New PermissionSetAssignment(AssigneeId = userId, PermissionsetId = PS.Id));
        }


        /*
        for ( String permissionSet : permissionSets ) {
            List<PermissionSet> permSet = [SELECT Id,Name from PermissionSet where Name =: permissionSet];
            if (permSet.size() > 0 ){
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = userId;
                psa.permissionsetId = permSet[0].Id;
                psaList.add ( psa );
            }

        }*/
        
        insertResults = Database.insert( psaList, false );
        for ( Integer i = 0; i < insertResults.size(); i++ ) {
            if ( !insertResults.get( i ).isSuccess() ) {
                return false;
            }
        }       
        return true;
        
    }

 /**
    * Wrapper class responsible to wrap the values sent on the API.
    * @author Jujhar Singh, CCS
    * @date  13-Jun-2022
    */
    global class RequestWrapper {
        global String fname;
        global String lname;
        global String email;
        global String username;
        global String role;
        global String profile;
        global Boolean flowUser;
        global Boolean serviceCloudUser;
        global String callCenter;
        global Boolean mfLicensesUser;
        global String fedId;
        global List<String> permissionSets;
        //global List<String> permissionSetGroup;

    }    

/**
* Wrapper class responsible to wrap the values returned on the API response.
* @author Jujhar Singh, CCS
* @date  13-Jun-2022
*/
    global class ResponseWrapper {
        global String id;
        global String success;
        global String error;

        // Constructor to fill the error messages
        public ResponseWrapper( String error ) {
            this.error = error;
        }

        // Constructor to fill the success messages
        public ResponseWrapper( String id, String success ) {
            this.id = id;
            this.success = success;
        }
    }       
}