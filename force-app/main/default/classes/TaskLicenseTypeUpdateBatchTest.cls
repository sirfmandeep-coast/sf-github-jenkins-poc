@IsTest
private class TaskLicenseTypeUpdateBatchTest {

    // ---------- Helpers ----------
    private static Profile getUserProfile() {
        List<Profile> profs = [SELECT Id, Name FROM Profile WHERE Name = 'CCS Member Facing' LIMIT 1];
        if (!profs.isEmpty()) return profs[0];
        return [SELECT Id, Name FROM Profile WHERE UserType = 'Standard' LIMIT 1];
    }

    private static User makeUser(String uniq, Boolean mf, Boolean iiroc) {
        Profile p = getUserProfile();

        User u = new User(
            FirstName = 'Test',
            LastName  = 'User ' + uniq,
            Alias     = ('t' + uniq).left(8),
            Email     = 'testuser' + uniq + '@example.com',
            Username  = 'testuser' + uniq + '+' + System.currentTimeMillis() + '@example.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey   = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );

        u.MF_Licensed_User__c = mf;
        u.IIROC_Licensed__c   = iiroc;
        return u;
    }

    // ---------- Test Setup (runs in its own transaction) ----------
    @testSetup
    static void setupData() {

        // Turn on bypass flags (dynamic, so it won't break compilation if field names differ)
        User me = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        try {
            me.put('No_Flow__c', true);
        } catch (Exception e) { /* ignore if field doesn't exist */ }
        try {
            me.put('No_Flows__c', true);
        } catch (Exception e) { /* ignore if field doesn't exist */ }
        try {
            me.put('No_Validation__c', true);
        } catch (Exception e) { /* ignore if field doesn't exist */ }

        try {
            update me;
        } catch (Exception e) {
            // Ignore if org prevents updating running user or fields don't exist
        }

        // Insert the three creator users
        User mfUser         = makeUser('MF', true, false);   // Mutual Fund
        User iirocUser      = makeUser('IR', false, true);   // IIROC
        User unlicensedUser = makeUser('UN', false, false);  // Unlicensed
        insert new List<User>{ mfUser, iirocUser, unlicensedUser };
    }

    // ---------- Actual Tests ----------
    @IsTest
    static void testBatch_updatesLicenseType_forAllCreatorTypes() {

        // Create an Account to satisfy common Task validation rules (WhatId or WhoId required)
        Account a = new Account(Name = 'Test Account');
        insert a;

        // Pull users created in @testSetup
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

        // Create tasks under each user so CreatedById is set correctly
        List<Id> createdTaskIds = new List<Id>();

        System.runAs(mfUser) {
            Task t1 = new Task(
                Subject  = 'MF task',
                Status   = 'Not Started',
                Priority = 'Normal',
                WhatId   = a.Id
            );
            insert t1;
            createdTaskIds.add(t1.Id);
        }

        System.runAs(iirocUser) {
            Task t2 = new Task(
                Subject  = 'IIROC task',
                Status   = 'Not Started',
                Priority = 'Normal',
                WhatId   = a.Id
            );
            insert t2;
            createdTaskIds.add(t2.Id);
        }

        System.runAs(unlicensedUser) {
            Task t3 = new Task(
                Subject  = 'Unlicensed task',
                Status   = 'Not Started',
                Priority = 'Normal',
                WhatId   = a.Id
            );
            insert t3;
            createdTaskIds.add(t3.Id);
        }

        // Task that should NOT be updated (already stamped)
        Task alreadyStamped = new Task(
            Subject = 'Already stamped',
            Status  = 'Not Started',
            Priority= 'Normal',
            WhatId  = a.Id,
            Task_License_Type__c = 'IIROC'
        );
        insert alreadyStamped;

        // Execute batch (UPDATED: constructor now requires dates)
        Test.startTest();
        Database.executeBatch(new TaskLicenseTypeUpdateBatch(null, null), 200);
        Test.stopTest();

        // Assert expected values by CreatedById (order-independent)
        Map<Id, String> expectedByCreator = new Map<Id, String>{
            mfUser.Id         => 'Mutual Fund',
            iirocUser.Id      => 'IIROC',
            unlicensedUser.Id => 'Unlicensed'
        };

        for (Task t : [
            SELECT Id, CreatedById, Task_License_Type__c
            FROM Task
            WHERE Id IN :createdTaskIds
        ]) {
            System.assertEquals(
                expectedByCreator.get(t.CreatedById),
                t.Task_License_Type__c,
                'Unexpected license type for task created by ' + t.CreatedById
            );
        }

        // Verify already-stamped task did not get overwritten
        Task verifyAlreadyStamped = [
            SELECT Id, Task_License_Type__c
            FROM Task
            WHERE Id = :alreadyStamped.Id
            LIMIT 1
        ];
        System.assertEquals('IIROC', verifyAlreadyStamped.Task_License_Type__c);
    }

    @IsTest
    static void testBatch_handlesEmptyScopeGracefully() {

        Account a = new Account(Name = 'No-op Account');
        insert a;

        // Only stamped task exists, so batch query finds no records with Task_License_Type__c = null
        Task t = new Task(
            Subject = 'No-op',
            Status  = 'Not Started',
            Priority= 'Normal',
            WhatId  = a.Id,
            Task_License_Type__c = 'Unlicensed'
        );
        insert t;

        Test.startTest();
        Database.executeBatch(new TaskLicenseTypeUpdateBatch(null, null), 200);
        Test.stopTest();

        Task t2 = [SELECT Task_License_Type__c FROM Task WHERE Id = :t.Id];
        System.assertEquals('Unlicensed', t2.Task_License_Type__c);
    }
}