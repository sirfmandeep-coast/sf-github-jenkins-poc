/**
*  UserCreationController.cls
*  By Rong Bin, CCS
*  Created Date: 15 Jun 2022
*  Description:  CRM-4691: User Creation Automation (Source Side APEX Controller)
*/

public with sharing class UserCreationController {
    
    @AuraEnabled (cacheable=true)
    public Static List <CRM_Automation_Configuration__mdt> getConfigurations (){
        return [SELECT MasterLabel, DeveloperName, Callback_URL__c, Target_Org__c, Target_Org_URL__c, Client_Id__c, Client_Secret__c, Refresh_Token__c FROM CRM_Automation_Configuration__mdt WHERE isActive__c = True ];
    }

    @AuraEnabled
    public Static String syncUser (Id userId, String refreshToken, String loginUri, String clientId, String clientSecret){
     
        refreshToken = refreshToken.replace('=','%3D').trim();
        String header = '';
        String endpoint = '';
        String callCenterName = '';
                 
        String queryParameters;
        String reqBody;
        List <PermissionSetAssignment> PSAList = new List <PermissionSetAssignment> (); 
        String permissionSetJSONString = '';
        String[] permissionSetNames = New String[]{};
        String sandboxName;

        User userRecord = [SELECT Id, UserName, LastName, FirstName, Profile.Name, UserRole.Name, Email, UserPermissionsInteractionUser, UserPermissionsSupportUser, CallCenterId, MF_Licensed_User__c, FederationIdentifier FROM User Where Id = :userId LIMIT 1]; 

        if (!String.isBlank(userRecord.CallCenterId))
        {
            CallCenter cCenter = [SELECT Id, Name FROM CallCenter WHERE Id = :userRecord.CallCenterId LIMIT 1];
            callCenterName = cCenter.Name;
        }

        PSAList = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userRecord.Id AND PermissionSet.IsOwnedByProfile = false];
        
        for(PermissionSetAssignment PSA : PSAList){
            permissionSetNames.add(PSA.PermissionSet.Name);
        }

        If (permissionSetNames.size() > 0 )
        {
            permissionSetJSONString = string.join(permissionSetNames,'","');
            permissionSetJSONString = ', "permissionSets": ["' + permissionSetJSONString + '"]';
        }
        
        queryParameters = 'grant_type=refresh_token' + '&client_id=' + clientId +
        '&client_secret=' + clientSecret +'&refresh_token=' + refreshToken;

        endpoint = loginUri + '/services/oauth2/token?' + queryParameters;

        Map<String, object> mapReqBody = UserCreationController.getHTTPResponse(endpoint, header, 'POST', '');
               
        if (!String.isBlank(string.valueOf(mapReqBody.get('error'))))
        {
            return 'Error during the callout. Error message : ' + string.valueOf(mapReqBody.get('error')).left(120);
        }
        
        
        header = string.valueOf(mapReqBody.get('token_type')) + ' ' + string.valueOf(mapReqBody.get('access_token'));
 
        String queryUri = loginUri + '/services/apexrest/UserCreation';
        
        endpoint = queryUri;
        //reqBody = '{"pushUserFields":{"username":"'+ userRecord.UserName +'", "lname":"'+ userRecord.LastName +'", "fname":"'+ userRecord.FirstName +'", "profile":"'+ userRecord.Profile.Name +'", "role" : "'+ userRecord.UserRole.Name +'","email":"'+ userRecord.Email +'", "flowUser" : '+ userRecord.UserPermissionsInteractionUser + ', "serviceCloudUser": '+ userRecord.UserPermissionsSupportUser +' , "callCenter" : "'+ callCenterName +'" , "mfLicensesUser" : '+ userRecord.MF_Licensed_User__c +' , "fedId" : "'+ userRecord.FederationIdentifier +'" , "permissionSets" : ["View Sortable Data Grids", "CCS Chatter Visibility"]}}';

        sandboxName = String.isBlank(System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName())?'':'.'+System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName();

        reqBody = '{"pushUserFields":{"username":"'+ userRecord.UserName.replace(sandboxName, '') +'", "lname":"'+ userRecord.LastName +'", "fname":"'+ userRecord.FirstName +'", "profile":"'+ userRecord.Profile.Name +'", "role" : "'+ userRecord.UserRole.Name +'","email":"'+ userRecord.Email +'", "flowUser" : '+ userRecord.UserPermissionsInteractionUser + ', "serviceCloudUser": '+ userRecord.UserPermissionsSupportUser +' , "callCenter" : "'+ callCenterName +'" , "mfLicensesUser" : '+ userRecord.MF_Licensed_User__c +' , "fedId" : "'+ userRecord.FederationIdentifier +'" '+ permissionSetJSONString +'}}';


        Map<String, object> mapReqQryBody = UserCreationController.getHTTPResponse(endpoint, header, 'POST', reqbody);

        if (!String.isBlank(string.valueOf(mapReqQryBody.get('error'))))
        {
            return 'Error on Target Org side. Error message : ' + string.valueOf(mapReqQryBody.get('error'));
        }
        else if (!String.isBlank(string.valueOf(mapReqQryBody.get('errorCode'))))
        {

            return 'Error on Target Org side. Error message : ' + string.valueOf(mapReqQryBody.get('message'));
        }

        return string.valueOf(mapReqQryBody.get('success')) + '  Record Id is ' + string.valueOf(mapReqQryBody.get('id'));
    }

    public static Map<String, object> getHTTPResponse(String endpoint, String header, String method, String requestBody){
        HttpRequest req = new HttpRequest();  
        req.setMethod(method);
        req.setEndpoint(endpoint);
        req.setTimeout(120000);
        if (!String.isEmpty(requestBody))
        {
            req.setBody(requestBody);
        }
        if(!String.isEmpty(header)){
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', header);
        }
        Http httpReq = new Http();  
        try {
            HTTPResponse res = httpReq.send(req);
            if(res.getStatusCode() == 500) {
                System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getBody());
                List<Object> results = (List<Object>) JSON.deserializeUntyped(res.getBody());
                return (Map<String, object>)JSON.deserializeUntyped(JSON.serialize(results[0]));
            }
            else
            { 
                return (Map<String, object>)JSON.deserializeUntyped(res.getBody());
            }
        }
        catch(Exception e) {
            return (new Map<String, String>{ 'error' => e.getMessage() });
            
        }
    }
}