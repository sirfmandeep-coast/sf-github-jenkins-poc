@isTest
public class TxnP_TestHelper {

     /* Create an example user */
    public static User createUser(){
        Profile p = [select id from profile where name='System Administrator'];
        String ourSysAdminString = p.Id; 
        
        User u = new User(alias = 'test', email='user@salesforce.com',
            emailencodingkey='UTF-8', lastname='TestLastname', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, country='United States',
            timezonesidkey='America/Los_Angeles', username=generateRandomUsername(7));
        insert u;
        return u;
    }

        public static User createNonAdminUser(){
        Profile p = [select id from profile where name='CCS Internal'];
        String ourSysAdminString = p.Id; 
        
        User u = new User(alias = 'test', email='user@salesforce.com',
            emailencodingkey='UTF-8', lastname='TestLastname', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, country='United States',
            timezonesidkey='America/Los_Angeles', username=generateRandomUsername(7));
        insert u;
        return u;
    }

    /**
     * Generates a random username of the form “[random]@[random].com”, where the 
     * length of the random string is the given Integer argument. For example, with 
     * an argument of 3, the following random username may be produced: 
     * “ajZ@ajZ.com”.
     */ 
    private static String generateRandomUsername(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr + '@' + randStr + '.com'; 
    }

    /** Returns current organization */
    private static Organization getOrganization(){
        return [SELECT id, Name FROM Organization];
    }
      
    
    /** Create a TxnSecurity.Event instance     */ 
    public static TxnSecurity.Event createTransactionSecurityEvent(User user, String entityName, String action, String resourceType, Id entityId, Map<String, String> eventMap)
    {

    dateTime currentDT = dateTime.now();
    Organization org =getOrganization();

        TxnSecurity.Event e = new TxnSecurity.Event(
             org.Id /* organizationId */,
             user.Id /* userId */,
             entityName /* Lead entityName */ ,
             action /*'DataExport'  action */,
             resourceType /* 'Lead' resourceType */,
             entityId /*'000000000000000' entityId */,
             currentDT /* timeStamp */,
             eventMap /* data - Map containing information about the event */ );
        return e;
    }
}