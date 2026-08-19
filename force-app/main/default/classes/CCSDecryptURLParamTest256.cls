@isTest
public class CCSDecryptURLParamTest256 {
    @testSetup
    static void setup() {
        // Setup data if necessary
    }
    
    @isTest
    static void testGenerateDecryptedString() {
        // Arrange
        CCSDecryptURLParam256.methodInput input = new CCSDecryptURLParam256.methodInput();
        
        // Simulate an encrypted parameter
        String originalText = 'TestString';
        // Load encryption key from Protected Custom Metadata
        Encryption_Config__mdt config =
            Encryption_Config__mdt.getInstance('AES256');
    	// Convert HEX key to Blob
        Blob key = EncodingUtil.convertFromHex(config.AES_256_Key__c);
         // Encrypt using managed IV
        Blob data = Crypto.encryptWithManagedIV(
            'AES256',
            key,
            Blob.valueOf(originalText)
        );
        input.encryptedParam = EncodingUtil.convertToHex(data);
        
        List<CCSDecryptURLParam256.methodInput> inputList = new List<CCSDecryptURLParam256.methodInput>{ input };
        
        // Act
        Test.startTest();
        List<CCSDecryptURLParam256.methodOutput> result = CCSDecryptURLParam256.generateDecryptedString256(inputList);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Result list should have one item');
        System.assertEquals(originalText, result[0].decryptedString, 'Decrypted text should match original');
    }
}