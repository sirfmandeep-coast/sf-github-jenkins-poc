import { LightningElement,wire,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'
import getRelatedRecordsInfo from '@salesforce/apex/AccountRelatedRecords.getRelatedRecordsInfo';

export default class AccountRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    @track opptyList=[];
    @track contactList =[];

    @track leadList = [];
    @track caseList = [];
    @track moneyChatList = [];
    @track eventList = [];
    @track taskList = [];
    //Added for CRM-4474 Date: July 19th 2022
    @track prodNotesList = [];

    leadCount = 0;
    caseCount = 0;
    moneyChatCount = 0;
    eventCount = 0;
    taskCount = 0;
    //Added for CRM-4474 Date: July 19th 2022
    prodNotesCount = 0;

    showLeads = false;
    showCases = false;
    showMoneyChats = false;
    showEvents = false;
    showTasks = false;
    //Added for CRM-4474 Date: July 19th 2022
    showProdNotes = false;

    isLeadsNull = true;
    isCasesNull = true;
    isMoneyChatsNull = true;
    isEventsNull = true;
    isTasksNull = true;
    //Added for CRM-4474 Date: July 19th 2022
    isProdNotesNull = true;
    
    opptyCount = 0;
    contactCount = 0;
    showOppties = false;
    showContact= false;
    isOptyNull =true;
    isContactNull =true;

    connectedCallback(){
        console.log('INSIDE CONSOLE LOG ::',this.recordId)
        getRelatedRecordsInfo({accountId: this.recordId})
        .then(result =>{
            
            let tempLeadList = result.FinServ__RelatedLeads__r;
            if(tempLeadList != null){
                this.isLeadsNull = false;
                this.leadCount = tempLeadList.length;
                console.log('length leads =====>>>>>'+tempLeadList.length);
                if(this.leadCount > 0){
                    this.leadList = JSON.parse(JSON.stringify(result.FinServ__RelatedLeads__r));
                    this.leadList.forEach(lead=>{
                        lead.showPopUp = false;
                        lead.url = '/lightning/r/Lead/' + lead.Id + '/view';
                    })
                    this.leadList = [...this.leadList];
                }
            }

            let tempOpptyList=result.Opportunities;
            if(tempOpptyList!=null){
                this.isOptyNull =false;
                this.opptyCount=tempOpptyList.length;
                console.log('OPTTY COUNT ::: '+this.opptyCount);
                if(this.opptyCount>0){
                    this.opptyList =JSON.parse(JSON.stringify(result.Opportunities)); 
                    this.opptyList.forEach(opp=>{
                        opp.showPopUp=false;
                        opp.url = '/lightning/r/Opportunity/' + opp.Id + '/view';
                    })    
                    this.opptyList =[...this.opptyList];
                }
            }

            let tempCaseList = result.Cases
            if(tempCaseList!=null){
                this.isCasesNull=false;
                this.caseCount=tempCaseList.length;
                console.log('CASE COUNT ::: '+this.caseCount);
                if(this.caseCount > 0){
                    this.caseList = JSON.parse(JSON.stringify(result.Cases));
                    this.caseList.forEach(cases=>{
                        cases.showPopUp=false;  
                        cases.url = '/lightning/r/Case/' + cases.Id + '/view';
                    }) 
                    this.caseList=[...this.caseList]; 
                }
            }

            let tempMoneyChatList = result.Money_Chats__r
            if(tempMoneyChatList!=null){
                this.isMoneyChatsNull=false;
                this.moneyChatCount = tempMoneyChatList.length;
                console.log('MONEY CHAT COUNT ::: '+this.moneyChatCount);
                if(this.moneyChatCount > 0){
                    this.moneyChatList = JSON.parse(JSON.stringify(result.Money_Chats__r));
                    this.moneyChatList.forEach(moneyChat=>{
                        moneyChat.showPopUp=false;  
                        moneyChat.url = '/lightning/r/Money_Chat__c/' + moneyChat.Id + '/view';
                    }) 
                    this.moneyChatList=[...this.moneyChatList]; 
                }
            }

            let tempEventList = result.Events
            if(tempEventList!=null){
                this.isEventsNull=false;
                this.eventCount = tempEventList.length;
                console.log('EVENT COUNT ::: '+this.moneyChatCount);
                if(this.eventCount > 0){
                    this.eventList = JSON.parse(JSON.stringify(result.Events));
                    this.eventList.forEach(eve=>{
                        eve.showPopUp=false; 
                        eve.url = '/lightning/r/Event/' + eve.Id + '/view'; 
                    }) 
                    this.eventList=[...this.eventList]; 
                }
            }

            let tempTaskList = result.Tasks
            if(tempTaskList!=null){
                this.isTasksNull=false;
                this.taskCount = tempTaskList.length;
                console.log('TASK COUNT ::: '+this.taskCount);
                if(this.taskCount > 0){
                    this.taskList = JSON.parse(JSON.stringify(result.Tasks));
                    this.taskList.forEach(task=>{
                        task.showPopUp=false;  
                        task.url = '/lightning/r/Event/' + task.Id + '/view'; 
                    }) 
                    this.taskList=[...this.taskList]; 
                }
            }

            //Added for CRM-4474 Date: July 19th 2022
            let tempProdNotesList = result.Product_Member_Review_Disclosures__r
            if(tempProdNotesList!=null){
                this.isProdNotesNull=false;
                this.prodNotesCount = tempProdNotesList.length;
                console.log('Product Notes Count ::: '+this.prodNotesCount);
                if(this.prodNotesCount > 0){
                    this.prodNotesList = JSON.parse(JSON.stringify(result.Product_Member_Review_Disclosures__r));
                    this.prodNotesList.forEach(prodNote=>{
                        prodNote.showPopUp=false;  
                        prodNote.url = '/lightning/r/Product_Review_Disclosure__c/' + prodNote.Product_Review_and_Disclosure__c + '/view'; 
                    }) 
                    this.prodNotesList=[...this.prodNotesList]; 
                }
            }
        })
        .catch(error=>{
            this.error = error;
            console.log('ERROR OCCURED ',this.error)
        });

    }

    
    // The following 5 handle events are to handle when on mouse over to show blue line
    handleLead1HoverChange() {
        this.template.querySelector('.lead1Hovered').classList.add('addBlueBorder');
        this.template.querySelector('.case1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.opp1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.moneychat1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.event1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.task1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.prodNotes1Hovered').classList.remove('addBlueBorder');


    }

    handleOpp1HoverChange(){
        this.template.querySelector('.opp1Hovered').classList.add('addBlueBorder'); 
        this.template.querySelector('.lead1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.case1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.moneychat1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.event1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.task1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.prodNotes1Hovered').classList.remove('addBlueBorder');
    }

    handleCase1HoverChange(){
        this.template.querySelector('.case1Hovered').classList.add('addBlueBorder'); 
        this.template.querySelector('.opp1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.lead1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.moneychat1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.event1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.task1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.prodNotes1Hovered').classList.remove('addBlueBorder');
    }

    handleMoneyChat1HoverChange() {
        this.template.querySelector('.moneychat1Hovered').classList.add('addBlueBorder');
        this.template.querySelector('.case1Hovered').classList.remove('addBlueBorder'); 
        this.template.querySelector('.opp1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.lead1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.event1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.task1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.prodNotes1Hovered').classList.remove('addBlueBorder');
    }

    handleEvent1HoverChange() {
        this.template.querySelector('.event1Hovered').classList.add('addBlueBorder');
        this.template.querySelector('.moneychat1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.case1Hovered').classList.remove('addBlueBorder'); 
        this.template.querySelector('.opp1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.lead1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.task1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.prodNotes1Hovered').classList.remove('addBlueBorder');
    }

    handleTask1HoverChange() {
        this.template.querySelector('.task1Hovered').classList.add('addBlueBorder');
        this.template.querySelector('.event1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.moneychat1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.case1Hovered').classList.remove('addBlueBorder'); 
        this.template.querySelector('.opp1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.lead1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.prodNotes1Hovered').classList.remove('addBlueBorder');
    }

    //Added for CRM-4474 Date: July 19th 2022
    handleProdNotes1HoverChange() {
        this.template.querySelector('.prodNotes1Hovered').classList.add('addBlueBorder');
        this.template.querySelector('.event1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.moneychat1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.case1Hovered').classList.remove('addBlueBorder'); 
        this.template.querySelector('.opp1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.lead1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.task1Hovered').classList.remove('addBlueBorder');
    }
    // The above 5 handle events are to handle when on mouse over to show blue line

    //the following function executes when on mouse out 
    handleOutHoverChange(){
        //this.template.querySelector('.conHovered').classList.remove('dynamicCSS');
        //this.template.querySelector('.oppHovered').classList.remove('dynamicCSS');
        this.template.querySelector('.case1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.opp1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.lead1Hovered').classList.remove('addBlueBorder'); 
        this.template.querySelector('.moneychat1Hovered').classList.remove('addBlueBorder'); 
        this.template.querySelector('.event1Hovered').classList.remove('addBlueBorder');
        this.template.querySelector('.task1Hovered').classList.remove('addBlueBorder');
        //Added for CRM-4474 Date: July 19th 2022
        this.template.querySelector('.prodNotes1Hovered').classList.remove('addBlueBorder');
    }
    //the above function executes when on mouse out
    
    // The following 5 handle events are to handle when on click of icons
    handleLead() {
        this.template.querySelector('.lead1Hovered').classList.add('addBlueBorder');
        this.showLeads = true; 
        this.showCases=false;
        this.showOppties = false;
        this.showMoneyChats = false;
        this.showEvents = false;
        this.showTasks = false;
        this.showProdNotes = false;
    }

    handleOpportunity(){
        this.template.querySelector('.opp1Hovered').classList.add('addBlueBorder'); 
        this.showOppties = true;
        this.showCases=false;
        this.showLeads = false;
        this.showMoneyChats = false;
        this.showEvents = false;
        this.showTasks = false; 
        this.showProdNotes = false;
    }

    handleCase(){
        this.template.querySelector('.case1Hovered').classList.add('addBlueBorder'); 
        this.showCases=true;
        this.showOppties =false;
        this.showLeads = false;
        this.showMoneyChats = false;
        this.showEvents = false;
        this.showTasks = false;
        this.showProdNotes = false;
    }

    handleMoneyChat(){
        this.template.querySelector('.moneychat1Hovered').classList.add('addBlueBorder'); 
        this.showMoneyChats = true;
        this.showCases=false;
        this.showOppties =false;
        this.showLeads = false;
        this.showEvents = false;
        this.showTasks = false;
        this.showProdNotes = false;
    }

    handleEvent(){
        this.template.querySelector('.event1Hovered').classList.add('addBlueBorder'); 
        this.showEvents = true;
        this.showMoneyChats = false;
        this.showCases=false;
        this.showOppties =false;
        this.showLeads = false;
        this.showTasks = false;
        this.showProdNotes = false;
    }

    handleTask(){
        this.template.querySelector('.task1Hovered').classList.add('addBlueBorder');
        this.showTasks = true; 
        this.showMoneyChats = false;
        this.showCases=false;   
        this.showOppties =false;
        this.showLeads = false;
        this.showEvents = false;
        this.showProdNotes = false;
    }
    //Added for CRM-4474 Date: July 19th 2022
    handleProdNotes() {
        this.template.querySelector('.prodNotes1Hovered').classList.add('addBlueBorder');
        this.showProdNotes = true;
        this.showTasks = false; 
        this.showMoneyChats = false;
        this.showCases=false;
        this.showOppties =false;
        this.showLeads = false;
        this.showEvents = false;
    }
    // The above 5 handle events are to handle when on click of icons

    // The following 5 handle events are to show popup or not

    handleOppMouseover(event){
        let oppId =event.currentTarget.dataset.id;
        console.log('oppId::',oppId);
         if(oppId){
             this.opptyList.forEach(opp=>{
                if(opp.Id==oppId){
                    opp.showPopUp=true;
                }
                else
                    opp.showPopUp=false;  
            }) 
            this.opptyList=[...this.opptyList]; 
        }  
    }

    handleOppMouseout(){
        console.log('OPP CALLED :::');
        this.opptyList.forEach(opp=>{
            opp.showPopUp=false;  
        }) 
        const toolTipDiv = this.template.querySelector('div.ModelTooltip');
        toolTipDiv.style.opacity = 0;
        toolTipDiv.style.display = "none"; 
    }

    handleLeadMouseover(event) {
        let leadId =event.currentTarget.dataset.id;
        console.log('leadId::',leadId);
         if(leadId){
             this.leadList.forEach(lead=>{
                if(lead.Id==leadId){
                    lead.showPopUp=true;
                }
                else
                lead.showPopUp=false;  
            }) 
            this.leadList=[...this.leadList]; 
        }   
    }

    handleLeadMouseout() {
        this.leadList.forEach(lead=>{
            lead.showPopUp=false;  
        }) 
        const toolTipDiv = this.template.querySelector('div.ModelTooltip');
        toolTipDiv.style.opacity = 0;
        toolTipDiv.style.display = "none"; 
    }

    handleCaseMouseover(event) {
        let caseId =event.currentTarget.dataset.id;
        console.log('caseId::',caseId);
         if(caseId){
             this.caseList.forEach(cases=>{
                if(cases.Id==caseId){
                    cases.showPopUp=true;
                }
                else
                    cases.showPopUp=false;  
            }) 
            this.caseList=[...this.caseList]; 
        }   
    }

    handleCaseMouseout() {
        this.caseList.forEach(cases=>{
            cases.showPopUp=false;  
        }) 
        const toolTipDiv = this.template.querySelector('div.ModelTooltip');
        toolTipDiv.style.opacity = 0;
        toolTipDiv.style.display = "none"; 
    }

    handleMoneyChatMouseover(event) {
        let moneyChatId =event.currentTarget.dataset.id;
        console.log('Money CHat Id::',moneyChatId);
         if(moneyChatId){
             this.moneyChatList.forEach(moneyChat=>{
                if(moneyChat.Id==moneyChatId){
                    moneyChat.showPopUp=true;
                }
                else
                moneyChat.showPopUp=false;  
            }) 
            this.moneyChatList=[...this.moneyChatList]; 
        }   
    }

    handleMoneyChatMouseout() {
        this.moneyChatList.forEach(moneyChat=>{
            moneyChat.showPopUp=false;  
        }) 
        const toolTipDiv = this.template.querySelector('div.ModelTooltip');
        toolTipDiv.style.opacity = 0;
        toolTipDiv.style.display = "none"; 
    }

    handleEventMouseover(event) {
        let eventId =event.currentTarget.dataset.id;
        console.log('Event Id::',eventId);
         if(eventId){
             this.eventList.forEach(eve=>{
                if(eve.Id==eventId){
                    eve.showPopUp=true;
                }
                else
                eve.showPopUp=false;  
            }) 
            this.eventList=[...this.eventList]; 
        }   
    }

    handleEventMouseout() {
        this.eventList.forEach(eve=>{
            eve.showPopUp=false;  
        }) 
        const toolTipDiv = this.template.querySelector('div.ModelTooltip');
        toolTipDiv.style.opacity = 0;
        toolTipDiv.style.display = "none"; 
    }

    handleTaskMouseover(event) {
        let taskId =event.currentTarget.dataset.id;
        console.log('Task Id::',taskId);
         if(taskId){
             this.taskList.forEach(task=>{
                if(task.Id==taskId){
                    task.showPopUp=true;
                }
                else
                task.showPopUp=false;  
            }) 
            this.taskList=[...this.taskList]; 
        }   
    }

    handleTaskMouseout() {
        this.taskList.forEach(task=>{
            task.showPopUp=false;  
        }) 
        const toolTipDiv = this.template.querySelector('div.ModelTooltip');
        toolTipDiv.style.opacity = 0;
        toolTipDiv.style.display = "none"; 
    }

    //Added for CRM-4474 Date: July 19th 2022
    handleProdNoteMouseover(event) {
        let prodNoteId =event.currentTarget.dataset.id;
        console.log('Product Notes Id::',prodNoteId);
         if(prodNoteId){
             this.prodNotesList.forEach(prodNote=>{
                if(prodNote.Id==prodNoteId){
                    prodNote.showPopUp=true;
                }
                else
                prodNote.showPopUp=false;  
            }) 
            this.prodNotesList=[...this.prodNotesList]; 
        }   
    }

    handleprodNoteMouseout() {
        this.prodNotesList.forEach(prodNote=>{
            prodNote.showPopUp=false;  
        }) 
        const toolTipDiv = this.template.querySelector('div.ModelTooltip');
        toolTipDiv.style.opacity = 0;
        toolTipDiv.style.display = "none"; 
    }
    // The above 5 handle events are to show popup or not

    /*
    //Following 5 functions are to navigate to the respective object record
    navigateToLead(event) {
        evt.preventDefault();
        evt.stopPropagation();
        let leadId =event.currentTarget.dataset.id;
        console.log('Lead ID IS ===>>>>:: ',leadId);
        this[NavigationMixin.Navigate]({ 
            type:'standard__recordPage',
            attributes:{ 
                recordId:leadId,
                objectApiName:'Lead',
                actionName:'view'
            }
        })
 
    }

    navigateToOpportunity(event){
        evt.preventDefault();
        evt.stopPropagation();
        let oppId =event.currentTarget.dataset.id;
        console.log('OPP ID From single record IS :: ',oppId);
        this[NavigationMixin.Navigate]({ 
            bubbles:true,
            type:'standard__recordPage',
            attributes:{ 
                recordId:oppId,
                objectApiName:'Opportunity',
                actionName:'view'
            }
        })

    }

    navigateToCase(event){
        evt.preventDefault();
        evt.stopPropagation();
        let caseId =event.currentTarget.dataset.id;
        console.log('CASE ID From single record IS :: ',caseId);
        this[NavigationMixin.Navigate]({ 
            type:'standard__recordPage',
            attributes:{ 
                recordId:caseId,
                objectApiName:'Case',
                actionName:'view'
            }
        })

    }

    navigateToMoneyChat(event){
        evt.preventDefault();
        evt.stopPropagation();
        let moneyChatId =event.currentTarget.dataset.id;
        console.log('CASE ID From single record IS :: ',moneyChatId);
        this[NavigationMixin.Navigate]({ 
            type:'standard__recordPage',
            attributes:{ 
                recordId:moneyChatId,
                objectApiName:'MoneyChat__c',
                actionName:'view'
            }
        })

    }

    navigateToEvent(event){
        evt.preventDefault();
        evt.stopPropagation();
        let eventId =event.currentTarget.dataset.id;
        console.log('Event id From single record IS :: ',eventId);
        this[NavigationMixin.Navigate]({ 
            type:'standard__recordPage',
            attributes:{ 
                recordId:eventId,
                objectApiName:'Event',
                actionName:'view'
            }
        })

    }

    navigateToTask(event){
        evt.preventDefault();
        evt.stopPropagation();
        let taskId =event.currentTarget.dataset.id;
        console.log('Task id From single record IS :: ',taskId);
        this[NavigationMixin.Navigate]({ 
            type:'standard__recordPage',
            attributes:{ 
                recordId:taskId,
                objectApiName:'Task',
                actionName:'view'
            }
        })

    }
    */

    //Above 5 functions are to navigate to the respective object record

    //Following 5 functions are to navigate to the objects respective related records list
    navigateToLeadRelatedList() {
        this[NavigationMixin.Navigate]({ 
            type:'standard__recordRelationshipPage',
            attributes:{ 
                recordId:this.recordId,
                objectApiName:'Account',
                relationshipApiName:'FinServ__RelatedLeads__r',
                actionName:'view'
            }
        })
    }

    navigateToOpportunityRelatedList(){
        this[NavigationMixin.Navigate]({ 
            type:'standard__recordRelationshipPage',
            attributes:{ 
                recordId:this.recordId,
                objectApiName:'Account',
                relationshipApiName:'Opportunities',
                actionName:'view'
            }
        })
    }

    
    navigateToCasesRelatedList(){ 
        this[NavigationMixin.Navigate]({ 
            type:'standard__recordRelationshipPage',
            attributes:{ 
                recordId:this.recordId,
                objectApiName:'Account',
                relationshipApiName:'Cases',
                actionName:'view'
            }
        })
    }

    navigateToMoneyChatRelatedList(){ 
        this[NavigationMixin.Navigate]({ 
            type:'standard__recordRelationshipPage',
            attributes:{ 
                recordId:this.recordId,
                objectApiName:'Account',
                relationshipApiName:'Money_Chats__r',
                actionName:'view'
            }
        })
    }

    navigateToEventRelatedList(){ 
        this[NavigationMixin.Navigate]({ 
            type:'standard__recordRelationshipPage',
            attributes:{ 
                recordId:this.recordId,
                objectApiName:'Account',
                relationshipApiName:'Event',
                actionName:'view'
            }
        })
    }

    navigateToTaskRelatedList(){ 
        this[NavigationMixin.Navigate]({ 
            type:'standard__recordRelationshipPage',
            attributes:{ 
                recordId:this.recordId,
                objectApiName:'Account',
                relationshipApiName:'Task',
                actionName:'view'
            }
        })
    }

    navigateToProductNotesRelatedList() {
        this[NavigationMixin.Navigate]({ 
            type:'standard__recordRelationshipPage',
            attributes:{ 
                recordId:this.recordId,
                objectApiName:'Account',
                relationshipApiName:'Product_Member_Review_Disclosures__r',
                actionName:'view'
            }
        })
    }

    //Above 5 functions are to navigate to the objects respective related records list
    
    navigateToOwner(event){
        let userId =event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({ 
            type:'standard__recordPage',
            attributes:{ 
                recordId:userId,
                objectApiName:'User',
                actionName:'view'
            }
        })
    }

    

    
}