import { LightningElement,api } from 'lwc';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';
export default class CcsRedirectToUrl extends LightningElement {

    @api destinationUrl;
    @api payloadReceivedFromFlow;
    payload = {};

    handleRedirect() {
                            try {
                                    this.payload = JSON.parse(this.payloadReceivedFromFlow); // Parse JSON from Flow
                                    console.log('Success');

                                } catch (error) {
                                    console.error('Error parsing JSON:', error);
                                }
                            console.warn(
                                        this.payload
                            );
                            if (!this.destinationUrl) {
                                        console.error('destinationUrl is undefined!');
                                        return;
                                    }
  
                            const form = document.createElement('form');
                            form.method = 'POST'
                            form.action = this.destinationUrl + '/salesforce/CreateBMB';
                            form.target = '_blank'
                            
                            if((this.payload.CustomerId)){
                                const CustomerId = document.createElement('input');
                                CustomerId.type = 'hidden';
                                CustomerId.name = 'customerId';
                                CustomerId.value = this.payload.CustomerId;
                                form.appendChild(CustomerId);
                                
                            }   
                             if(this.payload.BusinessMembershipId){
                                const BusinessMembershipId = document.createElement('input');
                                BusinessMembershipId.type = 'hidden';
                                BusinessMembershipId.name = 'businessMembershipId';
                                BusinessMembershipId.value = this.payload.BusinessMembershipId;
                                form.appendChild(BusinessMembershipId);
                                
                            }    
                            if(this.payload.BusinessProfileId){
                                const BusinessProfileId = document.createElement('input');
                                BusinessProfileId.type = 'hidden';
                                BusinessProfileId.name = 'businessProfileId';
                                BusinessProfileId.value = this.payload.BusinessProfileId;
                                form.appendChild(BusinessProfileId);
                                
                            }

                            if(this.payload.BMBID){
                                const BMBID = document.createElement('input');
                                BMBID.type = 'hidden';
                                BMBID.name = 'bmbId';
                                BMBID.value = this.payload.BMBID;
                                form.appendChild(BMBID);
                                
                            }
                            
                            const email = document.createElement('input');
                            email.type = 'hidden';
                            email.name = 'email';
                            email.value = '';
                            form.appendChild(email);
                            
                            document.body.appendChild(form);
                           // this event will inform the flow that the execution can be finished now and screen closes
                            const finishEvent = new FlowNavigationFinishEvent();
                            this.dispatchEvent(finishEvent);
                            form.submit();             
                        }
}