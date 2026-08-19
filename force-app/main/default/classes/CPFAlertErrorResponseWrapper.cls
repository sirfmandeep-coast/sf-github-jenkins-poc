/*******************************************************************************************************************************************************
*   Company         :   Coast Capital Savings Credit Union
*   Class           :   CPFAlertErrorResponseWrapper
*   Description     :   Wrapper class for the CPF Preference API error response.
********************************************************************************************************************************************************
*   Author           :  Rong Bin
*   Date Created     :  [2022.FEB.16]
*   History          :  
*       
*   [2022.FEB.16]  rcai -  Initial Version.
*                          
********************************************************************************************************************************************************/

public with sharing class CPFAlertErrorResponseWrapper {
    @AuraEnabled public Response response;

    public class Response {
		public String transactionType;
		public String transactionReference;
		public String code;
		public String transactionStatus;
		public String message;
	}

    public static CPFAlertErrorResponseWrapper parse (String json) {
		return (CPFAlertErrorResponseWrapper) System.JSON.deserialize(json, CPFAlertErrorResponseWrapper.class);
	}
}