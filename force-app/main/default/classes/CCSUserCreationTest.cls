@IsTest
global with sharing class CCSUserCreationTest {
    @IsTest static void testPostPositive() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        List <PermissionSet> psList = new List <PermissionSet> ();
        psList.Add(new PermissionSet(Label = 'View Sortable Data Grids 1', Name = 'View_Sortable_Data_Grids_1'));
        psList.Add(new PermissionSet(Label = 'CCS Chatter Visibility 1', Name = 'CCS_Chatter_Visibility_1'));
        insert psList;

        CCSUserCreation.RequestWrapper testWrapper = new CCSUserCreation.RequestWrapper();
        testWrapper.callCenter = 'NICE-inContact CXone - Central';
        testWrapper.email = 'test12.test12@coastcapitalsavings.com';
        testWrapper.fedId = '1213232';
        testWrapper.flowUser = true;
        testWrapper.fname = 'test12';
        testWrapper.lname = 'test12';
        testWrapper.mfLicensesUser = true;
        testWrapper.profile = 'System Administrator';
        testWrapper.role = 'CCS';
        testWrapper.serviceCloudUser = true;
        testWrapper.username = 'test12.test12@coastcapitalsavings.com';
        testWrapper.permissionSets = new List <String>();
        testWrapper.permissionSets.add('View_Sortable_Data_Grids_1');
        testWrapper.permissionSets.add('CCS_Chatter_Visibility_1');
        
        //String sampleString = '{"pushUserFields":{"username":"test12.test12@coastcapitalsavings.com", "lname":"test12", "fname":"test12", "profile":"System Administrator", "role" : "CCS","email":"test12.test12@coastcapitalsavings.com", "flowUser" : true, "serviceCloudUser": true , "callCenter" : "NICE-inContact CXone - Central" , "mfLicensesUser" : true , "fedId" : "12345678" , "permissionSets" : ["View Sortable Data Grids", "CCS Chatter Visibility"]}}';
        
        //testWrapper = (CCSUserCreation.RequestWrapper)JSON.deserialize(sampleString, CCSUserCreation.RequestWrapper.class);

        req.requestURI = '/services/apexrest/UserCreation';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(testWrapper));
        
        RestContext.request = req;
   	    RestContext.response= res;

        Test.startTest();
        CCSUserCreation.ResponseWrapper responseBody = CCSUserCreation.userRecordInfo(testWrapper);
        Test.stopTest();

    }

    @IsTest static void testNegativeNoRole() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        CCSUserCreation.RequestWrapper testWrapper = new CCSUserCreation.RequestWrapper();
        testWrapper.callCenter = 'NICE-inContact CXone - Central';
        testWrapper.email = 'test12.test12@coastcapitalsavings.com';
        testWrapper.fedId = '1213232';
        testWrapper.flowUser = true;
        testWrapper.fname = 'test12';
        testWrapper.lname = 'test12';
        testWrapper.mfLicensesUser = true;
        testWrapper.profile = 'System Administrator';
        testWrapper.role = 'abc';
        testWrapper.serviceCloudUser = true;
        testWrapper.username = 'test12.test12@coastcapitalsavings.com';
        testWrapper.permissionSets = new List <String>();
        testWrapper.permissionSets.add('View Sortable Data Grids');
        testWrapper.permissionSets.add('CCS Chatter Visibility');
        
        //String sampleString = '{"pushUserFields":{"username":"test12.test12@coastcapitalsavings.com", "lname":"test12", "fname":"test12", "profile":"System Administrator", "role" : "CCS","email":"test12.test12@coastcapitalsavings.com", "flowUser" : true, "serviceCloudUser": true , "callCenter" : "NICE-inContact CXone - Central" , "mfLicensesUser" : true , "fedId" : "12345678" , "permissionSets" : ["View Sortable Data Grids", "CCS Chatter Visibility"]}}';
        
        //testWrapper = (CCSUserCreation.RequestWrapper)JSON.deserialize(sampleString, CCSUserCreation.RequestWrapper.class);

        req.requestURI = '/services/apexrest/UserCreation';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(testWrapper));
        
        RestContext.request = req;
   	    RestContext.response= res;

        Test.startTest();
        CCSUserCreation.ResponseWrapper responseBody = CCSUserCreation.userRecordInfo(testWrapper);
        Test.stopTest();

    }


    @IsTest static void testPositiveUpdateUser() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        String sandboxName;

        sandboxName = String.isBlank(System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName())?'':'.'+System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName();

        User uu = [SELECT Id, Username, Email, Profile.Name FROM User WHERE isActive = True AND UserType = 'Standard' LIMIT 1 ];

        CCSUserCreation.RequestWrapper testWrapper = new CCSUserCreation.RequestWrapper();
        testWrapper.callCenter = 'NICE-inContact CXone - Central';
        testWrapper.email = uu.email;
        testWrapper.fedId = '1213232111111';
        testWrapper.flowUser = true;
        testWrapper.fname = 'test12';
        testWrapper.lname = 'test12';
        testWrapper.mfLicensesUser = true;
        testWrapper.profile = 'System Administrator';
        testWrapper.role = 'CCS';
        testWrapper.serviceCloudUser = true;
        testWrapper.username = uu.Username.replace (sandboxName, '');
        testWrapper.permissionSets = new List <String>();
        testWrapper.permissionSets.add('View_Sortable_Data_Grids_1');
        testWrapper.permissionSets.add('CCS_Chatter_Visibility_1');
        
        /*
        User u = new User();
        u.FirstName = 'test12';
        u.LastName = 'test12';
        u.ProfileId = CCSUserCreation.getProfileID( uu.Profile.Name );
        u.UserName = uu.username + System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName() ;
        u.Email = uu.email + '.invalid';
		u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.timezonesidkey = 'America/Los_Angeles';
        u.emailencodingkey = 'UTF-8';
        u.alias = 'tst1';
        u.FederationIdentifier = '121323221432432';
        u.UserRoleId = CCSUserCreation.getRoleId( 'CCS' );

        insert u;
        */
        List <PermissionSet> psList = new List <PermissionSet> ();
        psList.Add(new PermissionSet(Label = 'View Sortable Data Grids 1', Name = 'View_Sortable_Data_Grids_1'));
        psList.Add(new PermissionSet(Label = 'CCS Chatter Visibility 1', Name = 'CCS_Chatter_Visibility_1'));
        insert psList;

        List <PermissionSetAssignment> psaList = new List <PermissionSetAssignment> ();
        psaList.Add (new PermissionSetAssignment (assigneeId = uu.Id, permissionsetId = psList[0].Id));
        insert psaList;
        
        //String sampleString = '{"pushUserFields":{"username":"test12.test12@coastcapitalsavings.com", "lname":"test12", "fname":"test12", "profile":"System Administrator", "role" : "CCS","email":"test12.test12@coastcapitalsavings.com", "flowUser" : true, "serviceCloudUser": true , "callCenter" : "NICE-inContact CXone - Central" , "mfLicensesUser" : true , "fedId" : "12345678" , "permissionSets" : ["View Sortable Data Grids", "CCS Chatter Visibility"]}}';
        
        //testWrapper = (CCSUserCreation.RequestWrapper)JSON.deserialize(sampleString, CCSUserCreation.RequestWrapper.class);

        req.requestURI = '/services/apexrest/UserCreation';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(testWrapper));
        
        RestContext.request = req;
   	    RestContext.response= res;

        Test.startTest();
        System.runAs(uu){
            CCSUserCreation.ResponseWrapper responseBody = CCSUserCreation.userRecordInfo(testWrapper);
        }
        Test.stopTest();
        CCSUserCreation.ResponseWrapper responseBody2 = CCSUserCreation.userRecordInfo(testWrapper);
    }

}