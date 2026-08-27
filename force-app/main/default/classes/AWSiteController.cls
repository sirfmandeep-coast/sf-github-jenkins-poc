/**
 * An apex page controller that exposes the Agency Web site functionality
 */
global with sharing class AWSiteController {

//NOTE
    global String username {get; set;}
    global String password {get; set;}
    global String showUsername {get; set;}
    global String showPassword {get; set;}
    global String showLogin {get; set;}
    global String showNext {get; set;}
    global String message {get; set;}


    global PageReference login() {
        //String startUrl = System.currentPageReference().getParameters().get('startURL');
        return Site.login(username, password, '/s');
    }
    
    global PageReference forgotPassword() {
      boolean success = Site.forgotPassword(username);
      PageReference pr = Page.AWForgotPasswordConfirm;
      pr.setRedirect(true);
      
      if (success) {        
        return pr;
      }
      return null;
    }
    
    global PageReference next() {
        showUsername = 'false';
        showPassword = 'true';
        showLogin = 'true';
        showNext = 'false';
        return null;
    }
    
     global AWSiteController () {
         showUsername = 'true';
         showPassword = 'false';
         showLogin = 'false';
         showNext = 'true';
     }
     
     global void showErrorMessage() {
          
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, message));

     }
}
