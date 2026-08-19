@isTest(Seealldata=true)
public class TxnP_LoginHistoryTest {

  @isTest 
    public static void testLoginHistoryNotTriggered() {

   LoginHistory lh = [SELECT userId,Platform, Browser,SourceIP,LoginType,Application FROM LoginHistory where LoginType like '%sso%' order by LoginTime desc limit 1];
    
    User user = [Select Id from user where id=:lh.UserId];
    String entityName;
    String action = 'Login';
    String resourceType ='LoginHistory';
    Id entityId;
     
        Map<String, String> eventMap = new Map<String, String>();
        eventMap.put('LoginHistoryId', lh.Id);
     
    TxnSecurity.Event e = TxnP_TestHelper.createTransactionSecurityEvent(user, entityName, action, resourceType, entityId, eventMap) ;

    TxnP_LoginHistory txnPLoginHistory = new TxnP_LoginHistory();
    // Assert that the condition is triggered
    System.assertEquals(false, txnPLoginHistory.evaluate(e));
   }

   
    /* Test to check if policy doesn't get triggered */
/*  @isTest
    public static void testLoginHistoryNotTriggered() {

   LoginHistory lh = [SELECT userId,Platform, Browser,SourceIp,LoginType,Application FROM LoginHistory where LoginType ='Remote Access 2.0' and sourceIp in('204.174.76.34', '204.174.77.34') limit 1];
    
    User user = [Select Id from user where id=:lh.UserId];
    String entityName;
    String action = 'Login';
    String resourceType ='LoginHistory';
    Id entityId;
     
        Map<String, String> eventMap = new Map<String, String>();
        eventMap.put('LoginHistoryId', lh.Id);

    TxnSecurity.Event e = TxnP_TestHelper.createTransactionSecurityEvent(user, entityName, action, resourceType, entityId, eventMap) ;
      
    TxnP_LoginHistory txnPLoginHistory = new TxnP_LoginHistory();
      
    /* Assert that the condition is NOT triggered */
/*    System.assertEquals(false, txnPLoginHistory.evaluate(e));
  }
*/
}