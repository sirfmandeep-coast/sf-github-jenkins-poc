/**
	 * CcsBmbInvocable
	 * @description      :This class acts as the entry point between Salesforce Flow and external API integration.It * helps exposes the API logic to BMB Flows using InvocableMethod. It accepts structured inputs in the form of 
     * RequestDTO, call the API service and parse and return output DTOs to Flow
	 * @author           :Mandeep Sigh
	 * @last modified on :25 May 2026
	 * @last modified by :Mandeep Singh
	 * Modification Log
	 * Ver    Date            Author			Jira
	 * 1.0    25 May 2026   Mandeep Singh		CRM-6564
	 */
public with sharing class CcsBmbInvocable {
    
@InvocableMethod(label='CCS BMB Customer API (via Named Credential)')
public static List<CcsDto.CcsResponseDTO> invoke(List<CcsDto.CcsRequestDTO> requests)
{
    List<CcsDto.CcsResponseDTO> out = new List<CcsDto.CcsResponseDTO>();
    for (CcsDto.CcsRequestDTO r : requests)
    {
        CcsDto.CcsResponseDTO respDto = new CcsDto.CcsResponseDTO();
        List<CcsFlowChoice> membershipChoicesOut = new List<CcsFlowChoice>();//for regular Business memberships (including Sole Prop)
        List<CcsFlowChoice> membershipChoicesOut2 = new List<CcsFlowChoice>();//strictly for Sole Prop Memberships)
        try
        {
            CcsBmbService svc = new CcsBmbService(r.namedCredentials, r.path, r.method);
            if (r.profileId != null)
            {
                svc.setProfileId(r.profileId);
            }
            
            if (String.isNotBlank(r.profileId)) {
                svc.setPrincipalId(r.profileId);
            }

            HttpResponse res = svc.execute(); //CCSBmbService class object calls super class HTTPServiceBase method called execute
            // Audit / troubleshooting fields
            respDto.statusCode = res.getStatusCode();
            respDto.status     = res.getStatus();
            respDto.body       = res.getBody();
            respDto.conversationId = svc.getConversationId();
            respDto.finalEndpoint =
                'callout:' + r.namedCredentials + (r.path.startsWith('/') ? r.path : '/' + r.path);
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300)
            {
                // Deserialize only the parts we need (memberships/signers)
                CcsBmbResponseWrapper root =
                    (CcsBmbResponseWrapper) System.JSON.deserialize(res.getBody(), CcsBmbResponseWrapper.class);
                // 1) Build signer choices (ALL signers across memberships)
                List<CcsFlowChoice> signerChoicesOut = new List<CcsFlowChoice>();
                Set<String> membershipSet = new Set<String>();
                if (root != null && root.memberships != null)
                {
                    for (CcsBmbResponseWrapper.Membership m : root.memberships)
                    {
                        if (m == null || m.membershipType != 'Business') continue;
                        String memNum = safeStr(m.membershipNumber);
                        if (String.isNotBlank(memNum))
                        {
                            membershipSet.add(memNum);
                        }
                        if (m.signers == null) continue;
                        for (CcsBmbResponseWrapper.Signer s : m.signers)
                        {
                            if (s == null) continue;
                            // Build signer label: "First Last (Role)"
                            String given = safeStr(s.signerGivenName);
                            String family = safeStr(s.signerFamilyName);
                            String role = safeStr(s.signerRole);
                            String signerId = safeStr(s.signerId);
                            String fullName = given + (String.isBlank(family) ? '' : ' ' + family);
                            if (String.isBlank(fullName)) fullName = 'Signer';
                            String label = fullName + (String.isBlank(role) ? '' : ' (' + role + ')');

                            // Value: signerId if available, else a composite key
                            String value = signerId;
                            CcsFlowChoice signerChoice = new CcsFlowChoice();
                            signerChoice.label = label;
                            signerChoice.value = value;
                            signerChoice.membershipNumber = memNum;
                            signerChoicesOut.add(signerChoice);
                        }
                    }
                    // 2) Build all business memberships
                    for (CcsBmbResponseWrapper.Membership m : root.memberships)
                    {
                            if (m == null || m.membershipType != 'Business') continue;
                            CcsFlowChoice c = new CcsFlowChoice();
                            c.label = m.membershipNumber;              // what user sees
                            c.value = m.membershipNumber;              // what Flow stores as output from Flow radio button
                            c.membershipNumber = m.membershipNumber;   
                            c.membershipIndustry = m.membershipIndustry;
                            membershipChoicesOut.add(c);
                    }
                    // 2) Build all Sole Prop memberships
					for (CcsBmbResponseWrapper.Membership m : root.memberships)
                    {
                            if (m == null || m.membershipIndustry != 'Sole Proprietor') continue;
                            CcsFlowChoice c = new CcsFlowChoice();
                            c.label = m.membershipNumber;              // what user sees
                            c.value = m.membershipNumber;              // what Flow stores as output from Flow radio button
                            c.membershipNumber = m.membershipNumber;   
                            c.membershipIndustry = m.membershipIndustry;
                            membershipChoicesOut2.add(c);
                    }
                }

                // Flow outputs
                respDto.membershipChoices = membershipChoicesOut;
                respDto.solePropMembershipChoices = membershipChoicesOut2;
                respDto.signerChoices     = signerChoicesOut;
            }
        }
        catch (Exception ex)
        {
            respDto.errorMessage = ex.getMessage();
        }

        out.add(respDto);
    }

    return out;
}
    //Helper function to check null strings
     private static String safeStr(String s) 
     { return s == null ? '' : s; 
    }

}