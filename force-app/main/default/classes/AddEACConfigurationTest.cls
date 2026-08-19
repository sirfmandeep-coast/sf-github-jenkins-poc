@isTest
global with sharing  class AddEACConfigurationTest {
@IsTest static void testAddEACUser() {
    List<Id> userId = new List <Id>{'0052B000000HjlEQAS'};
        Test.startTest();
        AddEACConfiguration.AddEACUser(userId);
        Test.stopTest();
}
}