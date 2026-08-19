global with sharing class CcsFlowChoice {
    @AuraEnabled
    @InvocableVariable
    global String label;
    @AuraEnabled
    @InvocableVariable
    global String value;
    // Used to link signers to memberships so Flow can filter choices
    @AuraEnabled
    @InvocableVariable
    global String membershipNumber;
    // Required no-arg constructor for Apex-defined data types in Flow
    @AuraEnabled
    @InvocableVariable
    global String membershipIndustry;
    // Required no-arg constructor for Apex-defined data types in Flow
    global CcsFlowChoice() { }
}