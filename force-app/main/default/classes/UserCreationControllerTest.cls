@IsTest
global with sharing class UserCreationControllerTest {

    @IsTest static void testCallOutSuccess200() {
        User uu = [SELECT Id FROM User WHERE UserType = 'Standard' AND isActive = True AND CallCenterId != '' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new UserCreationControllerTest.UserCreationHttpCalloutMock());
        UserCreationController.syncUser(uu.Id, 'refreshToken', 'https://coastcapitalsavings--ccstrain31.my.salesforce.com', 'clientId', 'clientSecret');
    }

    @IsTest static void testCallOutFailure500() {
        User uu = [SELECT Id FROM User WHERE UserType = 'Standard' AND isActive = True AND CallCenterId != '' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new UserCreationControllerTest.UserCreationHttpCalloutMock(500, '[{"Id":"12345", "token_type": "2020-07-06T11:14:25Z", "access_token": "example.com", "success" : "success", "errorCode" : "errorCode"}]'));
        UserCreationController.syncUser(uu.Id, 'refreshToken', 'https://coastcapitalsavings--ccstrain31.my.salesforce.com', 'clientId', 'clientSecret');
    }

    @IsTest static void testCallOutFailure400() {
        User uu = [SELECT Id FROM User WHERE UserType = 'Standard' AND isActive = True AND CallCenterId != '' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new UserCreationControllerTest.UserCreationHttpCalloutMock(400, '{"Id":"12345", "token_type": "2020-07-06T11:14:25Z", "access_token": "example.com", "success" : "success", "errorCode" : "errorCode", "error" : "error" }'));
        UserCreationController.syncUser(uu.Id, 'refreshToken', 'https://coastcapitalsavings--ccstrain31.my.salesforce.com', 'clientId', 'clientSecret');
    }

    @IsTest static void testGetConfigurations (){
        UserCreationController.GetConfigurations();
    }

    global class UserCreationHttpCalloutMock implements HttpCalloutMock {
        private Integer responseCode;
        private String responseBody;

        public UserCreationHttpCalloutMock() {
            this.responseCode = 200;
            this.responseBody = '{"Id":"12345", "token_type": "2020-07-06T11:14:25Z", "access_token": "example.com", "success" : "success"}';
        }

        public UserCreationHttpCalloutMock (Integer responseCode, String responseBody) {
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