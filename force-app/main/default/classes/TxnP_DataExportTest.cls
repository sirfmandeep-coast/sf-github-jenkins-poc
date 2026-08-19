/**
 * Test for default MyDataLoaderLeadExportCondition provided by Salesforce
 * 
*/
@isTest
public class TxnP_DataExportTest {

    /*
     * Test to check if policy gets triggered when user exports Leads
    */
  @isTest
    public static void testDataExportTriggered() {

    User user = TxnP_TestHelper.createNonAdminUser();
    String entityName;	// = 'Lead';
    String action = 'DataExport';
    String resourceType;	// ='Lead';
    Id entityId; // ='000000000000000000';

    Integer adminRecordsAllowed = integer.valueof([SELECT label from TxnProfile_Settings__mdt where setting_name__c='export_records_admin' and isactive__c=true limit 1].label);

        Map<String, String> eventMap = new Map<String, String>();
        eventMap.put('NumberOfRecords', String.valueOf(adminRecordsAllowed+2));
        eventMap.put('ExecutionTime', '30');
        eventMap.put('EntityName', entityName);
     
    TxnSecurity.Event e = TxnP_TestHelper.createTransactionSecurityEvent(user, entityName, action, resourceType, entityId, eventMap) ;

    /* We are unit testing a PolicyCondition that triggers
       when an event is generated due to high NumberOfRecords */
    TxnP_DataExport txnPDataExport = new TxnP_DataExport();
    /* Assert that the condition is triggered */
    System.assertEquals(true, txnPDataExport.evaluate(e));
   }

   
    /*
     * Test to check if policy doesn't get triggered when user exports 200 Leads
    */
  @isTest
    public static void testDataExportNotTriggered() {

    User user = TxnP_TestHelper.createUser();
    String entityName;	// = 'Lead';
    String action = 'DataExport';
    String resourceType;	// ='Lead';
    Id entityId; // ='000000000000000000';

   Integer adminRecordsAllowed = integer.valueof([SELECT label from TxnProfile_Settings__mdt where setting_name__c='export_records_admin' and isactive__c=true limit 1].label);
        
        Map<String, String> eventMap = new Map<String, String>();
        eventMap.put('NumberOfRecords', String.valueOf(adminRecordsAllowed-2));
        eventMap.put('ExecutionTime', '30');
        eventMap.put('EntityName', entityName);
     
    TxnSecurity.Event e = TxnP_TestHelper.createTransactionSecurityEvent(user, entityName, action, resourceType, entityId, eventMap) ;

      /* We are unit testing a PolicyCondition that does not trigger
       an event due to low NumberOfRecords  */
    TxnP_DataExport_Admins txnPDataExport = new TxnP_DataExport_Admins();
      
    /* Assert that the condition is NOT triggered */
    System.assertEquals(false, txnPDataExport.evaluate(e));
  }

}