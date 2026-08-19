/*******************************************************************************************************************************************************
*   Company         :   Coast Capital Savings Credit  Union
*   Class           :   ContactInfoWrapperForAlertPrefs
*   Description     :   Wrapper class for the Profile API data.
********************************************************************************************************************************************************
*   Author           :  Sudhakar Botta
*   Date Created     :  [2021.DEC.01]
*   History          :  
*       
*   [2021.DEC.01]  sbotta - Initial Version [Created the structure for the Profile API payload].
*   [2022.FEB.16]  rcai -  [Create parseError function].
*                          
********************************************************************************************************************************************************/
public with sharing class ContactInfoWrapperForAlertPrefs {
    
    @AuraEnabled public List<ContactEmails> contactEmails;
    @AuraEnabled public List<ContactPhones> contactPhones;
    @AuraEnabled public List<DeviceInfo> deviceInfo;

    public class ContactEmails {
        @AuraEnabled public String emailAddress;
        @AuraEnabled public String emailType;
    }

    public class ContactPhones {
        @AuraEnabled public String phoneNumber;
        @AuraEnabled public String phoneNumberType;
    }

    public class DeviceInfo {
        @AuraEnabled public String pushToken;
        @AuraEnabled public String deviceOS;
    }
   
    /**
     * Author   :   sbotta
     * Purpose  :   This method is used deserialize the response from the Profile API.
     * Params   :   json of String type.
     * Returns  :   ContactInfoWrapperForAlertPrefs type.
     */
    public static ContactInfoWrapperForAlertPrefs parse(String json) {
        //System.debug('json string in profile wrapper========='+json);
		return (ContactInfoWrapperForAlertPrefs) System.JSON.deserialize(json, ContactInfoWrapperForAlertPrefs.class);
	}


}