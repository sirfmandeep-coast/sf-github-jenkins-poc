@IsTest
private class FeeDisclosureLicenseTypeUpdateBatchTest {

    /* ----------------------------
     * Helper: Profile
     * ---------------------------- */
    private static Profile getUserProfile() {
        List<Profile> profs = [
            SELECT Id
            FROM Profile
            WHERE Name = 'CCS Member Facing'
            LIMIT 1
        ];
        if (!profs.isEmpty()) {
            return profs[0];
        }
        return [
            SELECT Id
            FROM Profile
            WHERE UserType = 'Standard'
            LIMIT 1
        ];
    }

    /* ----------------------------
     * Helper: User creation
     * ---------------------------- */
    private static User makeUser(String suffix, Boolean mf, Boolean iiroc) {

        User u = new User(
            FirstName = 'Test',
            LastName  = 'User ' + suffix,
            Alias     = ('t' + suffix).left(8),
            Email     = 'testuser' + suffix + '@example.com',
            Username  = 'testuser' + suffix + '+' + System.currentTimeMillis() + '@example.com',
            TimeZoneSidKey     = 'America/Los_Angeles',
            LocaleSidKey       = 'en_US',
            EmailEncodingKey   = 'UTF-8',
            LanguageLocaleKey  = 'en_US',
            ProfileId          = getUserProfile().Id
        );

        u.MF_Licensed_User__c   = mf;
        u.IIROC_Licensed__c     = iiroc;

        return u;
    }

    /* ----------------------------
     * @testSetup
     * ---------------------------- */
    @testSetup
    static void setupUsers() {

        // Optional: enable bypass flags on running user if your org uses them
        // (matches approach we discussed earlier in this chat)
        try {
            User me = [
                SELECT Id, No_Flow__c, No_Validation__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ];
            me.No_Flow__c = true;
            me.No_Validation__c = true;
            update me;
        } catch (Exception e) {
            // Ignore if org does not have these fields
        }

        insert new List<User>{
            makeUser('MF', true,  false),  // Mutual Fund
            makeUser('IR', false, true),   // IIROC
            makeUser('UN', false, false)   // Unlicensed
        };
    }

    /* ----------------------------
     * Main batch test
     * ---------------------------- */
    @IsTest
    static void testBatch_updatesCreatorLicenseType() {

        // Fetch users created in @testSetup
        Map<String, User> usersByLastName = new Map<String, User>();
        for (User u : [
            SELECT Id, LastName
            FROM User
            WHERE LastName IN ('User MF', 'User IR', 'User UN')
        ]) {
            usersByLastName.put(u.LastName, u);
        }

        User mfUser         = usersByLastName.get('User MF');
        User iirocUser      = usersByLastName.get('User IR');
        User unlicensedUser = usersByLastName.get('User UN');

        List<Id> createdIds = new List<Id>();

        /* ---- Create Fee Disclosures under different creators ---- */

        System.runAs(mfUser) {
            Fee_Disclosure__c fd = new Fee_Disclosure__c(
                Fund_Code__c = 'FDMF'
                // Creator_License_Type__c intentionally left NULL
            );
            insert fd;
            createdIds.add(fd.Id);
        }

        System.runAs(iirocUser) {
            Fee_Disclosure__c fd = new Fee_Disclosure__c(
                Fund_Code__c = 'IIROC'
            );
            insert fd;
            createdIds.add(fd.Id);
        }

        System.runAs(unlicensedUser) {
            Fee_Disclosure__c fd = new Fee_Disclosure__c(
                Fund_Code__c = 'UN'
            );
            insert fd;
            createdIds.add(fd.Id);
        }

        /* ---- Control record (already stamped, should NOT change) ---- */
        Fee_Disclosure__c alreadyStamped = new Fee_Disclosure__c(
            Fund_Code__c = 'Exist',
            Creator_License_Type__c = 'IIROC'
        );
        insert alreadyStamped;

        /* ---- Execute batch ---- */
        Test.startTest();
        Database.executeBatch(
            new FeeDisclosureLicenseTypeUpdateBatch(),
            100
        );
        Test.stopTest();

        /* ---- Assertions ---- */
        Map<Id, String> expectedByCreator = new Map<Id, String>{
            mfUser.Id         => 'Mutual Fund',
            iirocUser.Id      => 'IIROC',
            unlicensedUser.Id => 'Unlicensed'
        };

        for (Fee_Disclosure__c fd : [
            SELECT Id, CreatedById, Creator_License_Type__c
            FROM Fee_Disclosure__c
            WHERE Id IN :createdIds
        ]) {
            System.assertEquals(
                expectedByCreator.get(fd.CreatedById),
                fd.Creator_License_Type__c,
                'Incorrect license type stamped for Fee Disclosure'
            );
        }

        // Verify existing record was not overwritten
        Fee_Disclosure__c verifyExisting = [
            SELECT Creator_License_Type__c
            FROM Fee_Disclosure__c
            WHERE Id = :alreadyStamped.Id
        ];
        System.assertEquals('IIROC', verifyExisting.Creator_License_Type__c);
    }

    /* ----------------------------
     * Empty-scope coverage
     * ---------------------------- */
    @IsTest
    static void testBatch_handlesEmptyScope() {

        Fee_Disclosure__c fd = new Fee_Disclosure__c(
            Fund_Code__c = 'Set',
            Creator_License_Type__c = 'Unlicensed'
        );
        insert fd;

        Test.startTest();
        Database.executeBatch(
            new FeeDisclosureLicenseTypeUpdateBatch(),
            100
        );
        Test.stopTest();

        Fee_Disclosure__c verify = [
            SELECT Creator_License_Type__c
            FROM Fee_Disclosure__c
            WHERE Id = :fd.Id
        ];
        System.assertEquals('Unlicensed', verify.Creator_License_Type__c);
    }
}