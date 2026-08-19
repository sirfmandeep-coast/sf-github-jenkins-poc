import { LightningElement, api, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from 'lightning/actions';
import BMB_URL_FIELD from "@salesforce/schema/Review__c.BMB_URL__c";
import BMB_ID_FIELD from "@salesforce/schema/Review__c.SourceSystemId__c";

export default class OpenBMBRecord extends LightningElement {

    @api destinationUrl;
    @api recordId;

    @wire(getRecord, { recordId: "$recordId", fields: [BMB_URL_FIELD, BMB_ID_FIELD] })
    wiredRecord ({ data, error }) {
        if (data) {
            const form = document.createElement('form');                 
            form.method = 'POST'
            form.action = data.fields.BMB_URL__c.value + '/salesforce/OpenBMB';
            form.target = '_blank'
            const BMBId = document.createElement('input');
            BMBId.type = 'hidden';
            BMBId.name = 'bmbId';
            BMBId.value = data.fields.SourceSystemId__c.value;
            form.appendChild(BMBId);
            document.body.appendChild(form);                    
            form.submit();

            this.dispatchEvent(new CloseActionScreenEvent());
        }
        else  {
           console.log (error);
        }           
    }

}