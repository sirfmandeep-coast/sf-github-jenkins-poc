/**
*  AgencyWebUserDeactivationBatch.cls
*  By Rong Bin, CCS
*  Created Date: 01 Dec 2023
*  Description:  AGENCY-212: Disable User if Password Not Changed at 90 Days 
*/

global class AgencyWebUserDeactivationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

             
    String query;
    Integer emailWarningPeriod = 75; // Number of days before an email is sent to notify the user they will be deactivate
    Integer deactivationPeriod = 90; // Number of days before the user is deactivated
    Integer i;
    Integer newUserExcludedPeriod = 90; // Number of excluded days for new created user 
    Boolean notificationOnly;
    Integer emailCount = 0;
    String sandboxName;
    String baseURL;
    Id OrgWideEmailAddressId;   

    // constructor
    global AgencyWebUserDeactivationBatch (Integer emailWarningPeriod, Integer deactivationPeriod, String exemptionProfiles, String targetProfiles, Boolean notificationOnly) {  
        //Exclude Administrator and EXEC Profile users and non-standard Users
        //[SELECT MasterLabel, DeveloperName, Deactivation_Period__c, Grace_Period__c, Exemption_Profile_List__c, Notification_Only__c, Target_Profile__c FROM CRM_User_Deactivation_Configuration__mdt];

        this.emailWarningPeriod = emailWarningPeriod;
        this.deactivationPeriod = deactivationPeriod;
        this.newUserExcludedPeriod = deactivationPeriod;
        this.notificationOnly = notificationOnly;
        this.sandboxName = getSandboxName();
        this.baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        this.OrgWideEmailAddressId = getOrgWideEmailAddressId();

        query = 'SELECT Id, Name, FirstName, IsActive, Email, Username, LastPasswordChangeDate, LastModifiedDate, Last_Deactivation_Email_Sent_Date__c, Last_Deactivation_Date__c FROM User WHERE IsActive = True AND UserType = \'PowerCustomerSuccess\' AND Do_Not_Deactivate__c != True ';

        //Include only users that have not been modified within the grace period
        query = query + ' AND (LastPasswordChangeDate  = null OR LastPasswordChangeDate < LAST_N_DAYS:' + this.emailWarningPeriod + ') And CreatedDate < LAST_N_DAYS:' + this.emailWarningPeriod;

        if(Test.isRunningTest()){
            targetProfiles = '\'CCS External Agent\'';
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

        //query = query + ' AND Id = \'005Au000005qyzhIAA\' ';


    }

    // Determine if this is Sandbox
    public Boolean isSandbox() {
        Organization currentOrg = [SELECT IsSandbox FROM Organization limit 1];
        return currentOrg.isSandbox;
    }

    public String getSandboxName (){
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        String sandboxName = d.getSandboxName();
    
        return String.isBlank(sandboxName)?'Production':'Sandbox "' + sandboxName +'"';
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
            if (emailCount <= 200) // To avoid hit daily email limitation  
            {
                user = (User) u;
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                // Deactivate users exceeding the deactivation period
                if(user.Last_Deactivation_Email_Sent_Date__c != null && user.Last_Deactivation_Email_Sent_Date__c.Date() <= Date.today() - this.deactivationPeriod + this.emailWarningPeriod && (user.LastPasswordChangeDate == null || user.LastPasswordChangeDate.Date() < Date.today() - this.deactivationPeriod)) {
                    System.Debug(Logginglevel.DEBUG,'UserDeactivationBatch.execute - Deactivating user ' + user.Name);
                    if (this.notificationOnly == False) 
                    {
                        user.IsActive = False;
                        user.Last_Deactivation_Date__c = Datetime.now();
                        updateUsersList.add(user);
                    }
                }
                              
                else { 
                    // Send an email to users exceeding the grace period, but before the deactivation period
                    if(user.Email != null && (user.Last_Deactivation_Email_Sent_Date__c == null || user.Last_Deactivation_Email_Sent_Date__c.Date() < Date.today() - this.emailWarningPeriod )) {
                        //System.debug(Logginglevel.DEBUG,'UserDeactivationBatch.execute - Sending email to: ' + user.Email);
                        //String tmpBody = 'It looks like you haven\'t logged into Salesforce ' + this.sandboxName +' for quite a while.  Please login now using the link below if you want to retain access to '+ this.sandboxName +'.  Otherwise, your user will be deactivated in 15 days in ' + this.sandboxName + ' and you will need to contact Coast Capital Savings Agency Team in order to reactivate your access.\n';
                        //String subject = 'Notice: Salesforce User Deactivation';
                        
                        //if (this.notificationOnly == True || Test.isRunningTest())
                        //{
                        //    tmpBody = 'It looks like you haven\'t logged into Salesforce ' + this.sandboxName +' for quite a while.  Please login now using the link below. \n';
                        //    subject = 'Reminding: Salesforce User Login';
                        //} 

                        //string body = 'Hi '+ user.FirstName +', \n';
                        //body = body + '\n';
                        //body = body + tmpBody;
                        //body = body + '\n';
                        //body = body + 'Login url: ' + this.baseURL + '\n';
                        //body = body + '\n';
                        //body = body + 'Regards,\n';
                        //body = body + 'IT - Corp Systems - CRM Team';
                        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Communities_Agency_Web_Password_Expiring_Email' Limit 1];
                        email.setTemplateId(et.Id);
                        //email.setSubject(subject);
                        email.setTargetObjectId(user.Id); 
                        email.setUseSignature(False);
                        email.setOrgWideEmailAddressId(OrgWideEmailAddressId);
                        //email.setToAddresses(new String[] {user.Email.Replace('.invalid', '')});
                        email.setSaveAsActivity(False);
                        //email.setPlainTextBody(body); 
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