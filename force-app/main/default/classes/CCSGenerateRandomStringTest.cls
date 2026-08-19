@isTest
public class CCSGenerateRandomStringTest {
    @testSetup
    static void setup() {
        // Setup data if necessary
    }
    
    @isTest
    static void testGenerateRandomString() {
        // Arrange
        CCSGenerateRandomString.methodInputs input = new CCSGenerateRandomString.methodInputs();
        input.len = 10; // Define desired length
        List<CCSGenerateRandomString.methodInputs> inputList = new List<CCSGenerateRandomString.methodInputs>{ input };
        
        // Act
        Test.startTest();
        List<CCSGenerateRandomString.methodOutputs> result = CCSGenerateRandomString.generateRandomString(inputList);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Result list should have one item');
        System.assertNotEquals(null, result[0].randomString, 'Random string should not be null');
        System.assertEquals(10, result[0].randomString.length(), 'Random string length should match input');
    }
}