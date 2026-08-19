/**
 * @author      Mandeep Singh
 * @created     2025-04-09
 * @story       CRM-6186
 * @description LWC for pasting rich text content into Flow,
 *              stores it as HTML for display on object records.
 */
import { LightningElement,api } from 'lwc';

export default class CcsRichTextInputProcessor extends LightningElement {
    @api fieldValue;

    onPasteHandler (event){
        let clipboardHtml = event.clipboardData?.getData('text/html');
        const clipboardText = event.clipboardData?.getData('text/plain');
        // Check if there is HTML content
        if (clipboardHtml) {
            // <style> tags were giving issues and hence removing it using below regex
            clipboardHtml = clipboardHtml.replace(/<style[\s\S]*?>[\s\S]*?<\/style>/gi, '');
            this.fieldValue = clipboardHtml;
            this.dispatchChange();
        } else { // for non HTML based paste
            this.fieldValue = clipboardText;
            this.dispatchChange();
        }
    };

    dispatchChange(){
        
        const valueChangedEvent = new CustomEvent("valuechange", { detail: { value: this.fieldValue } });
        this.dispatchEvent(valueChangedEvent);
    }


}