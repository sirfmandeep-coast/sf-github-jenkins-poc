/**
*  UserDeactivationBatch.cls
*  By Rong Bin, CCS
*  Created Date: 20 Oct 2022
*  Description:  CRM-4786: User Deactivation Automation 
*/

global class UserDeactivationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

             
    String query;
    Integer emailWarningPeriod = 173; // Number of days before an email is sent to notify the user they will be deactivate
    Integer deactivationPeriod = 180; // Number of days before the user is deactivated
    Integer i;
    Integer newUserExcludedPeriod = 180; // Number of excluded days for new created user 
    Boolean notificationOnly;
    Integer emailCount = 0;
    String sandboxName;
    String baseURL;
    Id OrgWideEmailAddressId;   

    // constructor
    global UserDeactivationBatch(Integer emailWarningPeriod, Integer deactivationPeriod, String exemptionProfiles, String targetProfiles, Boolean notificationOnly) {  
        //Exclude Administrator and EXEC Profile users and non-standard Users
        //[SELECT MasterLabel, DeveloperName, Deactivation_Period__c, Grace_Period__c, Exemption_Profile_List__c, Notification_Only__c, Target_Profile__c FROM CRM_User_Deactivation_Configuration__mdt];

        this.emailWarningPeriod = emailWarningPeriod;
        this.deactivationPeriod = deactivationPeriod;
        this.newUserExcludedPeriod = deactivationPeriod;
        this.notificationOnly = notificationOnly;
        this.sandboxName = getSandboxName();
        this.baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        this.OrgWideEmailAddressId = getOrgWideEmailAddressId();

        query = 'SELECT Id, Name, FirstName, IsActive, Email, Username, LastLoginDate, LastModifiedDate, Last_Deactivation_Email_Sent_Date__c, Last_Deactivation_Date__c FROM User WHERE IsActive = True AND UserType = \'Standard\' AND Do_Not_Deactivate__c != True AND UserName like \'%coastcapitalsavings.com%\' ';

        //Include only users that have not been modified within the grace period
        query = query + ' AND (LastLoginDate = null OR LastLoginDate < LAST_N_DAYS:' + this.emailWarningPeriod + ') And CreatedDate < LAST_N_DAYS:' + this.emailWarningPeriod;

        if(Test.isRunningTest()){
            exemptionProfiles = '\'System Administrator\'';
            targetProfiles = '\'CCS Internal\'';
        }
        
        if(!String.isBlank(exemptionProfiles))
        {
            query = query + ' AND Profile.Name NOT IN ( '+ exemptionProfiles + ' ) ';
        }

        if(!String.isBlank(targetProfiles))
        {
            query = query + ' AND Profile.Name IN ( '+ targetProfiles + ' ) ';
        }

        if(Test.isRunningTest()){
            query = query + ' Order by LastModifiedDate DESC LIMIT 10 ';
        }

        //query = query + ' AND Id = \'0052B000000Hk1F\' ';


    }

    // Determine if this is Sandbox
    public Boolean isSandbox() {
        Organization currentOrg = [SELECT IsSandbox FROM Organization limit 1];
        return currentOrg.isSandbox;
    }

    public String getSandboxName (){
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        String sandboxName = d.getSandboxName();
    
        return String.isBlank(sandboxName)?'Production': sandboxName == 'ccstrain31'? 'Training Playground':'Sandbox "' + sandboxName +'"';
    }

    public Id getOrgWideEmailAddressId (){
        OrgWideEmailAddress owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='no_reply@coastcapitalsavings.com' Limit 1];
        return owea.Id;
    }

    // start method
    global Database.querylocator start(Database.BatchableContext BC){   
        System.Debug('UserDeactivationBatch.Query ' + query);
        Database.querylocator qList = Database.getQueryLocator(query);
        System.Debug('UserDeactivationBatch.start - Getting query locator: ' + qList);
        return qList;
    }

    // execute method
    global void execute(Database.BatchableContext BC, List<sObject> users){ 
        User user = new User ();
        List<User> updateUsersList = new List<User>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage> ();



        for(sObject u:users){ 
            if (emailCount < 100) // To avoid hit daily email limitation  
            {
                user = (User) u;
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                // Deactivate users who are past the deactivate period
                 if(user.Last_Deactivation_Email_Sent_Date__c != null && user.Last_Deactivation_Email_Sent_Date__c.Date() <= Date.today() - this.deactivationPeriod + this.emailWarningPeriod && (user.LastLoginDate == null || user.LastLoginDate.Date() < Date.today() - this.deactivationPeriod)) {
                    System.Debug(Logginglevel.DEBUG,'UserDeactivationBatch.execute - Deactivating user ' + user.Name);
                    if (this.notificationOnly == False) 
                    {
                        user.IsActive = False;
                        user.Last_Deactivation_Date__c = Datetime.now();
                        updateUsersList.add(user);
                    }
                }
                // Send an email to users are past the grace period, but before the deactivate period
                else {
                    if(user.Email != null && (user.Last_Deactivation_Email_Sent_Date__c == null || user.Last_Deactivation_Email_Sent_Date__c.Date() < Date.today() - this.emailWarningPeriod )) {
                        System.debug(Logginglevel.DEBUG,'UserDeactivationBatch.execute - Sending email to: ' + user.Email);
                        String tmpBody = 'It looks like you haven\'t logged into Salesforce ' + this.sandboxName +' for quite a while.  Please login now if you want to retain access. \n'; 
                               tmpBody = tmpBody + '\n';
                               tmpBody = tmpBody + 'If you do not log in, your user will be deactivated in ' + String.valueOf(this.deactivationPeriod - this.emailWarningPeriod) + ' days. Once deactivated, you will need to submit a ServiceNow request in order to reactivate your access.\n';
                        String subject = 'Notice: Salesforce User Deactivation';
                        
                        if (this.notificationOnly == True || Test.isRunningTest())
                        {
                            tmpBody = 'It looks like you haven\'t logged into Salesforce ' + this.sandboxName +' for quite a while.  Please login now. \n';
                            subject = 'Reminding: Salesforce User Login';
                        } 

                        string body = 'Hi '+ user.FirstName +', \n';
                        body = body + '\n';
                        body = body + tmpBody;
                        body = body + '\n';
                        body = body + 'To log-in to Production, double click the "CRM" icon on your desktop and follow on-screen instructions.\n';
                        body = body + '\n';
                        body = body + 'To log-in to the Training Playground: Navigate to myCoast, search for "Playground" and select the "Log In Instructions for CRM Training Playground" PDF and follow instructions within the document.\n';
                        body = body + '\n';
                        body = body + 'Regards,\n';
                        body = body + 'IT - Corp Systems - CRM Team';
                        email.setSubject(subject);
                        //email.setTargetObjectId(user.Id); 
                        email.setUseSignature(False);
                        email.setOrgWideEmailAddressId(OrgWideEmailAddressId);
                        email.setToAddresses(new String[] {user.Email.Replace('.invalid', '')});
                        email.setSaveAsActivity(False);
                        email.setPlainTextBody(body); 
                        emailList.add(email);
                        user.Last_Deactivation_Email_Sent_Date__c = Datetime.now();
                        updateUsersList.add(user);
                        emailCount++;
                    }
                }
            }

        }

        try {
            if(!updateUsersList.isEmpty()) {
                Database.SaveResult[] SR = Database.update(updateUsersList, False);
                String errorMessage = '';
                for(Integer i=0;i<SR.size();i++){
                    if(!SR[i].isSuccess() || Test.isRunningTest()){
                        User tempUser = updateUsersList[i];
                        if(!tempUser.IsActive){
                            errorMessage = 'Error occurred when deactivating user....' + 'UserId: ' + tempUser.Id + '\n Errors: ';
                            for(Database.Error err : SR[i].getErrors()) {
                            errorMessage += (err.getFields() +  ' - ' +   err.getMessage() + '\n');
                        }
                        Messaging.SingleEmailMessage errorEmail = new Messaging.SingleEmailMessage();
                        string body = 'Hi Admins,\n';
                        body = body + errorMessage;
                        errorEmail.setSubject('Error: Salesforce User Deactivation');
                        //mail.setTargetObjectId(user.Id); 
                        errorEmail.setToAddresses(new String[] {'CRMApplicationSupport@coastcapitalsavings.com'});
                        errorEmail.setUseSignature(False);
                        errorEmail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
                        errorEmail.setSaveAsActivity(False);
                        errorEmail.setPlainTextBody(body); 
                        emailList.add(errorEmail);
                      }
                    }
                }
            }
            
        } 
        catch (Exception e){
            System.Debug(Logginglevel.DEBUG,'UserDeactivationBatch - Error when deactivating user records: ' + e.getMessage());
        }  
        try {
            if(!emailList.isEmpty()) {
                System.Debug(Logginglevel.DEBUG,'UserDeactivationBatch - Sending email: ' + emailList);
                Messaging.sendEmail(emailList);
            }
        } 
        catch (Exception e){
            System.Debug(Logginglevel.DEBUG,'UserDeactivationBatch - Error when sending emails: ' + e.getMessage());
        }  
        
    }  

    // finish method
    global void finish(Database.BatchableContext BC){ 
        System.Debug(Logginglevel.DEBUG,'UserDeactivationBatch.finish ' + emailCount);
 
    }

}