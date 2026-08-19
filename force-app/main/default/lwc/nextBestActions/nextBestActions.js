import { LightningElement, api, wire } from 'lwc';
import Id from "@salesforce/user/Id";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import MEMBER_ID_FIELD from "@salesforce/schema/NextBestAction__c.MemberName__c";
import NAME from '@salesforce/schema/User.Name';
import BRANCH_NAME from '@salesforce/schema/User.Branch__c';
import REPORTING_DIVISION from '@salesforce/schema/User.Reporting_Division__c';
import REGION from '@salesforce/schema/User.UserRegionFullName__c';
import ROLE_NAME from '@salesforce/schema/User.UserRoleName__c';
import getNextBestActionsByAccountId from '@salesforce/apex/NextBestActionController.getNextBestActionsByAccountId';
import saveRecord from '@salesforce/apex/NextBestActionController.saveRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class NextBestActions extends NavigationMixin(LightningElement) {
    @api recordId;
    @api flowURL;
    @api nextBestActions = [];
    @api userId = Id;
    userInfo = {Id: Id, Branch__c: 'No Branch', Reporting_division__c: 'No Branch', Userregionfullname__c: 'No Branch', Userrolename__c: null};

    @wire(getRecord, { recordId: Id, fields: [NAME, BRANCH_NAME, REPORTING_DIVISION, REGION, ROLE_NAME] })
    userDetails({ error, data }) {
        if (error) {
            console.log('ERROR OCCURED: ', error);
        } else if (data) {
      
            if (data.fields.Branch__c.value) {
                this.userInfo.Branch__c = data.fields.Branch__c.value;
            }
            if (data.fields.Reporting_Division__c.value) {
                this.userInfo.Reporting_Division__c = data.fields.Reporting_Division__c.value;
            }
            if (data.fields.UserRegionFullName__c.value) {
                this.userInfo.UserRegionFullName__c = data.fields.UserRegionFullName__c.value;
            }
            if (data.fields.UserRoleName__c.value) {
                this.userInfo.UserRoleName__c = data.fields.UserRoleName__c.value;
            }
        }
    }

    connectedCallback(){

        getNextBestActionsByAccountId({accountId: this.recordId})
        .then(result =>{
             
            result.forEach(record=>{
                record.showDetails = false;   
                record.showDetailsIcon = "utility:right";
                //record.numberOfDays = Math.round((new Date().getTime() - new Date(record.CreatedDate).getTime()) / (1000*60*60*24));
            })
            this.nextBestActions = result.slice(0, 3);

        }).catch(error=>{
            console.log('ERROR OCCURED: ', error);
        });
    }

    clickViewDetails(event){
        let myRecordId = event.currentTarget.dataset.id;   
        if(myRecordId){
            let myRecord = this.nextBestActions.find(x => x.Id === myRecordId);
            if (myRecord.showDetails == false) {
                myRecord.showDetails = true;
                myRecord.showDetailsIcon="utility:down";
            }
            else if (myRecord.showDetails == true) {
                myRecord.showDetails = false;
                myRecord.showDetailsIcon="utility:right";
            }
            this.nextBestActions=[...this.nextBestActions]; 
        } 
        
    }

    clickAccept(event){
        let myRecordId = event.currentTarget.dataset.id;
        
        if(myRecordId){
            this.prepareSaveRecord(myRecordId, 'Interested');
        }

        let myRecord = this.nextBestActions.find(x => x.Id === myRecordId);
        if (myRecord.Outcome_Action_Flow__c === undefined || myRecord.Outcome_Action_Flow__c == 'Default')
        {

            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/lightning/action/quick/NextBestAction__c.NBX_Action?context=RECORD_DETAIL&recordId='+ myRecordId + '&backgroundContext=%2Flightning%2Fr%2FAccount%2F' + this.recordId + '%2Fview'
                
                    //url: '/lightning/action/quick/NextBestAction__c.NBX_Action?context=RECORD_DETAIL&recordId=0014c000005MbR7AAK&accountId=a0gAu000001YVATIA4&outcomeFlow=Default&isRecommendationAccepted=true&backgroundContext=%2Flightning%2Fr%2FAccount%2F0014c000005MbR7AAK%2Fview'
                }
            });
        }
    }

    clickReject(event){
        let myRecordId = event.currentTarget.dataset.id;
        if(myRecordId){
            this.prepareSaveRecord(myRecordId, 'Not Interested');
        }
       
    }

    clickWait(event){
        let myRecordId = event.currentTarget.dataset.id;
        if(myRecordId){
            this.prepareSaveRecord(myRecordId, 'Remind Me Later');
        }
       
    }

    prepareSaveRecord (recordId, outcome)
    {
        const myRecord = {Id:recordId, Outcome__c:outcome, Actioned_Date__c: new Date().toISOString().split('T')[0], Actioned_Date_Time__c: new Date().toISOString(), UpdatedById__c : this.userInfo.Id, Updated_By_Branch__c: this.userInfo.Branch__c, Updated_By_Division__c: this.userInfo.Reporting_Division__c, Updated_By_Region__c: this.userInfo.UserRegionFullName__c, Updated_By_Role__c: this.userInfo.UserRoleName__c};
        saveRecord ({ recordToUpdate: myRecord })
        .then((result) => {
            this.refreshData();
            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Updated Next Best Experience Successfully!',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        })
        .catch((error) => {
            console.log(error);
        });
    }

    refreshData() {
        this.connectedCallback();
    }
}