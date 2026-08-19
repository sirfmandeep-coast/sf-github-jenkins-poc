public with sharing class GetCurrentLighningApp {
	// Used by Retail authentication flow to determine current user is in which Lightning app currently and which flavour of member auth. has to be opened for him
    public class Result {
        @InvocableVariable(label='App Label')
        public String appLabel;

        @InvocableVariable(label='App Durable Id')
        public String appDurableId;

        @InvocableVariable(label='Form Factor') // Small | Medium | Large
        public String formFactor;

        @InvocableVariable(label='Found?')
        public Boolean found;
    }

    /**
     * Flow invocable: returns the most recently used Lightning app for the running user.
     */
    @InvocableMethod(label='Get Current Lightning App'
                     description='Returns the label and durable Id of the most recently used Lightning app for the running user.')
    public static List<Result> getCurrentLightningApp(List<String> requests) {
        // We accept a dummy list (Flow requires a collection input). We return one Result.
        Result out = new Result();
        out.found = false;

        // Query the last recorded Lightning app for the running user.
        // NOTE: UserAppInfo is available starting API v38.0; AppDefinition is available from v43.0.
        // We sort by LastModifiedDate to prefer the most recent app record.
        
        	
            Integer countUai = [
                SELECT COUNT()
                FROM UserAppInfo
                WHERE UserId = :UserInfo.getUserId()
            ];
        
        if (countUai > 0){

            UserAppInfo uai = [
            SELECT Id, AppDefinitionId, FormFactor
            FROM UserAppInfo
            WHERE UserId = :UserInfo.getUserId()
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ];
        
        if (uai != null && uai.AppDefinitionId != null) {
            AppDefinition appDef = [
                SELECT DurableId, Label
                FROM AppDefinition
                WHERE DurableId = :uai.AppDefinitionId
                LIMIT 1
            ];

            if (appDef != null) {
                out.appLabel     = appDef.Label;
                out.appDurableId = String.valueOf(appDef.DurableId);
                out.formFactor   = String.valueOf(uai.FormFactor);
                out.found        = true;
            }
        }
        }
        
        return new List<Result>{ out };
    }



}