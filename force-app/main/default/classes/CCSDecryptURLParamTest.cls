@isTest
public class CCSDecryptURLParamTest {
    @testSetup
    static void setup() {
        // Setup data if necessary
    }
    
    @isTest
    static void testGenerateDecryptedString() {
        // Arrange
        CCSDecryptURLParam.methodInput input = new CCSDecryptURLParam.methodInput();
        
        // Simulate an encrypted parameter
        String originalText = 'TestString';
        Blob key = EncodingUtil.convertFromHex(System.Label.AESKey);
        Blob exampleIv = Blob.valueOf('3449878374837383');
        Blob data = Crypto.encrypt('AES128', key, exampleIv, Blob.valueOf(originalText));
        input.encryptedParam = EncodingUtil.convertToHex(data);
        
        List<CCSDecryptURLParam.methodInput> inputList = new List<CCSDecryptURLParam.methodInput>{ input };
        
        // Act
        Test.startTest();
        List<CCSDecryptURLParam.methodOutput> result = CCSDecryptURLParam.generateDecryptedString(inputList);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Result list should have one item');
        System.assertEquals(originalText, result[0].decryptedString, 'Decrypted text should match original');
    }
}