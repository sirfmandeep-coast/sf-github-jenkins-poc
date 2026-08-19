public class AccountTriggerHandler extends TriggerHandler {
    private List<Account> newRecords;
    private List<Account> oldRecords;
    private Map<Id, Account> newRecordsMap;
    private Map<Id, Account> oldRecordsMap;

    public AccountTriggerHandler (){
        super('AccountTriggerHandler');
        this.newRecords = Trigger.new;
        this.oldRecords = Trigger.old;
        this.newRecordsMap = (Map<Id, Account>) Trigger.newMap;
        this.oldRecordsMap = (Map<Id, Account>) Trigger.oldMap;
    }

    public override void beforeUpdate() {       
        handleOwnershipChange (this.newRecords, this.oldRecordsMap); 
        handleConsentChange (this.newRecords, this.oldRecordsMap);
    }
    
    public static void handleConsentChange (List<Account> newRecords, Map<Id, Account> oldRecordsMap) {
        List <Account_Integration__e> AccountIntegrationEventList = new List <Account_Integration__e> ();
        String profileId;
        String consentType;
        String consentValue;
        
        for(Account acc : newRecords){
            if(
            (acc.Consent_to_Electronic_Delivery_of_Docume__c != oldRecordsMap.get(acc.Id).Consent_to_Electronic_Delivery_of_Docume__c 
            || acc.Consent_to_General_Email_Communication__c != oldRecordsMap.get(acc.Id).Consent_to_General_Email_Communication__c
            )
           
            ){
                
                
                // Flip consent data to ensure no True - True case on any occasion
                if (acc.Consent_to_Electronic_Delivery_of_Docume__c != oldRecordsMap.get(acc.Id).Consent_to_Electronic_Delivery_of_Docume__c && acc.Consent_to_Electronic_Delivery_of_Docume__c == True)
                {
                    acc.Consent_to_General_Email_Communication__c = False;
                }
                else if (acc.Consent_to_General_Email_Communication__c != oldRecordsMap.get(acc.Id).Consent_to_General_Email_Communication__c && acc.Consent_to_General_Email_Communication__c == True)
                {
                    acc.Consent_to_Electronic_Delivery_of_Docume__c = False;
                }
                
                // Update Consent Data Last Timestamp
                if (acc.Consent_to_Electronic_Delivery_of_Docume__c != oldRecordsMap.get(acc.Id).Consent_to_Electronic_Delivery_of_Docume__c)
                {
                    acc.EDD_Last_Modified_Datetime__c = datetime.now();
                }
                    
                if (acc.Consent_to_General_Email_Communication__c != oldRecordsMap.get(acc.Id).Consent_to_General_Email_Communication__c)
                {
                    acc.GEC_Last_Modified_Datetime__c = datetime.now();
                }
                
                // Publish the event
                if ((acc.Name != 'COAST TEST')
                    && (!String.isBlank(acc.Banking_Id__c) || !String.isBlank(acc.T24_Profile_Number__c)) 
                    && (UserInfo.getName() != 'Service-Mulesoft Generic CRM' )
                    && (UserInfo.getName() != 'Service-IICS CRM' ))
                {
                    profileId = !String.isBlank(acc.Banking_Id__c) ? acc.Banking_Id__c : acc.T24_Profile_Number__c;
                    if (acc.Consent_to_Electronic_Delivery_of_Docume__c != oldRecordsMap.get(acc.Id).Consent_to_Electronic_Delivery_of_Docume__c)
                    {
                        AccountIntegrationEventList.add (new Account_Integration__e(Account_Id__c = acc.Id, Change_Value__c = String.valueOf(acc.Consent_to_Electronic_Delivery_of_Docume__c), Change_Type__c = 'Consent', Change_Name__c = 'EDD', Profile_Id__c = profileId, Staff__c = UserInfo.getName(), Change_Timestamp__c =  datetime.now())); 
                    }
                    
                    if (acc.Consent_to_General_Email_Communication__c != oldRecordsMap.get(acc.Id).Consent_to_General_Email_Communication__c)
                    {
                        AccountIntegrationEventList.add (new Account_Integration__e(Account_Id__c = acc.Id, Change_Value__c = String.valueOf(acc.Consent_to_General_Email_Communication__c), Change_Type__c = 'Consent', Change_Name__c = 'GEC', Profile_Id__c = profileId, Staff__c = UserInfo.getName(), Change_Timestamp__c =  datetime.now())); 
                    }

                }


            }
        }
        
        if (!AccountIntegrationEventList.isEmpty()){
            List<Database.SaveResult> results = EventBus.publish(AccountIntegrationEventList);

            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' + err.getStatusCode() );
                    }
                }
            }
        }
    }
    
    public static void handleOwnershipChange (List<Account> newRecords, Map<Id, Account> oldRecordsMap) {
       
        Set <Id> accountIdSet = new Set <Id> ();
        String str;
        
        for(Account acc : newRecords){
            if(acc.OwnerId != oldRecordsMap.get(acc.Id).OwnerId){
                accountIdSet.Add(acc.Id);
            }
        }
        
        if (!accountIdSet.isEmpty()) {
            List <AccountTeamMember> ATMList = [SELECT AccountId, UserId, TeamMemberRole, Source__c FROM AccountTeamMember WHERE AccountId IN :accountIdSet];
            
            if (!ATMList.isEmpty())
            {
                 str = JSON.serialize(ATMList); 
                 reinsertOldTeamMemberOnOwnerChange(str);
            }
        }
    }
    
    @future
    public static void reinsertOldTeamMemberOnOwnerChange(String str){
         List<AccountTeamMember> newATMList = (List<AccountTeamMember>) JSON.deserialize(str,List<AccountTeamMember>.class);
         for(AccountTeamMember newATM: newATMList ){
             newATM.Id= null;
         }
         insert newATMList;
    }
    
    
}