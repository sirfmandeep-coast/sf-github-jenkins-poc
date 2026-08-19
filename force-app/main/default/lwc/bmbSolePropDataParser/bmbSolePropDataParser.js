import { LightningElement,api } from 'lwc';

export default class BmbSolePropDataParser extends LightningElement {

    @api selectedMembershipRecordFromFlow;

    @api selectedMembershipBusinessOrgType;
    @api selectedMembershipNumber;

    connectedCallback(){

        if(this.selectedMembershipRecordFromFlow)
        {
            this.selectedMembershipBusinessOrgType=this.selectedMembershipRecordFromFlow.BusinessOrg_Type__c || '';
            this.selectedMembershipNumber=this.selectedMembershipRecordFromFlow.Membership_Num__c || '';

        }



    }







}