@istest
public class ccsExpireLeadsTest{
    //query the activities to process
    static testmethod void ccsExpireLeadsTestMethod(){
        Map<String,Id> recordtypeMap  = new Map<String,Id>();
    
        for(RecordType leadRT :  [select id, Name from RecordType where SObjectType = 'Lead' ]){
            recordtypeMap.put(leadRT.Name,leadRT.Id);
        }

        List<Lead> leads = new List<Lead>();
        leads.add( new Lead(RecordTypeId = recordtypeMap.get('CCS Business Lead'), lastName='Business 01', Status='New', End_Date__c=date.today()) );
        leads.add( new Lead(RecordTypeId = recordtypeMap.get('CCS Individual Lead'), lastName='Individual 01', Status='New', End_Date__c=date.today()) );

        insert leads;

        ccsExpireLeads batch = new ccsExpireLeads();
        Database.executebatch(batch, 200);
    }
}