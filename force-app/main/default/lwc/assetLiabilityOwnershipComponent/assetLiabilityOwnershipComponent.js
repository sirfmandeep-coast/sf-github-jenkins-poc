import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import LightningConfirm from "lightning/confirm";
import NAME_FIELD from "@salesforce/schema/Account.Name";
import getAssetRoles from '@salesforce/apex/AssetsAndLiabilitiesController.getAssetRoles';
import getAssetRecordRoles from '@salesforce/apex/AssetsAndLiabilitiesController.getAssetRecordRoles';
import deleteAssetOrLiabilityRole from '@salesforce/apex/AssetsAndLiabilitiesController.deleteAssetOrLiabilityRole';
    
export default class AssetLiabilityOwnershipComponent extends LightningElement {

    showNewJointOwnerCreationWindow = false;
    @api assetLiabilityId; 
    @track listOfAssetRoles=[];
    flowVariables = [];
    saveDraftValues = [];
    //recordName;

    @track ccsNonManagedAssetLiabilityRoleColumns = [
      { label: 'Individual', fieldName: 'Account_Name__c' },
      { label: 'Ownership %', fieldName: 'Ownership_Percent__c', editable: true},
      { label: 'Role', fieldName: 'Role__c'},
      { label: '', type: 'button-icon', typeAttributes: {iconName: 'action:delete', iconClass: 'slds-icon-text-error', name:'delete', class : {fieldName: 'showButton'}}}
    ];

    @wire(getAssetRoles, { assetId : '$assetLiabilityId' })
    AssetRoleRecords({error, data}) {
      if(data){
        this.listOfAssetRoles = data;
        this.listOfAssetRoles.forEach(assetRole => {
          if(assetRole.Role__c != 'Primary Owner'){
            assetRole.showButton = 'slds-show';
          }
          else {
            assetRole.showButton = 'slds-hide';
          }
        })
      }
      else if(error) {
        window.console.log('error =====> '+JSON.stringify(error));
      }
    }

    

    handleFlowStatusChange(event){
      if(event.detail.status?.toLowerCase() == 'finished'){
        this.showNewJointOwnerCreationWindow = false;
        //this.listOfAssetRoles = [];
        getAssetRecordRoles({assetId:this.assetLiabilityId})
        .then(result=>{
          let tempAssetRoleList = result;
          if(tempAssetRoleList != null){
            this.listOfAssetRoles = JSON.parse(JSON.stringify(result));
                    /*this.listOfAssetRoles.forEach(assetRole=>{
                        lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                    this.leadList = [...this.leadList];*/
          }
          //this.listOfAssetRoles = JSON.stringify(result);
        })
      }
    }

    handleNewJointOwner(){
      this.showNewJointOwnerCreationWindow = true;
      this.flowVariables = [
        {
          name:"assetIdFromLWC",
          type:"String",
          value: this.assetLiabilityId
        }
      ]
  }

  handleSave(){
    const createRec = new CustomEvent('jointownersaveclick', {detail:  {message: 'Joint Owners successfully created!' } });
    this.dispatchEvent(createRec);
  }

  async handleRowAction(event){
    const result = await LightningConfirm.open({
        message : "Are you sure to Delete this record?",
        theme : "Warning",
        label : "Warning!"
    });
      if(result){
        const rowToDelete = event.detail.row.Id;
        deleteAssetOrLiabilityRole({assetLiabilityRoleId: rowToDelete})
        .then(result=>{
            if(result){
               const evt = new ShowToastEvent({
                    title: 'Success!!',
                    message:'Record Deleted Successfully!',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                getAssetRecordRoles({assetId:this.assetLiabilityId})
               .then(result=>{
                  let tempAssetRoleList = result;
                  if(tempAssetRoleList != null){
                    this.listOfAssetRoles = JSON.parse(JSON.stringify(result));
                            /*this.listOfAssetRoles.forEach(assetRole=>{
                                lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                            })
                            this.leadList = [...this.leadList];*/
                  }
                  //this.listOfAssetRoles = JSON.stringify(result);
                })
            }
        })
    
      }
  }
  
  async handleAssetLiabilityRoleOwnershipUpdation(event) {
    this.saveDraftValues = event.detail.draftValues;
    const recordInputs = this.saveDraftValues.slice().map(draft => {
        const fields = Object.assign({}, draft);
        return { fields };
    });
    const promises = recordInputs.map(recordInput => updateRecord(recordInput));
    Promise.all(promises).then(res => {
        this.ShowToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
        this.saveDraftValues = [];
        return this.refresh();
    }).catch(error => {
        this.ShowToast('Error', 'Inline Edit Error Occured!!', 'error', 'dismissable');
    }).finally(() => {
        this.saveDraftValues = [];
        getAssetRecordRoles({assetId:this.assetLiabilityId})
    .then(result=>{
        let tempAssetRoleList = result;
        if(tempAssetRoleList != null){
          this.listOfAssetRoles = JSON.parse(JSON.stringify(result));
                  /*this.listOfAssetRoles.forEach(assetRole=>{
                      lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                  })
                  this.leadList = [...this.leadList];*/
        }
          //this.showNonManagedAssetModal = false;
          //return this.refresh();
      })
    })
  }

  handleAssetLiabilityRoleOwnershipCancel() {
    this.showNewJointOwnerCreationWindow = false;
}

}