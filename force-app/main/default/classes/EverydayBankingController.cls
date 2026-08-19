public with sharing class EverydayBankingController {
    public static String customerJSONString = '[{"t24ProfileId":"00408940","accountNumber":"11000779005566","loyaltyServiceName":"sigma","sigmaActCode":"001140","status":"ACTIVE","createdDate":"2022-09-09","lastModifiedOn":"2022-09-10","lastModifiedBy":"avishwa"},{"t24ProfileId":"00408941","accountNumber":"11000779005566","loyaltyServiceName":"coursera","emailAddress":"john.d@yahoo.com","status":"ACTIVE","createdDate":"2022-09-09","lastModifiedOn":"2022-09-10","lastModifiedBy":"avishwa"}]';
    public static String accountJSONString = '[{"t24ProfileId":"00408940","accountNumber":"11000779005566","loyaltyServiceName":"sigma","sigmaActCode":"001140","status":"ACTIVE","createdDate":"2022-09-09","lastModifiedOn":"2022-09-10","lastModifiedBy":"avishwa"},{"t24ProfileId":"00408941","accountNumber":"11000779005566","loyaltyServiceName":"coursera","emailAddress":"john.d@yahoo.com","status":"ACTIVE","createdDate":"2022-09-09","lastModifiedOn":"2022-09-10","lastModifiedBy":"avishwa"}]';

    @AuraEnabled
    public static FinServ__FinancialAccount__c getFinanicalAccount(String recordId) {
        return [SELECT Id, FinServ__FinancialAccountNumber__c 
                                        FROM FinServ__FinancialAccount__c WHERE Id =: recordId Limit 1];
            

    }

    @AuraEnabled
    public static string getLoyaltyProductsByProfileId(String profileId){
        Boolean isSuccess = true ;
        Boolean retailAlertsOnly = false;  
       
        HttpRequest request = new HttpRequest();

        request.setEndpoint('callout:CCS_Mule' + '/loyaltyproducts/services?t24profileId=' + profileId);
        request.setTimeout(120000);

        request.setHeader('X-Principal', profileId);

        request.setMethod( 'GET' );
      
        HTTPResponse response = new HttpResponse();
        
        try {
            Http http = new Http();
            response = http.send( request );
            System.debug(response);
            System.debug(response.getBody());
            if ( response.getStatusCode() == 200 ) {
                system.debug( response.getBody() );
                return response.getBody();           
            }
            else if (response.getStatusCode() == 404 || response.getStatusCode() == 400 ){

                throw new AuraHandledException(' Function: getLoyaltyProductsByProfileId|  StatusCode: ' + response.getStatusCode() + '| Message: ' + response.getBody());
            }
            else {
                throw new AuraHandledException(' Function: getLoyaltyProductsByProfileId|  StatusCode: ' + response.getStatusCode());
            }
        } catch( System.CalloutException e ) {
            System.debug( e.getMessage() + e.getStackTraceString() );
            String errorMessage = e.getMessage() + e.getStackTraceString();
            throw new AuraHandledException(' Function : getLoyaltyProductsByProfileId|  Message : ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static string getLoyaltyProductsByAccountNumber(String financialAccountNumber){
        Boolean isSuccess = true ;
        Boolean retailAlertsOnly = false;

        
        HttpRequest request = new HttpRequest();

        request.setEndpoint('callout:CCS_Mule' + '/loyaltyproducts/services?accountNumber=' + financialAccountNumber);
        request.setTimeout(120000);

        request.setHeader('X-Principal', financialAccountNumber);


        request.setMethod( 'GET' );
      
        HTTPResponse response = new HttpResponse();
        
        try {
            Http http = new Http();
            response = http.send( request );
            System.debug(response);
            System.debug(response.getBody());
            if ( response.getStatusCode() == 200 ) {
                system.debug( response.getBody() );
                return response.getBody();           
            }
            else if (response.getStatusCode() == 404 || response.getStatusCode() == 400 ){

                throw new AuraHandledException(' Function: getLoyaltyProductsByAccountNumber|  StatusCode: ' + response.getStatusCode() + '| Message: ' + response.getBody());
            }
            else {
                throw new AuraHandledException(' Function: getLoyaltyProductsByAccountNumber|  StatusCode: ' + response.getStatusCode());
            }
        } catch( System.CalloutException e ) {
            System.debug( e.getMessage() + e.getStackTraceString() );
            String errorMessage = e.getMessage() + e.getStackTraceString();
            //createIntegrationErrorRecord( errorMessage , response.getStatusCode() , 'getLoyaltyProductsByAccountNumber' );
            throw new AuraHandledException(' Function : getLoyaltyProductsByAccountNumber|  Message : ' + e.getMessage());
        }
    }

}