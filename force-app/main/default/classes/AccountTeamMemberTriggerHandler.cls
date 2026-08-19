public class AccountTeamMemberTriggerHandler extends TriggerHandler {
    private List<AccountTeamMember> newRecords;
    private List<AccountTeamMember> oldRecords;
    private Map<Id, AccountTeamMember> newRecordsMap;
    private Map<Id, AccountTeamMember> oldRecordsMap;

    public AccountTeamMemberTriggerHandler (){
        super('AccountTeamMemberTriggerHandler');
        this.newRecords = Trigger.new;
        this.oldRecords = Trigger.old;
        this.newRecordsMap = (Map<Id, AccountTeamMember>) Trigger.newMap;
        this.oldRecordsMap = (Map<Id, AccountTeamMember>) Trigger.oldMap;
    }

    public override void afterUpdate() {     
        cleanUpAccountTeamMember (this.newRecords);
    }
     
    
    public override void afterInsert() { 
        cleanUpAccountTeamMember (this.newRecords);
    }
        
    public static void cleanUpAccountTeamMember (List<AccountTeamMember> newRecords)
    {    
        Set <Id> accountIdSet = new Set <Id> ();
        Set <String> roleSet = new Set <String> ();
        List <AccountTeamMember> deleteList = new List <AccountTeamMember>();
        Set <Id> deleteIdSet = new Set <Id> ();
        
        For (AccountTeamMember newATM : newRecords ){
            
            If (!accountIdSet.contains(newATM.AccountId)) {
                accountIdSet.add (newATM.AccountId);
            }
            
            If (!roleSet .contains(newATM.TeamMemberRole)) {
                roleSet.add (newATM.TeamMemberRole);
            }
        }
        
        List <AccountTeamMember> existingATMList = [SELECT Id, AccountId, UserId, TeamMemberRole, Source__c FROM AccountTeamMember WHERE AccountId IN :accountIdSet AND TeamMemberRole IN :roleSet AND Id NOT IN :newRecords];
 
        For (AccountTeamMember newATM : newRecords){

            For (AccountTeamMember existingATM : existingATMList ){
                if (existingATM.Source__c == 'CRM' && newATM.Source__c == 'MDM' && newATM.AccountId == existingATM.AccountId && newATM.TeamMemberRole == existingATM.TeamMemberRole && newATM.UserId != existingATM.UserId ) {
                    deleteList.add (existingATM);
                }
                
                if (newATM.Source__c == 'CRM' && existingATM.Source__c == 'MDM' && newATM.AccountId == existingATM.AccountId && newATM.TeamMemberRole == existingATM.TeamMemberRole && newATM.UserId != existingATM.UserId ) {
                    If (!deleteIdSet.contains(newATM.Id))
                    {
                        deleteIdSet.add(newATM.Id);
                    }
                    break;
                }
                
            }
            
        }
        
        if (!deleteList.isEmpty())
        {
            delete deleteList;
        }
        
        if (!deleteIdSet.isEmpty())
        {
            deleteAccountTeamMemberSourceCRM (deleteIdSet);
        }
    }
    
    @future
    public static void deleteAccountTeamMemberSourceCRM (Set<Id> recordIdSet){
        List <AccountTeamMember> deleteList = new List <AccountTeamMember>();
        For (Id recordId : recordIdSet)
        {
            deleteList.Add (new AccountTeamMember (Id = recordId));
        }
        
        delete deleteList;
    }
    
}