@IsTest
public with sharing class AWSiteControllerTest {
    @IsTest
    public static void myTest() {
        AWSiteController controller = new AWSiteController();
        controller.message = 'Error';
        controller.showErrorMessage();
        PageReference pageRef = controller.login();
        pageRef = controller.forgotPassword();
        pageRef = controller.next();
    }

}