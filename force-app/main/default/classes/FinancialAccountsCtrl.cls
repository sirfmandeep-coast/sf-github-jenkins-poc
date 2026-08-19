/*******************************************************************************************************************************************************
*   Company         :   Coast Capital Savings Credit Union
*   Class           :   FinancialAccountsCtrl
*   Description     :   This Class is used to GET and SET data from/into Preferences API & GET data from Profile API.
********************************************************************************************************************************************************
*   Author           :  Jujhar Singh
*   Date Created     :  [2021.AUG.20]
*   History          :  
*       
*   [2021.AUG.20]  jsingh - Initial Version [Created the getPreferences method which fetches the data from the Preference API].
*   [2021.AUG.20]  jsingh - [Created the setPreferences method which pushes the modified data on changeAccountAlerts LWC to the Preference API].
*   [2021.AUG.20]  sbotta - [Created the getContactDetails method which fetches the data from the Profile API].
*   [2021.AUG.20]  sbotta - [Created the getBankingIdByAccountId method which fetches the Banking Id field from Account].
*                         
********************************************************************************************************************************************************/

public with sharing class FinancialAccountsCtrl {
    //public static String profileNum;
    public static String jsstring = '{"alertPreferences": [{"membershipNumber": "6869669","accountNumber": "10100999","accountTitle": "Free Chequing Free Debit","accountTypeCode": "1110","accountType": "CCA","productName": "1110_Free ChQ","limitReference": "","limitAmount": "","accountUse" : "Business","alert": [{"type": "LowBalance","threshold": "150","thresholdType": "BELOW","preferences": [{"deliveryChannel": "SMS","optIn": false},{"deliveryChannel": "EMAIL","optIn": true},{"deliveryChannel": "PUSH","optIn": false}]},{"type": "CreditRemaining","threshold": "150.00","thresholdType": "BELOW","preferences": [{"deliveryChannel": "SMS","optIn": false},{"deliveryChannel": "EMAIL","optIn": true},{"deliveryChannel": "PUSH","optIn": false}]}]},{"membershipNumber": "6869669","accountNumber": "10100998","accountTitle": "Free Chequing Free Debit","accountTypeCode": "1110","accountType": "CCA","productName": "1110_Free ChQ","limitReference": "","limitAmount": "","accountUse" : "Business","alert": [{"type": "LowBalance","threshold": "100.00","thresholdType": "BELOW","preferences": [{"deliveryChannel": "SMS","optIn": true},{"deliveryChannel": "EMAIL","optIn": true},{"deliveryChannel": "PUSH","optIn": true}]},{"type": "CreditRemaining","threshold": "100.00","thresholdType": "BELOW","preferences": [{"deliveryChannel": "SMS","optIn": true},{"deliveryChannel": "EMAIL","optIn": true},{"deliveryChannel": "PUSH","optIn": true}]}]},{"membershipNumber": "6869669","accountNumber": "10100997","accountTitle": "Free Chequing Free Debit","accountTypeCode": "1110","accountType": "CCA","productName": "1110_Free ChQ","limitReference": "","limitAmount": "","accountUse" : "Retail","alert": [{"type": "LowBalance","threshold": "100.00","thresholdType": "BELOW","preferences": [{"deliveryChannel": "SMS","optIn": true},{"deliveryChannel": "EMAIL","optIn": true},{"deliveryChannel": "PUSH","optIn": true}]},{"type": "CreditRemaining","threshold": "100.00","thresholdType": "BELOW","preferences": [{"deliveryChannel": "SMS","optIn": true},{"deliveryChannel": "EMAIL","optIn": true},{"deliveryChannel": "PUSH","optIn": true}]}]}]}';
    public static String jsstringConInfo = '{"contactEmails":[{"emailAddress":"customer@gmail.com","emailType":"Person"},{"emailAddress":"manager@gmail.com","emailType":"Business"}],"contactPhones":[{"phoneNumber":"416-555-0115","phoneNumberType":"Work cell phone"},{"phoneNumber":"416-555-0115","phoneNumberType":"Cell Phone"}],"deviceInfo":[{"deviceOS":"Android","pushToken":"34fr34"}]}';
    public static String jsstringNoPhone = '{"contactEmails":[{"emailAddress":"customer@gmail.com","emailType":"Person"},{"emailAddress":"manager@gmail.com","emailType":"Business"}],"contactPhones":[{"phoneNumber":"","phoneNumberType":"Work cell phone"},{"phoneNumber":"","phoneNumberType":"Cell Phone"}],"deviceInfo":[{"deviceOS":"Android","pushToken":"34fr34"}]}';
    public static String jsstringNoEmail = '{"contactEmails":[{"emailAddress":"","emailType":"Person"},{"emailAddress":"","emailType":"Business"}],"contactPhones":[{"phoneNumber":"416-555-0115","phoneNumberType":"Work cell phone"},{"phoneNumber":"416-555-0115","phoneNumberType":"Cell Phone"}],"deviceInfo":[{"deviceOS":"Android","pushToken":"34fr34"}]}';
    public static String jsstringNoDeviceInfo = '{"contactEmails":[{"emailAddress":"test@test.com","emailType":"Person"},{"emailAddress":"","emailType":"Business"}],"contactPhones":[{"phoneNumber":"416-555-0115","phoneNumberType":"Work cell phone"},{"phoneNumber":"416-555-0115","phoneNumberType":"Cell Phone"}],"deviceInfo":[{"deviceOS":"Android","pushToken":""}]}';
    public static String jsstringAllFalse = '{"contactEmails":[{"emailAddress":"","emailType":"Person"},{"emailAddress":"","emailType":"Business"}],"contactPhones":[{"phoneNumber":"","phoneNumberType":"Work cell phone"},{"phoneNumber":"","phoneNumberType":"Cell Phone"}],"deviceInfo":[{"deviceOS":"Android","pushToken":""}]}';
    public static String jsstringOnlyEmailTrue = '{"contactEmails":[{"emailAddress":"test@test.com","emailType":"Person"},{"emailAddress":"","emailType":"Business"}],"contactPhones":[{"phoneNumber":"","phoneNumberType":"Work cell phone"},{"phoneNumber":"","phoneNumberType":"Cell Phone"}],"deviceInfo":[{"deviceOS":"Android","pushToken":""}]}';
    public static String jsstringOnlyPhoneTrue = '{"contactEmails":[{"emailAddress":"","emailType":"Person"},{"emailAddress":"","emailType":"Business"}],"contactPhones":[{"phoneNumber":"1234567","phoneNumberType":"Work cell phone"},{"phoneNumber":"","phoneNumberType":"Cell Phone"}],"deviceInfo":[{"deviceOS":"Android","pushToken":""}]}';
    public static String jsstringOnlyDevice = '{"contactEmails":[{"emailAddress":"","emailType":"Person"},{"emailAddress":"","emailType":"Business"}],"contactPhones":[{"phoneNumber":"","phoneNumberType":"Work cell phone"},{"phoneNumber":"","phoneNumberType":"Cell Phone"}],"deviceInfo":[{"deviceOS":"Android","pushToken":"34fr34"}]}';
    public static String jsstringEmptyContactInfo = '{"contactEmails":[],"contactPhones":[],"deviceInfo":[]}';

    /**
     * Author   :   sbotta
     * Purpose  :   This method is used in the connectedCallBack method of changeAccountAlerts LWC.
     * Params   :   accountId of String type.
     * Returns  :   Account type.
     */
    @AuraEnabled
    public static Account getBankingIdByAccountId(String accountId){
        Account acc = [SELECT Banking_ID__c
                        FROM Account
                        WHERE Id=: accountId];
                        System.debug('getBankingIdByAccountId method ==========>>>>>>'+acc.Banking_ID__c);
        return acc;                
    }

    /**
     * Author   :   jsingh
     * Purpose  :   This method is called from the changeAccountAlerts LWC to get/pull data from Preference API and return the data to the component.
     * Params   :   accountId of String type.
     * Returns  :   AlertPreferencesWrapper type.
     */
    @AuraEnabled
    public static AlertPreferencesWrapper getPreferences( String profileNumber ) {
        //List<Account> account = [SELECT Banking_ID__c
          //                      FROM Account
           //                     WHERE Id=: accountId
             //                   LIMIT 1 ] ;
        //String profileNum = account[0].Banking_ID__c;
        System.debug('getPreferences Method ==========>>>>>>'+profileNumber);
        
        //return CPFAlertsCalloutHelper.getAlertPrefernces( profileNumber );
        AlertPreferencesWrapper APW = CPFAlertsCalloutHelper.getAlertPrefernces( profileNumber );
        
        //AlertPreferencesWrapper APW = AlertPreferencesWrapper.parse(jsstring);
        return APW;

    }

    /**
     * Author   :   jsingh
     * Purpose  :   This method is called from the changeAccountAlerts LWC to set/push data into Preference API.
     * Params   :   changed values from UI as String, accountId as String and formDate from UI as String.
     * Returns  :   Boolean type.
     */
    @AuraEnabled
    public static Boolean setPreferences( String changedPreferences, String profileNum, String formDate, String agentId ) {
        //Siddu code to add prefDateSubmittedFormDate
        AlertPreferencesWrapper altPrefWrapper = AlertPreferencesWrapper.parse(changedPreferences);
        altPrefWrapper.prefFormSubmissionDate = formDate;
        altPrefWrapper.agentId = agentId;
        changedPreferences = System.JSON.serialize(altPrefWrapper);
        system.debug('wrapper' + altPrefWrapper);
        system.debug('String' + changedPreferences);
        //Siddu code to add prefDateSubmittedFormDate  
        System.debug('setPreferences Method ==========>>>>>>'+profileNum);
        return CPFAlertsCalloutHelper.sendAlertPrefernces( changedPreferences, profileNum );
    }

    /**
     * Author   :   sbotta
     * Purpose  :   This method is called from the changeAccountAlerts LWC to get/pull data from Profile API and return the data to the component.
     * Params   :   profileNum (Banking Id on Account returned by getBankingIdByAccountId ) as String type.
     * Returns  :   ContactInfoWrapperForAlertPrefs type.
     */
    @AuraEnabled
    public static ContactInfoWrapperForAlertPrefs getContactDetails( String profileNum ) {
        system.debug('what is profile num' + profileNum);
        return CPFAlertsCalloutHelper.getContactInfo(profileNum);
        //ContactInfoWrapperForAlertPrefs CIWFAP = ContactInfoWrapperForAlertPrefs.parse(jsstringEmptyContactInfo);
        //System.debug('Get Contact Method ==========>>>>>>' + CIWFAP);
        //return CIWFAP;
    }

    /**
     * Author   :   jsingh
     * Purpose  :   <please write the purpose of this method>.
     * Params   :   errorMessage as string and httpcode as Integer.
     * Returns  :   void.
     */
    @AuraEnabled
    public static void createIntegrationErrorRecord( String errorMessage, String httpcode , String function){
        ErrorLog__c newErrorLog = new ErrorLog__c();
        newErrorLog.Type__c = 'Integration';
        newErrorLog.Class__c = 'CPFAlertsCalloutHelper';
        newErrorLog.Function__c = function;
        newErrorLog.ErrorMessage__c = errorMessage;
        //newErrorLog.RelatedRecordId__c = 'basedonPayload';
        newErrorLog.UserId__c = UserInfo.getUserId();
        newErrorLog.HttpCode__c =  httpcode;
        system.debug('to insert' +  newErrorLog );
        insert newErrorLog;
        system.debug('inserted' + newErrorLog.Id);
    }
}