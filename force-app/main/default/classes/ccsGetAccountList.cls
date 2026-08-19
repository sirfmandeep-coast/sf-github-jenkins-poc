/**
	 * ccsGetAccountList
	 * @description      :This class helps find duplicate record when searched either by First Name, Last Name, Phone number or Email
	 * @author           :
	 * @last modified on :21st Aug 2024
	 * @last modified by :Mandeep Singh
	 * Modification Log
	 * Ver    Date            Author			Jira
	 * 1.0    21st Aug 2024   Mandeep Singh		CRM-5992
	 */
public class ccsGetAccountList {
    @InvocableMethod(label='Get Account List' Description='Returns a list of Account Ids')
    public static List<methodOutputs> invokeThisMethod(List<methodInputs> request) {
        methodOutputs fo = new methodOutputs();
        //system.debug(request);
        try{
			
            
           
            List<String> accountIdList = new List<String>();
    		List<Account> accountList = [SELECT Id 
                                            FROM Account 
                                            WHERE Recordtype.developername = 'PersonAccount' 
                                             AND ( ((FirstName =: request[0].FirstName OR FirstName =: request[0].FirstName.toUpperCase() OR FirstName =: request[0].FirstName.toLowerCase() OR FirstName =: (request[0].FirstName.substring(0,1).toUpperCase() + request[0].FirstName.substring(1,request[0].FirstName.length()).toLowerCase())) 
                                                        AND (LastName =: request[0].LastName OR LastName =: request[0].LastName.toUpperCase() OR LastName =: request[0].LastName.toLowerCase() OR LastName =: (request[0].LastName.substring(0,1).toUpperCase() + request[0].LastName.substring(1,request[0].LastName.length()).toLowerCase()) )) 
                                                    OR (Phone =: request[0].Phone AND Phone != null ) 
                                                    OR (PersonMobilePhone =: request[0].Phone AND PersonMobilePhone != null) 
                                                    OR ((PersonEmail =: request[0].Email OR PersonEmail =: request[0].Email.toUpperCase() OR PersonEmail =: request[0].Email.toLowerCase() OR PersonEmail =: request[0].Email.capitalize() ) AND PersonEmail != null) )];
            for (Account a : accountList) {
				accountIdList.add(a.Id);
			}

        
			fo.DMLResult = 'Success' ;
            fo.AccountIDList = accountIdList ;
            
        } catch(Exception e){
            fo.DMLResult = 'Error' ;
        }
        List<MethodOutputs> theResults = new List<MethodOutputs>();
        theResults.add(fo) ;
        return theResults;
    }
    //input details that come to apex from flow
    public class methodInputs{
        @InvocableVariable
        public String FirstName;
        @InvocableVariable
        public String LastName;
        @InvocableVariable
        public string Phone;
        @InvocableVariable
        public String Email;
    }
    //output details which goes from apex to flow
    public class methodOutputs{
        @InvocableVariable
        public String DMLResult ;
        @InvocableVariable
        public List<String> AccountIDList ;
    } 
}