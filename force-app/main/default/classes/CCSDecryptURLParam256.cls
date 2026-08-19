//For decrypting Ids or other variable on AES256 algo CRM-6656
public class CCSDecryptURLParam256 {
    
            @InvocableMethod(label='Decrypt URL Param AES256' Description='Returns decrypted String')
    public static List<methodOutput> generateDecryptedString256(List<methodInput> request) {
    
    List<methodOutput> theResults = new List<methodOutput>();
    methodOutput fo = new methodOutput();

    // Fetch AES key from Protected Custom Metadata
    Encryption_Config__mdt config =
        Encryption_Config__mdt.getInstance('AES256');

    // Convert HEX key to Blob
    Blob key = EncodingUtil.convertFromHex(config.AES_256_Key__c);

    // Convert encrypted HEX string to Blob
    Blob encryptedBlob =
        EncodingUtil.convertFromHex(request[0].encryptedParam);

    // Decrypt using Managed IV (IV is extracted automatically)
    Blob decryptedBlob = Crypto.decryptWithManagedIV(
        'AES256',
        key,
        encryptedBlob
    );

    // Convert decrypted Blob to String
    fo.decryptedString = decryptedBlob.toString();
    theResults.add(fo);

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