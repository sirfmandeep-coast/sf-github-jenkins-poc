public class CCSGenerateRandomString {
    //Used for Retail Authentication process
    
    @InvocableMethod(label='Get Random String' Description='Returns a list of Account Ids')
    public static List<methodOutputs> generateRandomString(List<methodInputs> request) {
    final String chars = '21358412096471597413829';
    String randStr = '';
    methodOutputs fo = new methodOutputs();
    while (randStr.length() < request[0].len) {
       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
       randStr += chars.substring(idx, idx+1);
    }
        fo.randomString = randStr;
        List<MethodOutputs> theResults = new List<MethodOutputs>();
        theResults.add(fo) ;
        return theResults;
 
}
     public class methodInputs{
        @InvocableVariable
        public Integer len;
     }
    
    public class methodOutputs{
        @InvocableVariable
        public String randomString ;
    }

}