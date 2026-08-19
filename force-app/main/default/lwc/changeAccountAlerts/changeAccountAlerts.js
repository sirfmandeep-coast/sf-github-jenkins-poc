/*******************************************************************************************************************************************************
*   Company         :   Coast Capital Savings Credit Union
*   Component       :   changeAccountAlerts.
*   Description     :   Javascript/Client-side controller class to get & set data from/into Preferences API and get data from Profile API.
********************************************************************************************************************************************************
*   Author           :  Sudhakar Botta
*   Date Created     :  [2021.NOV.14]
*   History          :  
*   
*   [2021.NOV.14]  sbotta - Initial Version [Created the logic to get the Locale Date value].    
*   [2021.NOV.14]  sbotta - [Created the wire method "getPreferences" to fetch data from Preferences API].
*   [2022.JAN.26]  rcai - [clean up the code]
*   
*   
*   
*                          
********************************************************************************************************************************************************/
import { LightningElement, track, wire, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import uId from '@salesforce/user/Id';
import FEDERATION_IDENTIFIER_FIELD from '@salesforce/schema/User.FederationIdentifier';

import getPreferences from '@salesforce/apex/FinancialAccountsCtrl.getPreferences';
import setPreferences from  '@salesforce/apex/FinancialAccountsCtrl.setPreferences';
import getContactDetails from '@salesforce/apex/FinancialAccountsCtrl.getContactDetails';
import getBankingIdByAccountId from '@salesforce/apex/FinancialAccountsCtrl.getBankingIdByAccountId';
import createIntegrationErrorRecord from '@salesforce/apex/FinancialAccountsCtrl.createIntegrationErrorRecord';
import { deleteDataset } from 'lightning/analyticsWaveApi';
import MailingPostalCode from '@salesforce/schema/Contact.MailingPostalCode';

//const fields = [BANKINGID_FIELD];
export default class changeAccountAlerts extends LightningElement {
    @api recordId;
    @api userId = '';
    allRoles;
    roles;
    refreshRoles;
    //Added this line by siddu to populate the todays locale date on Form received date on UI
    dateFormReceived = new Date(new Date().toLocaleDateString()).toISOString();
    updatedRoles={};
    defaultSize=10;
    disablePre=true;
    disableNext=true;
    currentPage = 0;
    //new code
    @track error;
    alertPreferencesList;
    alertPreferencesListTemp;
    finalList;
    isOptOutAllSelected = false;
    alertPrefListOnOptOutAllSelected;
    changedOnlyFinalResponse;
    changedOnlyFinalResponseList;
    temporaryAlertPref=[];
    @api profileNum;

    //Following variables are used for profile info 
    contactInfoList;
    contactEmailInfo;
    contactPhoneInfo;
    isEmailAvailable = false;
    isPhoneAvailable = false;
    isDeviceAvailable = false;
    isLoadingCompleted = false;

    bothAvailable = false;
    bothNotAvailable = false;
    onlyEmailAvailable = false;
    onlyPhoneAvailabale = false;

    testVariable=false;
    pageValidationError = false;

    pageSize = 2;
    page = 1;
    totalRecountCount = 0; 
    totalPage = 0; 
    listShownOnPage=[];
    startingRecord = 1;
    endingRecord = 0;
    disablePrevButton=true;
    disableNextButton=true;
    errorCount = 0;
    changedAlerts = new Map();
    finalChangedAlerts = [];
    pageError =false;
    errorTitle = 'Please be advised there is something wrong with the component. Please contact your Salesforce Administrator';

    
    @wire(getRecord, {recordId: uId, fields: [FEDERATION_IDENTIFIER_FIELD]}) 
    wireuser({error,data}) {

        if (error) {
            this.showNotification(this.errorTitle, 'Error when getting User Federation Id: ' + error, 'error');
        } else if (data) {
            if (data.fields.FederationIdentifier.value)
            {
                this.userId = data.fields.FederationIdentifier.value;
            }
        }

    }

    connectedCallback(){
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            console.log('---- IN CONNECTED  CALLBACK ----',this.recordId)
            getBankingIdByAccountId ({accountId: this.recordId})
            .then (result =>{
                if (result.Banking_ID__c) {
                    this.profileNum = result.Banking_ID__c;
                    console.log('INSIDE CONSOLE CONNECTED CALL BACK METHOD ::',this.profileNum);
                    return getPreferences({profileNumber: this.profileNum});
                }
                else{
                    console.log('NO BANKING Id');
                    this.showNotification(this.errorTitle, 'Please verify that the Banking ID matches the Profile ID from T24. If no discrepancies exist, please submit an Incident in Service Now with the applicable details.', 'error');
                    this.closeAction();
                }
            })
            .then(result=>{
                if (result) {
                    this.loadPreference(result);
                    return getContactDetails({profileNum: this.profileNum});
                }
            })
            .then(result =>{
                if (result) {
                    this.loadContactInfo(result);
                }
            })
            .catch(error=>{
                this.error = error;
                console.log('ERROR OCCURED ',this.error)
                this.createIntegrationErrorRecord (error.body.message);
                this.showNotification(this.errorTitle, error.body.message.replaceAll('|', ','), 'error');
            });
        }, 0);
        
    }

    // Added this function by Siddu for CPF alerts UI - for checking date must not be future date
    dateValidator(){
        let inputDate = this.template.querySelector(".dateCmp");
        let dateValue = inputDate.value;
        var d1 = new Date(dateValue).toISOString().substring(0,10);
        var today = new Date().toISOString().substring(0,10);
        if(d1 > today){
            inputDate.setCustomValidity("Date value can not be a Future Date");
         }
        else {
             inputDate.setCustomValidity("");
             // new date value to be sent
             this.dateFormReceived = dateValue;
         } 
         inputDate.reportValidity();
        
     }
    
    handlePrev() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            if(this.page===1){
                this.disablePrevButton=true;
            }
            this.displayRecordPerPage(this.page);
            this.disableNextButton=false;
        }
        
    }

    //clicking on next button this method will be called
    handleNext() {
        console.log('NEXT CLICKED::');
        console.log('PAGE',this.page);
        console.log('TOTAL PAGE::',this.totalPage);
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            if(this.page===this.totalPage){
                this.disableNextButton=true;
            }
            this.displayRecordPerPage(this.page);            
            this.disablePrevButton=false;
        } 
                   
    }

    displayRecordPerPage(page){
        console.log('INSIDE DISPLAY RECORDS')
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
            ? this.totalRecountCount : this.endingRecord; 

        this.listShownOnPage = this.alertPreferencesListTemp.alertPreferences.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    } 

    //New logic for the page validation error to make the save button disabled if true otherwise enable the save button.
    handlePageValidationError(event){
        let errorStatus = event.detail.isErrored;
        let altIdentifier = event.detail.alertIdentifier;
        this.changedAlerts.set(altIdentifier,errorStatus);  
        
        this.finalChangedAlerts = [...this.changedAlerts.values()];
        this.pageError = this.finalChangedAlerts.includes(true);
        if(this.pageError == true){
            this.pageValidationError = true;
        }
        else{
            this.pageValidationError = false;
        }
            
    }
    
    handleUpdate(event) {
        let updatedPrefList = event.detail;
        let tempAlertPrefList = JSON.parse(JSON.stringify(this.alertPreferencesListTemp));
        let changedValueFinalResp =JSON.parse(JSON.stringify(this.alertPreferencesListTemp));
        let accountsOnlyChanged;
        let alertPreferences ;
        this.pageValidationError = false;
        if(updatedPrefList.label=="threshold"){
            Array.from(tempAlertPrefList.alertPreferences).forEach(element => {
                if(element.accountNumber===updatedPrefList.accountNumber){
                    for(let i=0;i<element.alert.length;i++){
                        if(i==updatedPrefList.outerIndex){
                            console.log('INSIDE THRESHOLD')
                            element.alert[i].threshold=updatedPrefList.threshold;
                        }
                    }
                }
            });
            accountsOnlyChanged = tempAlertPrefList;
            alertPreferences =Array.from(accountsOnlyChanged.alertPreferences).filter(element => element.accountNumber===updatedPrefList.accountNumber);
        }
        if(updatedPrefList.label=="limitAmount"){
            Array.from(tempAlertPrefList.alertPreferences).forEach(element => {
                if(element.accountNumber===updatedPrefList.accountNumber){
                    element.limitAmount=updatedPrefList.limitAmount;
                }
            });
            accountsOnlyChanged = tempAlertPrefList;
            alertPreferences =Array.from(accountsOnlyChanged.alertPreferences).filter(element => element.accountNumber===updatedPrefList.accountNumber);
        }
        if(updatedPrefList.label=="toggle"){
            console.log('INSIDE TOGGLE')
            Array.from(tempAlertPrefList.alertPreferences).forEach(element => {
                if(element.accountNumber===updatedPrefList.accountNumber){
                    for(let i=0;i<element.alert.length;i++){
                        if(i==updatedPrefList.outerIndex){
                            element.alert[i].preferences.forEach(eachPref=>{
                                if(eachPref.deliveryChannel == updatedPrefList.prefName){
                                    console.log('TOGGLE RESULT ::',updatedPrefList.toggleButtonChecked)
                                    eachPref.optIn=updatedPrefList.toggleButtonChecked;
                                }
                            })
                        }
                    }
                }
            });
            accountsOnlyChanged = tempAlertPrefList;
            alertPreferences =Array.from(accountsOnlyChanged.alertPreferences).filter(element => element.accountNumber===updatedPrefList.accountNumber);
        }

        let tempXYZ =JSON.parse(JSON.stringify(this.temporaryAlertPref))
        if(tempXYZ!='undefined' && tempXYZ.length>0){
            tempXYZ.forEach((each,index)=>{
                if(each.accountNumber==alertPreferences[0].accountNumber){
                    this.temporaryAlertPref.splice(index, 1);
                }
            })
            this.temporaryAlertPref.push(...alertPreferences)
        }else{
            this.temporaryAlertPref.push(...alertPreferences)
        }
        this.changedOnlyFinalResponse.alertPreferences= this.temporaryAlertPref;
        this.changedOnlyFinalResponse ={...this.changedOnlyFinalResponse} ;
        this.alertPreferencesListTemp = {...tempAlertPrefList}; 

        //optional validation to check anything got changed on UI or not from original payload values
        if(JSON.stringify(this.changedOnlyFinalResponse) == JSON.stringify(this.alertPreferencesListTemp)){
            
        }
    }

    loadPreference(result)
    {
        this.alertPreferencesList = result;
        for(let i=0;i<this.alertPreferencesList.alertPreferences.length;i++){
            for (let j=0;j<this.alertPreferencesList.alertPreferences[i].alert.length;j++){
                this.alertPreferencesList.alertPreferences[i].alert[j].preferences.sort((a, b) => (a.deliveryChannel.localeCompare(b.deliveryChannel) > 0) ? 1 : -1);
            }
        }     
        this.alertPreferencesListTemp = this.alertPreferencesList;
        this.alertPrefListOnOptOutAllSelected = this.alertPreferencesList;
        this.changedOnlyFinalResponse =JSON.parse(JSON.stringify(this.alertPreferencesList));
        this.changedOnlyFinalResponse.alertPreferences=[];

            //Pagination
        this.totalRecountCount = this.alertPreferencesListTemp.alertPreferences.length; //here it is 23
        console.log('TOTAL RECORD COUNT',this.totalRecountCount);
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        console.log('TOTAL PAGE',this.totalPage);
        if (this.totalPage > 1)
        {
            this.disableNextButton = false;
        }
        this.listShownOnPage = this.alertPreferencesListTemp.alertPreferences.slice(0,this.pageSize);
        console.log('SHOW LIST::-',this.listShownOnPage);
    }

    loadContactInfo (result)
    {
        this.contactInfoList = result;  
        console.log('INSIDE SECOND METHOD::',JSON.stringify(this.contactInfoList))
        let conList = JSON.parse(JSON.stringify(this.contactInfoList));                                                                     
        //logic to see whether the profile api has email address in contactEmails, if so make the boolean as true
        if (conList.contactEmails)
        {
            Array.from(conList.contactEmails).forEach(element => {
                console.log('email address===='+element.emailAddress);
                if(element.emailAddress!==''){
                    this.isEmailAvailable = true;
                }
            });
        }
        //logic to see whether the profile api has phone number in contactPhones, if so make the boolean as true
        if (conList.contactPhones)
        {
            Array.from(conList.contactPhones).forEach(element => {
                console.log('Phone number===='+element.phoneNumber);
                if(element.phoneNumber!==''){
                    this.isPhoneAvailable = false;
                }
            });
        }
        if (conList.deviceInfo) 
        {
            Array.from(conList.deviceInfo).forEach(element => {
                console.log('Device Info===='+element.pushToken);
                if(element.pushToken!==''){
                    this.isDeviceAvailable = false;
                }
            });
        }
        this.testVariable=true;
        this.pageValidationError = true;
        this.isLoadingCompleted = true;
    }

    createIntegrationErrorRecord (message) {
        var errorCode = '';
        var errorMessage = '';
        var methodName = '';
        var mArray = message.split('|'); 
        for (var i = 0; i < mArray.length ; i++) {
            if (mArray[i].includes('Function'))
            {
                methodName = mArray[i].trim();
            } 
            else if (mArray[i].includes('StatusCode'))
            {
                errorCode = mArray[i].trim();
            }
            else if (mArray[i].includes('Message'))
            {
                errorMessage = mArray[i].trim();
            }
        }
        console.log('Error Code ', errorCode);
        console.log('Error Message ', errorMessage);
        
        createIntegrationErrorRecord ({
            errorMessage: errorMessage,
            httpcode : errorCode,
            function: methodName
        }).then()
        .catch(error => { console.log('ERROR OCCURED ', error)});
    }

    handleSavePrefence() {
    //need to the setalertpref 
        if(this.isOptOutAllSelected == true) {
            console.log('All toggle off',JSON.stringify(this.alertPrefListOnOptOutAllSelected));
            console.log('userId ', this.userId);
            setPreferences({
                changedPreferences: JSON.stringify(this.alertPrefListOnOptOutAllSelected),
                profileNum:this.profileNum,
                formDate: this.dateFormReceived,
                agentId: this.userId
            })
            .then(result => {
                if (result) {
                //refreshApex(this.refreshRoles);
                //this.template.querySelector('c-role-alert-change').updateForm();
                    this.showNotification('Success', 'The Alerts are updated successfully.', 'success');
                    this.closeAction();
                }
            })
            .catch(error => {
                this.createIntegrationErrorRecord (error.body.message);
                this.showNotification(this.errorTitle, error.body.message.replaceAll('|', ','), 'error');
            });
        }
        else {
            if(JSON.stringify(this.alertPreferencesList) == JSON.stringify(this.alertPreferencesListTemp)){
                this.pageValidationError =true;
                this.showNotification('Warning', 'No Changes are made from Original Data', 'warning');
            }
            else{
                console.log('Optoutall is false',JSON.stringify(this.changedOnlyFinalResponse));
                console.log('userId ', this.userId);
                console.log('formDate' + this.dateFormReceived);
                setPreferences({
                changedPreferences: JSON.stringify(this.changedOnlyFinalResponse),
                profileNum:this.profileNum,
                formDate: this.dateFormReceived,
                agentId: this.userId
                })
                .then(result => {
                //refreshApex(this.refreshRoles);
                //this.template.querySelector('c-role-alert-change').updateForm();
                    if (result) {
                        this.showNotification('Success', 'The Alerts are updated successfully.', 'success');
                        this.closeAction();
                    }
                })
                .catch(error => {
                    this.createIntegrationErrorRecord (error.body.message);
                    this.showNotification(this.errorTitle, error.body.message.replaceAll('|', ','), 'error');
                });
            }
        }
    }

    optOutAll(event){
        this.isOptOutAllSelected = event.target.checked;
        let tempAlertPrefList = JSON.parse(JSON.stringify(this.alertPreferencesList));
        if(this.isOptOutAllSelected == true) {
            Array.from(tempAlertPrefList.alertPreferences).forEach(element => {
                for(let i=0;i<element.alert.length;i++) {
                    element.alert[i].preferences.forEach(eachPref=> {
                        if (eachPref.deliveryChannel == "EMAIL"){
                            eachPref.optIn = false;
                        }
                        
                    })
                }
            });
            this.alertPrefListOnOptOutAllSelected = {...tempAlertPrefList};
            this.pageValidationError = false;
        }
        if(this.isOptOutAllSelected == false){
            this.alertPreferencesListTemp = JSON.parse(JSON.stringify(this.alertPreferencesList));
        }

    }

    showNotification(title, message, variant) {
        var mode;
        if (variant == 'error')
        {
            mode = 'sticky';
        }
        else
        {
            mode = 'dismissible';
        }
        const evt = new ShowToastEvent({
            title: title,
            mode: mode,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    closeAction(){ 
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}