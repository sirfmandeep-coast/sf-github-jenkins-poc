//For encrypting Ids or other variable on AES256 algo CRM-6656
public class CCSEncryptURLParam256 {
    
    @InvocableMethod(label='Encrypt URL Param AES256' Description='Returns encrypted String')
    public static List<methodOutputs> generateEncryptedString256(List<methodInputs> request) {
     
        List<methodOutputs> results = new List<methodOutputs>();
        methodOutputs fo = new methodOutputs();

        // Convert input string to Blob
        Blob data = Blob.valueOf(request[0].toEncryptParam);
		
		// Load encryption key from Protected Custom Metadata
        Encryption_Config__mdt config =
            Encryption_Config__mdt.getInstance('AES256');

       
		// Convert HEX key to Blob
        Blob key = EncodingUtil.convertFromHex(config.AES_256_Key__c);

        // Encrypt using managed IV
        Blob encryptedBlob = Crypto.encryptWithManagedIV(
            'AES256',
            key,
            data
        );

        // Convert encrypted Blob (IV + ciphertext) to hex
        String encryptedString = EncodingUtil.convertToHex(encryptedBlob);
        fo.encryptedString = encryptedString;
        results.add(fo);
        return results;
 
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