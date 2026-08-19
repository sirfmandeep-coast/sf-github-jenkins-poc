/*******************************************************************************************************************************************************
*   Company         :   Coast Capital Savings Credit Union
*   Component       :   netWorthStatementComponent.
*   Description     :   Javascript/Client-side controller class to display Asset and Liabilities data table on the Net Worthtab under Account UI.
********************************************************************************************************************************************************
*   Author           :  Sudhakar Botta
*   Date Created     :  [2022.OCT.14]
*   History          :  
*       
*   [2022.OCT.14]    sbotta - Initial Version.
*   [2022.OCT.18]    sbotta - [Added logic to fetch assets and liabilieties from the FinServ__FinancialAccount__c].
*   [2022.OCT.20]    sbotta - [Added logic to fetch assets and liabilieties from the FinServ__AssetsAndLiabilities__c].
*   [2022.OCT.24]    sbotta - [Added logic to update the amount on the UI for Non CCS Managed Assets].
*   [2022.OCT.25]    sbotta - [Added logic to update the amount on the UI for Non CCS Managed Liabilities].
*   [2022.OCT.26]    sbotta - [Added logic to insert new asset/liability to FinServ__AssetsAndLiabilities__c].
*   [2022.OCT.27]    sbotta - [Added logic to soft delete asset/liability making the Is Deleted field as selected on FinServ__AssetsAndLiabilities__c].
*   [2022.OCT.27]    sbotta - [Added logic to calaculate the amount sub totals of Assets and Liabilities also the Total Net worth calculation].
*   [2023.APR.03]    sbotta - [CRM - 5207 Added new column Ownership % on both ccs and nonccs managedcolumns and made it editable on the UI].
*
********************************************************************************************************************************************************/
import { LightningElement, api, track, wire} from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import LightningConfirm from "lightning/confirm";
import getCCSManagedAssets from '@salesforce/apex/AssetsAndLiabilitiesController.getCCSManagedAssets';
import getNonCCSManagedAssets from '@salesforce/apex/AssetsAndLiabilitiesController.getNonCCSManagedAssets';
import getCCSManagedLiabilities from '@salesforce/apex/AssetsAndLiabilitiesController.getCCSManagedLiabilities';
import getNonCCSManagedLiabilities from '@salesforce/apex/AssetsAndLiabilitiesController.getNonCCSManagedLiabilities';
import insertNonManagedAssetLiability from '@salesforce/apex/AssetsAndLiabilitiesController.insertNonManagedAssetLiability';
import deleteAssetOrLiability from '@salesforce/apex/AssetsAndLiabilitiesController.deleteAssetOrLiability';
import fetchRecTypeIdByName from '@salesforce/apex/AssetsAndLiabilitiesController.fetchRecTypeIdByName';
import getTotalAssetsAmount from '@salesforce/apex/AssetsAndLiabilitiesController.getTotalAssetsAmount';
import getTotalLiabilititesAmount from '@salesforce/apex/AssetsAndLiabilitiesController.getTotalLiabilititesAmount';
import ASSETANDLIABILITY_OBJECT from '@salesforce/schema/FinServ__AssetsAndLiabilities__c';
import NAME_FIELD from '@salesforce/schema/FinServ__AssetsAndLiabilities__c.Name';
import AMOUNT_FIELD from '@salesforce/schema/FinServ__AssetsAndLiabilities__c.FinServ__Amount__c';
import TYPE_FIELD from '@salesforce/schema/FinServ__AssetsAndLiabilities__c.FinServ__AssetsAndLiabilitiesType__c';
import SUBTYPE_FIELD from '@salesforce/schema/FinServ__AssetsAndLiabilities__c.Sub_Type__c';
import COLORS from '@salesforce/resourceUrl/NWSTableColors';
import {loadStyle} from 'lightning/platformResourceLoader';

import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import updateAssetOrLiability from '@salesforce/apex/AssetsAndLiabilitiesController.updateAssetOrLiability';
import updateCCSAssetOrLiabilityOwnershipPercent from '@salesforce/apex/AssetsAndLiabilitiesController.updateCCSAssetOrLiabilityOwnershipPercent';

export default class NetWorthStatementComponent extends LightningElement {

    @track ccsManagedColumns = [
        { label: 'Source', fieldName: 'FinServ__FinancialAccountSource__c', cellAttributes: {class : {fieldName: 'sourceColumnColor'}} },
        //{ label: 'Name', fieldName: 'Name'},
        { label: 'Type', fieldName: 'FinServ__FinancialAccountType__c'},
        { label: 'Sub Type', fieldName: 'Plan_Type__c'},
        { label: 'Last Updated', fieldName: 'LastModifiedDate', cellAttributes: {class : {fieldName: 'lastModifiedDateColor'}}},
        { label: 'Amount', fieldName: 'FinServ__Balance__c'},
        { label: 'Renewal Date', fieldName: 'renewOrMaturityDate'},
        { label: 'Ownership %', fieldName: 'Primary_Ownership_Percent__c', editable: true},
        { label: ''}
    ];

    @track ccsNonManagedColumns = [
        { label: 'Source', fieldName: 'FinServ__AssetsAndLiabilitiesSource__c' },
        { label: 'Type', fieldName: 'FinServ__AssetsAndLiabilitiesType__c'},
        { label: 'Sub Type', fieldName: 'Sub_Type__c'},
        { label: 'Last Updated', fieldName: 'LastModifiedDate', cellAttributes: {class : {fieldName: 'lastModifiedDateColor'}}},
        { label: 'Amount', fieldName: 'FinServ__Amount__c', editable: true},
        { label: 'Renewal Date', fieldName: 'renewOrMaturityDate'},
        { label: 'Ownership %', fieldName: 'Primary_Ownership_Percent__c', editable: true},
        { label: '', type: 'button-icon', typeAttributes: {iconName: 'action:delete', iconClass: 'slds-icon-text-error', name:'delete'}}
    ];

    //Dependent picklist Type and sub type for new functionality code
   controllingPicklist=[];
   dependentPicklist;
   @track finalDependentVal=[];
   @track selectedControlling="--None--";
   showpicklist = false;
   dependentDisabled=true;
   showdependent = false;
   //Dependent picklist Type and sub type for new functionality code
   showNonManagedAssetModal = false;
   isCssLoaded = false;
   newNonManagedAssetAmout;
    ccsassetsList =[];
    nonCCSAssetsList = [];
    ccsLiabilitiesList = [];
    nonCCSLiabilitiesList = [];
    saveDraftValues = [];
    ccsAssetsSubtotal = 0;
    nonCCSAssetsSubTotal = 0;
    ccsLiabilitiesSubtotal = 0;
    nonCCSLiabilitiesSubTotal = 0;
    totAssets = 0;
    totLiablities = 0;
    totAssetsBeforeConvert = 0;
    totLiabilitiesBeforeConvert = 0;
    @track selectedOption;
    @track value;
    @track options;
    @track selectedType;
    @track selectedSubType;
    @api recordId

    @api selectedRecTypeId;
    showNext = false;
    showOwnershipPage = false;
    @api assetRoleRecord = []; 
    
    connectedCallback(){
        getCCSManagedAssets({AccountId:this.recordId})
        .then(result=>{
            this.ccsassetsList=result;
            this.ccsassetsList.forEach(asset=>{
                //NWS 1.1
                if(asset.FinServ__FinancialAccountRoles__r != null){
                    let assetRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(asset.FinServ__FinancialAccountRoles__r));
                    assetRolesListOfPrimaryAccount.forEach(assetRoleOfPrimaryAccount=>{
                        asset.Primary_Ownership_Percent__c = assetRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                    })
                }
                //NWS 1.1
                asset.sourceColumnColor = "datatable-blue";
                asset.amountAlign = "datatable-amount-right";
                if(asset.FinServ__FinancialAccountType__c == 'Term Deposit'){
                    asset.renewOrMaturityDate = asset.Maturity_Date__c;
                }
                else{
                    asset.renewOrMaturityDate = '';
                }
                if(asset.LastModifiedDate != null){
                    asset.LastModifiedDate =asset.LastModifiedDate.split('T')[0];
                    let date_1 = new Date();
                    let date_2 = new Date(asset.LastModifiedDate);
                    
                    const days = (date_1, date_2) =>{
                        let difference = date_1.getTime() - date_2.getTime();
                        let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                        return TotalDays;
                    }
                    if(days(date_1, date_2) >= 730){
                        asset.lastModifiedDateColor = "datatable-red";
                    }
                    //additional code - Jan 18th 2023
                }   
                
                this.ccsAssetsSubtotal+=asset.FinServ__Balance__c;
                if(asset.FinServ__Balance__c != null) {
                    asset.FinServ__Balance__c=(asset.FinServ__Balance__c).toLocaleString('en-US', {
                        style: 'currency',
                        currency: 'USD',
                    });
                }
            })
            this.ccsAssetsSubtotal=this.ccsAssetsSubtotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getNonCCSManagedAssets({AccountId:this.recordId})
        }).then(result=>{
            this.nonCCSAssetsList = result;
            this.nonCCSAssetsList.forEach(nonCCSAsset=>{
                //NWS 1.1
                if(nonCCSAsset.Asset_Liability_Roles__r != null){
                    let assetRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(nonCCSAsset.Asset_Liability_Roles__r));
                    assetRolesListOfPrimaryAccount.forEach(assetRoleOfPrimaryAccount=>{
                        nonCCSAsset.Primary_Ownership_Percent__c = assetRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                //Jan 23rd 2023
                if(nonCCSAsset.FinServ__AssetsAndLiabilitiesType__c == 'Investment - Personal'){
                    if(nonCCSAsset.Sub_Type__c == 'Registered GIC' || nonCCSAsset.Sub_Type__c == 'Non Registered GIC' ) //Non-Registered Term
                    nonCCSAsset.renewOrMaturityDate = nonCCSAsset.Maturity_Date__c;
                }
                else{
                    nonCCSAsset.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                nonCCSAsset.LastModifiedDate =nonCCSAsset.LastModifiedDate.split('T')[0];
                //additional code - Jan 18th 2023
                let date_1 = new Date();
                let date_2 = new Date(nonCCSAsset.LastModifiedDate);
                
                //let numOfDays = 0;

                const days = (date_1, date_2) =>{
                    let difference = date_1.getTime() - date_2.getTime();
                    let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                    return TotalDays;
                }
                if(days(date_1, date_2) >= 730){
                    nonCCSAsset.lastModifiedDateColor = "datatable-red";
                }
                 //additional code - Jan 18th 2023
                this.nonCCSAssetsSubTotal+=nonCCSAsset.FinServ__Amount__c;
                nonCCSAsset.FinServ__Amount__c=(nonCCSAsset.FinServ__Amount__c).toLocaleString('en-US', {
                    style: 'currency',
                    currency: 'USD',
                });
            })
            this.nonCCSAssetsSubTotal=this.nonCCSAssetsSubTotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getCCSManagedLiabilities({AccountId:this.recordId})
        }).then(result=>{
            this.ccsLiabilitiesList = result;
            this.ccsLiabilitiesList.forEach(liability=>{
                //NWS 1.1
                if(liability.FinServ__FinancialAccountRoles__r != null){
                    let liabilityRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(liability.FinServ__FinancialAccountRoles__r));
                    liabilityRolesListOfPrimaryAccount.forEach(liabilityRoleOfPrimaryAccount=>{
                        liability.Primary_Ownership_Percent__c = liabilityRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                liability.sourceColumnColor = "datatable-blue";
                //Jan 23rd 2023
                    if(liability.FinServ__FinancialAccountType__c == 'Mortgage' || liability.FinServ__FinancialAccountType__c == 'Loans'){
                        liability.renewOrMaturityDate = liability.FinServ__RenewalDate__c;
                    }
                    else{
                        liability.renewOrMaturityDate = '';
                    }
                //Jan 23rd 2023
                if(liability.LastModifiedDate != null){
                    liability.LastModifiedDate =liability.LastModifiedDate.split('T')[0];
                    //additional code - Jan 18th 2023
                    let date_1 = new Date();
                    let date_2 = new Date(liability.LastModifiedDate);
                    
                    //let numOfDays = 0;

                    const days = (date_1, date_2) =>{
                        let difference = date_1.getTime() - date_2.getTime();
                        let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                        return TotalDays;
                    }
                    if(days(date_1, date_2) >= 730){
                        liability.lastModifiedDateColor = "datatable-red";
                    }
                     //additional code - Jan 18th 2023
                }   
                this.ccsLiabilitiesSubtotal+=liability.FinServ__Balance__c;
                if(liability.FinServ__Balance__c != null) {
                    liability.FinServ__Balance__c=(liability.FinServ__Balance__c).toLocaleString('en-US', {
                        style: 'currency',
                        currency: 'USD',
                    });
                }
            })
            this.ccsLiabilitiesSubtotal=this.ccsLiabilitiesSubtotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getNonCCSManagedLiabilities({AccountId:this.recordId})
        }).then(result=>{
            this.nonCCSLiabilitiesList = result;
            this.nonCCSLiabilitiesList.forEach(nonCCSLiability=>{
                //NWS 1.1
                if(nonCCSLiability.Asset_Liability_Roles__r != null){
                    let liabilityRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(nonCCSLiability.Asset_Liability_Roles__r));
                    liabilityRolesListOfPrimaryAccount.forEach(liabilityRoleOfPrimaryAccount=>{
                        nonCCSLiability.Primary_Ownership_Percent__c = liabilityRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                //Jan 23rd 2023
                if(nonCCSLiability.FinServ__AssetsAndLiabilitiesType__c == 'Lending - Personal' || nonCCSLiability.FinServ__AssetsAndLiabilitiesType__c == 'Lending - Corporate'){
                    if(nonCCSLiability.Sub_Type__c == 'Loan - Corporate' || nonCCSLiability.Sub_Type__c == 'Loan - Retail' || nonCCSLiability.Sub_Type__c == 'Mortgage - Corporate'
                        || nonCCSLiability.Sub_Type__c == 'Mortgage - Retail' || nonCCSLiability.Sub_Type__c == 'Auto loan(s)'){
                            nonCCSLiability.renewOrMaturityDate = nonCCSLiability.Maturity_Date__c;
                        }
                }
                else{
                    nonCCSLiability.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
            nonCCSLiability.LastModifiedDate =nonCCSLiability.LastModifiedDate.split('T')[0];
                //additional code - Jan 18th 2023
                let date_1 = new Date();
                let date_2 = new Date(nonCCSLiability.LastModifiedDate);
                
                //let numOfDays = 0;

                const days = (date_1, date_2) =>{
                    let difference = date_1.getTime() - date_2.getTime();
                    let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                    return TotalDays;
                }
                if(days(date_1, date_2) >= 730){
                    nonCCSLiability.lastModifiedDateColor = "datatable-red";
                }
                 //additional code - Jan 18th 2023
                this.nonCCSLiabilitiesSubTotal+=nonCCSLiability.FinServ__Amount__c;
                nonCCSLiability.FinServ__Amount__c=(nonCCSLiability.FinServ__Amount__c).toLocaleString('en-US', {
                    style: 'currency',
                    currency: 'USD',
                });
            })
            this.nonCCSLiabilitiesSubTotal=this.nonCCSLiabilitiesSubTotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
        })
    }

    renderedCallback(){ 
        if(this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, COLORS).then(()=>{
            console.log("Loaded Successfully")
        }).catch(error=>{ 
            console.error("Error in loading the colors")
        })
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

    handleSubTypeChange(event){
        this.selectedSubType = event.target.value;
    }
    
    async handleRowAction(event){
        const result = await LightningConfirm.open({
            message : "Are you sure to Delete this record?",
            theme : "Warning",
            label : "Warning!"
        });
        if(result){
            const rowToDelete = event.detail.row.Id;
            deleteAssetOrLiability({assetLiabilityId: rowToDelete})
            .then(result=>{
                if(result){
                   const evt = new ShowToastEvent({
                        title: 'Success!!',
                        message:'Record Deleted Successfully!',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    getCCSManagedAssets({AccountId:this.recordId})
        .then(result=>{
            this.ccsassetsList=result;
            this.ccsassetsList.forEach(asset=>{
                //NWS 1.1
                if(asset.FinServ__FinancialAccountRoles__r != null){
                    let assetRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(asset.FinServ__FinancialAccountRoles__r));
                    assetRolesListOfPrimaryAccount.forEach(assetRoleOfPrimaryAccount=>{
                        asset.Primary_Ownership_Percent__c = assetRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                asset.sourceColumnColor = "datatable-blue";
                //Jan 23rd 2023
                if(asset.FinServ__FinancialAccountType__c == 'Term Deposit'){
                    asset.renewOrMaturityDate = asset.Maturity_Date__c;
                }
                else{
                    asset.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                if(asset.LastModifiedDate != null){
                    asset.LastModifiedDate =asset.LastModifiedDate.split('T')[0];
                    //additional code - Jan 18th 2023
                    let date_1 = new Date();
                    let date_2 = new Date(asset.LastModifiedDate);
                    
                    //let numOfDays = 0;

                    const days = (date_1, date_2) =>{
                        let difference = date_1.getTime() - date_2.getTime();
                        let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                        return TotalDays;
                    }
                    if(days(date_1, date_2) >= 730){
                        asset.lastModifiedDateColor = "datatable-red";
                    }
                    //additional code - Jan 18th 2023
                }   
                this.ccsAssetsSubtotal+=asset.FinServ__Balance__c;
                if(asset.FinServ__Balance__c != null) {
                    asset.FinServ__Balance__c=(asset.FinServ__Balance__c).toLocaleString('en-US', {
                        style: 'currency',
                        currency: 'USD',
                    });
                }
            })
            this.ccsAssetsSubtotal=this.ccsAssetsSubtotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });

            return getNonCCSManagedAssets({AccountId:this.recordId})
        }).then(result=>{
            this.nonCCSAssetsList = result;
            this.nonCCSAssetsList.forEach(nonCCSAsset=>{
                //NWS 1.1
                if(nonCCSAsset.Asset_Liability_Roles__r != null){
                    let assetRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(nonCCSAsset.Asset_Liability_Roles__r));
                    assetRolesListOfPrimaryAccount.forEach(assetRoleOfPrimaryAccount=>{
                        nonCCSAsset.Primary_Ownership_Percent__c = assetRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                //Jan 23rd 2023
                if(nonCCSAsset.FinServ__AssetsAndLiabilitiesType__c == 'Investment - Personal'){
                    if(nonCCSAsset.Sub_Type__c == 'Registered GIC' || nonCCSAsset.Sub_Type__c == 'Non Registered GIC' ) //Non-Registered Term
                    nonCCSAsset.renewOrMaturityDate = nonCCSAsset.Maturity_Date__c;
                }
                else{
                    nonCCSAsset.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                nonCCSAsset.LastModifiedDate =nonCCSAsset.LastModifiedDate.split('T')[0];
                //additional code - Jan 18th 2023
                let date_1 = new Date();
                let date_2 = new Date(nonCCSAsset.LastModifiedDate);
                
                //let numOfDays = 0;

                const days = (date_1, date_2) =>{
                    let difference = date_1.getTime() - date_2.getTime();
                    let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                    return TotalDays;
                }
                if(days(date_1, date_2) >= 730){
                    nonCCSAsset.lastModifiedDateColor = "datatable-red";
                }
                 //additional code - Jan 18th 2023
                this.nonCCSAssetsSubTotal+=nonCCSAsset.FinServ__Amount__c;
                nonCCSAsset.FinServ__Amount__c=(nonCCSAsset.FinServ__Amount__c).toLocaleString('en-US', {
                    style: 'currency',
                    currency: 'USD',
                });
            })
            this.nonCCSAssetsSubTotal=this.nonCCSAssetsSubTotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getCCSManagedLiabilities({AccountId:this.recordId})
        }).then(result=>{
            this.ccsLiabilitiesList = result;
            this.ccsLiabilitiesList.forEach(liability=>{
                //NWS 1.1
                if(liability.FinServ__FinancialAccountRoles__r != null){
                    let liabilityRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(liability.FinServ__FinancialAccountRoles__r));
                    liabilityRolesListOfPrimaryAccount.forEach(liabilityRoleOfPrimaryAccount=>{
                        liability.Primary_Ownership_Percent__c = liabilityRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                liability.sourceColumnColor = "datatable-blue";
                //Jan 23rd 2023
                if(liability.FinServ__FinancialAccountType__c == 'Mortgage' || liability.FinServ__FinancialAccountType__c == 'Loans'){
                    liability.renewOrMaturityDate = liability.FinServ__RenewalDate__c;
                }
                else{
                    liability.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                if(liability.LastModifiedDate != null){
                    liability.LastModifiedDate =liability.LastModifiedDate.split('T')[0];
                    //additional code - Jan 18th 2023
                    let date_1 = new Date();
                    let date_2 = new Date(liability.LastModifiedDate);
                    
                    //let numOfDays = 0;

                    const days = (date_1, date_2) =>{
                        let difference = date_1.getTime() - date_2.getTime();
                        let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                        return TotalDays;
                    }
                    if(days(date_1, date_2) >= 730){
                        liability.lastModifiedDateColor = "datatable-red";
                    }
                     //additional code - Jan 18th 2023
                }   
                this.ccsLiabilitiesSubtotal+=liability.FinServ__Balance__c;
                if(liability.FinServ__Balance__c != null){
                    liability.FinServ__Balance__c=(liability.FinServ__Balance__c).toLocaleString('en-US', {
                        style: 'currency',
                        currency: 'USD',
                    });
                }
            })
            this.ccsLiabilitiesSubtotal=this.ccsLiabilitiesSubtotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getNonCCSManagedLiabilities({AccountId:this.recordId})
        }).then(result=>{
            this.nonCCSLiabilitiesList = result;
            this.nonCCSLiabilitiesList.forEach(nonCCSLiability=>{
                //NWS 1.1
                if(nonCCSLiability.Asset_Liability_Roles__r != null){
                    let liabilityRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(nonCCSLiability.Asset_Liability_Roles__r));
                    liabilityRolesListOfPrimaryAccount.forEach(liabilityRoleOfPrimaryAccount=>{
                        nonCCSLiability.Primary_Ownership_Percent__c = liabilityRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                //Jan 23rd 2023
                if(nonCCSLiability.FinServ__AssetsAndLiabilitiesType__c == 'Lending - Personal' || nonCCSLiability.FinServ__AssetsAndLiabilitiesType__c == 'Lending - Corporate'){
                    if(nonCCSLiability.Sub_Type__c == 'Loan - Corporate' || nonCCSLiability.Sub_Type__c == 'Loan - Retail' || nonCCSLiability.Sub_Type__c == 'Mortgage - Corporate'
                        || nonCCSLiability.Sub_Type__c == 'Mortgage - Retail' || nonCCSLiability.Sub_Type__c == 'Auto loan(s)'){
                            nonCCSLiability.renewOrMaturityDate = nonCCSLiability.Maturity_Date__c;
                        }
                }
                else{
                    nonCCSLiability.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
            nonCCSLiability.LastModifiedDate =nonCCSLiability.LastModifiedDate.split('T')[0];
            //additional code - Jan 18th 2023
            let date_1 = new Date();
            let date_2 = new Date(nonCCSLiability.LastModifiedDate);
            
            //let numOfDays = 0;

            const days = (date_1, date_2) =>{
                let difference = date_1.getTime() - date_2.getTime();
                let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                return TotalDays;
            }
            if(days(date_1, date_2) >= 730){
                nonCCSLiability.lastModifiedDateColor = "datatable-red";
            }
             //additional code - Jan 18th 2023
                this.nonCCSLiabilitiesSubTotal+=nonCCSLiability.FinServ__Amount__c;
                nonCCSLiability.FinServ__Amount__c=(nonCCSLiability.FinServ__Amount__c).toLocaleString('en-US', {
                    style: 'currency',
                    currency: 'USD',
                });
            })
            this.nonCCSLiabilitiesSubTotal=this.nonCCSLiabilitiesSubTotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
        })
        this.showNonManagedAssetModal = false;
            return this.refresh();
                    }
            })
        }
        
    }

    recTypeChangeHandler(event) {
        const field = event.target.name;
        if (field === 'optionSelect') {
            this.selectedOption = event.target.value;
        }
        fetchRecTypeIdByName({recTypeName:this.selectedOption})
        .then(result=>{
            this.selectedRecTypeId = result;
        })
    }

    handleSourceChange(event){
        this.value = event.target.value;
    }
    
    handleAssetLiabilityAmountCancel() {
        this.showNonManagedAssetModal = false;
    }

    ShowToast(title, message, variant, mode){
        const evt = new ShowToastEvent({
                title: title,
                message:message,
                variant: variant,
                mode: mode
            });
            this.dispatchEvent(evt);
    }

    // This function is used to refresh the table once data updated
    async refresh() {
        await refreshApex(this.nonManagedAssetsList);
    }

    //Asset -NEW
    handleNewNonManagedAsset(){
        this.showNonManagedAssetModal= true

    }

    //Asset - MODAL CANCEL
    handleModalCancel(){
        this.showNonManagedAssetModal= false;
        this.showNext = false;
    }

    //April 25th 2023 

    handleNewJointOwner(){
        console.log("account id from the parent into ownership cmp is ::::"+this.accId);
        
    }

    handleJointOwnerCreation(event) {
        const evt = new ShowToastEvent({
            title: 'Success',
            message:event.detail.message,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        getCCSManagedAssets({AccountId:this.recordId})
        .then(result=>{
            this.ccsassetsList=result;
            this.ccsassetsList.forEach(asset=>{
                //NWS 1.1
                if(asset.FinServ__FinancialAccountRoles__r != null){
                    let assetRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(asset.FinServ__FinancialAccountRoles__r));
                    assetRolesListOfPrimaryAccount.forEach(assetRoleOfPrimaryAccount=>{
                        asset.Primary_Ownership_Percent__c = assetRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                    asset.sourceColumnColor = "datatable-blue";
                   //Jan 23rd 2023
                if(asset.FinServ__FinancialAccountType__c == 'Term Deposit'){
                    asset.renewOrMaturityDate = asset.Maturity_Date__c;
                }
                else{
                    asset.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                if(asset.LastModifiedDate != null){
                    asset.LastModifiedDate =asset.LastModifiedDate.split('T')[0];
                    //additional code - Jan 18th 2023
                    let date_1 = new Date();
                    let date_2 = new Date(asset.LastModifiedDate);
                    
                    //let numOfDays = 0;

                    const days = (date_1, date_2) =>{
                        let difference = date_1.getTime() - date_2.getTime();
                        let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                        return TotalDays;
                    }
                    if(days(date_1, date_2) >= 730){
                        asset.lastModifiedDateColor = "datatable-red";
                    }
                    //additional code - Jan 18th 2023
                }   
                this.ccsAssetsSubtotal+=asset.FinServ__Balance__c;
                if(asset.FinServ__Balance__c != null){
                    asset.FinServ__Balance__c=(asset.FinServ__Balance__c).toLocaleString('en-US', {
                        style: 'currency',
                        currency: 'USD',
                    });
                }
            })
            this.ccsAssetsSubtotal=this.ccsAssetsSubtotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getNonCCSManagedAssets({AccountId:this.recordId})
        }).then(result=>{
            this.nonCCSAssetsList = result;
            this.nonCCSAssetsList.forEach(nonCCSAsset=>{
                //NWS 1.1
                if(nonCCSAsset.Asset_Liability_Roles__r != null){
                    let assetRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(nonCCSAsset.Asset_Liability_Roles__r));
                    assetRolesListOfPrimaryAccount.forEach(assetRoleOfPrimaryAccount=>{
                        nonCCSAsset.Primary_Ownership_Percent__c = assetRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                //Jan 23rd 2023
                if(nonCCSAsset.FinServ__AssetsAndLiabilitiesType__c == 'Investment - Personal'){
                    if(nonCCSAsset.Sub_Type__c == 'Registered GIC' || nonCCSAsset.Sub_Type__c == 'Non Registered GIC' ) //Non-Registered Term
                    nonCCSAsset.renewOrMaturityDate = nonCCSAsset.Maturity_Date__c;
                }
                else{
                    nonCCSAsset.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                nonCCSAsset.LastModifiedDate =nonCCSAsset.LastModifiedDate.split('T')[0];
                //additional code - Jan 18th 2023
                let date_1 = new Date();
                let date_2 = new Date(nonCCSAsset.LastModifiedDate);
                
                //let numOfDays = 0;

                const days = (date_1, date_2) =>{
                    let difference = date_1.getTime() - date_2.getTime();
                    let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                    return TotalDays;
                }
                if(days(date_1, date_2) >= 730){
                    nonCCSAsset.lastModifiedDateColor = "datatable-red";
                }
                 //additional code - Jan 18th 2023
                this.nonCCSAssetsSubTotal+=nonCCSAsset.FinServ__Amount__c;
                nonCCSAsset.FinServ__Amount__c=(nonCCSAsset.FinServ__Amount__c).toLocaleString('en-US', {
                    style: 'currency',
                    currency: 'USD',
                });
            })
            this.nonCCSAssetsSubTotal=this.nonCCSAssetsSubTotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getCCSManagedLiabilities({AccountId:this.recordId})
        }).then(result=>{
            this.ccsLiabilitiesList = result;
            this.ccsLiabilitiesList.forEach(liability=>{
                //NWS 1.1
                if(liability.FinServ__FinancialAccountRoles__r != null){
                    let liabilityRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(liability.FinServ__FinancialAccountRoles__r));
                    liabilityRolesListOfPrimaryAccount.forEach(liabilityRoleOfPrimaryAccount=>{
                        liability.Primary_Ownership_Percent__c = liabilityRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                liability.sourceColumnColor = "datatable-blue";
                //Jan 23rd 2023
                if(liability.FinServ__FinancialAccountType__c == 'Mortgage' || liability.FinServ__FinancialAccountType__c == 'Loans'){
                    liability.renewOrMaturityDate = liability.FinServ__RenewalDate__c;
                }
                else{
                    liability.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                if(liability.LastModifiedDate != null){
                    liability.LastModifiedDate =liability.LastModifiedDate.split('T')[0];
                    //additional code - Jan 18th 2023
                    let date_1 = new Date();
                    let date_2 = new Date(liability.LastModifiedDate);
                    
                    //let numOfDays = 0;

                    const days = (date_1, date_2) =>{
                        let difference = date_1.getTime() - date_2.getTime();
                        let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                        return TotalDays;
                    }
                    if(days(date_1, date_2) >= 730){
                        liability.lastModifiedDateColor = "datatable-red";
                    }
                     //additional code - Jan 18th 2023
                }   
                this.ccsLiabilitiesSubtotal+=liability.FinServ__Balance__c;
                if(liability.FinServ__Balance__c != null){
                    liability.FinServ__Balance__c=(liability.FinServ__Balance__c).toLocaleString('en-US', {
                        style: 'currency',
                        currency: 'USD',
                    });
                }
            })
            this.ccsLiabilitiesSubtotal=this.ccsLiabilitiesSubtotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getNonCCSManagedLiabilities({AccountId:this.recordId})
        }).then(result=>{
            this.nonCCSLiabilitiesList = result;
            this.nonCCSLiabilitiesList.forEach(nonCCSLiability=>{
                //NWS 1.1
                if(nonCCSLiability.Asset_Liability_Roles__r != null){
                    let liabilityRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(nonCCSLiability.Asset_Liability_Roles__r));
                    liabilityRolesListOfPrimaryAccount.forEach(liabilityRoleOfPrimaryAccount=>{
                        nonCCSLiability.Primary_Ownership_Percent__c = liabilityRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                //Jan 23rd 2023
                if(nonCCSLiability.FinServ__AssetsAndLiabilitiesType__c == 'Lending - Personal' || nonCCSLiability.FinServ__AssetsAndLiabilitiesType__c == 'Lending - Corporate'){
                    if(nonCCSLiability.Sub_Type__c == 'Loan - Corporate' || nonCCSLiability.Sub_Type__c == 'Loan - Retail' || nonCCSLiability.Sub_Type__c == 'Mortgage - Corporate'
                        || nonCCSLiability.Sub_Type__c == 'Mortgage - Retail' || nonCCSLiability.Sub_Type__c == 'Auto loan(s)'){
                            nonCCSLiability.renewOrMaturityDate = nonCCSLiability.Maturity_Date__c;
                        }
                }
                else{
                    nonCCSLiability.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
            nonCCSLiability.LastModifiedDate =nonCCSLiability.LastModifiedDate.split('T')[0];
            //additional code - Jan 18th 2023
            let date_1 = new Date();
            let date_2 = new Date(nonCCSLiability.LastModifiedDate);
            
            //let numOfDays = 0;

            const days = (date_1, date_2) =>{
                let difference = date_1.getTime() - date_2.getTime();
                let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                return TotalDays;
            }
            if(days(date_1, date_2) >= 730){
                nonCCSLiability.lastModifiedDateColor = "datatable-red";
            }
             //additional code - Jan 18th 2023
                this.nonCCSLiabilitiesSubTotal+=nonCCSLiability.FinServ__Amount__c;
                nonCCSLiability.FinServ__Amount__c=(nonCCSLiability.FinServ__Amount__c).toLocaleString('en-US', {
                    style: 'currency',
                    currency: 'USD',
                });
            })
            this.nonCCSLiabilitiesSubTotal=this.nonCCSLiabilitiesSubTotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
        })
            // commented below 2 lines for displaying the Ownership page after saving the Asset/Liabilty instead of the main component
            this.showNonManagedAssetModal= false;
            this.showNext = false;

            //added the below line for new UI to display the ownership page
            this.showOwnershipPage = false;
            //added the below line for new UI to display the ownership page
            return this.refresh();
    }
    //April 25th 2023
    handleAssetLiabilityCreation(event) {
        insertNonManagedAssetLiability({AccountId:this.recordId, recTypeId:event.detail.recTypeId, Amount:event.detail.amount, Source:event.detail.source, Type: event.detail.type, SubType: event.detail.subtype, maturityDate: event.detail.maturityDate})
        .then(result=>{
            if(result){
                //result has the asset Id created and assigning this to var for new UI April 25th 2023
                this.assetRoleRecord = result;
                //result has the asset Id created and assigning this to var for new UI April 25th 2023
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message:'Record Created Successfully!',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                getCCSManagedAssets({AccountId:this.recordId})
        .then(result=>{
            this.ccsassetsList=result;
            this.ccsassetsList.forEach(asset=>{
                //NWS 1.1
                if(asset.FinServ__FinancialAccountRoles__r != null){
                    let assetRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(asset.FinServ__FinancialAccountRoles__r));
                    assetRolesListOfPrimaryAccount.forEach(assetRoleOfPrimaryAccount=>{
                        asset.Primary_Ownership_Percent__c = assetRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                    asset.sourceColumnColor = "datatable-blue";
                   //Jan 23rd 2023
                if(asset.FinServ__FinancialAccountType__c == 'Term Deposit'){
                    asset.renewOrMaturityDate = asset.Maturity_Date__c;
                }
                else{
                    asset.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                if(asset.LastModifiedDate != null){
                    asset.LastModifiedDate =asset.LastModifiedDate.split('T')[0];
                    //additional code - Jan 18th 2023
                    let date_1 = new Date();
                    let date_2 = new Date(asset.LastModifiedDate);
                    
                    //let numOfDays = 0;

                    const days = (date_1, date_2) =>{
                        let difference = date_1.getTime() - date_2.getTime();
                        let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                        return TotalDays;
                    }
                    if(days(date_1, date_2) >= 730){
                        asset.lastModifiedDateColor = "datatable-red";
                    }
                    //additional code - Jan 18th 2023
                }   
                this.ccsAssetsSubtotal+=asset.FinServ__Balance__c;
                if(asset.FinServ__Balance__c != null){
                    asset.FinServ__Balance__c=(asset.FinServ__Balance__c).toLocaleString('en-US', {
                        style: 'currency',
                        currency: 'USD',
                    });
                }
            })
            this.ccsAssetsSubtotal=this.ccsAssetsSubtotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getNonCCSManagedAssets({AccountId:this.recordId})
        }).then(result=>{
            this.nonCCSAssetsList = result;
            this.nonCCSAssetsList.forEach(nonCCSAsset=>{
                //NWS 1.1
                if(nonCCSAsset.Asset_Liability_Roles__r != null){
                    let assetRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(nonCCSAsset.Asset_Liability_Roles__r));
                    assetRolesListOfPrimaryAccount.forEach(assetRoleOfPrimaryAccount=>{
                        nonCCSAsset.Primary_Ownership_Percent__c = assetRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                //Jan 23rd 2023
                if(nonCCSAsset.FinServ__AssetsAndLiabilitiesType__c == 'Investment - Personal'){
                    if(nonCCSAsset.Sub_Type__c == 'Registered GIC' || nonCCSAsset.Sub_Type__c == 'Non Registered GIC' ) //Non-Registered Term
                    nonCCSAsset.renewOrMaturityDate = nonCCSAsset.Maturity_Date__c;
                }
                else{
                    nonCCSAsset.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                nonCCSAsset.LastModifiedDate =nonCCSAsset.LastModifiedDate.split('T')[0];
                //additional code - Jan 18th 2023
                let date_1 = new Date();
                let date_2 = new Date(nonCCSAsset.LastModifiedDate);
                
                //let numOfDays = 0;

                const days = (date_1, date_2) =>{
                    let difference = date_1.getTime() - date_2.getTime();
                    let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                    return TotalDays;
                }
                if(days(date_1, date_2) >= 730){
                    nonCCSAsset.lastModifiedDateColor = "datatable-red";
                }
                 //additional code - Jan 18th 2023
                this.nonCCSAssetsSubTotal+=nonCCSAsset.FinServ__Amount__c;
                nonCCSAsset.FinServ__Amount__c=(nonCCSAsset.FinServ__Amount__c).toLocaleString('en-US', {
                    style: 'currency',
                    currency: 'USD',
                });
            })
            this.nonCCSAssetsSubTotal=this.nonCCSAssetsSubTotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getCCSManagedLiabilities({AccountId:this.recordId})
        }).then(result=>{
            this.ccsLiabilitiesList = result;
            this.ccsLiabilitiesList.forEach(liability=>{
                //NWS 1.1
                if(liability.FinServ__FinancialAccountRoles__r != null){
                    let liabilityRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(liability.FinServ__FinancialAccountRoles__r));
                    liabilityRolesListOfPrimaryAccount.forEach(liabilityRoleOfPrimaryAccount=>{
                        liability.Primary_Ownership_Percent__c = liabilityRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                liability.sourceColumnColor = "datatable-blue";
                //Jan 23rd 2023
                if(liability.FinServ__FinancialAccountType__c == 'Mortgage' || liability.FinServ__FinancialAccountType__c == 'Loans'){
                    liability.renewOrMaturityDate = liability.FinServ__RenewalDate__c;
                }
                else{
                    liability.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                if(liability.LastModifiedDate != null){
                    liability.LastModifiedDate =liability.LastModifiedDate.split('T')[0];
                    //additional code - Jan 18th 2023
                    let date_1 = new Date();
                    let date_2 = new Date(liability.LastModifiedDate);
                    
                    //let numOfDays = 0;

                    const days = (date_1, date_2) =>{
                        let difference = date_1.getTime() - date_2.getTime();
                        let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                        return TotalDays;
                    }
                    if(days(date_1, date_2) >= 730){
                        liability.lastModifiedDateColor = "datatable-red";
                    }
                     //additional code - Jan 18th 2023
                }   
                this.ccsLiabilitiesSubtotal+=liability.FinServ__Balance__c;
                if(liability.FinServ__Balance__c != null){
                    liability.FinServ__Balance__c=(liability.FinServ__Balance__c).toLocaleString('en-US', {
                        style: 'currency',
                        currency: 'USD',
                    });
                }
            })
            this.ccsLiabilitiesSubtotal=this.ccsLiabilitiesSubtotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getNonCCSManagedLiabilities({AccountId:this.recordId})
        }).then(result=>{
            this.nonCCSLiabilitiesList = result;
            this.nonCCSLiabilitiesList.forEach(nonCCSLiability=>{
                //NWS 1.1
                if(nonCCSLiability.Asset_Liability_Roles__r != null){
                    let liabilityRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(nonCCSLiability.Asset_Liability_Roles__r));
                    liabilityRolesListOfPrimaryAccount.forEach(liabilityRoleOfPrimaryAccount=>{
                        nonCCSLiability.Primary_Ownership_Percent__c = liabilityRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                //Jan 23rd 2023
                if(nonCCSLiability.FinServ__AssetsAndLiabilitiesType__c == 'Lending - Personal' || nonCCSLiability.FinServ__AssetsAndLiabilitiesType__c == 'Lending - Corporate'){
                    if(nonCCSLiability.Sub_Type__c == 'Loan - Corporate' || nonCCSLiability.Sub_Type__c == 'Loan - Retail' || nonCCSLiability.Sub_Type__c == 'Mortgage - Corporate'
                        || nonCCSLiability.Sub_Type__c == 'Mortgage - Retail' || nonCCSLiability.Sub_Type__c == 'Auto loan(s)'){
                            nonCCSLiability.renewOrMaturityDate = nonCCSLiability.Maturity_Date__c;
                        }
                }
                else{
                    nonCCSLiability.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
            nonCCSLiability.LastModifiedDate =nonCCSLiability.LastModifiedDate.split('T')[0];
            //additional code - Jan 18th 2023
            let date_1 = new Date();
            let date_2 = new Date(nonCCSLiability.LastModifiedDate);
            
            //let numOfDays = 0;

            const days = (date_1, date_2) =>{
                let difference = date_1.getTime() - date_2.getTime();
                let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                return TotalDays;
            }
            if(days(date_1, date_2) >= 730){
                nonCCSLiability.lastModifiedDateColor = "datatable-red";
            }
             //additional code - Jan 18th 2023
                this.nonCCSLiabilitiesSubTotal+=nonCCSLiability.FinServ__Amount__c;
                nonCCSLiability.FinServ__Amount__c=(nonCCSLiability.FinServ__Amount__c).toLocaleString('en-US', {
                    style: 'currency',
                    currency: 'USD',
                });
            })
            this.nonCCSLiabilitiesSubTotal=this.nonCCSLiabilitiesSubTotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
        })
            // commented below 2 lines for displaying the Ownership page after saving the Asset/Liabilty instead of the main component
            //this.showNonManagedAssetModal= false;
            //this.showNext = false;

            //added the below line for new UI to display the ownership page
            this.showOwnershipPage = true;
            //added the below line for new UI to display the ownership page
            return this.refresh();
            }
        })
    }

    //new code

    //new code
    handleNext(event){
        this.showNext = true;
        //added the below line for new UI design April 25th 2023
        //this.isNew = true;
    }

    get totalAssets(){
        getTotalAssetsAmount({AccountId:this.recordId})
        .then(result=>{
            this.totAssetsBeforeConvert = result;
            this.totAssets = result.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
        })
        return this.totAssets;
    }

    get totalLiabilities(){
        getTotalLiabilititesAmount({AccountId:this.recordId})
        .then(result=>{
            this.totLiabilitiesBeforeConvert = result;
            this.totLiablities = result.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
        })
        return this.totLiablities
    }

    get totalNetWorth(){
       let totalNetWorth = this.totAssetsBeforeConvert + this.totLiabilitiesBeforeConvert;
        totalNetWorth = totalNetWorth.toLocaleString('en-US', {
            style: 'currency',
            currency: 'USD',
        });

        return totalNetWorth
    }

    //NWS 1.1
    /*handleCCSAssetLiabilityUpdateCancel() {
        this.showNonManagedAssetModal = false;
    }*/

    async handleCCSAssetLiabilityUpdation(event){
        const updatedFields = event.detail.draftValues;
        //get 2 seperate maps for the Amount and Percentage fields

        const notifyChangeIds = updatedFields.map((row) => {
        return { recordId: row.Id };
        });
        try {
        // Pass edited fields to the updateContacts Apex controller
        const result = await updateCCSAssetOrLiabilityOwnershipPercent({ data: updatedFields, accountId: this.recordId });
        this.dispatchEvent(
            new ShowToastEvent({
            title: "Success",
            message: "Success: Asset Or Liability Ownership updated successfully!",
            variant: "success"
            })
        );
        } catch (error) {
            console.log("###Error : " + JSON.stringify(error));
            }
        this.saveDraftValues = [];
        getCCSManagedAssets({AccountId:this.recordId})
        .then(result=>{
            this.ccsassetsList=result;
            this.ccsassetsList.forEach(asset=>{
                //NWS 1.1
                if(asset.FinServ__FinancialAccountRoles__r != null){
                    let assetRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(asset.FinServ__FinancialAccountRoles__r));
                    assetRolesListOfPrimaryAccount.forEach(assetRoleOfPrimaryAccount=>{
                        asset.Primary_Ownership_Percent__c = assetRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                    asset.sourceColumnColor = "datatable-blue";
                   //Jan 23rd 2023
                if(asset.FinServ__FinancialAccountType__c == 'Term Deposit'){
                    asset.renewOrMaturityDate = asset.Maturity_Date__c;
                }
                else{
                    asset.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                if(asset.LastModifiedDate != null){
                    asset.LastModifiedDate =asset.LastModifiedDate.split('T')[0];
                    //additional code - Jan 18th 2023
                    let date_1 = new Date();
                    let date_2 = new Date(asset.LastModifiedDate);
                    
                    //let numOfDays = 0;

                    const days = (date_1, date_2) =>{
                        let difference = date_1.getTime() - date_2.getTime();
                        let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                        return TotalDays;
                    }
                    if(days(date_1, date_2) >= 730){
                        asset.lastModifiedDateColor = "datatable-red";
                    }
                    //additional code - Jan 18th 2023
                }   
                this.ccsAssetsSubtotal+=asset.FinServ__Balance__c;
                if(asset.FinServ__Balance__c != null){
                    asset.FinServ__Balance__c=(asset.FinServ__Balance__c).toLocaleString('en-US', {
                        style: 'currency',
                        currency: 'USD',
                    });
                }
            })
            this.ccsAssetsSubtotal=this.ccsAssetsSubtotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getNonCCSManagedAssets({AccountId:this.recordId})
        }).then(result=>{
            this.nonCCSAssetsList = result;
            this.nonCCSAssetsList.forEach(nonCCSAsset=>{
                //NWS 1.1
                if(nonCCSAsset.Asset_Liability_Roles__r != null){
                    let assetRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(nonCCSAsset.Asset_Liability_Roles__r));
                    assetRolesListOfPrimaryAccount.forEach(assetRoleOfPrimaryAccount=>{
                        nonCCSAsset.Primary_Ownership_Percent__c = assetRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                //Jan 23rd 2023
                if(nonCCSAsset.FinServ__AssetsAndLiabilitiesType__c == 'Investment - Personal'){
                    if(nonCCSAsset.Sub_Type__c == 'Registered GIC' || nonCCSAsset.Sub_Type__c == 'Non Registered GIC' ) //Non-Registered Term
                    nonCCSAsset.renewOrMaturityDate = nonCCSAsset.Maturity_Date__c;
                }
                else{
                    nonCCSAsset.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                nonCCSAsset.LastModifiedDate =nonCCSAsset.LastModifiedDate.split('T')[0];
                //additional code - Jan 18th 2023
                let date_1 = new Date();
                let date_2 = new Date(nonCCSAsset.LastModifiedDate);
                
                //let numOfDays = 0;

                const days = (date_1, date_2) =>{
                    let difference = date_1.getTime() - date_2.getTime();
                    let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                    return TotalDays;
                }
                if(days(date_1, date_2) >= 730){
                    nonCCSAsset.lastModifiedDateColor = "datatable-red";
                }
                 //additional code - Jan 18th 2023
                this.nonCCSAssetsSubTotal+=nonCCSAsset.FinServ__Amount__c;
                nonCCSAsset.FinServ__Amount__c=(nonCCSAsset.FinServ__Amount__c).toLocaleString('en-US', {
                    style: 'currency',
                    currency: 'USD',
                });
            })
            this.nonCCSAssetsSubTotal=this.nonCCSAssetsSubTotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getCCSManagedLiabilities({AccountId:this.recordId})
        }).then(result=>{
            this.ccsLiabilitiesList = result;
            this.ccsLiabilitiesList.forEach(liability=>{
                //NWS 1.1
                if(liability.FinServ__FinancialAccountRoles__r != null){
                    let liabilityRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(liability.FinServ__FinancialAccountRoles__r));
                    liabilityRolesListOfPrimaryAccount.forEach(liabilityRoleOfPrimaryAccount=>{
                        liability.Primary_Ownership_Percent__c = liabilityRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                liability.sourceColumnColor = "datatable-blue";
                //Jan 23rd 2023
                if(liability.FinServ__FinancialAccountType__c == 'Mortgage' || liability.FinServ__FinancialAccountType__c == 'Loans'){
                    liability.renewOrMaturityDate = liability.FinServ__RenewalDate__c;
                }
                else{
                    liability.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                if(liability.LastModifiedDate != null){
                    liability.LastModifiedDate =liability.LastModifiedDate.split('T')[0];
                    //additional code - Jan 18th 2023
                    let date_1 = new Date();
                    let date_2 = new Date(liability.LastModifiedDate);
                    
                    //let numOfDays = 0;

                    const days = (date_1, date_2) =>{
                        let difference = date_1.getTime() - date_2.getTime();
                        let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                        return TotalDays;
                    }
                    if(days(date_1, date_2) >= 730){
                        liability.lastModifiedDateColor = "datatable-red";
                    }
                     //additional code - Jan 18th 2023
                }   
                this.ccsLiabilitiesSubtotal+=liability.FinServ__Balance__c;
                if(liability.FinServ__Balance__c != null){
                    liability.FinServ__Balance__c=(liability.FinServ__Balance__c).toLocaleString('en-US', {
                        style: 'currency',
                        currency: 'USD',
                    });
                }
            })
            this.ccsLiabilitiesSubtotal=this.ccsLiabilitiesSubtotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getNonCCSManagedLiabilities({AccountId:this.recordId})
        }).then(result=>{
            this.nonCCSLiabilitiesList = result;
            this.nonCCSLiabilitiesList.forEach(nonCCSLiability=>{
                //NWS 1.1
                if(nonCCSLiability.Asset_Liability_Roles__r != null){
                    let liabilityRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(nonCCSLiability.Asset_Liability_Roles__r));
                    liabilityRolesListOfPrimaryAccount.forEach(liabilityRoleOfPrimaryAccount=>{
                        nonCCSLiability.Primary_Ownership_Percent__c = liabilityRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                //Jan 23rd 2023
                if(nonCCSLiability.FinServ__AssetsAndLiabilitiesType__c == 'Lending - Personal' || nonCCSLiability.FinServ__AssetsAndLiabilitiesType__c == 'Lending - Corporate'){
                    if(nonCCSLiability.Sub_Type__c == 'Loan - Corporate' || nonCCSLiability.Sub_Type__c == 'Loan - Retail' || nonCCSLiability.Sub_Type__c == 'Mortgage - Corporate'
                        || nonCCSLiability.Sub_Type__c == 'Mortgage - Retail' || nonCCSLiability.Sub_Type__c == 'Auto loan(s)'){
                            nonCCSLiability.renewOrMaturityDate = nonCCSLiability.Maturity_Date__c;
                        }
                }
                else{
                    nonCCSLiability.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
            nonCCSLiability.LastModifiedDate =nonCCSLiability.LastModifiedDate.split('T')[0];
            //additional code - Jan 18th 2023
            let date_1 = new Date();
            let date_2 = new Date(nonCCSLiability.LastModifiedDate);
            
            //let numOfDays = 0;

            const days = (date_1, date_2) =>{
                let difference = date_1.getTime() - date_2.getTime();
                let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                return TotalDays;
            }
            if(days(date_1, date_2) >= 730){
                nonCCSLiability.lastModifiedDateColor = "datatable-red";
            }
             //additional code - Jan 18th 2023
                this.nonCCSLiabilitiesSubTotal+=nonCCSLiability.FinServ__Amount__c;
                nonCCSLiability.FinServ__Amount__c=(nonCCSLiability.FinServ__Amount__c).toLocaleString('en-US', {
                    style: 'currency',
                    currency: 'USD',
                });
            })
            this.nonCCSLiabilitiesSubTotal=this.nonCCSLiabilitiesSubTotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
        })
            // commented below 2 lines for displaying the Ownership page after saving the Asset/Liabilty instead of the main component
            this.showNonManagedAssetModal= false;
            this.showNext = false;

            //added the below line for new UI to display the ownership page
            this.showOwnershipPage = false;
            //added the below line for new UI to display the ownership page
            return this.refresh();

        // Refresh LDS cache and wires
        /*getRecordNotifyChange(notifyChangeIds);

        // Display fresh data in the datatable
        refreshApex(this.contact).then(() => {
            // Clear all draft values in the datatable
            this.draftValues = [];
        });*/
    }
    
    async handleNonCCSAssetLiabilityUpdation(event) {
        const updatedFields = event.detail.draftValues;
        //get 2 seperate maps for the Amount and Percentage fields

        const notifyChangeIds = updatedFields.map((row) => {
        return { recordId: row.Id };
        });
        try {
        // Pass edited fields to the updateContacts Apex controller
        const result = await updateAssetOrLiability({ data: updatedFields, accountId: this.recordId });
        this.dispatchEvent(
            new ShowToastEvent({
            title: "Success",
            message: "Success: Asset Or Liability Ownership updated successfully!",
            variant: "success"
            })
        );
        } catch (error) {
            console.log("###Error : " + JSON.stringify(error));
            }
        this.saveDraftValues = [];
        getCCSManagedAssets({AccountId:this.recordId})
        .then(result=>{
            this.ccsassetsList=result;
            this.ccsassetsList.forEach(asset=>{
                //NWS 1.1
                if(asset.FinServ__FinancialAccountRoles__r != null){
                    let assetRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(asset.FinServ__FinancialAccountRoles__r));
                    assetRolesListOfPrimaryAccount.forEach(assetRoleOfPrimaryAccount=>{
                        asset.Primary_Ownership_Percent__c = assetRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                    asset.sourceColumnColor = "datatable-blue";
                   //Jan 23rd 2023
                if(asset.FinServ__FinancialAccountType__c == 'Term Deposit'){
                    asset.renewOrMaturityDate = asset.Maturity_Date__c;
                }
                else{
                    asset.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                if(asset.LastModifiedDate != null){
                    asset.LastModifiedDate =asset.LastModifiedDate.split('T')[0];
                    //additional code - Jan 18th 2023
                    let date_1 = new Date();
                    let date_2 = new Date(asset.LastModifiedDate);
                    
                    //let numOfDays = 0;

                    const days = (date_1, date_2) =>{
                        let difference = date_1.getTime() - date_2.getTime();
                        let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                        return TotalDays;
                    }
                    if(days(date_1, date_2) >= 730){
                        asset.lastModifiedDateColor = "datatable-red";
                    }
                    //additional code - Jan 18th 2023
                }   
                this.ccsAssetsSubtotal+=asset.FinServ__Balance__c;
                if(asset.FinServ__Balance__c != null){
                    asset.FinServ__Balance__c=(asset.FinServ__Balance__c).toLocaleString('en-US', {
                        style: 'currency',
                        currency: 'USD',
                    });
                }
            })
            this.ccsAssetsSubtotal=this.ccsAssetsSubtotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getNonCCSManagedAssets({AccountId:this.recordId})
        }).then(result=>{
            this.nonCCSAssetsList = result;
            this.nonCCSAssetsList.forEach(nonCCSAsset=>{
                //NWS 1.1
                if(nonCCSAsset.Asset_Liability_Roles__r != null){
                    let assetRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(nonCCSAsset.Asset_Liability_Roles__r));
                    assetRolesListOfPrimaryAccount.forEach(assetRoleOfPrimaryAccount=>{
                        nonCCSAsset.Primary_Ownership_Percent__c = assetRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                //Jan 23rd 2023
                if(nonCCSAsset.FinServ__AssetsAndLiabilitiesType__c == 'Investment - Personal'){
                    if(nonCCSAsset.Sub_Type__c == 'Registered GIC' || nonCCSAsset.Sub_Type__c == 'Non Registered GIC' ) //Non-Registered Term
                    nonCCSAsset.renewOrMaturityDate = nonCCSAsset.Maturity_Date__c;
                }
                else{
                    nonCCSAsset.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                nonCCSAsset.LastModifiedDate =nonCCSAsset.LastModifiedDate.split('T')[0];
                //additional code - Jan 18th 2023
                let date_1 = new Date();
                let date_2 = new Date(nonCCSAsset.LastModifiedDate);
                
                //let numOfDays = 0;

                const days = (date_1, date_2) =>{
                    let difference = date_1.getTime() - date_2.getTime();
                    let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                    return TotalDays;
                }
                if(days(date_1, date_2) >= 730){
                    nonCCSAsset.lastModifiedDateColor = "datatable-red";
                }
                 //additional code - Jan 18th 2023
                this.nonCCSAssetsSubTotal+=nonCCSAsset.FinServ__Amount__c;
                nonCCSAsset.FinServ__Amount__c=(nonCCSAsset.FinServ__Amount__c).toLocaleString('en-US', {
                    style: 'currency',
                    currency: 'USD',
                });
            })
            this.nonCCSAssetsSubTotal=this.nonCCSAssetsSubTotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getCCSManagedLiabilities({AccountId:this.recordId})
        }).then(result=>{
            this.ccsLiabilitiesList = result;
            this.ccsLiabilitiesList.forEach(liability=>{
                //NWS 1.1
                if(liability.FinServ__FinancialAccountRoles__r != null){
                    let liabilityRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(liability.FinServ__FinancialAccountRoles__r));
                    liabilityRolesListOfPrimaryAccount.forEach(liabilityRoleOfPrimaryAccount=>{
                        liability.Primary_Ownership_Percent__c = liabilityRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                liability.sourceColumnColor = "datatable-blue";
                //Jan 23rd 2023
                if(liability.FinServ__FinancialAccountType__c == 'Mortgage' || liability.FinServ__FinancialAccountType__c == 'Loans'){
                    liability.renewOrMaturityDate = liability.FinServ__RenewalDate__c;
                }
                else{
                    liability.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
                if(liability.LastModifiedDate != null){
                    liability.LastModifiedDate =liability.LastModifiedDate.split('T')[0];
                    //additional code - Jan 18th 2023
                    let date_1 = new Date();
                    let date_2 = new Date(liability.LastModifiedDate);
                    
                    //let numOfDays = 0;

                    const days = (date_1, date_2) =>{
                        let difference = date_1.getTime() - date_2.getTime();
                        let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                        return TotalDays;
                    }
                    if(days(date_1, date_2) >= 730){
                        liability.lastModifiedDateColor = "datatable-red";
                    }
                     //additional code - Jan 18th 2023
                }   
                this.ccsLiabilitiesSubtotal+=liability.FinServ__Balance__c;
                if(liability.FinServ__Balance__c != null){
                    liability.FinServ__Balance__c=(liability.FinServ__Balance__c).toLocaleString('en-US', {
                        style: 'currency',
                        currency: 'USD',
                    });
                }
            })
            this.ccsLiabilitiesSubtotal=this.ccsLiabilitiesSubtotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
            return getNonCCSManagedLiabilities({AccountId:this.recordId})
        }).then(result=>{
            this.nonCCSLiabilitiesList = result;
            this.nonCCSLiabilitiesList.forEach(nonCCSLiability=>{
                //NWS 1.1
                if(nonCCSLiability.Asset_Liability_Roles__r != null){
                    let liabilityRolesListOfPrimaryAccount = JSON.parse(JSON.stringify(nonCCSLiability.Asset_Liability_Roles__r));
                    liabilityRolesListOfPrimaryAccount.forEach(liabilityRoleOfPrimaryAccount=>{
                        nonCCSLiability.Primary_Ownership_Percent__c = liabilityRoleOfPrimaryAccount.Ownership_Percent__c + '%';
                        //lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                }
                //NWS 1.1
                //Jan 23rd 2023
                if(nonCCSLiability.FinServ__AssetsAndLiabilitiesType__c == 'Lending - Personal' || nonCCSLiability.FinServ__AssetsAndLiabilitiesType__c == 'Lending - Corporate'){
                    if(nonCCSLiability.Sub_Type__c == 'Loan - Corporate' || nonCCSLiability.Sub_Type__c == 'Loan - Retail' || nonCCSLiability.Sub_Type__c == 'Mortgage - Corporate'
                        || nonCCSLiability.Sub_Type__c == 'Mortgage - Retail' || nonCCSLiability.Sub_Type__c == 'Auto loan(s)'){
                            nonCCSLiability.renewOrMaturityDate = nonCCSLiability.Maturity_Date__c;
                        }
                }
                else{
                    nonCCSLiability.renewOrMaturityDate = '';
                }
            //Jan 23rd 2023
            nonCCSLiability.LastModifiedDate =nonCCSLiability.LastModifiedDate.split('T')[0];
            //additional code - Jan 18th 2023
            let date_1 = new Date();
            let date_2 = new Date(nonCCSLiability.LastModifiedDate);
            
            //let numOfDays = 0;

            const days = (date_1, date_2) =>{
                let difference = date_1.getTime() - date_2.getTime();
                let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
                return TotalDays;
            }
            if(days(date_1, date_2) >= 730){
                nonCCSLiability.lastModifiedDateColor = "datatable-red";
            }
             //additional code - Jan 18th 2023
                this.nonCCSLiabilitiesSubTotal+=nonCCSLiability.FinServ__Amount__c;
                nonCCSLiability.FinServ__Amount__c=(nonCCSLiability.FinServ__Amount__c).toLocaleString('en-US', {
                    style: 'currency',
                    currency: 'USD',
                });
            })
            this.nonCCSLiabilitiesSubTotal=this.nonCCSLiabilitiesSubTotal.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
            });
        })
            // commented below 2 lines for displaying the Ownership page after saving the Asset/Liabilty instead of the main component
            this.showNonManagedAssetModal= false;
            this.showNext = false;

            //added the below line for new UI to display the ownership page
            this.showOwnershipPage = false;
            //added the below line for new UI to display the ownership page
            return this.refresh();

        // Refresh LDS cache and wires
        /*getRecordNotifyChange(notifyChangeIds);

        // Display fresh data in the datatable
        refreshApex(this.contact).then(() => {
            // Clear all draft values in the datatable
            this.draftValues = [];
        });*/
        
    }

    //NWS 1.1

    
}