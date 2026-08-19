@IsTest
public with sharing class ShowCurrentRatesControllerTest {
    @isTest
    public static void myTest() {
        ShowCurrentRatesController controller = new ShowCurrentRatesController();
        String aa = controller.contentHostname;
        aa = controller.contentVersionId;
        try {
            aa = controller.versionData;
        } catch (Exception e) {
            
        }
        
    }
}