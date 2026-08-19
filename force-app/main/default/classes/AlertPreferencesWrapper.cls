/*******************************************************************************************************************************************************
*   Company         :   Coast Capital Savings Credit Union
*   Class           :   ContactInfoWrapperForAlertPref
*   Description     :   Wrapper class for the Profile API data.
********************************************************************************************************************************************************
*   Author           :  Jujhar Singh
*   Date Created     :  [2021.NOV.09]
*   History          :  
*       
*   [2021.NOV.09]  jsingh - Initial Version [Created the structure for the Preferences API payload].
*   [2022.FEB.16]  rcai -  [Create parseError function].
*                          
********************************************************************************************************************************************************/
public with sharing class AlertPreferencesWrapper {


	@AuraEnabled public String prefFormSubmissionDate = '';
	@AuraEnabled public String agentId = '';
	@AuraEnabled public List<AlertPreferences> alertPreferences;

	public class Alert {
		@AuraEnabled public String type;
		@AuraEnabled public Decimal threshold;
		@AuraEnabled public String thresholdType;
		@AuraEnabled public List<Preferences> preferences;
	}

	public class AlertPreferences {
		//@AuraEnabled public String t24ProfileId;
		@AuraEnabled public String membershipNumber;
		@AuraEnabled public String accountNumber;
		@AuraEnabled public String accountTitle;
		@AuraEnabled public String accountTypeCode;
		//@AuraEnabled public String accountType;
		@AuraEnabled public String productName;
		//@AuraEnabled public String limitReference;
		@AuraEnabled public Decimal limitAmount;
		@AuraEnabled public String accountUse;
		@AuraEnabled public List<Alert> alert;
	}

	public class Preferences {
		@AuraEnabled public String deliveryChannel;
		@AuraEnabled public Boolean optIn;
	}
	
	/**
     * Author   :   jsingh
     * Purpose  :   This method is used deserialize the response from the Preferences API.
     * Params   :   json of String type.
     * Returns  :   AlertPreferencesWrapper type.
     */
	public static AlertPreferencesWrapper parse(String json) {
		return (AlertPreferencesWrapper) System.JSON.deserialize(json, AlertPreferencesWrapper.class);
	}

}