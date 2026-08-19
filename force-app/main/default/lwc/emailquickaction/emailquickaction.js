import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';


export default class Emailquickaction extends NavigationMixin(LightningElement) {
    @api recordId;
    @api invoke(){
        var pageRef = {
            type: "standard__quickAction",
            attributes: {
                apiName:"Global.SendEmail"
            },
            state: {
                recordId: this.recordId,
                defaultFieldValues:
                    encodeDefaultFieldValues({
                        HtmlBody: "Type in your Content here.",
                        Subject:"Hello from Coast Capital"
                    })
            }
        };
        this[NavigationMixin.Navigate](pageRef);
    }
}