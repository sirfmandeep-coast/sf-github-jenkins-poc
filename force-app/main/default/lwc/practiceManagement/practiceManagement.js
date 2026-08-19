import { LightningElement, wire, track, api } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import ACCOUNT_CLASSIFICATION_FIELD from '@salesforce/schema/Account.Classification__c';
import TASK_INTERACTION_TYPE from '@salesforce/schema/Task.Interaction_Type__c';
import TASK_LINE_OF_BUSINESS from '@salesforce/schema/Task.Line_Of_Business__c';
import TASK_TOPIC from '@salesforce/schema/Task.Topic__c';
import TASK_SUBTOPIC from '@salesforce/schema/Task.Subtopic__c';
import USER_FULL_NAME from '@salesforce/schema/User.Name';
import Id from "@salesforce/user/Id";
import getAccounts from '@salesforce/apex/PracticeManagementController.getAccounts';
import updateAccounts from '@salesforce/apex/PracticeManagementController.updateAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import lookUp from '@salesforce/apex/CustomLookupController.search';

const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Delete', name: 'delete' },
];

const columns = [
    { label: 'Name', fieldName: 'accountUrl', type: 'url', typeAttributes: {label: { fieldName: 'name'  }, target: '_blank'}},
    { label: 'Lastname', fieldName: 'lastName', sortable: 'true'},
    { label: 'Classification', fieldName: 'classification'},
    { label: 'Open Opportunity Amount', fieldName: 'opportunityListUrl', type: 'url', typeAttributes: {label: { fieldName: 'openOpportunityAmount' }, target: '_blank'}},
    { label: 'Interaction Status', fieldName: 'interactionStatus' }, 
    { label: 'Next Interaction', fieldName: 'nextInteractionDue', sortable: 'true'},
    { label: 'Review Status', fieldName: 'reviewStatus' },
    { label: 'Next Review', fieldName: 'nextReviewDue' , sortable: 'true'},
    { label: 'Birthday', cellAttributes:{iconName: {fieldName: 'birthdayImage'}}},
    { type: 'button-icon', typeAttributes:{iconName: 'utility:email',name: 'email', alternativeText: 'Send Email',}, fixedWidth: 40},
    { type: 'button-icon', typeAttributes:{iconName: 'utility:call',name: 'call', alternativeText: 'Log Interaction',}, fixedWidth: 40},
    { type: 'button-icon', typeAttributes:{iconName: 'utility:opportunity',name: 'opportunity', alternativeText: 'Create Opportunity',}, fixedWidth: 40},
    { type: 'button-icon', typeAttributes:{iconName: 'utility:lead',name: 'lead', alternativeText: 'Create Referral',}, fixedWidth: 40},
    { type: 'button-icon', typeAttributes:{iconName: 'utility:service_appointment',name: 'bookAppointment', alternativeText: 'Book Appointment',}, fixedWidth: 40},
    { type: 'button-icon', typeAttributes:{iconName: 'utility:record_update',name: 'changeClassification', alternativeText: 'Change Classification',}, fixedWidth: 40}
    /*{
        type: 'action',
        typeAttributes: { rowActions: actions },
    },*/
];


export default class PracticeManagement extends NavigationMixin (LightningElement) {
    classes = [];
    eligibleClasses = [];
    interactionStatus = [ { label: 'All', value: 'All' }, { label: 'Completed', value: 'Completed' }, { label: 'Overdue', value: 'Overdue' } ];
    reviewStatus = [ { label: 'All', value: 'All' }, { label: 'Completed', value: 'Completed' }, { label: 'Overdue', value: 'Overdue' } ];
    households = [{ label: 'All', value: 'All' }, { label: 'Household Only', value: 'householdOnly' }];
    wiredResults;
    accountData = [];
    columns = columns;
    selectedUserId = Id;
    runningUserId = Id;
    userFullName;
    classSelection = 'All';
    interactionStatusSelection = 'All';
    reviewStatusSelection = 'All';
    householdFlagSelection = '';
    selectedRecords=[];
    selectedRows=[];
    dataErrors = {};
    pageSizeOptions = [50, 100, 200];
    totalRecords = 0; 
    pageSize = 50; 
    totalPages;
    pageNumber = 1;    
    recordsToDisplay = []; 
    showLogInteractionModal = false;
    interactionFlowInputVariables = [];
    showUpdateClassModal = false;
    classSelectionForMassUpdate;
    showSpinner = false;
    showAppointmentFlowModal = false;
    appointmentFlowInputVariables = [];
    showOpportunityFlowModal = false;
    opportunityFlowInputVariables = [];
    showReferralFlowModal = false;
    referralFlowInputVariables = [];
    showChangeAccountClassificationFlowModal = false;
    changeAccountClassificationFlowInputVariables = [];
    sortBy;
    @track sortDirection;
    @track defaultSortDirection = 'asc';

    /*
    
    searchAccounts () {
        getAccounts({userId: this.selectedUserId, classification: this.classSelection, interactionStatus: this.interactionSelection, houseHoldFlag: this.householdFlagSelection,})
        .then(result =>{
            let data =  JSON.parse(JSON.stringify(result));
            data.forEach((record, index)=>{
                let opportunityAmounts = 0.0; 
                if (record.Opportunities)
                {
                    record.Opportunities.forEach(element => {
                        if (element.Amount) {
                            opportunityAmounts = opportunityAmounts + element.Amount;
                        }     
                    });
                    record.openOpportunityAmount = opportunityAmounts;
                    record.opportunityListUrl = '/lightning/r/Account/' + record.Id + '/related/Opportunities/view';
                }
                if (index % 2 == 0)
                {record.canSelect = true;}
                else
                {record.canSelect = false;}
            })
            this.accountData = [...data];
            this.totalRecords = data.length; // update total records count                 
            this.pageSize = this.pageSizeOptions[2]; //set pageSize with default value as first option
            setTimeout(() =>
                this.template.querySelector('[name="pageSize"]').selectedIndex = 2
            );
            this.paginationHelper();
        }).catch(error=>{
            console.log('ERROR OCCURED: ', error);
        });
    }
    */

    @wire( getAccounts, {userId: '$selectedUserId', classification: '$classSelection', interactionStatus: '$interactionStatusSelection', reviewStatus: '$reviewStatusSelection', houseHoldFlag: '$householdFlagSelection', runningUserId: '$runningUserId'})
    //@wire( getAccounts, {userId: '$selectedUserId', classification: '', interactionStatus: '', houseHoldFlag: ''})
    wiredAccounts (value)
    {   
        this.wiredResults = value;
        const { data, error } = value;
        if (data){
            this.showSpinner = false;
            this.selectedRows = [];
            this.dataErrors = [];
            let myData =  JSON.parse(JSON.stringify(data));
            /*
            myData.forEach((record, index)=>{
                
                record.opportunityListUrl = '/lightning/r/Account/' + record.Id + '/related/Opportunities/view';
            
                if (index % 2 == 0)
                {record.canSelect = true;}
                else
                {record.canSelect = false;}
            })*/
            this.accountData = [...myData];
            this.totalRecords = myData.length; // update total records count
            if (this.sortDirection && this.sortBy)
            {
                if (this.sortBy === 'nextInteractionDue' || this.sortBy === 'nextReviewDue'){
                    this.sortNextDueData(this.sortBy, this.sortDirection);
                }
                else {
                    this.sortData(this.sortBy, this.sortDirection);
                }
            }
            else
            {
                this.paginationHelper();
            }
            
        }
        else if (error)  {
            this.showSpinner = false;
            console.log(error);
        }
    }
    

    @wire(getRecord, { recordId: Id, fields: [USER_FULL_NAME] })
    userDetails({ error, data }) {
        if (error) {
            console.log(error);
        } else if (data) {
            if (data.fields.Name.value != null) {
                this.userFullName = data.fields.Name.value;
                //this.isValueSelected = true;
                //this.selectedName = this.userFullName;
                //if(this.blurTimeout) {
                //    clearTimeout(this.blurTimeout);
                //}
                //this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';    
            }
        }
    }

    @wire(getPicklistValues, {recordTypeId: '012000000000000AAA', fieldApiName: ACCOUNT_CLASSIFICATION_FIELD})
    getClasses({ data, error }) {
        if (error) {
            console.log(error);
        } else if (data) {

            this.eligibleClasses = [...data.values];
            this.classes = [{ label: 'All', value: 'All' }, {label: 'Unclassified', value: 'Unclassified'}, ...data.values];

            this.eligibleClasses = this.eligibleClasses.filter((option) => (option.value != 'AS' && option.value != 'AF'));
        }
    }

    @wire(getPicklistValues, {recordTypeId: '012000000000000AAA', fieldApiName: TASK_INTERACTION_TYPE})
    getInteractionTypes({ data, error }) {
        if (error) {
            console.log(error);
        } else if (data) {
            this.interactionTypes = [...data.values];
        }
    }
    
    handleChangeInteractionStatus(event){
        this.interactionStatusSelection = event.detail.value;
        //this.searchAccounts();
        //return refreshApex (this.wiredResults);
    }

    handleChangeReviewStatus(event){
        this.reviewStatusSelection = event.detail.value;
        //this.searchAccounts();
        //return refreshApex (this.wiredResults);
    }

    handleChangeClass(event){
        this.classSelection = event.detail.value;
        //this.searchAccounts();
            setTimeout(() =>
                refreshApex (this.wiredResults)
            );
        
    }

    handleChangeHousehold(event){
        this.householdFlagSelection = event.detail.value;
        //this.searchAccounts();
        //return refreshApex (this.wiredResults);
    }

    handleUserSelection(event){
        
        if(event.detail!=undefined || event.detail!=null){
            //console.log ('User selection: ', event.detail);
            if(event.detail =='removed'){
                this.selectedUserId = undefined;
                this.accountData = [];
                this.dataErrors = [];
                this.pageSize = this.pageSizeOptions[0];
            }
            else{
                this.selectedUserId=event.detail;
                return refreshApex (this.wiredResults);
                //this.searchAccounts();
                
            }
        }
    }
    
    handleRowSelection(event) {
        switch (event.detail.config.action) {
            case 'selectAllRows':
                this.selectedRows = this.recordsToDisplay.filter(row => row.canSelect == true).map(row => {
                    return row.id;    
                });
            
                this.recordsToDisplay.filter(row => row.canSelect != true).map(row => {
                    this.handleAddDataError();   
                });
                event.detail.selectedRows = this.recordsToDisplay.filter(row => row.canSelect == true);
                    //this.selectedRows.push(event.detail.selectedRows[i]);
                    //this.selectedRecords.push(event.detail.selectedRows[i]);
                
                break;
            case 'deselectAllRows':
                this.selectedRows = [];
                this.dataErrors = [];
                
                break;
            case 'rowSelect':
                let selectedItemsSet = new Set(this.selectedRows);            
                event.detail.selectedRows.filter(row => row.canSelect == true).map(row => {    
                    if (!selectedItemsSet.has(row.id)) {
                        selectedItemsSet.add(row.id);
                    }
            
                });
            
                this.selectedRows = [...selectedItemsSet];

                event.detail.selectedRows.filter(row => row.canSelect != true).map(row => {
                    this.handleAddDataError();   
                });
                event.detail.selectedRows = event.detail.selectedRows.filter(row => row.canSelect == true);
               
                break;
            case 'rowDeselect':  
                       
                let index = this.selectedRows.indexOf(event.detail.config.value);
                if (index !== -1) {
                    this.selectedRows.splice(index, 1);
                }
                console.log (this.selectedRows);
                break;
            default:
                break;
        }
    }

    handleAddDataError(){
        let rowError = {};
        let dataError = {};
        let title = 'Error !';
        let messages = ['You are not part of the right account team to update classification!'];
        this.accountData.forEach(item=>{
            if(item.canSelect == false){
             let fieldNames = ['name'];
             rowError[item.id] =this.triggerError(title,messages,fieldNames);
             dataError['rows'] = rowError;
            }
        });
        this.dataErrors = dataError;           
    }

    triggerError(title,messages,fieldNames) {
        let rowError = {};
        rowError['title'] = title;
        rowError['messages'] = messages;
        rowError['fieldNames'] = fieldNames;
        return rowError;
    }

    /*
    handleRowSelection(event) {
        this.selectedRecords=[];
        this.selectedRows=[];
        console.log (event.detail.selectedRows);
        event.detail.selectedRows.forEach(row=>{
            if(1==0){ //use your condition here
                //the datatable only needs the row id
                this.selectedRows=[...this.selectedRows, row.Id];
                //but to be able to acess the selected records you need to save them in a different variable
                this.selectedRecords.push(row);
                
            }
        });
    }
    
    */
    handleRowAction(event) {
        let actionName = event.detail.action.name;
        let row = event.detail.row;
        switch (actionName) {
            case 'call':
                this.interactionFlowInputVariables = [{ name: 'accountId', type: 'String', value: row.id, }];
                this.showLogInteractionModal = true;               
                break;

            case 'email':   
                
                this[NavigationMixin.GenerateUrl]({
                    type: "standard__quickAction",
                    attributes: {
                        apiName:"Global.SendEmail"
                    },
                    state: {
                        recordId: row.id,
                        //backgroundContext: '/lightning/r/Account/' + this.recordId + '/view',
                        defaultFieldValues:
                            encodeDefaultFieldValues({
                                HtmlBody: "Type in your Content here.",
                                Subject:"Hello from Coast Capital", 
                                RelatedToId: row.id,
                            })
                        }
                    }).then(url => {
                        window.open(url, "_blank");
                    });
                
                /*
                this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/lightning/action/quick/Global.SendEmail?recordId='+ row.id 
                
                    //url: '/lightning/action/quick/NextBestAction__c.NBX_Action?context=RECORD_DETAIL&recordId=0014c000005MbR7AAK&accountId=a0gAu000001YVATIA4&outcomeFlow=Default&isRecommendationAccepted=true&backgroundContext=%2Flightning%2Fr%2FAccount%2F0014c000005MbR7AAK%2Fview'
                }
                }); */    
                break;
            
            case 'bookAppointment':   
                this.appointmentFlowInputVariables = [{ name: 'recordId', type: 'String', value: row.id, }];
                this.showAppointmentFlowModal = true;               
                break;

            case 'opportunity':   
                this.opportunityFlowInputVariables = [{ name: 'accountId', type: 'String', value: row.id, }];
                this.showOpportunityFlowModal = true;               
                break;
            
            case 'lead':   
                this.referralFlowInputVariables = [{ name: 'accountId', type: 'String', value: row.id, }];
                this.showReferralFlowModal = true;               
                break;

            case 'changeClassification':
                this.changeAccountClassificationFlowInputVariables =  [{ name: 'recordId', type: 'String', value: row.id, }];
                this.showChangeAccountClassificationFlowModal = true;
                break;

            default:
        }
    }
    
    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }


    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.selectedRows = [];
        this.paginationHelper();
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.selectedRows = [];
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.selectedRows = [];
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.selectedRows = [];
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.selectedRows = [];
        this.paginationHelper();
    }
    // JS function to handel pagination logic 
    paginationHelper() {
        this.recordsToDisplay = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.accountData[i]);
        }
        if (this.selectedRows.length)
        {
            this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
        }
    }
   
    handleLogInteractionCancel() {
		this.showLogInteractionModal = false;
	}
    
    handleUpdateClass (){
        if (this.selectedRows.length)
        {
            this.showUpdateClassModal = true;
        }
        else
        {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select at least one record!',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    handleUpdateClassCancel (){
        this.showUpdateClassModal = false;
    }

    handleUpdateClassSave (){
        this.showUpdateClassModal = false;
        if (this.classSelectionForMassUpdate && this.selectedRows.length)
        {
            let accountRecords = [];
            this.showSpinner = true;
            this.selectedRows.forEach(item=>{
                let accountRecord = {Id: item, Classification__c: this.classSelectionForMassUpdate, Classification_Change_Reason__c: 'Change of Household - Other', Classification_Change_Reason_Other__c: 'Mass Update Classification'};
                accountRecords.push (accountRecord);
            });
            updateAccounts ({ recordsToUpdate: accountRecords })
            .then((result) => {
                return refreshApex (this.wiredResults);
                //this.searchAccounts();
            })
            .catch((error) => {
                console.log(error);
                let errorMessage;
                if (error.body.message)
                {
                    errorMessage = error.body.message;
                }
                else if (error.body.fieldErrors.length)
                {
                    errorMessage = error.body.fieldErrors[0].message;
                }

                else if (error.body.pageErrors.length)
                {
                    errorMessage = error.body.pageErrors[0].message;
                }
                
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: errorMessage,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });

        }
    }

    handleChangeClassModal(event){
        this.classSelectionForMassUpdate = event.detail.value;
    }

    handleAppointmentFlowStatusChange(event) {
        if (event.detail.status === 'FINISHED'){
            this.showAppointmentFlowModal = false;
        }
    }

    handleAppointmentFlowCancel (event)
    {
        this.showAppointmentFlowModal = false;
    }


    handleOpportunityFlowStatusChange(event) {
        if (event.detail.status === 'FINISHED'){
            this.showOpportunityFlowModal = false;
        }
    }

    handleOpportunityFlowCancel (event)
    {
        this.showOpportunityFlowModal = false;
    }

    handleReferralFlowStatusChange(event) {
        if (event.detail.status === 'FINISHED'){
            this.showReferralFlowModal = false;
        }
    }

    handleReferralFlowCancel (event)
    {
        this.showReferralFlowModal = false;
    }

    handleChangeAccountClassificationFlowStatusChange (event) {
        if (event.detail.status === 'FINISHED'){
            this.showChangeAccountClassificationFlowModal = false;
            return refreshApex (this.wiredResults);
        }
    }

    handleChangeAccountClassificationFlowCancel (event)
    {
        this.showChangeAccountClassificationFlowModal = false;
    }

    handleInteractionFlowStatusChange(event) {
        if (event.detail.status === 'FINISHED'){
            this.showLogInteractionModal = false;
            return refreshApex (this.wiredResults)
        }
    }

    handleInteractionFlowCancel (event)
    {
        this.showLogInteractionModal = false;
    }

    handleSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        if (this.sortBy === 'nextInteractionDue' || this.sortBy === 'nextReviewDue'){
            this.sortNextDueData(this.sortBy, this.sortDirection);
        }
        else {
            this.sortData(this.sortBy, this.sortDirection);
        }
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.accountData));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        console.log (keyValue);
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.accountData = [...parseData];
        this.paginationHelper();
    }    


     sortNextDueData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.accountData));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? Number(keyValue(x).replace(' Days', '')) : ''; // handling null values
            y = keyValue(y) ? Number(keyValue(y).replace(' Days', '')) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.accountData = [...parseData];
        this.paginationHelper();
    }    
}