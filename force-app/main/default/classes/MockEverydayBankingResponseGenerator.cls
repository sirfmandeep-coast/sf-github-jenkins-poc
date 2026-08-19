@isTest

public class MockEverydayBankingResponseGenerator implements HttpCalloutMock {

    String callMethod;
    Integer statusCode;
    Public MockEverydayBankingResponseGenerator (String inCallMethod, Integer inStatusCode){
        callMethod = inCallMethod;
        statusCode = inStatusCode;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (callMethod == 'profile'){
            res.setBody('[{"t24ProfileId":"00408940","accountNumber":"11000779005566","loyaltyServiceName":"sigma","sigmaActCode":"001140","status":"ACTIVE","createdDate":"2022-09-09","lastModifiedOn":"2022-09-10","lastModifiedBy":"avishwa"},{"t24ProfileId":"00408941","accountNumber":"11000779005566","loyaltyServiceName":"coursera","emailAddress":"john.d@yahoo.com","status":"ACTIVE","createdDate":"2022-09-09","lastModifiedOn":"2022-09-10","lastModifiedBy":"avishwa"}]');
        }
        else 
        {
            res.setBody('[{"t24ProfileId":"00408940","accountNumber":"11000779005566","loyaltyServiceName":"sigma","sigmaActCode":"001140","status":"ACTIVE","createdDate":"2022-09-09","lastModifiedOn":"2022-09-10","lastModifiedBy":"avishwa"},{"t24ProfileId":"00408941","accountNumber":"11000779005566","loyaltyServiceName":"coursera","emailAddress":"john.d@yahoo.com","status":"ACTIVE","createdDate":"2022-09-09","lastModifiedOn":"2022-09-10","lastModifiedBy":"avishwa"}]');
        }
        res.setStatusCode(statusCode);
        return res;
    }
}