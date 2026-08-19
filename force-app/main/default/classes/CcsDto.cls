/**
	 * CcsDto
	 * @description      :This class defines Data Transfer Objects used between Flow and Apex. 
     * @author           :Mandeep Sigh
	 * @last modified on :25 May 2026
	 * @last modified by :Mandeep Singh
	 * Modification Log
	 * Ver    Date            Author			Jira
	 * 1.0    25 May 2026   Mandeep Singh		CRM-6564
	 */
public class CcsDto {
   
   public class CcsRequestDTO {
    @InvocableVariable (required=true)
    public String namedCredentials;
    @InvocableVariable (required=true)
    public String method;
    @InvocableVariable (required=true)
    public String path;
    @InvocableVariable (required=true)
    public String profileId;
}

    public class CcsResponseDTO{
        @InvocableVariable
        public Integer statusCode;
        @InvocableVariable
        public String status;
        @InvocableVariable
        public String body;
        @InvocableVariable
        public String conversationId;
        @InvocableVariable
        public String finalEndpoint;
        @InvocableVariable
        public String errorMessage;
        @InvocableVariable public List<CcsFlowChoice> membershipChoices;
        @InvocableVariable public List<CcsFlowChoice> solePropMembershipChoices;
        @InvocableVariable public List<CcsFlowChoice> signerChoices;
    }
}