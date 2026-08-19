public class CCSDecryptURLParam {
            @InvocableMethod(label='Decrypt URL Param' Description='Returns decrypted String')
    public static List<methodOutput> generateDecryptedString(List<methodInput> request) {
    
    methodOutput fo = new methodOutput();
        Blob exampleIv = Blob.valueOf('3449878374837383');
        Blob key = Crypto.generateAesKey(128);
         system.debug('decryptkey '+EncodingUtil.convertToHex(key));
          system.debug('encrypted string passed '+ request[0].encryptedParam);
        Blob data = EncodingUtil.convertFromHex(request[0].encryptedParam);
        Blob decrypted = Crypto.decrypt('AES128', EncodingUtil.convertFromHex(System.Label.AESKey) , exampleIv, data);
         
        	
        String decryptedString = decrypted.toString(); 
        system.debug('decryptedString '+ decryptedString);
        fo.decryptedString = decryptedString;
        List<MethodOutput> theResults = new List<MethodOutput>();
        theResults.add(fo) ;
        return theResults;
 
}
     public class methodInput{
        @InvocableVariable
        public String encryptedParam;
     }
    
    public class methodOutput{
        @InvocableVariable
        public String decryptedString ;
    }


}