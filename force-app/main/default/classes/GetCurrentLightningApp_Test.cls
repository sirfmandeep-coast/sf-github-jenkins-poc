@IsTest
private class GetCurrentLightningApp_Test {
    
    /**
     * Utility to create a fresh standard user to ensure deterministic
     * "no data" behavior (no UserAppInfo rows expected for the new user).
     */
    private static User createFreshUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            ProfileId = p.Id
        );
        insert u;
        return u;
    }

    @IsTest
    static void returnsOneResult_andFoundIsFalse_whenNoUserAppInfo() {
        // Arrange: run as a new user that won't have UserAppInfo rows.
        User u = createFreshUser();
        System.runAs(u) {
            Test.startTest();
            List<String> input = new List<String>{ 'dummy' }; // Flow-style collection input
            List<GetCurrentLighningApp.Result> out = GetCurrentLighningApp.getCurrentLightningApp(input);
            Test.stopTest();

            // Assert: always returns exactly one result
            System.assertEquals(1, out.size(), 'Should return exactly one Result');

            GetCurrentLighningApp.Result r = out[0];

            // For a fresh user, we expect no UserAppInfo → found == false
            System.assertEquals(false, r.found, 'Expected found=false for a new user with no UserAppInfo');
            System.assertEquals(null, r.appLabel, 'App label should be null when not found');
            System.assertEquals(null, r.appDurableId, 'Durable Id should be null when not found');
            System.assertEquals(null, r.formFactor, 'Form factor should be null when not found');
        }
    }

    /**
     * Optional coverage for the "happy path". We cannot create UserAppInfo/AppDefinition,
     * so we use SeeAllData=true to *attempt* to read existing org data for the running user.
     * The assertions are conditional to keep the test deterministic.
     */
    @IsTest(SeeAllData=true)
    static void returnsFoundTrue_ifOrgHasUserAppInfo() {
        Test.startTest();
        List<String> input = new List<String>{ 'dummy' };
        List<GetCurrentLighningApp.Result> out = GetCurrentLighningApp.getCurrentLightningApp(input);
        Test.stopTest();

        System.assertEquals(1, out.size(), 'Should return exactly one Result');
        GetCurrentLighningApp.Result r = out[0];

        // Deterministic: If found, ensure fields are populated; if not found, ensure fields are null.
        if (r.found == true) {
            System.assertNotEquals(null, r.appLabel, 'Label should be populated when found=true');
            System.assertNotEquals(null, r.appDurableId, 'Durable Id should be populated when found=true');
      
        } else {
            System.assertEquals(null, r.appLabel, 'Label should be null when not found');
            System.assertEquals(null, r.appDurableId, 'Durable Id should be null when not found');

        }
    }
}