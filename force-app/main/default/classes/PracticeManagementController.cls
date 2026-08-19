public with sharing class PracticeManagementController {
    @AuraEnabled(cacheable=true)
    public static List<AccountWrapper> getAccounts(String userId, String classification, String interactionStatus, String reviewStatus, String houseHoldFlag, String runningUserId) {
    
        String accountQuery = ' Select Id, Name, LastName, PersonContactId, Classification__c, Interaction_Status__c, Open_Opportunity_Amount__c, Next_Account_Team_Interaction__c, Review_Status__c, Next_Account_Team_Review__c, Birthday_in_Next_7_Days__pc From Account Where Id in (Select AccountId From AccountTeamMember WHERE UserId = :userId ) ';
        List <AccountWrapper> acctWrapperList = new List <AccountWrapper> ();
        List <Account> accountList = new List <Account> ();
        AccountWrapper acctWrapper = new AccountWrapper ();

        //String accountQuery = ' Select Id, Name, PersonContactId, Classification__c, Interaction_Status__c, Open_Opportunity_Amount__c, Next_Account_Team_Interaction__c, Review_Status__c, Next_Account_Team_Review__c, LastActivityDate From Account Where Id != null '; //Where Id IN (\'0014c000005MbR7AAK\', \'0014c000005SpzOAAS\')';

        if (!String.isBlank(classification) && classification != 'All')
        {
            if (classification == 'Unclassified') {
                accountQuery = accountQuery + ' And Classification__c = \'\' ';
            }
            else {
                accountQuery = accountQuery + ' And Classification__c = \'' + classification + '\' ';
            }
        }

        if (!String.isBlank(interactionStatus)  && interactionStatus != 'All')
        {
            accountQuery = accountQuery + ' And Interaction_Status__c = \'' + interactionStatus + '\' ';
        }

        if (!String.isBlank(reviewStatus)  && reviewStatus != 'All')
        {
            accountQuery = accountQuery + ' And Review_Status__c = \'' + reviewStatus + '\' ';
        }

        if (!String.isBlank(houseHoldFlag))
        {
            accountQuery = accountQuery;
        }

        accountList = Database.query(accountQuery);

        for (Account aa: accountList)
        {
                
            acctWrapper = new AccountWrapper ();
            acctWrapper.id = aa.Id;
            acctWrapper.name = aa.Name;
            acctWrapper.lastName = String.isBlank(aa.Lastname) ? aa.Name : aa.Lastname ;
            acctWrapper.accountUrl = '/' + aa.Id;
            acctWrapper.personContactId = aa.PersonContactId;
            acctWrapper.classification = aa.Classification__c;
            acctWrapper.interactionStatus = aa.Interaction_Status__c;
            acctWrapper.openOpportunityAmount = '$' + String.valueOf(aa.Open_Opportunity_Amount__c.setScale(2).format());
            acctWrapper.opportunityListUrl = '/lightning/r/Account/' + aa.Id + '/related/Opportunities/view';
            acctWrapper.nextInteractionDue = aa.Next_Account_Team_Interaction__c;
            acctWrapper.nextReviewDue = aa.Next_Account_Team_Review__c;
            acctWrapper.reviewStatus = aa.Review_Status__c;
            acctWrapper.birthdayImage = String.isBlank(aa.Birthday_in_Next_7_Days__pc) ? '':'action:share_thanks';
            acctWrapper.canSelect = true;
            acctWrapperList.Add(acctWrapper);
        }

        /*
        if (userId != runningUserId)
        {
            String accountRunningUserQuery = ' Select Id, Name, PersonContactId, Classification__c, Interaction_Status__c, Open_Opportunity_Amount__c, Next_Account_Team_Interaction__c, Review_Status__c, Next_Account_Team_Review__c From Account Where Id In (Select AccountId From AccountTeamMember WHERE UserId = :runningUserId ) And Id In :accountList '; 

            Map<Id, Account> acctMap = new Map<Id, Account>((List<Account>) Database.query(accountRunningUserQuery));

            for (Account aa: accountList)
            {
                
                acctWrapper = new AccountWrapper ();
                acctWrapper.id = aa.Id;
                acctWrapper.name = aa.Name;
                acctWrapper.accountUrl = '/' + aa.Id;
                acctWrapper.personContactId = aa.PersonContactId;
                acctWrapper.classification = aa.Classification__c;
                acctWrapper.interactionStatus = aa.Interaction_Status__c;
                acctWrapper.openOpportunityAmount = '$' + String.valueOf(aa.Open_Opportunity_Amount__c.setScale(2).format());
                acctWrapper.opportunityListUrl = '/lightning/r/Account/' + aa.Id + '/related/Opportunities/view';
                acctWrapper.nextInteractionDue = aa.Next_Account_Team_Interaction__c;
                acctWrapper.reviewStatus = aa.Review_Status__c;
                acctWrapper.nextReviewDue = aa.Next_Account_Team_Review__c;

                if (acctMap.containsKey(aa.Id))
                {
                    acctWrapper.canSelect = true;
                }
                else
                {
                    acctWrapper.canSelect = false;
                } 

                acctWrapperList.Add(acctWrapper);
            }
        }
        else {
            for (Account aa: accountList)
            {
                
                acctWrapper = new AccountWrapper ();
                acctWrapper.id = aa.Id;
                acctWrapper.name = aa.Name;
                acctWrapper.accountUrl = '/' + aa.Id;
                acctWrapper.personContactId = aa.PersonContactId;
                acctWrapper.classification = aa.Classification__c;
                acctWrapper.interactionStatus = aa.Interaction_Status__c;
                acctWrapper.openOpportunityAmount = '$' + String.valueOf(aa.Open_Opportunity_Amount__c.setScale(2).format());
                acctWrapper.opportunityListUrl = '/lightning/r/Account/' + aa.Id + '/related/Opportunities/view';
                acctWrapper.nextInteractionDue = aa.Next_Account_Team_Interaction__c;
                acctWrapper.reviewStatus = aa.Review_Status__c;
                acctWrapper.nextReviewDue = aa.Next_Account_Team_Review__c;
                acctWrapper.canSelect = true;
                acctWrapperList.Add(acctWrapper);
            }
        }
        */

        return acctWrapperList;
        

    }

    @AuraEnabled
    public static void updateAccounts (List <Account> recordsToUpdate){ 
        update recordsToUpdate; 
    }

    public class AccountWrapper{
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String lastName;
        @AuraEnabled public Id personContactId;
        @AuraEnabled public String classification;
        @AuraEnabled public String interactionStatus;
        @AuraEnabled public String openOpportunityAmount; 
        @AuraEnabled public Boolean canSelect;
        @AuraEnabled public String opportunityListUrl;
        @AuraEnabled public String accountUrl;
        @AuraEnabled public String nextInteractionDue;
        @AuraEnabled public String nextReviewDue;
        @AuraEnabled public String reviewStatus;
        @AuraEnabled public String birthdayImage;
    }

}