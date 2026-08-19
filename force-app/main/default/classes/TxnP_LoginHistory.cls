global class TxnP_LoginHistory implements TxnSecurity.PolicyCondition {

    public boolean evaluate(TxnSecurity.Event e) {

        boolean isExceptionProfile = false;
        boolean isIPListed = false;
        boolean checkIP = false;
        boolean checkIE = false;
        boolean checkSSO = false;

     if (e.action == 'Login') {
        
         // Get the platform & browser from LoginHistory for this login attempt.
        LoginHistory loginAttempt =
        [SELECT userId,Platform, Browser,SourceIP,LoginType,Application FROM LoginHistory
         WHERE Id = :e.data.get('LoginHistoryId')];

         String platform = loginAttempt.Platform;
         String browser = loginAttempt.Browser;
         String sourceip = loginAttempt.SourceIP;
         String logintype = loginAttempt.LoginType;
         String application = loginAttempt.Application;
         
        User loginUser = [Select profile.name from user where id = :loginAttempt.UserId];
        system.debug(loginUser.profile.name);
        system.debug(loginAttempt);
        
        TxnProfile_Settings__mdt[] exceptionProfiles = [SELECT label from TxnProfile_Settings__mdt where setting_name__c='profile' and isActive__c=true and label=:loginUser.profile.name];
        isExceptionProfile = !exceptionProfiles.isEmpty();
        System.debug(exceptionProfiles+'--'+isExceptionProfile);
     
        TxnProfile_Settings__mdt[] listedIPs = [SELECT label from TxnProfile_Settings__mdt where setting_name__c='ip_address' and isactive__c=true and label=:sourceip];
        isIPListed = !listedIPs.isEmpty();
        System.debug(listedIPs+'--'+isIPListed);

      // The policy is triggered if the browser is ie11.
//      if (browser.startsWith('IE 11')) 
//      { checkIE = true;}
//          { 
//              if (application.contains('Dataloader'))checkIE = false;
//              else checkIE=true;
//          }
         
      // Check IP address
//      if (!sourceip.equals('204.174.76.34') && !sourceip.equals('204.174.77.34'))
        if (!isIPListed)checkIP=true;
/*       { 
              if (logintype.contains('Remote Access'))checkIP = false;
              else checkIP=true;
          }
*/
      //check SSO
      if (!loginType.containsIgnoreCase('sso'))
          {
//              if (logintype.contains('Remote Access') || isExceptionProfile)checkSSO = false;
              if (application.contains('Outlook') || (isExceptionProfile) )checkSSO = false;
              else checkSSO = true;
          }
    }

   system.debug(checkIE+'--'+checkIP+'--'+checkSSO);
   if (checkIE || checkIP || checkSSO) return true;
    else return false;
    }
}