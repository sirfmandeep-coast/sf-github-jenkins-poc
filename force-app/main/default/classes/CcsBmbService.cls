/**
	 * CcsBmbService
	 * @description      :This class acts as a thin service layer that extends HttpServiceBase. It is responsible 
     * for preparing and executing API requests. It helps specify endpoint path and HTTP method to inject dynamic * headers or payloads
	 * @author           :Mandeep Sigh
	 * @last modified on :25 May 2026
	 * @last modified by :Mandeep Singh
	 * Modification Log
	 * Ver    Date            Author			Jira
	 * 1.0    25 May 2026   Mandeep Singh		CRM-6564
	 */
public class CcsBmbService extends HttpServiceBase{
    
    //ncName=Named Credentials
    public CcsBmbService(String ncName,String path, String method) {
        super(ncName, path, method);
    }

    public void setProfileId(String profileId)
    {
        if(String.isNotBlank(profileId))
        {
            setHeader('X-ProfileID',profileId);
        }
    }
}