public class CCSEncryptURLParam {
    
    @InvocableMethod(label='Encrypt URL Param' Description='Returns encrypted String')
    public static List<methodOutputs> generateEncryptedString(List<methodInputs> request) {
    
    methodOutputs fo = new methodOutputs();
        Blob exampleIv = Blob.valueOf('3449878374837383');
        Blob key = Crypto.generateAesKey(128);
        Blob data = Blob.valueOf(request[0].toEncryptParam);
        Blob encrypted = Crypto.encrypt('AES128', EncodingUtil.convertFromHex(System.Label.AESKey), exampleIv, data);
        
        String encryptedString = EncodingUtil.convertToHex(encrypted);
        system.debug('hex'+EncodingUtil.convertToHex(encrypted));
        system.debug(EncodingUtil.convertToHex(key));
        system.debug('encrupte sin'+encryptedString);
        fo.encryptedString = encryptedString;
        List<MethodOutputs> theResults = new List<MethodOutputs>();
        theResults.add(fo) ;
        return theResults;
 
}
     public class methodInputs{
        @InvocableVariable
        public String toEncryptParam;
     }
    
    public class methodOutputs{
        @InvocableVariable
        public String encryptedString ;
    }



}