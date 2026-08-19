@istest
class ccsExpireLeadsSchedulerTest{
    public static testMethod void testschedule() {
        Test.StartTest();
        ccsExpireLeadsScheduler testsche = new ccsExpireLeadsScheduler ();
        system.schedule('Test status Check 01', '0 0 * * * ?', testsche );
        system.schedule('Test status Check 02', '0 15 * * * ?', testsche );
        system.schedule('Test status Check 03', '0 30 * * * ?', testsche );
        system.schedule('Test status Check 04', '0 45 * * * ?', testsche );
        Test.stopTest();
    }
}