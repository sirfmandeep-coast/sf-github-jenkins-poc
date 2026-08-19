import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createBulkJob from '@salesforce/apex/DataMigrationController.createBulkJob';
import uploadBulkData from '@salesforce/apex/DataMigrationController.uploadBulkData';
import closeBulkJob from '@salesforce/apex/DataMigrationController.closeBulkJob';
import getBulkJobResults from '@salesforce/apex/DataMigrationController.getBulkJobResults';
import SOAPLogin from '@salesforce/apex/DataMigrationController.SOAPLogin';
import queryRecords from '@salesforce/apex/DataMigrationController.queryRecords';
import getFailedRecords from '@salesforce/apex/DataMigrationController.getFailedRecords';



export default class DataMigration extends LightningElement {

    @api refreshToken = 'refreshToken';

    @api configurations = new Map();

    @track predefinedScenarioOptions = [
        { label: 'Lightning Scheduler', value: 'Lightning Scheduler'},
        { label: 'Product Note Reason', value: 'Product Note Reason'},
        { label: 'NBX Template', value: 'NBX Template'},
        { label: 'Product Discussion Topic', value: 'Product Discussion Topic'},
        { label: 'CCS Core Fund', value: 'CCS Core Fund'},
        { label: 'Enhanced Letterhead', value: 'Enhanced Letterhead'}
    ];

    @track authenticationTypeOptions = [
        { label: 'Username/Password', value: 'usernamePassword' }
    ];

    @track migrationTypeOptions = [
        { label: 'Scenario', value: 'scenario' }
    ];


    @api errorMessage;
    @api userId;
    @track selectedValue = "";
    @api processInfo = "Progress Info: <br>";
    @api showLogInModal = false;
    @api username;
    @api password;
    @api loginUri;
    @api authenticationMode = "usernamePassword";
    @api objectName;
    @api fieldList;
    @api queryFilter;
    @api showByScenario = !false;
    @api isShow = false;
    @api numberOfItems = 0;
    @api intervalId;
    @api sessionId;
    @api recordList;
    @api currentStep = 0;
    @api migrationConfigs = [];
    @api csvData;
    @api externalKeys;

    

    objectConfigs = [
        {name : "OperatingHours", objectName : "OperatingHours", fields : "TimeZone,Prod_Id__c,SourceSystemId__c,Name,Description", csvHeaders : "TimeZone,Prod_Id__c,SourceSystemId__c,Name,Description", operation : "upsert", keyField : "Prod_Id__c", queryFilter : "Prod_Id__c != null", orderBy : "Id ASC", timeTypeFields : []},
        {name : "User", objectName : "User", fields : "SourceSystemId__c,LastName,FirstName,isActive", csvHeaders : "SourceSystemId__c,LastName,FirstName,isActive", operation : "upsert", keyField : "SourceSystemId__c", queryFilter : "SourceSystemId__c != null AND IsActive = TRUE AND UserType = 'Standard'", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False" },
        {name : "WorkTypeGroup", objectName : "WorkTypeGroup", fields : "Name,Prod_Id__c,GroupType,Description,SourceSystemId__c,AdditionalInformation,IsActive", csvHeaders : "Name,Prod_Id__c,GroupType,Description,SourceSystemId__c,AdditionalInformation,IsActive", operation : "upsert", keyField : "Prod_Id__c", queryFilter : "Prod_Id__c != null", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False" },
        {name : "Skill", objectName : "Skill", fields : "MasterLabel,DeveloperName", csvHeaders : "MasterLabel,DeveloperName", operation : "upsert", keyField : "Id", queryFilter : "Id != null", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False"},
        {name : "WorkType", objectName : "WorkType", fields : "Name,TimeframeStart,TimeframeEnd,TimeFrameStartUnit,TimeFrameEndUnit,Prod_Id__c,SourceSystemId__c,OperatingHours.Prod_Id__c,Description,EstimatedDuration,DurationType,DefaultAppointmentType,BlockTimeBeforeUnit,BlockTimeBeforeAppointment,BlockTimeAfterUnit,BlockTimeAfterAppointment", csvHeaders : "Name,TimeframeStart,TimeframeEnd,TimeFrameStartUnit,TimeFrameEndUnit,Prod_Id__c,SourceSystemId__c,OperatingHours.Prod_Id__c,Description,EstimatedDuration,DurationType,DefaultAppointmentType,BlockTimeBeforeUnit,BlockTimeBeforeAppointment,BlockTimeAfterUnit,BlockTimeAfterAppointment", operation : "upsert", keyField : "Prod_Id__c", queryFilter : "Prod_Id__c != null", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False" },
        {name : "ServiceTerritory", objectName : "ServiceTerritory", fields : "PostalCode,TypicalInTerritoryTravelTime,State,Services__c,Prod_Id__c,OperatingHours.Prod_Id__c,Name,Longitude,Location_Type__c,Latitude,Is_Branch_Open__c,GeocodeAccuracy,Description,Country,City,Street,IsActive", csvHeaders : "PostalCode,TypicalInTerritoryTravelTime,State,Services__c,Prod_Id__c,OperatingHours.Prod_Id__c,Name,Longitude,Location_Type__c,Latitude,Is_Branch_Open__c,GeocodeAccuracy,Description,Country,City,Street,IsActive", operation : "upsert", keyField : "Prod_Id__c", queryFilter : "Prod_Id__c != null", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False"},
        {name : "TimeSlot", objectName : "TimeSlot", fields : "WorkTypeGroup.Prod_Id__c,Type,StartTime,SourceSystemId__c,Source_System_Id__c,Prod_Id__c,OperatingHours.Prod_Id__c,MaxAppointments,EndTime,DayOfWeek", csvHeaders : "WorkTypeGroup.Prod_Id__c,Type,StartTime,SourceSystemId__c,Source_System_Id__c,Prod_Id__c,OperatingHours.Prod_Id__c,MaxAppointments,EndTime,DayOfWeek", operation : "upsert", keyField : "Prod_Id__c", queryFilter : "Prod_Id__c != null", orderBy : "Id ASC", timeTypeFields : ["StartTime", "EndTime"], needAdditionalFilter : "False"},
        {name : "WorkTypeGroupMember", objectName : "WorkTypeGroupMember", fields : "SourceSystemId__c,WorkType.Prod_Id__c,WorkTypeGroup.Prod_Id__c", csvHeaders : "SourceSystemId__c,WorkType.Prod_Id__c,WorkTypeGroup.Prod_Id__c", operation : "upsert", keyField : "SourceSystemId__c", queryFilter : "SourceSystemId__c != null", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False" },
        {name : "ServiceResource", objectName : "ServiceResource", fields : "RelatedRecord.SourceSystemId__c,Title__c,Source_System_Id__c,ResourceType,Prod_Id__c,Name,Description,IsActive", csvHeaders : "RelatedRecord.SourceSystemId__c,Title__c,Source_System_Id__c,ResourceType,Prod_Id__c,Name,Description,IsActive", operation : "upsert", keyField : "Prod_Id__c", queryFilter : "Prod_Id__c != null", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False"},
        {name : "ServiceResourceSkill", objectName : "ServiceResourceSkill", fields : "EffectiveStartDate,SkillLevel,SkillId,ServiceResource.Prod_Id__c,Prod_Id__c,SourceSystemId__c,EffectiveEndDate", csvHeaders : "EffectiveStartDate,SkillLevel,SkillId,ServiceResource.Prod_Id__c,Prod_Id__c,SourceSystemId__c,EffectiveEndDate", operation : "upsert", keyField : "Prod_Id__c", queryFilter : "Prod_Id__c != null", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False" },
        {name : "ServiceTerritoryWorkType", objectName : "ServiceTerritoryWorkType", fields : "WorkType.Prod_Id__c,Prod_Id__c,SourceSystemId__c,ServiceTerritory.Prod_Id__c", csvHeaders : "WorkType.Prod_Id__c,Prod_Id__c,SourceSystemId__c,ServiceTerritory.Prod_Id__c", operation : "upsert", keyField : "Prod_Id__c", queryFilter : "Prod_Id__c != null", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False" },
        {name : "ServiceTerritoryMember", objectName : "ServiceTerritoryMember", fields : "PostalCode,State,EffectiveStartDate,Source_System_Id__c,SourceSystemId__c,ServiceTerritory.Prod_Id__c,Role,ServiceResource.Prod_Id__c,Prod_Id__c,OperatingHours.Prod_Id__c,Longitude,TerritoryType,Latitude,GeocodeAccuracy,EffectiveEndDate,Country,City,Street", csvHeaders : "PostalCode,State,EffectiveStartDate,Source_System_Id__c,SourceSystemId__c,ServiceTerritory.Prod_Id__c,Role,ServiceResource.Prod_Id__c,Prod_Id__c,OperatingHours.Prod_Id__c,Longitude,TerritoryType,Latitude,GeocodeAccuracy,EffectiveEndDate,Country,City,Street", operation : "upsert", keyField : "Prod_Id__c", queryFilter : "Prod_Id__c != null", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False" },
        {name : "SkillRequirement", objectName : "SkillRequirement", fields : "TYPEOF RelatedRecord WHEN WorkType THEN Prod_Id__c END,SkillLevel,SkillId,Prod_ID__c,SourceSystemId__c", csvHeaders : "RelatedRecord.Prod_Id__c,SkillLevel,SkillId,Prod_ID__c,SourceSystemId__c", operation : "upsert", keyField : "Prod_ID__c", queryFilter : "Prod_ID__c != null AND RelatedRecord.Type IN ('WorkType')", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False"},
        {name : "NBX_Template__c", objectName : "NBX_Template__c", fields : "Name,Display_Name__c,Inbound_Script__c,Interested_Process__c,Outbound_Script__c,Rank__c", csvHeaders : "Name,Display_Name__c,Inbound_Script__c,Interested_Process__c,Outbound_Script__c,Rank__c",operation : "insert", keyField : "Id", queryFilter : "Id != null", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False"},
        {name : "Product_Note_Reason__c", objectName : "Product_Note_Reason__c", fields : "Active__c,Product__c,Reason__c", csvHeaders : "Active__c,Product__c,Reason__c", operation : "insert", keyField : "Id", queryFilter : "Id != null", orderBy : "Id ASC", timeTypeFields : []},
        {name : "Product_Discussion_Topic__c", objectName : "Product_Discussion_Topic__c", fields : "Name", csvHeaders: "Name", operation : "insert", keyField : "Id", queryFilter : "Id != null", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False"},
        {name : "CCS_Core_Fund__c", objectName : "CCS_Core_Fund__c", fields : "Name,Dealer_Fee_Percent__c,Fund_Code__c,MERPercent__c,TERPercent__c", csvHeaders : "Name,Dealer_Fee_Percent__c,Fund_Code__c,MERPercent__c,TERPercent__c", operation : "insert", keyField : "Id", queryFilter : "Id != null", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False"},
        {name : "EnhancedLetterhead", objectName : "EnhancedLetterhead", fields : "Name,Description,LetterheadHeader,LetterheadFooter", csvHeaders : "Name,Description,LetterheadHeader,LetterheadFooter", operation : "insert", keyField : "Id", queryFilter : "Id != null", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False"},
        {name : "AccountForInvestmentCompliance", objectName : "Account", fields : "Banking_id__c,Firstname,Lastname,RecordTypeId", csvHeaders : "Banking_id__c,Firstname,Lastname,RecordTypeId", operation : "upsert", keyField : "Banking_Id__c", queryFilter : "IsPersonAccount = True and Banking_Id__c != null and Id In (Select Account__c From Fee_Disclosure__c) limit 100", orderBy : "Id ASC", timeTypeFields : [], needAdditionalFilter : "False"}
        
    ];

    dataMigrationMap = new Map ([
        ["Lightning Scheduler", ["OperatingHours", "User", "WorkTypeGroup", "Skill", "WorkType", "ServiceTerritory","TimeSlot","WorkTypeGroupMember","ServiceTerritoryWorkType","SkillRequirement","ServiceResource","ServiceResourceSkill","ServiceTerritoryMember"]],
        ["Product Note Reason", ["Product_Note_Reason__c"]],
        ["NBX Template", ["NBX_Template__c"]],
        ["Product Discussion Topic", ["Product_Discussion_Topic__c"]],
        ["CCS Core Fund", ["CCS_Core_Fund__c"]],
        ["Enhanced Letterhead", ["EnhancedLetterhead"]]
    ]);
    
    renderedCallback (){
              
    }

    disconnectedCallback() {            
        this.stopApexPolling();
    }

    handleMigrationTypeChange (event) {
        if (event.detail.value === 'scenario'){
            this.showByScenario = true;
        }
    }

    handleAuthenticationTypeChange (event) {
        this.authenticationMode = event.detail.value;
    }
    
    handleScenarioChange (event) {
        this.selectedValue = event.detail.value;
    };

    dataMigration(){
        if (this.selectedValue && this.showByScenario){
            this.showLogInModal = true;
        }
        else if (!this.showByScenario && this.objectName && this.fieldList && this.queryFilter){
            this.showLogInModal = true;
        }
        else {
            let event = new ShowToastEvent({
                title: 'Error!',
                message: 'Please select one of the scenarios',
                variant: 'error'
            });
            this.dispatchEvent(event);
        }
    }

    handleLoginCancel (){
        this.showLogInModal = false;
    }

    handleInputChange(event) {
        if (event.target.label === 'Username') {
            this.username = event.target.value;
        } else if (event.target.label === 'Password') {
            this.password = event.target.value;
        } else if (event.target.label === 'Object API Name') {
            this.objectName = event.target.value;
        } else if (event.target.label === 'Field List') {
            this.fieldList = event.target.value;
        } else if (event.target.label === 'Query Filter') {
            this.queryFilter = event.target.value;
        }

    }

     handleProcessInfoChange(message) {
        this.processInfo = this.processInfo + message;
        setTimeout(() => {
            const anchor = this.template.querySelector('.slds-scroll-anchor');
            if (anchor) {
                anchor.scrollIntoView({ behavior: 'smooth', block: 'end' });
            }
        }, 100);
    }

    handleLogin(){
        SOAPLogin({ username: this.username, password: this.password })
            .then(result => { 
                    this.processInfo = "Progress Info: <br>";
                    this.errorMessage = null;
                    this.showLogInModal = false;
                    this.sessionId = result.sessionId;
                    this.loginUri = result.loginUri;
                    let configInfo;
                    this.currentStep = 0;
                    if (this.showByScenario === true) {
                        this.migrationConfigs = this.dataMigrationMap.get(this.selectedValue);
                    
                        if (this.migrationConfigs && this.currentStep < this.migrationConfigs.length) {
                            this.handleProcessInfoChange('<br> Target Org : ' +  this.loginUri + '<br><br> Object Name : ' +  this.migrationConfigs[this.currentStep]);
                            configInfo = this.objectConfigs.find(config => config.name === this.migrationConfigs[this.currentStep]);                           
                        }
                    }
                    else {
                        this.migrationConfigs.push (this.objectName);
                        configInfo = {name: this.objectName, objectName : this.objectName, fields : this.fieldList, operation : "insert", keyField : "Id", queryFilter : this.queryFilter, orderBy : "Id ASC", timeTypeFields : []};
                        this.handleProcessInfoChange('<br> Target Org : ' +  this.loginUri + '<br><br> Object Name : ' +  this.migrationConfigs[this.currentStep]);
                    
                    }
                    this.processData(configInfo);
                    
                }
            ).catch((error) => {
                
                this.errorMessage = error.body.message;
            });   
    }

    async processData(configInfo) 
    {
            
            let queryString = " SELECT " + configInfo.fields + " FROM " + configInfo.objectName + " WHERE " + configInfo.queryFilter;
            
                this.currentStep++ ;

                try {

                    let result = await queryRecords({ query: queryString, offset: 0 });

                    if (result.length > 0)
                    {
                        this.recordList = result;   
                        this.handleProcessInfoChange('<br> Retrived: ' + this.recordList.length +' records<br>');
                        let bulkJobResult = await createBulkJob ({ loginUri: this.loginUri, objectName : configInfo.objectName, keyField : configInfo.keyField, operation : configInfo.operation, refreshToken : this.sessionId, authenticationMode : this.authenticationMode })
                                   
                        this.jobId = bulkJobResult;
                        this.handleProcessInfoChange('<br> Job Id: ' + this.jobId);
                        this.generateCSV(configInfo.csvHeaders, configInfo.timeTypeFields, this.recordList);


                        await uploadBulkData({loginUri: this.loginUri, jobId : this.jobId, csvData : this.csvData, refreshToken : this.sessionId, authenticationMode : this.authenticationMode});          

                        await closeBulkJob ({loginUri: this.loginUri, jobId : this.jobId, refreshToken : this.sessionId, authenticationMode : this.authenticationMode});

                        if (!this.intervalId) {
                            this.intervalId = setInterval(() => {
                                this.jobResult();
                            }, 10000);
                        }
                            
                    }
                    else 
                    {
                        this.handleProcessInfoChange('<br> Retrived: 0');
                        if (this.currentStep < this.migrationConfigs.length) {
                            setTimeout(() => {
                                this.handleProcessInfoChange('<br><br> Object Name : ' +  this.migrationConfigs[this.currentStep]);
                                let configInfo = this.objectConfigs.find(config => config.name === this.migrationConfigs[this.currentStep]);
                                this.processData(configInfo);
                            }, 5000);
                        }
                        else 
                        {
                            this.handleProcessInfoChange('<br> Migration Completed:');
                        }
                    }
                    

                } catch (error) {
                    this.errorMessage = error;
                }

    }

    generateCSV (headers, timeTypeFields, records) {
        let fields;
   
        fields = headers.split(',');
       
        let csvString = headers + '\n';

        records.forEach(record => {
            let row = fields.map((field) => {
                if (field.includes('.')){
                    let keys = field.split('.');
                    return this.escapeCsvValue(timeTypeFields.includes(field), record[keys[0]]?record[keys[0]][keys[1]]:'') || '';
                }
                else {
                    return this.escapeCsvValue(timeTypeFields.includes(field), record[field]) || '';
                }
            }).join(',');
            csvString += row + '\n';
        });

        this.csvData = csvString;
    }

    escapeCsvValue(timeTypeFlag, value) {
        if (value === null || value === undefined) {
            return '';
        }
        let stringValue = String(value).replace(/"/g, '""');
        if (timeTypeFlag) 
        {
            stringValue = this.formattedTime(value);
        }
        if (stringValue.includes(',') || stringValue.includes('"') || stringValue.includes('\n')) {
            return `"${stringValue}"`; 
        }
        return stringValue;
    }

    formattedTime(durationInMilliseconds) {
        
        let dateObject = new Date(durationInMilliseconds );

        let formattedHours = String(dateObject.getUTCHours()).padStart(2, '0');
        let formattedMinutes = String(dateObject.getUTCMinutes()).padStart(2, '0');
        let formattedSeconds = String(dateObject.getUTCSeconds()).padStart(2, '0');

        return `${formattedHours}:${formattedMinutes}:${formattedSeconds}`;
    }

    async jobResult() {
        try {
            let result = await getBulkJobResults({loginUri: this.loginUri, jobId: this.jobId, refreshToken: this.sessionId, authenticationMode : this.authenticationMode })
            
            if (result) {
    
                this.handleProcessInfoChange('<br>' + (new Date()).toLocaleTimeString() + ' -- JobId: '+ this.jobId + ' -- Job State: ' + result.state + ' -- Processed: ' +   result.numberRecordsProcessed + ' -- Failed: ' + result.numberRecordsFailed);
                if (result.state === 'JobComplete' || result.state === 'Closed' || result.state === 'Aborted' || result.state === 'Failed') 
                {
                    this.stopApexPolling();
                    
                        getFailedRecords({loginUri: this.loginUri, jobId: this.jobId, refreshToken: this.sessionId, authenticationMode : this.authenticationMode })
                        .then(result => {
                            console.log (result); 
                        })
                        .catch((error) => {
                            console.error("Error getFailedRecords:", error.message); 
                        });
                            
                    
                    if (this.currentStep < this.migrationConfigs.length) {
                        this.handleProcessInfoChange('<br><br> Object Name : ' +  this.migrationConfigs[this.currentStep]);
                        let configInfo = this.objectConfigs.find(config => config.name === this.migrationConfigs[this.currentStep]);
                        this.processData (configInfo);
                        }
                    else 
                    {
                        this.handleProcessInfoChange(this.processInfo + '<br> Migration Completed:');
                    }
                }
            }
                
        }
        catch(error){
            console.error('Error calling getBulkJobResults:', error);
        }
    }

    stopApexPolling() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
    }
    
}