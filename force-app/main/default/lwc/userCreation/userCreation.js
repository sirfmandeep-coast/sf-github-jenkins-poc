import { LightningElement, api, wire, track } from 'lwc';
import syncUser from '@salesforce/apex/UserCreationController.syncUser';
import getConfigurations from '@salesforce/apex/UserCreationController.getConfigurations';


export default class UserCreation extends LightningElement {
    @api code;
    @api refreshToken;
    @api contacts = [];
    @track targetOrgOptions = [];
    @api configurations = new Map();
    /*
    @track options = [
        { label: 'DevTarget', value: 'DevTarget'},
        { lable: 'Train31', value: 'Train31'},
    ];*/
    @api returnMessage;
    @api userId;
    @track selectedValue;

    
    @wire (getConfigurations) wiredConfiguration({data,error}){

        if (data) {
            let tmpOptions = [];
            let myMap = new Map(); 
            data.forEach(record => {
                tmpOptions.push({label: record.Target_Org__c , value: record.Target_Org__c });
                this.configurations.set(record.Target_Org__c, record);
                
            });
            this.targetOrgOptions = tmpOptions;

        } else if (error) {
            console.log(error);
        }
 
    };

    syncUser () {  
        if (this.selectedValue)
        {
            syncUser({userId : this.userId, refreshToken : this.configurations.get(this.selectedValue).Refresh_Token__c, loginUri: this.configurations.get(this.selectedValue).Target_Org_URL__c, clientId : this.configurations.get(this.selectedValue).Client_Id__c, clientSecret : this.configurations.get(this.selectedValue).Client_Secret__c})
                .then (result =>{
                    if (result){
                        console.log ('result is ' + result);
                        this.returnMessage = result;
                    }
                });
        }
    };

    handleTargetOrgChange (event) {
        this.selectedValue = event.detail.value;
    };
}