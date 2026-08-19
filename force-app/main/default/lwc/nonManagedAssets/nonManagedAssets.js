/*******************************************************************************************************************************************************
*   Company         :   Coast Capital Savings Credit Union
*   Component       :   nonManagedAssets.
*   Description     :   Javascript/Client-side controller class to display new Assets/Liability form on UI.
********************************************************************************************************************************************************
*   Author           :  Sudhakar Botta
*   Date Created     :  [2022.OCT.14]
*   History          :  
*       
*   [2022.OCT.14]    sbotta - Initial Version.
*   [2022.OCT.18]    sbotta - [Added logic to incoporate the Type and Sub Type deendent picklist].
*   [2022.OCT.20]    sbotta - [Added logic to Save the record].
*   [2022.NOV.08]    sbotta - [Added logic to validate the amount, type and sub type fields on the new asset/liability form].
*   [2023.JAN.05]    sbotta - [Added logic to display the maturity date field on the UI].
*
********************************************************************************************************************************************************/
import { LightningElement,api,track, wire} from 'lwc';
import { getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NonManagedAssets extends LightningElement {

    //@api nonManagedAssets
    @api nonManagedAssetsSubtotal
    @track tempNonManagedAssets=[]
    @api nonManagedAssetEdit
    

    //new code
    @api recTypeId;
    @api recTypeName;
    @track options;
    @api showNonManagedAssetModal;
    @api showNext;
    @track selectedType;
    @track selectedSubType;
    @track selectedMaturityDate;
    hasError = false;
    newNonManagedAssetAmout;

     //Dependent picklist Type and sub type for new functionality code
   controllingPicklist=[];
   dependentPicklist;
   @track finalDependentVal=[];
   @track selectedControlling="--None--";
   showpicklist = false;
   dependentDisabled=true;
   showdependent = false;
   displayMaturityDateField = false;
   //Dependent picklist Type and sub type for new functionality code

    @wire(getPicklistValuesByRecordType, { objectApiName: 'FinServ__AssetsAndLiabilities__c', recordTypeId: '$recTypeId' }) 
    SourcePicklistValues({error, data}) {
        if(data) {
            this.options = data.picklistFieldValues.FinServ__AssetsAndLiabilitiesSource__c.values;
        }
        else if(error) {
            window.console.log('error =====> '+JSON.stringify(error));
        }
        if(data && data.picklistFieldValues){
            let optionsValue = {}
            optionsValue["label"] = "--None--";
            optionsValue["value"] = "--None--";
            this.controllingPicklist.push(optionsValue);
            data.picklistFieldValues["FinServ__AssetsAndLiabilitiesType__c"].values.forEach(optionData => {
                this.controllingPicklist.push({label : optionData.label, value : optionData.value});
            });
            this.dependentPicklist = data.picklistFieldValues["Sub_Type__c"];
            this.showpicklist = true;
        }
    }

    fetchDependentValue(event){
        this.finalDependentVal=[];
        this.showdependent = false;
        const selectedVal = event.target.value;
        this.selectedType = event.target.value;
        this.finalDependentVal.push({label : "--None--", value : "--None--"})
        let controllerValues = this.dependentPicklist.controllerValues;
        this.dependentPicklist.values.forEach(depVal => {
            depVal.validFor.forEach(depKey =>{
                if(depKey === controllerValues[selectedVal]){
                    this.dependentDisabled = false;
                    this.showdependent = true;
                    this.finalDependentVal.push({label : depVal.label, value : depVal.value});
                }
            });
            
        });
    }

    //Asset - AMOUNT CHANGE
    handleAmountChange(event){
        this.newNonManagedAssetAmout=event.target.value
    }
    handleSourceChange(event){
        this.value = event.target.value;
    }

    handleSubTypeChange(event){
        this.selectedSubType = event.target.value;
        //new code Jan 23rd 2023
        if( 
            ( (this.selectedType == 'Investment - Personal' ) && (this.selectedSubType == 'Registered GIC' || this.selectedSubType =='Non Registered GIC') )
            ||
            ( (this.selectedType == 'Lending - Personal' ) && (this.selectedSubType =='Loan - Retail' || this.selectedSubType =='Mortgage - Retail' || this.selectedSubType =='Auto Loan(s)') )
            ||
            ( (this.selectedType == 'Lending - Corporate' ) && (this.selectedSubType =='Loan - Corporate' || this.selectedSubType =='Mortgage - Corporate') )
            ) {
                this.displayMaturityDateField = true;
            
        }
        else{
            this.displayMaturityDateField = false;
        }
        //new code Jan 23rd 2023
    }
    handleMaturityDate(event){
        this.selectedMaturityDate = event.target.value;
    }
    
    handleModalCancel(event){
        this.showNonManagedAssetModal= false;
        this.showNext = false;
        const createRecCancel = new CustomEvent('newrecordcancelclick', {detail:  {showMainComponent:this.showNonManagedAssetModal ,  showNextVar: this.showNext} });
        this.dispatchEvent(createRecCancel);
    }

    handleSave(event){
        this.showNonManagedAssetModal= false;
        this.showNext = false;
        
        if(this.recTypeName == 'CCSNonManagedAsset' && this.newNonManagedAssetAmout < 0 ){
            const evtAssetAmountNotNegative = new ShowToastEvent({
                title: 'Error',
                message:'Asset cannot have negative Amount values!',
                variant: 'error',
                mode: 'dismissable'
            });
            this.hasError = true;
            this.dispatchEvent(evtAssetAmountNotNegative);
            
        }
        else if(this.recTypeName == 'CCSNonManagedLiability' && this.newNonManagedAssetAmout > 0 ){
            const evtLiabilityAmountNotPositive = new ShowToastEvent({
                title: 'Error',
                message:'Liability cannot have positive Amount values!',
                variant: 'error',
                mode: 'dismissable'
            });
            this.hasError = true;
            this.dispatchEvent(evtLiabilityAmountNotPositive);
        }
        else if(this.newNonManagedAssetAmout == null || this.newNonManagedAssetAmout == ''){
            const evtAmountNotNull = new ShowToastEvent({
                title: 'Error',
                message:'Amount field is required!',
                variant: 'error',
                mode: 'dismissable'
            });
            this.hasError = true;
            this.dispatchEvent(evtAmountNotNull);
        }
        else if(this.selectedType == null || this.selectedType == '--None--'){
            const evtTypeNotSelected = new ShowToastEvent({
                title: 'Error',
                message:'Type field is required!',
                variant: 'error',
                mode: 'dismissable'
            });
            this.hasError = true;
            this.dispatchEvent(evtTypeNotSelected);
        }
        else if(
            (this.selectedType != null || this.selectedType != '--None--') &&
            (this.selectedType == 'Accounts' || this.selectedType == 'Investment' || this.selectedType == 'Vehicle' 
            || this.selectedType == 'Real Estate' || this.selectedType == 'Expense'|| this.selectedType == 'Lending') && 
            (this.selectedSubType == null || this.selectedSubType == '--None--')
            ){
                    const evtSubTypeNotSelected = new ShowToastEvent({
                        title: 'Error',
                        message:'Sub Type field is required!',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.hasError = true;
                    this.dispatchEvent(evtSubTypeNotSelected);
                
            }
        else {
            const createRec = new CustomEvent('newrecordsaveclick', {detail:  {parent: this.accountId, amount: this.newNonManagedAssetAmout, source: this.value, recTypeId: this.recTypeId, type:this.selectedType, subtype:this.selectedSubType, maturityDate:this.selectedMaturityDate} });
            this.dispatchEvent(createRec);
        }
        
    }
    
}