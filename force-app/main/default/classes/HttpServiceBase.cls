/**
	 * CcsBmbService
	 * @description      :This class helps encapsulates all core HTTP callout logic. It uses Named Credentials (secure, decoupled authentication).
	 * It automatically injects dynamic headers (e.g. Profile-X, ConversationId) and handles GET/POST/PUT/DELETE via method override
	 * @author           :Mandeep Sigh
	 * @last modified on :25 May 2026
	 * @last modified by :Mandeep Singh
	 * Modification Log
	 * Ver    Date            Author			Jira
	 * 1.0    25 May 2026   Mandeep Singh		CRM-6564
	 */
public abstract class HttpServiceBase {
    
    protected String namedCredentials; // stores namedCredential set up for accessing particular API
    protected String relativeUri; // its the Uri that gets appended to base API Uri for calling specific Api endpoint method
    protected String httpMethod; // Get, Post etc.
    protected Integer timeoutMs = 120000; // default 120s
    protected Map<String,String> headers = new Map<String,String>();
   // public Map<String,String> urlParams = new Map<String,String>();
    protected String requestBody; // payload that gets sent to API
    //protected Blob requestBodyBlob;
    protected String clientCertificateName;

    protected final String conversationId = String.valueOf(UUID.randomUUID()); // creates random conversationId

    protected HttpServiceBase(String nc, String rel, String method)
    {
        this.namedCredentials=nc;
        this.relativeUri=rel.startsWith('/') ? rel : '/' + rel;
        this.httpMethod=method;

        headers.put('Content-Type', 'application/json');
        headers.put('X-ConversationId',conversationId);
    }

    public void setHeader(String key, String value)
    {
        headers.put(key,value);
    }

    public void setBody(String json)
    {
        requestBody=json;
    }

    public void setClientCertificate(String certName)
    {
        clientCertificateName=certName;
    }
    
    public void setTimeout(Integer ms){ timeoutMs = ms; }

    public void setPrincipalId(String principalId)
    {
        if (String.isNotBlank(principalId))
        {
            headers.put('X-PrincipalId', principalId);
        }
    }


    public virtual HttpResponse execute()
    {
       
       String finalEndPoint = 'callout:'+namedCredentials+relativeUri; // Important as this tells the HTTPRequest as to where exactly send the request
        HttpRequest req = new HttpRequest();
        try{
        req.setEndpoint(finalEndPoint);
        req.setMethod(httpMethod);
        req.setTimeout(timeoutMs);
        
        for(String h: headers.keySet())
        {
            req.setHeader(h, headers.get(h));
        }
        if(String.isNotBlank(requestBody)) req.setBody(requestBody);
        if(String.isNotBlank(clientCertificateName)) req.setClientCertificateName(clientCertificateName);

        Http http = new Http();
        
        return http.send(req);
        }
        catch(Exception ex)
        {
            System.debug('General Exception on attempt : ' + ex.getMessage());
            throw ex;

        }
    }

    public String getConversationId()
    {
        return conversationId;
    }
}