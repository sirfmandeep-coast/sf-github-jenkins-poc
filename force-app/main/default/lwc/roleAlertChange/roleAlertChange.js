/*******************************************************************************************************************************************************
*   Company         :   Coast Capital Savings Credit Union
*   Component       :   roleAlertChange.
*   Description     :   Javascript/Client-side controller class to display data from Parent component changeAccountAlerts on UI.
********************************************************************************************************************************************************
*   Author           :  Sudhakar Botta
*   Date Created     :  [2021.NOV.14]
*   History          :  
*       
*   [2021.NOV.14]  sbotta - Initial Version [Created the logic to handle changes from template].
*   
*   
*   
*   
*   [2021.NOV.14]  sbotta - Logic for threshold field validations with limit amount and withot limit amount.      
*   [2022.JAN.10]  Rong Bin - Updated alert type name from CreditRemainingAlert to CreditRemaining
                        - Cast type to Number to do numeric comparsion in handleChanges function     
    [2022.JAN.21]  Rong Bin - Updated alert type name from CreditRemaining to CreditRemainingAlert
********************************************************************************************************************************************************/
import { LightningElement, track, wire, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';

export default class roleAlertChange extends LightningElement {
    @api recordId;
    @api preflist;
    @track preflistClone;
    role;
    channel;
    threshold;
    isDisabled= false;
    //for Profile api 
    @api isemailavailable;
    @api isphoneavailable;
    @api isdeviceavailable;

    altIdentity;
    
	connectedCallback() {
		this.preflistClone = JSON.parse(JSON.stringify(this.preflist));
        for(let i=0;i<this.preflistClone.alert.length;i++){
            this.preflistClone.alert[i].alertIdentifier = this.preflistClone.accountNumber + 'Alert'+i;
            // Change here for CreditRemainingAlert to RemainingCreditAlert
            if(this.preflistClone.alert[i].type=="CreditRemainingAlert"){ 
				this.preflistClone.alert[i].showOdpLimit=true;
			}else{
				this.preflistClone.alert[i].showOdpLimit=false;
			}
            //Logic begin for Prefrences toggle using profile api
            //For each alert preference check the conditions from parent for 3 var and in the pref list add a dynamic field showToggle
            /*for(let prefIndex=0;prefIndex<this.preflistClone.alert[i].preferences.length;prefIndex++){
                if(this.isemailavailable == false){
                    if(this.preflistClone.alert[i].preferences[prefIndex].deliveryChannel == "Email"){
                        this.preflistClone.alert[i].preferences[prefIndex].showEmailToggle = false;
                    }
                } else{
                    if(this.preflistClone.alert[i].preferences[prefIndex].deliveryChannel == "Email"){
                        this.preflistClone.alert[i].preferences[prefIndex].showEmailToggle = true;
                    }
                }*/
                
                //this.preflistClone.alert[i].preferences.sort((a, b) => (a.deliveryChannel.localeCompare(b.deliveryChannel) > 0) ? 1 : -1);
                for(let prefIndex=0;prefIndex<this.preflistClone.alert[i].preferences.length;prefIndex++){
                //console.log('Delivery Channel is====>>>>'+this.preflistClone.alert[i].preferences[prefIndex].deliveryChannel);
                
                if(this.preflistClone.alert[i].preferences[prefIndex].deliveryChannel == "EMAIL"){
                    this.preflistClone.alert[i].preferences[prefIndex].isEmailType = true;
                    this.preflistClone.alert[i].preferences[prefIndex].isPhoneType = false;
                    this.preflistClone.alert[i].preferences[prefIndex].isDeviceType = false;
                }
                if(this.preflistClone.alert[i].preferences[prefIndex].deliveryChannel == "SMS"){
                    this.preflistClone.alert[i].preferences[prefIndex].isEmailType = false;
                    this.preflistClone.alert[i].preferences[prefIndex].isPhoneType = true;
                    this.preflistClone.alert[i].preferences[prefIndex].isDeviceType = false;
                }
                if(this.preflistClone.alert[i].preferences[prefIndex].deliveryChannel == "PUSH"){
                    this.preflistClone.alert[i].preferences[prefIndex].isEmailType = false;
                    this.preflistClone.alert[i].preferences[prefIndex].isPhoneType = false;
                    this.preflistClone.alert[i].preferences[prefIndex].isDeviceType = false;
                    // removal of PUSH notifications
                }
                
            }
        }
            //Logic begin for Prefrences toggle using profile api

	
		this.preflistClone={...this.preflistClone}
        
	} 
   
    handleChanges(event) {
        let tempPreList =JSON.parse(JSON.stringify(this.preflistClone));
        const  label  = event.currentTarget.dataset.value;
        console.log('LABEL IS :: ',label);
        const outerIndex = event.currentTarget.dataset.id;
        console.log('OUTER INDEX IS ::',outerIndex);
        
        if(label==="threshold"){
            //[2021.NOV.14]  sbotta - Below if - else is logic for validating threshod field with & without limit amount.
            let thresholdField = event.target;
            let value = event.target.value;
            this.altIdentity = tempPreList.alert[outerIndex].alertIdentifier;
            console.log('Identifier::'+this.altIdentity);
            console.log('vaalue form handle change::'+value);
            
            if(tempPreList.alert[outerIndex].showOdpLimit == false) {
                console.log('threshold if block ::');
                if( Number(value)>= 0 &&  Number(value)<= 9999999 ){
                    thresholdField.setCustomValidity("");
                    const selectedEvent = new CustomEvent('updated',
                    { detail:{'outerIndex':outerIndex,'label':label,'threshold':value,'accountNumber':tempPreList.accountNumber}});
                    this.dispatchEvent(selectedEvent);
                    const selectedPageValidEvent = new CustomEvent('pagevalidationerror',
                    { detail:{'isErrored':false,'alertIdentifier':this.altIdentity}});
                    this.dispatchEvent(selectedPageValidEvent);
                }
                else if( Number(value) < 0 ){
                    thresholdField.setCustomValidity("Value must be greater than or equal to 0.");
                    const selectedEvent = new CustomEvent('pagevalidationerror',
                    { detail:{'isErrored':true,'alertIdentifier':this.altIdentity}});
                    this.dispatchEvent(selectedEvent);
                }
                //thresholdField.reportValidity();
            }
            else{
                if( Number(value) >= 0 && Number(value) <= Number(tempPreList.limitAmount)){
                    console.log('Success ----value of the limiti amount======>>>>>'+tempPreList.limitAmount);
                    thresholdField.setCustomValidity("");
                    const selectedEvent = new CustomEvent('updated',
                    { detail:{'outerIndex':outerIndex,'label':label,'threshold':value,'accountNumber':tempPreList.accountNumber}});
                    this.dispatchEvent(selectedEvent);
                    const selectedPageValidEvent = new CustomEvent('pagevalidationerror',
                    { detail:{'isErrored':false,'alertIdentifier':this.altIdentity}});
                    this.dispatchEvent(selectedPageValidEvent);
                }
                else if(Number(value) > 0 && Number(value) > Number(tempPreList.limitAmount)){
                    console.log('greater than la ----value of the limiti amount======>>>>>'+tempPreList.limitAmount);
                    thresholdField.setCustomValidity("Value must be less than or equal to limit amount value");
                    const selectedEvent = new CustomEvent('pagevalidationerror',
                    { detail:{'isErrored':true,'alertIdentifier':this.altIdentity}});
                    this.dispatchEvent(selectedEvent);
                }
                else if(Number(value) < 0 && Number(value) < Number(tempPreList.limitAmount)){
                    thresholdField.setCustomValidity("Value must be greater than or equal to 0.");
                    const selectedEvent = new CustomEvent('pagevalidationerror',
                    { detail:{'isErrored':true,'alertIdentifier':this.altIdentity}});
                    this.dispatchEvent(selectedEvent);
                }
                //thresholdField.reportValidity();
            }
            thresholdField.reportValidity();
        }
		if(label==="limitAmount"){
            let value = event.target.value;
            console.log('VALUE is :: ',value);
            const selectedEvent = new CustomEvent('updated', 
            { detail:{'outerIndex':outerIndex,'label':label,'odpLimit':value,'accountNumber':tempPreList.accountNumber}});
            this.dispatchEvent(selectedEvent);
        }
        if(label=="toggle"){
            const  toggleButtonChecked  = event.detail.checked;
            console.log('BUTTON CHECKED ::',toggleButtonChecked)
            const prefName = event.currentTarget.dataset.name;
            console.log('PREFNAME ::',prefName); 
            const selectedEvent = new CustomEvent('updated', 
            { detail:{'outerIndex':outerIndex,'label':label,'prefName':prefName,'accountNumber':tempPreList.accountNumber,'toggleButtonChecked':toggleButtonChecked}});
            this.dispatchEvent(selectedEvent);
        } 
    }

    
}