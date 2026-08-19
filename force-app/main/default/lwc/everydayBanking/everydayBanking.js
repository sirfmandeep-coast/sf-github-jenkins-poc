import { LightningElement, track, wire, api } from 'lwc';
import getBankingIdByAccountId from '@salesforce/apex/FinancialAccountsCtrl.getBankingIdByAccountId';
import getFinanicalAccount from '@salesforce/apex/EverydayBankingController.getFinanicalAccount';
import getLoyaltyProductsByProfileId from '@salesforce/apex/EverydayBankingController.getLoyaltyProductsByProfileId';
import getLoyaltyProductsByAccountNumber from '@salesforce/apex/EverydayBankingController.getLoyaltyProductsByAccountNumber';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class EverydayBanking extends LightningElement {
    @api recordId;
    @api profileId;
    @api financialAccountNumber;
    @track loyaltyProducts = [];
    @api noService = false;
    @api objectApiName;
    @api hasError;
    @api isProfile;
    @api isFinancialAccount;

    @track profileColumns = [
        { label: 'Service', fieldName: 'loyaltyServiceName' },
        { label: 'Code', fieldName: 'sigmaActCode'},
        { label: 'Email Address', fieldName: 'emailAddress'},
        { label: 'Financial Account #', fieldName: 'accountNumber'}     
    ];
    
    @track financialAccountColumns = [
        { label: 'Service', fieldName: 'loyaltyServiceName' },
        { label: 'Code', fieldName: 'sigmaActCode'},
        { label: 'Email Address', fieldName: 'emailAddress'},
        { label: 'T24 Profile #', fieldName: 't24ProfileId'}     
    ];

    connectedCallback(){
        console.log (this.recordId);
        console.log ('object name:' + this.objectApiName);
        
        if (this.objectApiName === 'Account')
        {
            this.isProfile = true;
            this.getIntergrationDataByProfile();
        }
        else if (this.objectApiName === 'FinServ__FinancialAccount__c')
        {
            this.isFinancialAccount = true;
            this.getIntergrationDataByAccount();
        }
        else
        {
            console.log('Unsupported SObjectType.  Only supports Account and FinServ__FinancialAccount__c.');
        }
    }


    

    getIntergrationDataByProfile ()
    {
        getBankingIdByAccountId ({accountId: this.recordId})
            .then (result =>{
                if (result.Banking_ID__c) {
                    console.log (result.Banking_ID__c);
                    this.profileId = result.Banking_ID__c;
                    return getLoyaltyProductsByProfileId({profileId: this.profileId});
                }
                else{
                    console.log('NO BANKING Id');
                    this.noService = true;
                    //this.showNotification('No Banking ID', 'Please verify that the Banking ID matches the Profile ID from T24. If no discrepancies exist, please submit an Incident in Service Now with the applicable details.', 'error');
                }
            })
            .then(result=>{
                if (result) {
                    console.log(result);
                    this.handleLoyaltyProducts(result);
                }
            })
            .catch(error=>{
                this.error = error;
                console.log('ERROR OCCURED ',this.error);
                this.hasError = true;
                //this.showNotification('Integration Error', error.body.message.replaceAll('|', ','), 'error');
            });
    }

    getIntergrationDataByAccount ()
    {
        getFinanicalAccount ({recordId: this.recordId})
            .then (result =>{
                if (result.FinServ__FinancialAccountNumber__c) {
                    console.log (result.FinServ__FinancialAccountNumber__c);
                    this.financialAccountNumber = result.FinServ__FinancialAccountNumber__c;
                    return getLoyaltyProductsByAccountNumber({financialAccountNumber: this.financialAccountNumber});
                }
                else{
                    console.log('NO Finanical Account Number');
                    this.noService = true;
                    //this.showNotification('No Banking ID', 'Please verify that the Banking ID matches the Profile ID from T24. If no discrepancies exist, please submit an Incident in Service Now with the applicable details.', 'error');
                }
            })
            .then(result=>{
                if (result) {
                    console.log(result);
                    this.handleLoyaltyProducts(result);
                }
            })
            .catch(error=>{
                this.error = error;
                console.log('ERROR OCCURED ',this.error)
                this.hasError = true;
                //this.showNotification('Integration Error', error.body.message.replaceAll('|', ','), 'error');
            });
    }

    handleLoyaltyProducts (result)
    {
        this.loyaltyProducts = JSON.parse(result);
        if (this.loyaltyProducts.length === 0)
        {
            this.noService = true;
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

}