/*******************************************************************************************************************************************************
*   Company         :   Coast Capital Savings Credit Union
*   Class           :   CPFAlertsCalloutHelper
*   Description     :   Helper class for FinancialAccountsCtrl class in getting and setting data from/into Preferences API & getting data from Profile API.
********************************************************************************************************************************************************
*   Author           :  Jujhar Singh
*   Date Created     :  [2021.SEP.23]
*   History          :  
*       
*   [2021.AUG.23]  jsingh - Initial Version [Created the getAlertPrefernces method which fetches the data from the Preference API].
*   [2021.AUG.23]  jsingh - [Created the sendAlertPrefernces method which pushes the modified data on changeAccountAlerts LWC to the Preference API].
*   [2022.JAN.13]  rcai   - [Created the getContactInfo method which fetches the data from the Profile API]. 
*   [2022.FEB.15]  rcai   - [CRM-4228 : Regarding Limit Amount Not Present Change in CRM side].
*                          
********************************************************************************************************************************************************/
public without sharing class CPFAlertsCalloutHelper implements Database.AllowsCallouts {
    
    
    public static final String HTTP_METHOD_PATCH = 'PATCH';
    public static final String HTTP_METHOD_PUT = 'PUT';
    public static final String HTTP_METHOD_GET = 'GET';
    public static final Integer HTTP_STANDARD_SUCCESS_OK = 200;
    public static final Integer HTTP_STANDARD_SUCCESS_NOTOK = 404;
    public static final Integer HTTP_STANDARD_SUCCESS_NOOK = 400;
    public static final String INTEGRATION_NAME = 'CPF';
    public static Boolean isSandbox;
    public static Integer count = 23;

    /**
     * Author   :   jsingh
     * Purpose  :   <please write the purpose of this method>.
     * Params   :   profileNum of String type.
     * Returns  :   AlertPreferencesWrapper type.
     */
    public static AlertPreferencesWrapper getAlertPrefernces( String profileNum ) {

        Boolean isSuccess = true ;
        Boolean retailAlertsOnly = false;
        count ++;   
        //String endPoint = 'https://ccs-nonprod-01.api.coastcapitalonline.com/ccs-development-customer-api/api/V1/customers/'+profileNum+'/alert-preferences';
        String endPoint = getEndpoint( INTEGRATION_NAME ) + '/customers/' + profileNum +'/alert-preferences';
        retailAlertsOnly = getIntegrationDetails( INTEGRATION_NAME ).Retail_Alerts_Only__c;
        // Get Mulesoft Endpoint and Authentication related Info from Custom Settings and Set Header
        HttpRequest request = new HttpRequest();
        // all below Endpoint certificate name and headers can be pulled from Mulesoft Endpoints mdt

        //request.setClientCertificateName(getIntegrationDetails( INTEGRATION_NAME ).Certifcation__c ); 
        //request.setEndpoint(getEndpoint( INTEGRATION_NAME ));
        request.setTimeout( Integer.valueOf( getIntegrationDetails( INTEGRATION_NAME ).Timeout__c) );
        Blob headerValue = Blob.valueOf( getIntegrationDetails( INTEGRATION_NAME ).Client_Id__c + ':' + getIntegrationDetails( INTEGRATION_NAME ).Client_Secret__c );
        String authorizationHeader = 'Basic' + ' ' + EncodingUtil.base64Encode( headerValue );
        request.setHeader( 'Authorization', authorizationHeader );
        //request.setHeader( 'client_id', getIntegrationDetails( INTEGRATION_NAME ).Client_Id__c);
        //request.setHeader( 'client_secret', getIntegrationDetails( INTEGRATION_NAME ).Client_Secret__c);
        request.setEndpoint( endPoint );
        //request.setHeader( 'client_id', 'e15948a49bc94c2da88f48242eb18add');
        //request.setHeader( 'client_secret', '980d4c7c65F643e1809b3A1D0986EEF8');
        request.setHeader('Content-Type','application/JSON');
        request.setHeader('X-ConversationId', profileNum + count );
        request.setHeader('X-LanguageId','ENG');
        request.setHeader('X-Principal',profileNum);
        request.setHeader('X-Channel', 'CRM');
        request.setMethod( HTTP_METHOD_GET );
        //request.setHeader(key, value); 
        // etc
       // Now Body needs to be Encrypted 
       // Body needs to be known for request which to Include UpdatedRoles and FormDate  >>>   String body = createBody();
       //request.setBody( JSON.serialize( requestBody ) ); Encrypt and Serialize
       //String body ='';  // << Payload to come >>
        //String encryptionAlgorithm = getIntegrationDetails( INTEGRATION_NAME ).Encryption_Algortihm__c;
        //String encrpytionKey = getIntegrationDetails( INTEGRATION_NAME ).Encryption_Key__c;
        //String initializationVector = getIntegrationDetails( INTEGRATION_NAME ).Initialization_Vector__c;
       // String encyrptedData = EncodingUtil.base64Encode(Crypto.encrypt(encryptionAlgorithm, EncodingUtil.base64Decode(encrpytionKey), EncodingUtil.base64Decode(initializationVector), Blob.valueOf(body)));
       // request.setBody(encyrptedData);
        HTTPResponse response = new HttpResponse();
        AlertPreferencesWrapper preferencesWrapper;
        CPFAlertErrorResponseWrapper errorResponseWrapper;
           try {
               Http http = new Http();
               response = http.send( request );
               System.debug(response);
               System.debug(response.getBody());
               // << need to decrpyt response here, same way as above >>
               if ( response.getStatusCode() == HTTP_STANDARD_SUCCESS_OK ) {
                
                    preferencesWrapper = AlertPreferencesWrapper.parse( response.getBody() );
                    if (retailAlertsOnly == True)
                    {
                        for (Integer i = preferencesWrapper.alertPreferences.size() - 1; i>=0 ; i--)
                        {
                            if (preferencesWrapper.alertPreferences.get(i).accountUse != 'Retail')
                            {
                                preferencesWrapper.alertPreferences.remove(i);
                            } 
                            else if (String.isEmpty(String.valueOf(preferencesWrapper.alertPreferences.get(i).limitAmount)))
                            {
                                for (Integer j = preferencesWrapper.alertPreferences.get(i).alert.size() - 1 ; j>=0 ; j--)
                                {
                                    if (preferencesWrapper.alertPreferences.get(i).alert.get(j).type == 'CreditRemainingAlert')
                                    {
                                        preferencesWrapper.alertPreferences.get(i).alert.remove(j);
                                        break;
                                    }
                                }
                            }
                        }
                    
                        system.debug( preferencesWrapper);
                
                
                    }
               }
               else if (response.getStatusCode() == HTTP_STANDARD_SUCCESS_NOTOK || response.getStatusCode() == HTTP_STANDARD_SUCCESS_NOOK ){
                //else if (response.getStatusCode() == HTTP_STANDARD_SUCCESS_NOTOK || response.getStatusCode() == HTTP_STANDARD_SUCCESS_NOOK ){
                    //system.debug( response);
                   // preferencesWrapper = AlertPreferencesWrapper.Response.parse( response.getBody() );
                    errorResponseWrapper = CPFAlertErrorResponseWrapper.parse( response.getBody() );
                    system.debug( response.getBody());
                    system.debug('GetAlertPreferences');
                    //createIntegrationErrorRecord( preferencesWrapper.response.message , response.getStatusCode() , 'getAlertPrefernces' );
                    throw new AuraHandledException(' Function: getAlertPrefernces|  StatusCode: ' + response.getStatusCode() + '| Message: ' + errorResponseWrapper.response.message);
               }
               else {
                    throw new AuraHandledException(' Function: getAlertPrefernces|  StatusCode: ' + response.getStatusCode());
               }
            
           } catch( System.CalloutException e ) {
               System.debug( e.getMessage() + e.getStackTraceString() );
               String errorMessage = e.getMessage() + e.getStackTraceString();
               //createIntegrationErrorRecord( errorMessage , response.getStatusCode() , 'getAlertPrefernces' );
               throw new AuraHandledException(' Function : getAlertPrefernces|  Message : ' + e.getMessage());
           }

           return preferencesWrapper;

    }

    /**
     * Author   :   jsingh
     * Purpose  :   <please write the purpose of this method>.
     * Params   :   modified values from changeAccountAlerts LWC as String and profileNum of String type.
     * Returns  :   Boolean type.
     */
        public static Boolean sendAlertPrefernces( String changedPreferences, String profileNum ) {

        Boolean isSuccess = true ;
        String endPoint = getEndpoint( INTEGRATION_NAME ) + '/customers/' + profileNum +'/alert-preferences';
        //String endPoint = 'https://ccs-nonprod-01.api.coastcapitalonline.com/ccs-development-customer-api/api/V1/customers/'+profileNum+'/alert-preferences';

        // Get Mulesoft Endpoint and Authentication related Info from Custom Settings and Set Header
        HttpRequest request = new HttpRequest();
        // all below Endpoint certificate name and headers can be pulled from Mulesoft Endpoints mdt

        //request.setClientCertificateName(getIntegrationDetails( INTEGRATION_NAME ).Certifcation__c ); 
        //request.setEndpoint(getEndpoint( INTEGRATION_NAME ));
        request.setTimeout( Integer.valueOf(getIntegrationDetails( INTEGRATION_NAME ).Timeout__c) );
        request.setEndpoint( endPoint );
        //request.setHeader( 'client_id', 'e15948a49bc94c2da88f48242eb18add');
        //request.setHeader( 'client_secret', '980d4c7c65F643e1809b3A1D0986EEF8');
        request.setHeader('Content-Type','application/JSON');
        request.setHeader('X-ConversationId', profileNum + count );
        request.setHeader('X-LanguageId','ENG');
        request.setHeader('X-Principal',profileNum);
        request.setHeader('X-Channel', 'CRM');
        Blob headerValue = Blob.valueOf( getIntegrationDetails( INTEGRATION_NAME ).Client_Id__c + ':' + getIntegrationDetails( INTEGRATION_NAME ).Client_Secret__c );
        String authorizationHeader = 'Basic' + ' ' + EncodingUtil.base64Encode( headerValue );
        request.setHeader( 'Authorization', authorizationHeader );
        //request.setHeader( 'client_id', getIntegrationDetails( INTEGRATION_NAME ).Client_Id__c);
        //request.setHeader( 'client_secret', getIntegrationDetails( INTEGRATION_NAME ).Client_Secret__c);
        request.setMethod( HTTP_METHOD_PUT );
        //request.setHeader(key, value); 
        // etc
       // Now Body needs to be Encrypted 
       // Body needs to be known for request which to Include UpdatedRoles and FormDate  >>>   String body = createBody();
       //request.setBody( JSON.serialize( requestBody ) ); Encrypt and Serialize
       String body = changedPreferences;  // << Payload to come >>
       // String encryptionAlgorithm = getIntegrationDetails( INTEGRATION_NAME ).Encryption_Algortihm__c;
        //String encrpytionKey = getIntegrationDetails( INTEGRATION_NAME ).Encryption_Key__c;
        //String initializationVector = getIntegrationDetails( INTEGRATION_NAME ).Initialization_Vector__c;
       // String encyrptedData = EncodingUtil.base64Encode(Crypto.encrypt(encryptionAlgorithm, EncodingUtil.base64Decode(encrpytionKey), EncodingUtil.base64Decode(initializationVector), Blob.valueOf(body)));
        //request.setBody(encyrptedData);
        request.setBody(body);
        HTTPResponse response = new HttpResponse();
        AlertPreferencesWrapper preferencesWrapper;
        CPFAlertErrorResponseWrapper errorResponseWrapper;
           try {
               Http http = new Http();
               response = http.send( request );
               System.debug(response);
               System.debug(response.getStatusCode());
               System.debug(response.getBody());
               // << need to decrpyt response here, same way as above >>
               if ( response.getStatusCode() == HTTP_STANDARD_SUCCESS_OK ) {
                   system.debug('in helper class set pref success code============');
                    return isSuccess;
                
                    
               } else if (response.getStatusCode() == HTTP_STANDARD_SUCCESS_NOOK ){
                //else if (response.getStatusCode() == HTTP_STANDARD_SUCCESS_NOTOK || response.getStatusCode() == HTTP_STANDARD_SUCCESS_NOOK ){
                    //system.debug( response);
                   // preferencesWrapper = AlertPreferencesWrapper.Response.parse( response.getBody() );
                    errorResponseWrapper = CPFAlertErrorResponseWrapper.parse( response.getBody() );
                    throw new AuraHandledException(' Function: sendAlertPrefernces|  StatusCode: ' + response.getStatusCode() + '| Message: ' + errorResponseWrapper.response.message);
               } 
               else {
                system.debug('in helper class set pref fail code============');
                    isSuccess = false;
                    //createIntegrationErrorRecord( response.getBody() , response.getStatusCode() , 'sendAlertPrefernces' );
                    throw new AuraHandledException(' Function : sendAlertPrefernces|  StatusCode : ' + response.getStatusCode());
                    //return isSuccess;
               }
   
           } catch( System.CalloutException e ) {
               System.debug( e.getMessage() + e.getStackTraceString() );
               String errorMessage = e.getMessage() + e.getStackTraceString();
               //createIntegrationErrorRecord( errorMessage , response.getStatusCode() , 'sendAlertPreferences' );
               throw new AuraHandledException(' Function : sendAlertPrefernces|  Message : ' + e.getMessage());
           } 
           //system.debug('in helper class set pref end code============'+isSuccess);
           //return isSuccess;

    }

    /**
     * Author   :   rcai
     * Purpose  :   <please write the purpose of this method>.
     * Params   :   profileNum of String type.
     * Returns  :   ContactInfoWrapperForAlertPrefs type.
     */
    public static ContactInfoWrapperForAlertPrefs getContactInfo(String profileNum) {

        Boolean isSuccess = true ;
		String returnMsg = '';
        HttpRequest request = new HttpRequest();
        //String endPoint = 'https://ccs-nonprod-01.api.coastcapitalonline.com/ccs-development-customer-api/api/V1/customers/' + profileNum;
        String endPoint = getEndpoint( INTEGRATION_NAME ) + '/customers/' + profileNum;

        // all below Endpoint certificate name and headers can be pulled from Mulesoft Endpoints mdt
        //request.setClientCertificateName(getIntegrationDetails( INTEGRATION_NAME ).Certifcation__c ); 
        request.setEndpoint(endPoint);
        request.setTimeout(Integer.valueOf( getIntegrationDetails( INTEGRATION_NAME ).Timeout__c));
        Blob headerValue = Blob.valueOf( getIntegrationDetails( INTEGRATION_NAME ).Client_Id__c + ':' + getIntegrationDetails( INTEGRATION_NAME ).Client_Secret__c );
        String authorizationHeader = 'Basic' + ' ' + EncodingUtil.base64Encode( headerValue );
        request.setHeader( 'Authorization', authorizationHeader );
        //request.setHeader('client_id', getIntegrationDetails( INTEGRATION_NAME ).Client_Id__c);
        //request.setHeader('client_secret', getIntegrationDetails( INTEGRATION_NAME ).Client_Secret__c);
        request.setHeader('Content-Type','application/JSON');
        request.setHeader('X-ConversationId', profileNum);
        request.setHeader('X-LanguageId','ENG');
        request.setHeader('X-Principal',profileNum);
        request.setHeader('X-Channel', 'CRM');
        request.setMethod( HTTP_METHOD_GET );
        
        HTTPResponse response = new HttpResponse();
        ContactInfoWrapperForAlertPrefs conInfoWrapper;
        CPFAlertErrorResponseWrapper errorResponseWrapper;
        
        try {
			Http http = new Http();
            response = http.send(request);

            if ( response.getStatusCode() == HTTP_STANDARD_SUCCESS_OK ) { 
                
                conInfoWrapper = ContactInfoWrapperForAlertPrefs.parse(response.getBody());	
            }
            else if (response.getStatusCode() == HTTP_STANDARD_SUCCESS_NOTOK || response.getStatusCode() == HTTP_STANDARD_SUCCESS_NOOK) {
                //conInfoWrapper = ContactInfoWrapperForAlertPrefs.parse(response.getBody());
                //createIntegrationErrorRecord( response.getBody() , response.getStatusCode() , 'getContactInfo' );
                errorResponseWrapper = CPFAlertErrorResponseWrapper.parse( response.getBody() );	
                throw new AuraHandledException(' Function : getContactInfo|  StatusCode : ' + response.getStatusCode() + '| Message: ' + errorResponseWrapper.response.message);
            }
            else {
                throw new AuraHandledException(' Function : getContactInfo|  StatusCode : ' + response.getStatusCode() );
            }

   
        } catch( System.CalloutException e ) {
				System.debug( e.getMessage() + e.getStackTraceString() );
				String errorMessage = e.getMessage() + e.getStackTraceString();
                //createIntegrationErrorRecord( errorMessage , response.getStatusCode() , 'getContactInfo' );
                throw new AuraHandledException(' Function : getContactInfo|  Message : ' + e.getMessage());

		} 
        return conInfoWrapper;


    }

    /**
     * Author   :   jsingh
     * Purpose  :   <please write the purpose of this method>.
     * Params   :   integrationName of String type.
     * Returns  :   MulesoftEndpoints__mdt type.
     */
    public static MulesoftEndpoints__mdt getIntegrationDetails( String integrationName ) {


        MulesoftEndpoints__mdt mulesoftEndpoint = [
                                                                    SELECT 
                                                                            Endpoint__c,
                                                                            Client_Id__c,
                                                                            Client_Secret__c,
                                                                            Certifcation__c,
                                                                            MockEndpoint__c,
                                                                            Timeout__c,
                                                                            Encryption_Algortihm__c,
                                                                            Encryption_Key__c,
                                                                            Initialization_Vector__c,
                                                                            Retail_Alerts_Only__c
                                                                    FROM 
                                                                    MulesoftEndpoints__mdt 
                                                                    WHERE 
                                                                            DeveloperName =: integrationName
                                                                    LIMIT 1

                                                                  ];
        

        return mulesoftEndpoint;

    }
    
     /**
     * Author   :   jsingh
     * Purpose  :   <please write the purpose of this method>.
     * Params   :   integrationName of String type.
     * Returns  :   String type.
     */
    public static String getEndpoint( String integrationName ) {

        if ( integrationName == null ) {
            return 'No Integration name defined';
        }

        String endPointUrl;
        MulesoftEndpoints__mdt mulesoftEndpoints = [
                                                                    SELECT 
                                                                            Endpoint__c,
                                                                            Client_Id__c,
                                                                            Client_Secret__c,
                                                                            Certifcation__c,
                                                                            MockEndpoint__c,
                                                                            Timeout__c
                                                                    FROM 
                                                                    MulesoftEndpoints__mdt 
                                                                    WHERE 
                                                                            DeveloperName =: integrationName
                                                                    LIMIT 1

                                                                  ];
        
        endPointUrl = mulesoftEndpoints.Endpoint__c;   
        
        if ( runningInASandbox() || Test.isRunningTest()) {
            // If is running on a sandbox, use the development endpoint.
            endPointUrl = mulesoftEndpoints.MockEndpoint__c;
        }

        if ( endPointUrl == null || endPointUrl == '' ) {
            return 'Endpoint not defined for this metadata type.';
        }

        return endPointUrl;

    }

    /**
     * Author   :   jsingh
     * Purpose  :   <please write the purpose of this method>
     * Params   :   No Params.
     * Returns  :   Boolean type.
     */
    public static Boolean runningInASandbox() {

        // If the static value is null, query the organization information to define if the integration is being called from a sandbox or not.
        if ( isSandbox == null ) {
            isSandbox = [ SELECT IsSandbox FROM Organization LIMIT 1 ].IsSandbox;
 
        }

        return isSandbox;
    }

    /**
     * Author   :   jsingh
     * Purpose  :   <please write the purpose of this method>.
     * Params   :   errorMessage as string and httpcode as Integer.
     * Returns  :   void.
     */
    
   /* public static void createIntegrationErrorRecord( String errorMessage, Integer httpcode , String function){
        ErrorLog__c newErrorLog = new ErrorLog__c();
        newErrorLog.Type__c = 'Integration';
        newErrorLog.Class__c = 'CPFAlertsCalloutHelper';
        newErrorLog.Function__c = function;
        newErrorLog.ErrorMessage__c = errorMessage;
        newErrorLog.RelatedRecordId__c = 'basedonPayload';
        newErrorLog.UserId__c = UserInfo.getUserId();
        newErrorLog.HttpCode__c =  httpcode;
        system.debug('to insert' +  newErrorLog );
        insert newErrorLog;
        system.debug('inserted' + newErrorLog.Id);
    }*/
}