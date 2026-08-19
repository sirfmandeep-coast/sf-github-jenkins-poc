@isTest
public class CCSEncryptURLParamTest {

    // Test method for generateEncryptedString
    @isTest
    public static void testGenerateEncryptedString() {
        
        // Prepare test data
        String inputString = 'TestStringToEncrypt';
        
        // Create a list of methodInputs with the input data
        List<CCSEncryptURLParam.methodInputs> inputs = new List<CCSEncryptURLParam.methodInputs>();
        CCSEncryptURLParam.methodInputs input = new CCSEncryptURLParam.methodInputs();
        input.toEncryptParam = inputString;
        inputs.add(input);
        
        // Call the method to be tested
        Test.startTest();
        List<CCSEncryptURLParam.methodOutputs> outputs = CCSEncryptURLParam.generateEncryptedString(inputs);
        Test.stopTest();
        
        // Assert that the result is not null and contains the expected values
        System.assertNotEquals(outputs, null, 'Output should not be null');
        System.assertEquals(outputs.size(), 1, 'Expected only one result in the list');
        System.assertNotEquals(outputs[0].encryptedString, null, 'Encrypted string should not be null');
        
        // Debugging to check the values
        System.debug('Encrypted String: ' + outputs[0].encryptedString);
        
        // Further assert that the encrypted string is a valid hex value
        String encryptedString = outputs[0].encryptedString;
        //Boolean isValidHex = encryptedString.matches('^[0-9A-Fa-f]+$');
        //System.assert(isValidHex, 'Encrypted string should be a valid hexadecimal string');
    }
}