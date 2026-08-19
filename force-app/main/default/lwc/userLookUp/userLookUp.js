import lookUp from '@salesforce/apex/CustomLookupController.search';
import { api, LightningElement, track, wire } from 'lwc';

export default class UserLookUp extends LightningElement {
    @api objName;
    @api iconName;
    @api filter = '';
    @api searchPlaceholder='Search';
    @api defaultUserId = '';
    @api defaultUserFullName ='';
    @api selectedName;
    @track records;
    @api isValueSelected;
    @track blurTimeout;
    searchTerm;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    
    connectedCallback(){
        if (this.defaultUserId && this.defaultUserFullName){
            let selectedId = this.defaultUserId;
            let selectedName = this.defaultUserFullName;
            //const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
            //this.dispatchEvent(valueSelectedEvent);
            this.isValueSelected = true;
            this.selectedName = selectedName;
            if(this.blurTimeout) {
                clearTimeout(this.blurTimeout);
            }
            this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
        }
    }
    
    @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName', filter : '$filter'})
    wiredRecords({ error, data }) {
        if (data) {
            this.error = undefined;
            this.records = data;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }
    handleClick() {
        this.searchTerm = undefined;
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() {
        this.searchTerm = '';
        this.isValueSelected = false;
        const valueRemoved = new CustomEvent('lookupremoved', {detail:  'removed' });
        this.dispatchEvent(valueRemoved);
    }

    onChange(event) {
        this.searchTerm = event.target.value;
    }
}