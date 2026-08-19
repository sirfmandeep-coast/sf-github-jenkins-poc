@IsTest
global with sharing class DataMigrationControllerTest {
    /*
    @IsTest static void testCallOutSuccess200() {
        User uu = [SELECT Id FROM User WHERE UserType = 'Standard' AND isActive = True AND CallCenterId != '' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new DataMigrationControllerTest.DataMigrationHttpCalloutMock());
        DataMigrationController.SOAPLogin(uu.Id, 'refreshToken', 'https://coastcapitalsavings--ccstrain31.my.salesforce.com', 'clientId', 'clientSecret');
    }

    @IsTest static void testCallOutFailure500() {
        User uu = [SELECT Id FROM User WHERE UserType = 'Standard' AND isActive = True AND CallCenterId != '' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new DataMigrationControllerTest.DataMigrationHttpCalloutMock(500, '[{"Id":"12345", "token_type": "2020-07-06T11:14:25Z", "access_token": "example.com", "success" : "success", "errorCode" : "errorCode"}]'));
        DataMigrationController.SOAPLogin(uu.Id, 'refreshToken', 'https://coastcapitalsavings--ccstrain31.my.salesforce.com', 'clientId', 'clientSecret');
    }

    @IsTest static void testCallOutFailure400() {
        User uu = [SELECT Id FROM User WHERE UserType = 'Standard' AND isActive = True AND CallCenterId != '' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new DataMigrationControllerTest.DataMigrationHttpCalloutMock(400, '{"Id":"12345", "token_type": "2020-07-06T11:14:25Z", "access_token": "example.com", "success" : "success", "errorCode" : "errorCode", "error" : "error" }'));
        DataMigrationController.SOAPLogin(uu.Id, 'refreshToken', 'https://coastcapitalsavings--ccstrain31.my.salesforce.com', 'clientId', 'clientSecret');
    }
    */
    @IsTest static void testQueryRecords (){
        DataMigrationController.queryRecords('SELECT Id FROM Account Order By Id ASC LIMIT 5', 0);
        DataMigrationController.queryRecords('SELECT Id FROM Account Order By Id ASC LIMIT 5', 2);
    }

    @IsTest static void testSOAPLoginSuccess200 (){
        Integer responseCode = 200;
        String responseBody = '<?xml version="1.0" encoding="utf-8" ?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:partner.soap.sforce.com" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                                +'<soapenv:Header>'
                                +'</soapenv:Header>'
                                +'<soapenv:Body>'
                                    +'<urn:loginResponse>'
                                        +'<urn:result>'
                                            +'<urn:metadataServerUrl>https://mydomainname.my.salesforce.com</urn:metadataServerUrl>'
                                            +'<urn:passwordExpired>false</urn:passwordExpired>'
                                            +'<urn:sandbox>true</urn:sandbox>'
                                            +'<urn:serverUrl>https://yourInstance--sandbox.my.salesforce.com/services/Soap/u/64.0</urn:serverUrl>'
                                            +'<urn:sessionId>yourGeneratedSessionIdHere12345</urn:sessionId>'
                                            +'<urn:userId>005XXXXXXXXXXXXXXX</urn:userId>'
                                            +'<urn:userInfo>'

                                            +'</urn:userInfo>'
                                        +'</urn:result>'
                                    +'</urn:loginResponse>'
                                +'</soapenv:Body>'
                                +'</soapenv:Envelope>';
        Test.setMock(HttpCalloutMock.class, new DataMigrationControllerTest.DataMigrationHttpCalloutMock(responseCode, responseBody));
        DataMigrationController.SOAPLogin('https://test.salesforce.com', 'whatever@coastcapitalsavings.com.ccsprod.whatever', 'whateverpassword');
    }

    @IsTest static void testSOAPLoginFailure400 (){
        Integer responseCode = 400;
        String responseBody = '<?xml version="1.0" encoding="utf-8" ?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:partner.soap.sforce.com" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                                +'<soapenv:Header>'
                                +'</soapenv:Header>'
                                +'<soapenv:Body>'
                                    +'<urn:loginResponse>'
                                        +'<urn:result>'
                                            +'<urn:metadataServerUrl>https://mydomainname.my.salesforce.com</urn:metadataServerUrl>'
                                            +'<urn:passwordExpired>false</urn:passwordExpired>'
                                            +'<urn:sandbox>true</urn:sandbox>'
                                            +'<urn:serverUrl>https://yourInstance--sandbox.my.salesforce.com/services/Soap/u/64.0</urn:serverUrl>'
                                            +'<urn:sessionId>yourGeneratedSessionIdHere12345</urn:sessionId>'
                                            +'<urn:userId>005XXXXXXXXXXXXXXX</urn:userId>'
                                            +'<urn:userInfo>'

                                            +'</urn:userInfo>'
                                        +'</urn:result>'
                                    +'</urn:loginResponse>'
                                +'</soapenv:Body>'
                                +'</soapenv:Envelope>';
        Test.setMock(HttpCalloutMock.class, new DataMigrationControllerTest.DataMigrationHttpCalloutMock(responseCode, responseBody));
        try {
            DataMigrationController.SOAPLogin('https://test.salesforce.com', 'whatever@coastcapitalsavings.com.ccsprod.whatever', 'whateverpassword');
        }
        catch (Exception e) {
        
        }
    }

    @IsTest static void testBulkJobSuccess200 (){
        Integer responseCode = 200;
        String responseBody = '{'
                            +'"id" : "7505j00000KOpn1AAD",'
                            +'"operation" : "insert",'
                            +'"object" : "Contact",'
                            +'"createdById" : "0055j000004e0HpAAI",'
                            +'"createdDate" : "2025-03-04T12:00:00.000+0000",'
                            +'"systemModstamp" : "2025-03-04T12:00:00.000+0000",'
                            +'"state" : "Open",'
                            +'"concurrencyMode" : "Parallel",'
                            +'"contentType" : "CSV",'
                            +'"apiVersion" : 58.0,'
                            +'"externalIdFieldName" : null,'
                            +'"lineEnding" : "LF",'
                            +'"columnDelimiter" : "COMMA",'
                            +'"jobRecords" : null'
                            +'}';
        Test.setMock(HttpCalloutMock.class, new DataMigrationControllerTest.DataMigrationHttpCalloutMock(responseCode, responseBody));
        DataMigrationController.createBulkJob('https://mydomainname.my.salesforce.com', 'Account', 'Id', 'Insert', 'refreshToken', 'usernamePassword');
        try {
            DataMigrationController.uploadBulkData('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', null, 'refreshToken' , 'usernamePassword');
         }
        catch (Exception e) {
        
        }
        try {
            DataMigrationController.closeBulkJob ('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', 'refreshToken' , 'usernamePassword');
         }
        catch (Exception e) {
        
        }
        try {    
            DataMigrationController.getBulkJobResults('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', 'refreshToken' , 'usernamePassword');
         }
        catch (Exception e) {
        
        }
        try {
            DataMigrationController.getFailedRecords('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', 'refreshToken' , 'usernamePassword');
             }
        catch (Exception e) {
        
        }
        
    }

    @IsTest static void testBulkJobFailure500WithErrorCode (){
        Integer responseCode = 500;
        String responseBody = '{'
                            +'"id" : "7505j00000KOpn1AAD",'
                            +'"operation" : "insert",'
                            +'"object" : "Contact",'
                            +'"createdById" : "0055j000004e0HpAAI",'
                            +'"createdDate" : "2025-03-04T12:00:00.000+0000",'
                            +'"systemModstamp" : "2025-03-04T12:00:00.000+0000",'
                            +'"state" : "Open",'
                            +'"concurrencyMode" : "Parallel",'
                            +'"contentType" : "CSV",'
                            +'"apiVersion" : 58.0,'
                            +'"externalIdFieldName" : null,'
                            +'"lineEnding" : "LF",'
                            +'"columnDelimiter" : "COMMA",'
                            +'"jobRecords" : null,'
                            +'"errorCode" : "errorCode"'
                            +'}';
        Test.setMock(HttpCalloutMock.class, new DataMigrationControllerTest.DataMigrationHttpCalloutMock(responseCode, responseBody));
        
        DataMigrationController.createBulkJob('https://mydomainname.my.salesforce.com', 'Account', 'Id', 'Insert', 'refreshToken', 'usernamePassword');
        try {
            DataMigrationController.uploadBulkData('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', null, 'refreshToken' , 'usernamePassword');
         }
        catch (Exception e) {
        
        }
        try {
            DataMigrationController.closeBulkJob ('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', 'refreshToken' , 'usernamePassword');
         }
        catch (Exception e) {
        
        }
        try {    
            DataMigrationController.getBulkJobResults('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', 'refreshToken' , 'usernamePassword');
         }
        catch (Exception e) {
        
        }
        try {
            DataMigrationController.getFailedRecords('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', 'refreshToken' , 'usernamePassword');
             }
        catch (Exception e) {
        
        }
    }

    @IsTest static void testBulkJobFailure400WithError (){
        Integer responseCode = 400;
        String responseBody = '{'
                            +'"id" : "7505j00000KOpn1AAD",'
                            +'"operation" : "insert",'
                            +'"object" : "Contact",'
                            +'"createdById" : "0055j000004e0HpAAI",'
                            +'"createdDate" : "2025-03-04T12:00:00.000+0000",'
                            +'"systemModstamp" : "2025-03-04T12:00:00.000+0000",'
                            +'"state" : "Open",'
                            +'"concurrencyMode" : "Parallel",'
                            +'"contentType" : "CSV",'
                            +'"apiVersion" : 58.0,'
                            +'"externalIdFieldName" : null,'
                            +'"lineEnding" : "LF",'
                            +'"columnDelimiter" : "COMMA",'
                            +'"jobRecords" : null,'
                            +'"error" : "error"'
                            +'}';
        Test.setMock(HttpCalloutMock.class, new DataMigrationControllerTest.DataMigrationHttpCalloutMock(responseCode, responseBody));
        
        DataMigrationController.createBulkJob('https://mydomainname.my.salesforce.com', 'Account', 'Id', 'Insert', 'refreshToken', 'usernamePassword');
        try {
            DataMigrationController.uploadBulkData('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', null, 'refreshToken' , 'usernamePassword');
         }
        catch (Exception e) {
        
        }
        try {
            DataMigrationController.closeBulkJob ('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', 'refreshToken' , 'usernamePassword');
         }
        catch (Exception e) {
        
        }
        try {    
            DataMigrationController.getBulkJobResults('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', 'refreshToken' , 'usernamePassword');
         }
        catch (Exception e) {
        
        }
        try {
            DataMigrationController.getFailedRecords('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', 'refreshToken' , 'usernamePassword');
             }
        catch (Exception e) {
        
        }
    }

    @IsTest static void testRefreshTokenFailure (){
        Integer responseCode = 200;
        String responseBody = '{'
                            +'"id" : "7505j00000KOpn1AAD",'
                            +'"operation" : "insert",'
                            +'"object" : "Contact",'
                            +'"createdById" : "0055j000004e0HpAAI",'
                            +'"createdDate" : "2025-03-04T12:00:00.000+0000",'
                            +'"systemModstamp" : "2025-03-04T12:00:00.000+0000",'
                            +'"state" : "Open",'
                            +'"concurrencyMode" : "Parallel",'
                            +'"contentType" : "CSV",'
                            +'"apiVersion" : 58.0,'
                            +'"externalIdFieldName" : null,'
                            +'"lineEnding" : "LF",'
                            +'"columnDelimiter" : "COMMA",'
                            +'"jobRecords" : null,'
                            +'"error" : "error"'
                            +'}';
        Test.setMock(HttpCalloutMock.class, new DataMigrationControllerTest.DataMigrationHttpCalloutMock(responseCode, responseBody));
        
        DataMigrationController.createBulkJob('https://mydomainname.my.salesforce.com', 'Account', 'Id', 'Insert', 'refreshToken', 'nonusernamePassword');
        try {
            DataMigrationController.uploadBulkData('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', null, 'refreshToken' , 'nonusernamePassword');
         }
        catch (Exception e) {
        
        }
        try {
            DataMigrationController.closeBulkJob ('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', 'refreshToken' , 'nonusernamePassword');
         }
        catch (Exception e) {
        
        }
        try {    
            DataMigrationController.getBulkJobResults('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', 'refreshToken' , 'nonusernamePassword');
         }
        catch (Exception e) {
        
        }
        try {
            DataMigrationController.getFailedRecords('https://mydomainname.my.salesforce.com', '7505j00000KOpn1AAD', 'refreshToken' , 'nonusernamePassword');
             }
        catch (Exception e) {
        
        }
    }

    global class DataMigrationHttpCalloutMock implements HttpCalloutMock {
        private Integer responseCode;
        private String responseBody;

        public DataMigrationHttpCalloutMock() {
    
        }
        /*
        public DataMigrationHttpCalloutMock() {
            this.responseCode = 200;
            this.responseBody = '{"Id":"12345", "token_type": "2020-07-06T11:14:25Z", "access_token": "example.com", "success" : "success"}';
        }*/

        public DataMigrationHttpCalloutMock (Integer responseCode, String responseBody) {
            this.responseCode = responseCode;
            this.responseBody = responseBody;
        }
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest request) {
                
            //First create a fake response
            HttpResponse response = new HttpResponse();
                
            response.setHeader('Content-Type', 'application/json');
            response.setBody(this.responseBody);
            response.setStatusCode(this.responseCode);
                
            return response;
        }
    }
}