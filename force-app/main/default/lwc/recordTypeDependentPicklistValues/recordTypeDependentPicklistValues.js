import { LightningElement, wire, api, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class RecordTypeDependentPicklistValues extends LightningElement {

    @api controllingField;
    @api dependentField;
    @api objectName;
    @api controllingFieldValue;
    @api dependentFieldValue;
    @api isControllingFieldRequired;
    @api isDependentFieldRequired;
    @api recordTypeId;

  
    @api validate() {
        if( 
            (!this.isControllingFieldRequired
                || ( this.isControllingFieldRequired && this.controllingFieldValue && this.controllingFieldValue.length > 0 ))
            &&
            (!this.isDependentFieldRequired
                || ( this.isDependentFieldRequired && this.dependentFieldValue && this.dependentFieldValue.length > 0 ))
        )   
        {
            return { isValid: true };
        } else {
            return {
                isValid: false,
                errorMessage: this.errorMessage
             };
         }
    }


    handleControllingPicklistChange(event) {
        this.controllingFieldValue = event.detail.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('controllingFieldValue',  event.target.value));
    }

    handleDependentPicklistChange(event) {
        this.dependentFieldValue = event.detail.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('dependentFieldValue',  event.target.value));
    }

}