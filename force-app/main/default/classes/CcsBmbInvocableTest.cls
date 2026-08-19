@isTest
private class CcsBmbInvocableTest {

    /**
     * Mock response that covers:
     * 1) Business membership path
     * 2) Sole Proprietor membership path
     * 3) Non-Business membership being skipped
     * 4) Signer collection population
     */
    private class BmbMixedMembershipMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');

            String body =
                '{' +
                    '"memberships":[' +
                        '{' +
                            '"membershipNumber":"40130743",' +
                            '"membershipIndustry":"Incorporated Association",' +
                            '"membershipType":"Business",' +
                            '"signers":[' +
                                '{"signerId":"40130735","signerRole":"Owner"},' +
                                '{"signerId":"451850","signerGivenName":"GIVEN451850","signerFamilyName":"FAMILY451850","signerRole":"Director"}' +
                            ']' +
                        '},' +
                        '{' +
                            '"membershipNumber":"SP10001",' +
                            '"membershipIndustry":"Sole Proprietor",' +
                            '"membershipType":"Business",' +
                            '"signers":[' +
                                '{"signerId":"999999","signerGivenName":"SOLE","signerFamilyName":"OWNER","signerRole":"Owner"}' +
                            ']' +
                        '},' +
                        '{' +
                            '"membershipNumber":"PERS0001",' +
                            '"membershipIndustry":"Personal",' +
                            '"membershipType":"Personal",' +
                            '"signers":[' +
                                '{"signerId":"123456","signerGivenName":"IGNORE","signerFamilyName":"ME","signerRole":"Viewer"}' +
                            ']' +
                        '}' +
                    ']' +
                '}';

            res.setBody(body);
            return res;
        }
    }

    /**
     * Simple valid response used for the null-profileId branch.
     */
    private class BmbSimpleSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{' +
                    '"memberships":[' +
                        '{' +
                            '"membershipNumber":"40130743",' +
                            '"membershipIndustry":"Incorporated Association",' +
                            '"membershipType":"Business",' +
                            '"signers":[' +
                                '{"signerId":"40130735","signerRole":"Owner"}' +
                            ']' +
                        '}' +
                    ']' +
                '}'
            );
            return res;
        }
    }

    /**
     * Malformed JSON to force JSON.deserialize(...) to throw an exception
     * so the catch(Exception ex) branch is covered.
     */
    private class BmbInvalidJsonMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "memberships": [ { "membershipNumber": "40130743", '); // deliberately broken JSON
            return res;
        }
    }

    @isTest
    static void testInvoke_CoversBusinessAndSolePropBranches() {
        // Arrange
        CcsDto.CcsRequestDTO req = new CcsDto.CcsRequestDTO();
        req.namedCredentials = 'CCSBmbCustomer';
        req.method = 'GET';
        req.path = '/memberships/customer-details';
        req.profileId = '40130735';

        Test.setMock(HttpCalloutMock.class, new BmbMixedMembershipMock());

        // Act
        Test.startTest();
        List<CcsDto.CcsResponseDTO> results =
            CcsBmbInvocable.invoke(new List<CcsDto.CcsRequestDTO>{ req });
        Test.stopTest();

        // Assert top-level response
        System.assertEquals(1, results.size(), 'Exactly one response DTO should be returned');

        CcsDto.CcsResponseDTO resp = results[0];
        System.assertEquals(200, resp.statusCode, 'Status code should be captured from the mock response');
        System.assertEquals('OK', resp.status, 'Status text should be captured from the mock response');
        System.assertNotEquals(null, resp.body, 'Response body should be captured');
        System.assertNotEquals(null, resp.conversationId, 'ConversationId should be captured');
        System.assertEquals(
            'callout:CCSBmbCustomer/memberships/customer-details',
            resp.finalEndpoint,
            'Final endpoint should be constructed from named credential + path'
        );

        // membershipChoices should include Business memberships
        System.assertNotEquals(null, resp.membershipChoices, 'Regular membership choices should be populated');
        System.assertEquals(
            2,
            resp.membershipChoices.size(),
            'Regular business membership choices should include the two Business memberships'
        );

        Set<String> regularMembershipNums = new Set<String>();
        Set<String> regularIndustries = new Set<String>();
        for (CcsFlowChoice c : resp.membershipChoices) {
            System.assertNotEquals(null, c, 'Membership choice should not be null');
            regularMembershipNums.add(c.membershipNumber);
            regularIndustries.add(c.membershipIndustry);
        }
        System.assert(regularMembershipNums.contains('40130743'),
            'Regular membership choices should include 40130743');
        System.assert(regularMembershipNums.contains('SP10001'),
            'Regular membership choices should include the Sole Proprietor membership number too');
        System.assert(regularIndustries.contains('Incorporated Association'),
            'Regular membership choices should include Incorporated Association');
        System.assert(regularIndustries.contains('Sole Proprietor'),
            'Regular membership choices should include Sole Proprietor');

        // solePropMembershipChoices should cover the previously missed lines
        System.assertNotEquals(null, resp.solePropMembershipChoices,
            'Sole Proprietor membership choices should be populated');
        System.assertEquals(
            1,
            resp.solePropMembershipChoices.size(),
            'Exactly one Sole Proprietor membership should be returned'
        );

        CcsFlowChoice soleProp = resp.solePropMembershipChoices[0];
        System.assertEquals('SP10001', soleProp.label,
            'Sole Prop label should be the membership number');
        System.assertEquals('SP10001', soleProp.value,
            'Sole Prop value should be the membership number');
        System.assertEquals('SP10001', soleProp.membershipNumber,
            'Sole Prop membershipNumber should be set');
        System.assertEquals('Sole Proprietor', soleProp.membershipIndustry,
            'Sole Prop membershipIndustry should be set');

        // signerChoices should still populate
        System.assertNotEquals(null, resp.signerChoices, 'Signer choices should be populated');
        System.assert(
            resp.signerChoices.size() > 0,
            'At least one signer choice should be returned'
        );
    }

    @isTest
    static void testInvoke_NullProfileIdBranch() {
        // Arrange
        CcsDto.CcsRequestDTO req = new CcsDto.CcsRequestDTO();
        req.namedCredentials = 'CCSBmbCustomer';
        req.method = 'GET';
        req.path = '/memberships/customer-details';
        req.profileId = null; // covers branch where setProfileId is not invoked

        Test.setMock(HttpCalloutMock.class, new BmbSimpleSuccessMock());

        // Act
        Test.startTest();
        List<CcsDto.CcsResponseDTO> results =
            CcsBmbInvocable.invoke(new List<CcsDto.CcsRequestDTO>{ req });
        Test.stopTest();

        // Assert
        System.assertEquals(1, results.size(), 'One response DTO should still be returned');
        System.assertEquals(200, results[0].statusCode, 'Mock should still return 200');
        System.assertNotEquals(null, results[0].membershipChoices,
            'Membership choices should still populate when profileId is null');
        System.assertEquals(1, results[0].membershipChoices.size(),
            'One business membership should be returned from the simple mock');
    }

    @isTest
    static void testInvoke_ExceptionPath_SetsErrorMessage() {
        // Arrange
        CcsDto.CcsRequestDTO req = new CcsDto.CcsRequestDTO();
        req.namedCredentials = 'CCSBmbCustomer';
        req.method = 'GET';
        req.path = '/memberships/customer-details';
        req.profileId = '40130735';

        Test.setMock(HttpCalloutMock.class, new BmbInvalidJsonMock());

        // Act
        Test.startTest();
        List<CcsDto.CcsResponseDTO> results =
            CcsBmbInvocable.invoke(new List<CcsDto.CcsRequestDTO>{ req });
        Test.stopTest();

        // Assert
        System.assertEquals(1, results.size(), 'One response DTO should be returned even on exception');

        CcsDto.CcsResponseDTO resp = results[0];
        System.assertEquals(200, resp.statusCode,
            'Status code should already be captured before JSON parsing fails');
        System.assertEquals('OK', resp.status,
            'Status should already be captured before JSON parsing fails');
        System.assertNotEquals(null, resp.body,
            'Body should already be captured before JSON parsing fails');

        // This is the key assertion for:
        // catch (Exception ex) { respDto.errorMessage = ex.getMessage(); }
        System.assertNotEquals(null, resp.errorMessage,
            'errorMessage should be populated when an exception is thrown');
        System.assert(resp.errorMessage.length() > 0,
            'errorMessage should not be blank when an exception is thrown');
    }
}