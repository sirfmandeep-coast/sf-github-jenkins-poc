@isTest 
public class ccsConvertLeadActionTest{
   public static testMethod void createnewlead() {
      
      User u = [Select id from user where profile.name='System Administrator' and IsActive = TRUE Limit 1];
      //create account
      String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
      Account a = new Account(
      RecordTypeID = recordTypeId ,
      FirstName ='Test FName',
      LastName ='Test LName',
      PersonMailingStreet ='test@yahoo.com.invalid',
      PersonMailingPostalCode ='12345',
      PersonMailingCity ='SFO',
      PersonEmail ='test@yahoo.com',
      PersonHomePhone ='1234567',
      PersonMobilePhone ='12345678'
      );
      insert a;

      //create opportunity
      Opportunity o = new Opportunity(
      StageName = 'Consent',
      CloseDate = System.Today(),
      AccountId = a.Id,
      Name = 'Test Opportunity'
      );
      insert o;

      //create lead
      recordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('CCS Individual Lead').getRecordTypeId();
      Lead l1 = new Lead(
      recordTypeId = recordTypeId,
      FinServ__RelatedAccount__c = a.Id,
      LastName ='Test1',
      Company ='Company',
      LeadSource ='Marketing',
      Status ='New',
      isActioned__c = true
      );
      insert l1; 

      Lead l2 = new Lead(
      recordTypeId = recordTypeId,
      FinServ__RelatedAccount__c = a.Id,
      LastName ='Test2',
      Company ='Company',
      LeadSource ='Marketing',
      Status ='New',
      isActioned__c = true
      );
      insert l2;

      Lead l3 = new Lead(
      recordTypeId = recordTypeId,
      FinServ__RelatedAccount__c = a.Id,
      LastName ='Test3',
      Company ='Company',
      LeadSource ='Marketing',
      Status ='New',
      isActioned__c = true
      );
      insert l3;

      List<Lead> leads = new List<Lead>();
      leads.add(l2);
      leads.add(l3);

      Test.startTest(); 
      
      ccsConvertLeadAction.ccsConvertLeadActionRequest clar1 = new ccsConvertLeadAction.ccsConvertLeadActionRequest();
      clar1.convertedStatus = 'Converted';
      clar1.leadId = l1.Id;
      clar1.accountId = l1.FinServ__RelatedAccount__c;
      clar1.createOpportunity = TRUE;
      clar1.opportunityId = o.Id;
      ccsConvertLeadAction.convertLead(clar1);

      Lead queryLead1 = [SELECT id, ConvertedOpportunityId, Status FROM Lead WHERE Id =: l1.Id limit 1 ];
      System.assertEquals(o.Id, queryLead1.ConvertedOpportunityId);

      List<ccsConvertLeadAction.ccsConvertLeadActionRequest> clars = new List<ccsConvertLeadAction.ccsConvertLeadActionRequest>();
      for(Lead l : leads) {
         ccsConvertLeadAction.ccsConvertLeadActionRequest clar = new ccsConvertLeadAction.ccsConvertLeadActionRequest();
         clar.convertedStatus = 'Converted';
         clar.leadId = l.Id;
         clar.accountId = l.FinServ__RelatedAccount__c;
         clar.createOpportunity = TRUE;
         clar.opportunityName = 'test opportunity';
         clar.sendEmailToOwner = TRUE;
         clars.add(clar);
      }
      ccsConvertLeadAction.convertLeads(clars);

      List<Lead> leadResults = new List<Lead>();
      for(Lead lResult : leadResults) {
         System.assertEquals(lResult.isConverted, TRUE);
      }   

      Test.stopTest();

   }
}