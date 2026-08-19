global class ccsConvertLeadAction {
  @InvocableMethod(label='Convert Leads')
  global static List<ccsConvertLeadActionResult> convertLeads(List<ccsConvertLeadActionRequest> requests) {
    List<ccsConvertLeadActionResult> results = new List<ccsConvertLeadActionResult>();
    for (ccsConvertLeadActionRequest request : requests) {
      results.add(convertLead(request));
    }
    return results;
  }
 
  public static ccsConvertLeadActionResult convertLead(ccsConvertLeadActionRequest request) {
    Database.LeadConvert lc = new Database.LeadConvert();
    lc.setLeadId(request.leadId);
    lc.setConvertedStatus(request.convertedStatus);
 
    if (request.accountId != null) {
        lc.setAccountId(request.accountId);
    }
 
    /* Currently using person accounts only, not required at this time
    if (request.contactId != null) {
      lc.setContactId(request.contactId);
    } */
 
    if (request.overWriteLeadSource != null && request.overWriteLeadSource) {
      lc.setOverwriteLeadSource(request.overWriteLeadSource);
    }
    if (request.createOpportunity == null) {
      lc.setDoNotCreateOpportunity(TRUE);
    }
    
    if (request.createOpportunity != null && !request.createOpportunity) {
      lc.setDoNotCreateOpportunity(request.createOpportunity);
    }
    
    if (request.opportunityId != null) {
      lc.setOpportunityId(request.opportunityId);
    }
 
    if (request.opportunityName != null) {
      lc.setOpportunityName(request.opportunityName);
    }
 
    if (request.ownerId != null) {
      lc.setOwnerId(request.ownerId);
    }
 
    if (request.sendEmailToOwner != null && request.sendEmailToOwner) {
      lc.setSendNotificationEmail(request.sendEmailToOwner);
    }
 
    Database.LeadConvertResult lcr = Database.convertLead(lc, true);
    if (lcr.isSuccess()) {
      ccsConvertLeadActionResult result = new ccsConvertLeadActionResult();
      result.accountId = lcr.getAccountId();
      /* Currently using person accounts only, not required at this time
      result.contactId = lcr.getContactId(); */
      result.opportunityId = lcr.getOpportunityId();
      return result;
    } else {
      throw new ccsConvertLeadActionException(lcr.getErrors()[0].getMessage());
    }
  }
 
  global class ccsConvertLeadActionRequest {
    @InvocableVariable(required=true)
    global ID leadId;
 
    @InvocableVariable(required=true)
    global String convertedStatus;
 
    @InvocableVariable
    global ID accountId;
 
    /* Currently using person accounts only, not required at this time
    @InvocableVariable
    global ID contactId; */
 
    @InvocableVariable
    global Boolean overWriteLeadSource;
 
    @InvocableVariable
    global Boolean createOpportunity;
    
    @InvocableVariable
    global Id opportunityId;
 
    @InvocableVariable
    global String opportunityName;
 
    @InvocableVariable
    global ID ownerId;
 
    @InvocableVariable
    global Boolean sendEmailToOwner;
  }
 
  global class ccsConvertLeadActionResult {
    @InvocableVariable
    global ID accountId;
 
    /* Currently using person accounts only, not required at this time
    @InvocableVariable
    global ID contactId; */
 
    @InvocableVariable
    global ID opportunityId;
  }
 
  class ccsConvertLeadActionException extends Exception {}
}