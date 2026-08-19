public with sharing class DataMigrationController {

    @AuraEnabled
    public static List<SObject> queryRecords (String query, Integer offset){
        List<SObject> records = new List <SObject> ();
        
        if (offset == 0)
        {
            records = Database.query(query);
        }
        else {
            query = query + ' OFFSET ' + String.valueOf(offset);
            records = Database.query(query);
        }
        return records;
    }

    @AuraEnabled
    public static Map<String, String> SOAPLogin (String loginURL, String username, String password) {
         Map<String, String> retBody = new Map<String, String> ();
        
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint('https://test.salesforce.com/services/Soap/u/62.0'); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('SOAPAction', 'login');
        req.setHeader('charset', 'UTF-8');

        // Construct the request body with username and password
        String requestBody = '<?xml version="1.0" encoding="utf-8" ?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:partner.soap.sforce.com" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                            + '<soapenv:Body>'
                            + '<urn:login>'
                            + '<urn:username>' + username + '</urn:username>'
                            + '<urn:password>' + password + '</urn:password>'
                            + '</urn:login>'
                            + '</soapenv:Body>'
                            + '</soapenv:Envelope>';
       
        req.setBody(requestBody);
        
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                
                

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
                
                Dom.XmlNode resultNode = doc.getRootElement()
                                            .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                                            .getChildElement('loginResponse', 'urn:partner.soap.sforce.com') 
                                            .getChildElement('result', 'urn:partner.soap.sforce.com');
                                                   
                String sessionId = resultNode.getChildElement('sessionId', 'urn:partner.soap.sforce.com').getText();
                
                String temp = resultNode.getChildElement('serverUrl', 'urn:partner.soap.sforce.com').getText().substringAfter('https://');        
                String loginUri = 'https://' + temp.substring(0, temp.indexOf('/'));

                retBody.put ('sessionId', sessionId);
                retBody.put ('loginUri', loginUri);

            } else {
                System.debug('Error during login: ' + res.getStatusCode() + ' - ' + res.getBody());
                throw new CalloutException('Error Login: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception Login: ' + e.getMessage());
            throw new CalloutException('Exception Login: ' + e.getMessage());
        }
        
        return retBody;
    }


    @AuraEnabled
    public static String createBulkJob(String loginUri, String objectName, String keyField, String operation, String refreshToken, String authenticationMode) {

        HttpRequest req = new HttpRequest();
        String queryParameters;
        String reqBody;
        String authorizationHeader;
        String endpoint;

        if (authenticationMode == 'usernamePassword')
        {
            authorizationHeader = string.valueOf('Bearer ' + refreshToken);
        } 
        else 
        {
            queryParameters = 'grant_type=refresh_token' + '&client_id=' + '3MVG9TZvGM_0NqB1Oc_WTCesgrNIBC0TAx0bVuUsjs5TyqwZi8zWuNQNLY3.jiK38P8Vj5MaIM4Wew3qNu92E' +
            '&client_secret=' + 'FAF6342FC9BAEF7290C9C72EDD7867E1218CA18E3CE22EE184F10316B8B7F95D' +'&refresh_token=' + refreshToken;

            endpoint = loginUri + '/services/oauth2/token?' + queryParameters;

            Map<String, object> mapReqBody = DataMigrationController.getHTTPResponse(endpoint, '', 'POST', '', 'application/json');
                
            if (!String.isBlank(string.valueOf(mapReqBody.get('error'))))
            {
                return 'Error during the callout. Error message : ' + string.valueOf(mapReqBody.get('error')).left(120);
            }

            authorizationHeader = string.valueOf(mapReqBody.get('token_type')) + ' ' + string.valueOf(mapReqBody.get('access_token'));
        }

        endpoint = loginUri + '/services/data/v62.0/jobs/ingest';
        
        Map<String, String> jobDetails = new Map<String, String>{
            'externalIdFieldName' => keyField,
            //'lineEnding'=> 'CRLF', 
            'object' => objectName,
            'operation' => operation,
            'contentType' => 'CSV'
        };

        reqBody = JSON.serialize(jobDetails);
        Map<String, object> mapReqQryBody = DataMigrationController.getHTTPResponse(endpoint, authorizationHeader, 'POST', reqBody, 'application/json');
        
        if (!String.isBlank(string.valueOf(mapReqQryBody.get('error'))))
        {
            return 'Error creating bulk job. Error message : ' + string.valueOf(mapReqQryBody.get('error'));
        }
        else if (!String.isBlank(string.valueOf(mapReqQryBody.get('errorCode'))))
        {

            return 'Error creating bulk job. Error message : ' + string.valueOf(mapReqQryBody.get('message'));
        }

        return string.valueOf(mapReqQryBody.get('id'));

    }

    @AuraEnabled
    public static void uploadBulkData(String loginUri, String jobId, String csvData, String refreshToken, String authenticationMode) {
        HttpRequest req = new HttpRequest();

        String queryParameters;
        String reqBody;
        String authorizationHeader;
        String endpoint;
        if (authenticationMode == 'usernamePassword')
        {
            authorizationHeader = string.valueOf('Bearer ' + refreshToken);
        } 
        
        else 
        {
            queryParameters = 'grant_type=refresh_token' + '&client_id=' + '3MVG9TZvGM_0NqB1Oc_WTCesgrNIBC0TAx0bVuUsjs5TyqwZi8zWuNQNLY3.jiK38P8Vj5MaIM4Wew3qNu92E' +
            '&client_secret=' + 'FAF6342FC9BAEF7290C9C72EDD7867E1218CA18E3CE22EE184F10316B8B7F95D' +'&refresh_token=' + refreshToken;

            endpoint = loginUri + '/services/oauth2/token?' + queryParameters;

            Map<String, object> mapReqBody = DataMigrationController.getHTTPResponse(endpoint, '', 'POST', '', 'application/json');
                
            if (!String.isBlank(string.valueOf(mapReqBody.get('error'))))
            {
                System.debug('Error getting access token: ' + string.valueOf(mapReqBody.get('error')).left(120));
                throw new CalloutException('Error getting access token: ' + string.valueOf(mapReqBody.get('error')).left(120));
            }
            authorizationHeader = string.valueOf(mapReqBody.get('token_type')) + ' ' + string.valueOf(mapReqBody.get('access_token'));
        }

        endpoint = loginUri + '/services/data/v62.0/jobs/ingest/' + jobId + '/batches';

        Map<String, object> mapReqQryBody = DataMigrationController.getHTTPResponse(endpoint, authorizationHeader, 'PUT', csvData, 'text/csv');
        
        if (!String.isBlank(string.valueOf(mapReqQryBody.get('error'))))
        {
            System.debug('Error creating bulk job. Error message: ' + string.valueOf(mapReqQryBody.get('error')));
            throw new CalloutException('Error uploading bulk job data. Error message: ' + string.valueOf(mapReqQryBody.get('error')));
        }
        else if (!String.isBlank(string.valueOf(mapReqQryBody.get('errorCode'))))
        {
            System.debug('Error creating bulk job. Error message: ' + string.valueOf(mapReqQryBody.get('errorCode')));
            throw new CalloutException('Error uploading bulk job data. Error message: ' + string.valueOf(mapReqQryBody.get('errorCode')));
        }

    }

    @AuraEnabled
    public static void closeBulkJob(String loginUri, String jobId, String refreshToken, String authenticationMode) {
        HttpRequest req = new HttpRequest();

        String queryParameters;
        String reqBody;
        String authorizationHeader;
        String endpoint;

        if (authenticationMode == 'usernamePassword')
        {
            authorizationHeader = string.valueOf('Bearer ' + refreshToken);
        } 
        
        else 
        {  
            queryParameters = 'grant_type=refresh_token' + '&client_id=' + '3MVG9TZvGM_0NqB1Oc_WTCesgrNIBC0TAx0bVuUsjs5TyqwZi8zWuNQNLY3.jiK38P8Vj5MaIM4Wew3qNu92E' +
            '&client_secret=' + 'FAF6342FC9BAEF7290C9C72EDD7867E1218CA18E3CE22EE184F10316B8B7F95D' +'&refresh_token=' + refreshToken;

            endpoint = loginUri + '/services/oauth2/token?' + queryParameters;

            Map<String, object> mapReqBody = DataMigrationController.getHTTPResponse(endpoint, '', 'POST', '', 'application/json');
                
            if (!String.isBlank(string.valueOf(mapReqBody.get('error'))))
            {
                System.debug('Error getting access token: ' + string.valueOf(mapReqBody.get('error')).left(120));
                throw new CalloutException('Error getting access token: ' + string.valueOf(mapReqBody.get('error')).left(120));
            }
            authorizationHeader = string.valueOf(mapReqBody.get('token_type')) + ' ' + string.valueOf(mapReqBody.get('access_token'));
        }

        endpoint = loginUri + '/services/data/v62.0/jobs/ingest/' + jobId;
     

        Map<String, String> jobState = new Map<String, String>{
            'state' => 'UploadComplete'
        };
        reqBody = JSON.serialize(jobState);

        Map<String, object> mapReqQryBody = DataMigrationController.getHTTPResponse(endpoint, authorizationHeader, 'PATCH', reqBody, 'application/json');
        
        if (!String.isBlank(string.valueOf(mapReqQryBody.get('error'))))
        {
            System.debug('Error closing bulk job: ' + string.valueOf(mapReqQryBody.get('error')));
            throw new CalloutException('Error closing bulk job: ' + string.valueOf(mapReqQryBody.get('error')));
        }
        else if (!String.isBlank(string.valueOf(mapReqQryBody.get('errorCode'))))
        {

            System.debug('Error closing bulk job: ' + string.valueOf(mapReqQryBody.get('errorCode')));
            throw new CalloutException('Error closing bulk job: ' + string.valueOf(mapReqQryBody.get('errorCode')));
        }

    }
    
    // Additional methods for checking job status and retrieving results would also be needed.
    @AuraEnabled
    public static Map<String, object> getBulkJobResults(String loginUri, String jobId, String refreshToken, String authenticationMode) {
        HttpRequest req = new HttpRequest();
        String queryParameters;
        String reqBody;
        String authorizationHeader;
        String endpoint;
        
        if (authenticationMode == 'usernamePassword')
        {
            authorizationHeader = string.valueOf('Bearer ' + refreshToken);
        } 
        
        else 
        {  
            queryParameters = 'grant_type=refresh_token' + '&client_id=' + '3MVG9TZvGM_0NqB1Oc_WTCesgrNIBC0TAx0bVuUsjs5TyqwZi8zWuNQNLY3.jiK38P8Vj5MaIM4Wew3qNu92E' +
            '&client_secret=' + 'FAF6342FC9BAEF7290C9C72EDD7867E1218CA18E3CE22EE184F10316B8B7F95D' +'&refresh_token=' + refreshToken;

            endpoint = loginUri + '/services/oauth2/token?' + queryParameters;

            Map<String, object> mapReqBody = DataMigrationController.getHTTPResponse(endpoint, '', 'POST', '', 'application/json');
                
            if (!String.isBlank(string.valueOf(mapReqBody.get('error'))))
            {
                System.debug('Error getting access token: ' + string.valueOf(mapReqBody.get('error')).left(120));
                throw new CalloutException('Error getting access token: ' + string.valueOf(mapReqBody.get('error')).left(120));
            }
            authorizationHeader = string.valueOf(mapReqBody.get('token_type')) + ' ' + string.valueOf(mapReqBody.get('access_token'));
        }
            
               
        endpoint = loginUri + '/services/data/v62.0/jobs/ingest/' + jobId;
        

        Map<String, object> mapReqQryBody = DataMigrationController.getHTTPResponse(endpoint, authorizationHeader, 'GET', reqBody, 'application/json');

        if (!String.isBlank(string.valueOf(mapReqQryBody.get('error'))))
        {
            System.debug('Error get bulk job result: ' + string.valueOf(mapReqQryBody.get('error')));
            throw new CalloutException('Error getting bulk job result: ' + string.valueOf(mapReqQryBody.get('error')));
        }
        else if (!String.isBlank(string.valueOf(mapReqQryBody.get('errorCode'))))
        {

            System.debug('Error get bulk job result: ' + string.valueOf(mapReqQryBody.get('errorCode')));
            throw new CalloutException('Error getting bulk job result: ' + string.valueOf(mapReqQryBody.get('errorCode')));
        }

        return mapReqQryBody;
        
    }


    @AuraEnabled
    public static String getFailedRecords(String loginUri, String jobId, String refreshToken, String authenticationMode) {
        HttpRequest req = new HttpRequest();
        String queryParameters;
        String reqBody;
        String authorizationHeader;
        String endpoint;
        
        if (authenticationMode == 'usernamePassword')
        {
            authorizationHeader = string.valueOf('Bearer ' + refreshToken);
        } 
        
        else 
        {  
            queryParameters = 'grant_type=refresh_token' + '&client_id=' + '3MVG9TZvGM_0NqB1Oc_WTCesgrNIBC0TAx0bVuUsjs5TyqwZi8zWuNQNLY3.jiK38P8Vj5MaIM4Wew3qNu92E' +
            '&client_secret=' + 'FAF6342FC9BAEF7290C9C72EDD7867E1218CA18E3CE22EE184F10316B8B7F95D' +'&refresh_token=' + refreshToken;

            endpoint = loginUri + '/services/oauth2/token?' + queryParameters;

            Map<String, object> mapReqBody = DataMigrationController.getHTTPResponse(endpoint, '', 'POST', '', 'application/json');
                
            if (!String.isBlank(string.valueOf(mapReqBody.get('error'))))
            {
                System.debug('Error getting access token: ' + string.valueOf(mapReqBody.get('error')).left(120));
                throw new CalloutException('Error getting access token: ' + string.valueOf(mapReqBody.get('error')).left(120));
            }
            authorizationHeader = string.valueOf(mapReqBody.get('token_type')) + ' ' + string.valueOf(mapReqBody.get('access_token'));
        }
        
        endpoint = loginUri + '/services/data/v62.0/jobs/ingest/' + jobId + '/failedResults';

        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', authorizationHeader); 
        req.setTimeout(120000); // Set a timeout as needed

        try {
            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                return res.getBody(); 
            } else {
                System.debug('Error getting failed records: ' + res.getStatusCode() + ' - ' + res.getBody());
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception getting failed records: ' + e.getMessage());
            return null;
        }
    }


    public static Map<String, object> getHTTPResponse (String endpoint, String authorizationHeader, String method, String requestBody, String contentType){
        HttpRequest req = new HttpRequest();  
        req.setMethod(method);
        req.setEndpoint(endpoint);
        req.setTimeout(120000);

        if (!String.isEmpty(requestBody))
        {
            req.setBody(requestBody);
        }
        if(!String.isEmpty(authorizationHeader)){
            req.setHeader('Authorization', authorizationHeader);
        }
        req.setHeader ('Content-Type', contentType);
        Http httpReq = new Http();  
        try {
            HTTPResponse res = httpReq.send(req);
            if(res.getStatusCode() == 500) {
                System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getBody());
                List<Object> results = (List<Object>) JSON.deserializeUntyped(res.getBody());
                return (Map<String, object>)JSON.deserializeUntyped(JSON.serialize(results[0]));
            }
            else if (res.getStatusCode() == 201 || res.getStatusCode() == 200)
            { 
                if (!String.isEmpty(res.getBody())) {
                    return (Map<String, object>)JSON.deserializeUntyped(res.getBody());
                }
                else {
                    return (new Map<String, object>());
                }
            }
            else {
                System.debug('The status code returned was not expected: ' + res.getBody());
                return (new Map<String, String>{ 'error' => res.getBody() });
            }
        }
        catch(Exception e) {
            return (new Map<String, String>{ 'error' => e.getMessage() });
            
        }
    }

}