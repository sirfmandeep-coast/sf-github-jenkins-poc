@isTest
public class CCSEncryptURLParamTest256 {

    // Test method for generateEncryptedString
    @isTest
    public static void testGenerateEncryptedString() {
        
        // Prepare test data
        String inputString = 'TestStringToEncrypt';
        
        // Create a list of methodInputs with the input data
        List<CCSEncryptURLParam256.methodInputs> inputs = new List<CCSEncryptURLParam256.methodInputs>();
        CCSEncryptURLParam256.methodInputs input = new CCSEncryptURLParam256.methodInputs();
        input.toEncryptParam = inputString;
        inputs.add(input);
        
        // Call the method to be tested in here
        Test.startTest();
        List<CCSEncryptURLParam256.methodOutputs> outputs = CCSEncryptURLParam256.generateEncryptedString256(inputs);
        Test.stopTest();
        
        // Assert that the result is not null and contains the expected values
        System.assertNotEquals(outputs, null, 'Output should not be null');
        System.assertEquals(outputs.size(), 1, 'Expected only one result in the list');
        System.assertNotEquals(outputs[0].encryptedString, null, 'Encrypted string should not be null');
        String encryptedString = outputs[0].encryptedString;

    }
}